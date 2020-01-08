//
//  PhotoViewModel.swift
//  IdealVisual
//
//  Created by a.kurganova on 27.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import CoreData

final class PostViewModel: NSObject, PostViewModelProtocol {
    private var user: User?
    private var postCoreData: PostCoreDataProtocol
    private var postNetworkManager: PostNetworkManagerProtocol
    private var photoNetworkManager: PhotoNetworkManagerProtocol

    private var notif_posts = [(PostViewModelProtocol) -> Void]()

    private var fetcher: NSFetchedResultsController<Post>

    private let photoFolder = "posts/"

//    private var sectionChanges = [(type: NSFetchedResultsChangeType, sectionIndex: Int)]()
    private var itemChanges = [(type: NSFetchedResultsChangeType, indexPath: IndexPath?, newIndexPath: IndexPath?)]()

    var posts = [Post]()

    override init() {
        self.user = UserCoreData().get()

        self.postCoreData = PostCoreData()
        self.postNetworkManager = PostNetworkManager()
        self.photoNetworkManager = PhotoNetworkManager()

        self.fetcher = self.postCoreData.getAll()
        super.init()

        self.fetcher.delegate = self

        do {
            try self.fetcher.performFetch()
        } catch {
            let fetchError = error as NSError
            Logger.log("\(fetchError), \(fetchError.localizedDescription)")
        }

        guard let fetched = fetcher.fetchedObjects else { return }
        posts = fetched

        // TODO: sync
        sync()
    }

    func sync() { // TODO: completion
//        postNetworkManager.get(token: ,
//        completion: ) {
//            foreach if $0.id not in posts {
//                go za photo na server
//                coredata.create
//            }
//        }
    }

    func create(photoName: String, photoData: Data?, date: Date? = nil, place: String? = nil,
                text: String? = nil, completion: ((ErrorViewModel?) -> Void)?) {
        let photoPath: String = photoFolder + photoName
        _ = MyFileManager.saveFile(data: photoData!, filePath: photoPath)

        guard let photoData = photoData, let date = date, let place = place, let text = text else {
            completion?(ErrorsPostViewModel.noData)
            return
        }

        // for core data
        let indexPhoto = posts.count

        guard let user = user, let token = user.token else {
            Logger.log("error unautorized: \(ErrorsPostViewModel.cannotCreate)")
            completion?(ErrorsPostViewModel.unauthorized)
            return
        }

        guard let created = postCoreData.create(user: user, photo: photoPath, date: date, place: place,
                                                text: text, indexPhoto: indexPhoto)
        else {
            Logger.log("error on create: \(ErrorsPostViewModel.cannotCreate)")
            completion?(ErrorsPostViewModel.cannotCreate)
            return
        }

        photoNetworkManager.upload(token: token, data: photoData, name: photoName,
                                   completion: { (path, error) in
            if let error = error {
                switch error.name {
                case ErrorsNetwork.unauthorized:
                    completion?(ErrorsPostViewModel.unauthorized)
                default:
                    Logger.log("\(ErrorsPostViewModel.unknownError)")
                    completion?(ErrorsPostViewModel.unknownError)
                }
                return
            }

            guard let path = path else {
                Logger.log("data error: \(ErrorsPostViewModel.noData)")
                return
            }

            var jsonPost = self.convertDBModelToJSON(post: created)
            jsonPost.photo = path

            self.postNetworkManager.create(token: token, post: jsonPost, completion: { (post, error) in
                if let error = error {
                    switch error.name {
                    case ErrorsNetwork.unauthorized:
                        completion?(ErrorsPostViewModel.unauthorized)
                    default:
                        Logger.log("\(ErrorsPostViewModel.unknownError)")
                        completion?(ErrorsPostViewModel.unknownError)
                    }
                    return
                }

                guard let post = post else {
                    Logger.log("data error: \(ErrorsPostViewModel.noData)")
                    completion?(ErrorsPostViewModel.noData)
                    return
                }

                _ = self.postCoreData.update(post: created, id: post.id, date: nil, place: nil, text: nil)
                completion?(nil)
            })
        })

    }

