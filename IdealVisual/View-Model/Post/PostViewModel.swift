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
    func getPhoto(path: String) -> String {
        return resolveAbsoluteFilePath(filePath: path).path
    }

    private var postCoreData: PostCoreDataProtocol
    private var postNetworkManager: PostNetworkManagerProtocol
    private var notif_posts = [(PostViewModelProtocol) -> Void]()

    private var fetcher: NSFetchedResultsController<Post>

//    private var sectionChanges = [(type: NSFetchedResultsChangeType, sectionIndex: Int)]()
    private var itemChanges = [(type: NSFetchedResultsChangeType, indexPath: IndexPath?, newIndexPath: IndexPath?)]()

    var posts = [Post]()

    override init() {
        self.postCoreData = PostCoreData()
        self.postNetworkManager = PostNetworkManager()

        self.fetcher = self.postCoreData.getAll()
        super.init()

        self.fetcher.delegate = self

        do {
            try self.fetcher.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.localizedDescription)")
        }

        guard let fetched = fetcher.fetchedObjects else { return }
        posts = fetched
    }

    func create(photoName: String, photoData: Data?, date: Date? = nil, place: String? = nil,
                text: String? = nil, completion: ((ErrorViewModel?) -> Void)?) {
        var photoPath: String = ""
        photoPath = "posts/" + photoName
        _ = saveFile(data: photoData!, filePath: photoPath)

        guard let date = date, let place = place, let text = text
        else { return }

        // for core data
        let indexPhoto = self.fetcher.fetchedObjects!.count

        _ = postCoreData.create(photo: photoPath, date: date, place: place, text: text,
                                indexPhoto: indexPhoto)
    }

    func update(post: Post, date: Date? = nil, place: String? = nil, text: String? = nil,
                completion: ((ErrorViewModel?) -> Void)?) {
        postCoreData.update(post: post, id: post.id, date: date, place: place, text: text)
        guard let id = post.id else {
            completion?(ErrorsPostViewModel.noID)
            return
        }
        postNetworkManager.update(post: JsonPostModel(
            id: id, photoIndex: post.indexPhoto,
            dateStr: date ?? Date(timeIntervalSince1970: 0),
            placeStr: place ?? "",
            textStr: text ?? ""),
            completion: { (error) in
                if let error = error {
                    switch error {
                    case ErrorsNetwork.noData:
                        completion?(ErrorsPostViewModel.noData); return
                    default:
                        print("undefined user error: \(error)"); return
                    }
                }
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
            deleteFile(filePath: delPost.photo!)

            postCoreData.delete(post: delPost)
        }

        postCoreData.reinitIndices(posts: posts)

        postNetworkManager.delete(ids: uuids, completion: { (error) in
            if let error = error {
                switch error {
                case ErrorsNetwork.notFound:
                    completion?(ErrorsPostViewModel.notFound); return
                default:
                    print("undefined user error: \(error)"); return
                }
            }
        })
    }

    func swap(source: Int, dest: Int) {
        postCoreData.swap(posts, source: source, dest: dest)
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

        // TODO: better to crud with itemChanges
//        for change in viewModel.itemChanges {
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