    private func convertDBModelToJSON(post: Post) -> JsonPostModel {
        return JsonPostModel(
            id: post.id ?? UUID(uuid: UUID_NULL),
            photo: post.photo ?? "",
            photoIndex: post.indexPhoto,
            date: post.date ?? Date(timeIntervalSince1970: 0),
            place: post.place ?? "",
            text: post.text ?? ""
        )
    }

    func getPhoto(path: String) -> String {
        return MyFileManager.resolveAbsoluteFilePath(filePath: path).path
    }

    func update(post: Post,
                date: Date? = nil, place: String? = nil, text: String? = nil,
                completion: ((ErrorViewModel?) -> Void)?) {
        postCoreData.update(post: post, id: post.id, date: date, place: place, text: text)

        guard let token = user?.token else {
            Logger.log("token in coredata is nil")
            completion?(ErrorsPostViewModel.unauthorized)
            return
        }
        var jsonPost = convertDBModelToJSON(post: post)
        jsonPost.photo = "" // don't update photo on server
        postNetworkManager.update(token: token, post: jsonPost,
            completion: { (_, error) in
                if let error = error {
                    switch error.name {
                    case ErrorsNetwork.noData:
                        completion?(ErrorsPostViewModel.noData)
                    case ErrorsNetwork.unauthorized:
                        completion?(ErrorsPostViewModel.unauthorized)
                    default:
                        Logger.log("unknown error: \(error)")
                        completion?(ErrorsPostViewModel.unknownError)
                    }
                }
                completion?(nil)
            }
        )
    }

    func subscribe(completion: @escaping (PostViewModelProtocol) -> Void) {
        notif_posts.append(completion)
    }

    func delete(atIndices: [Int], completion: ((ErrorViewModel?) -> Void)?) {
        var uuids = [UUID]()
        for index in atIndices {
            let delPost = posts[index]
            uuids.append(delPost.id!)
            MyFileManager.deleteFile(filePath: delPost.photo!)

            postCoreData.delete(post: delPost)
        }

        postCoreData.reinitIndices(posts: posts)

        guard let token = user?.token else {
            Logger.log("token in coredata is nil")
            completion?(ErrorsPostViewModel.unauthorized)
            return
        }
        postNetworkManager.delete(token: token, ids: uuids, completion: { (error) in
            if let error = error {
                switch error.name {
                case ErrorsNetwork.notFound:
                    completion?(ErrorsPostViewModel.notFound)
                case ErrorsNetwork.unauthorized:
                    completion?(ErrorsPostViewModel.unauthorized)
                default:
                    Logger.log("\(ErrorsPostViewModel.unknownError)")
                    completion?(ErrorsPostViewModel.unknownError)
                }
                return
            }
            completion?(nil)
        })
    }

    func swap(source: Int, dest: Int) {
        postCoreData.swap(posts, source: source, dest: dest)

        guard let token = user?.token else {
//            TODO: completion?()
            return
        }

        var forChange: ArraySlice<Post>
        if source < dest {
            forChange = posts[source...dest]
        } else {
            forChange = posts[dest...source]
        }
        forChange.forEach {
            var jsonPost = convertDBModelToJSON(post: $0)
            jsonPost.photo = "" // don't update photo on server
            postNetworkManager.update(token: token, post: jsonPost, completion: { (_, error) in
                if let error = error {
                    Logger.log(error)
                }
            })
        }
    }
}

extension PostViewModel: NSFetchedResultsControllerDelegate {
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
//                    didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int,
//                    for type: NSFetchedResultsChangeType) {
//        sectionChanges.append((type, sectionIndex))
//    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        itemChanges.append((type, indexPath, newIndexPath))
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let fetched = fetcher.fetchedObjects else { return }
        posts = fetched // non-optimal way

        print("content changed \(fetched)")
        // TODO: better to crud with itemChanges
//        for change in self.itemChanges {
//            switch change.type {
//            case .insert: self.content.insertItems(at: [change.newIndexPath!])
//            case .delete: self.content.deleteItems(at: [change.indexPath!])
//            case .update: self.content.reloadItems(at: [change.indexPath!])
//            case .move:
//                self?.content.deleteItems(at: [change.indexPath!])
//                self?.content.insertItems(at: [change.newIndexPath!])
//            @unknown default:
//                fatalError()
//            }
//        }

        for notify in notif_posts {
            notify(self)
        }
        self.itemChanges.removeAll()
    }
}
