//
//  PhotoViewModel.swift
//  IdealVisual
//
//  Created by a.kurganova on 27.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import CoreData
import PromiseKit

final class PostViewModel: NSObject, PostViewModelProtocol {
    private var user: User?
    private var postCoreData: PostCoreDataProtocol
    private var postNetworkManager: PostNetworkManagerProtocol
    private var photoNetworkManager: PhotoNetworkManagerProtocol
    private var promise = Promise()

    private var notif_posts = [(PostViewModelProtocol) -> Void]()

    private var fetcher: NSFetchedResultsController<Post>

    private let photoFolder = "posts/"

    private weak var delegatePosts: PostChangedDelegate?
    private var itemChanges = [(type: NSFetchedResultsChangeType, indexPath: IndexPath?, newIndexPath: IndexPath?)]()

    var posts = [Post]()

    init(delegat: PostChangedDelegate?) {
        self.user = UserCoreData().get()
        self.delegatePosts = delegat
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
    }

// MARK: - sync posts

    // MARK: - checking field differences in posts
    private func differentFieldsPosts(post: Post, jspost: JsonPostModel) -> Bool {
        if post.date != jspost.date || post.place != jspost.place || post.text != jspost.text ||
            post.indexPhoto != jspost.photoIndex ||
            post.lastUpdated ?? Date(timeIntervalSince1970: 0) != jspost.lastUpdated {
            return post.lastUpdated != nil && post.lastUpdated! <= jspost.lastUpdated
        }
        return false
    }

    // MARK: - if UUID not null update core data or server
    private func uuidNotNull(jsposts: [JsonPostModel], post: Post) -> Promise<Any> {
        var foundArray: [UUID] = [UUID]() // массив айдишек для синка постов (разница постов в бд и на сервере)

        var converted = convertDBModelToJSON(post: post)
        converted.photo = ""

        guard let user = self.user, let token = user.token else {
            return Promise(error: PostViewModelErrors.notFound)
        }

        // Search for post and return promise with action depending on difference
        for jspost in jsposts where post.id == jspost.id {
            foundArray.append(jspost.id)

            if self.differentFieldsPosts(post: post, jspost: jspost) {
                var photoIndex: Int?
                if let jsPhotoIndex = jspost.photoIndex {
                    photoIndex = Int(jsPhotoIndex)
                }

                return Promise<Any> { _ in
                    try self.postCoreData.update(post: post, id: jspost.id, date: jspost.date, place: jspost.place,
                                                 text: jspost.text, indexPhoto: photoIndex,
                                                 lastUpdated: jspost.lastUpdated)
                }
            } else {
                firstly {
                    self.postNetworkManager.update(token: token, post: converted)
                }.done { _ in
                }.catch { (error) in
                    guard let error = error as? NetworkErr else {
                        return self.promise = Promise { seal in seal.reject(PostViewModelErrors.unknown) }
                    }
                    switch error {
                    case .noData:
                        return self.promise = Promise { seal in seal.reject(PostViewModelErrors.noData) }
                    case .unauthorized:
                        return self.promise = Promise { seal in seal.reject(PostViewModelErrors.unauthorized) }
                    default:
                        Logger.log("unknown error: \(error)")
                        return self.promise = Promise { seal in seal.reject(PostViewModelErrors.unknown) }
                    }
                }
            }
        }

        return Promise<Any> { _ in
           try self.postCoreData.delete(post: post)
        }
    }

    // MARK: - if uuid is null create post on server and update id photo core data
    private func uuidIsNull(jsposts: [JsonPostModel], post: Post) -> Promise<Any> {
        var promise: Promise<Any> = Promise<Any> { _ in }

        guard let ph = post.photo, let dataPhoto = MyFileManager.getFile(filePath: ph),
            let namePhoto = URL(string: ph)?.lastPathComponent
        else {
            promise = Promise(error: PostViewModelErrors.noData)
            return promise
        }

        guard let user = self.user, let token = user.token else {
            return Promise<Any> { seal in seal.reject(UserViewModelErrors.notFound) }
        }

        firstly {
            self.photoNetworkManager.upload(token: token, data: dataPhoto, name: namePhoto)
        }.then { (uploaded: String) -> Promise<JsonPostModel> in
            var converted = self.convertDBModelToJSON(post: post)
            converted.photo = uploaded
            return Promise<JsonPostModel> { seal in seal.fulfill(converted) }
        }.then { (converted: JsonPostModel) -> Promise<JsonPostModel> in
            return self.postNetworkManager.create(token: token, post: converted)
        }.done { (created: JsonPostModel) in
            try self.postCoreData.update(post: post, id: created.id, date: nil, place: nil, text: nil,
                                         indexPhoto: nil, lastUpdated: created.lastUpdated)
        }.catch { (error) in
            guard let error = error as? NetworkErr else {
                return promise = Promise<Any> { seal in seal.reject(PostViewModelErrors.unknown) }
            }
            switch error {
            case .noConnection:
                return promise = Promise<Any> { seal in seal.reject(PostViewModelErrors.noConnection) }
            case .unauthorized:
                return promise = Promise<Any> { seal in seal.reject(UserViewModelErrors.unauthorized) }
            case .notFound:
                return promise = Promise<Any> { seal in seal.reject(PostViewModelErrors.notFound) }
            default:
                return promise = Promise<Any> { seal in seal.reject(PostViewModelErrors.unknown) }
            }
        }
        print(promise)
        return promise
    }

    private func foundPosts(jsposts: [JsonPostModel]) -> [Promise<Any>] {
        let posts = self.posts // make a copy, because posts will change

        var postActions: [Promise<Any>] = []

        posts.forEach {
            if $0.id != UUID(uuid: UUID_NULL) {
                postActions.append(self.uuidNotNull(jsposts: jsposts, post: $0))
            } else {
                postActions.append(self.uuidIsNull(jsposts: jsposts, post: $0))
            }
        }

        return postActions
    }

    // FIXME: что в ошибках?

    func sync() -> Promise<Void> {
        guard let user = self.user, let token = user.token else {
            Logger.log("token in coredata is nil")
            return Promise(error: PostViewModelErrors.unknown)
        }

        firstly {
            postNetworkManager.get(token: token)
        }.then { (jsposts: [JsonPostModel]) -> Promise<[JsonPostModel]> in
            if jsposts.count == 0 {
                try self.posts.forEach {
                    try self.postCoreData.delete(post: $0)
                }
                return Promise<[JsonPostModel]> { seal in seal.reject(PostViewModelErrors.notFound) }
            }

            let sorted_posts = jsposts.sorted(by: { (first, second) in
                first.photoIndex ?? 0 < second.photoIndex ?? 0
            })

            return Promise<[JsonPostModel]> { seal in seal.fulfill(sorted_posts) }

        }.then { (jsposts: [JsonPostModel]) -> Promise<[Any]> in
            when(fulfilled: self.foundPosts(jsposts: jsposts)) // TODO: выпилить ретерн промиса от жспостов
        }.done { (_: [Any]) in
        }.catch { (error) in
            guard let err = error as? NetworkErr else {
                return self.promise = Promise { seal in seal.reject(PostViewModelErrors.unknown) }
            }
            switch err {
            case .unauthorized:
                return self.promise = Promise { seal in seal.reject(PostViewModelErrors.unauthorized)}
            case .notFound:
                return self.promise = Promise { seal in seal.reject(PostViewModelErrors.notFound) }
            case .noConnection:
                return self.promise = Promise { seal in seal.reject(PostViewModelErrors.noConnection) }
            default:
                Logger.log(error)
                return self.promise = Promise { seal in seal.reject(PostViewModelErrors.unknown) }
            }
        }
        return self.promise
    }

    // MARK: - create post
    func create(photoName: String, photoData: Data?, date: Date? = nil, place: String? = nil,
                text: String? = nil) -> Promise<Void> {
//        guard promise.isResolved else { return promise }

        let photoPath: String = photoFolder + photoName

        guard let photoData = photoData, let date = date, let place = place, let text = text else {
            return Promise(error: PostViewModelErrors.noData)
        }

        _ = MyFileManager.saveFile(data: photoData, filePath: photoPath)

        // for core data
        let indexPhoto = posts.count

        guard let user = user, let token = user.token else {
            Logger.log("error unautorized: \(PostViewModelErrors.cannotCreate)")
            return Promise(error: PostViewModelErrors.unauthorized)
        }

        guard let created = postCoreData.create(user: user, id: nil, photo: photoPath, date: date, place: place,
                                                text: text, indexPhoto: indexPhoto, lastUpdated: nil)
        else {
            Logger.log("error on create: \(PostViewModelErrors.cannotCreate)")
            return Promise(error: PostViewModelErrors.cannotCreate)
        }

        firstly {
            self.photoNetworkManager.upload(token: token, data: photoData, name: photoName)
        }.then { (path: String) -> Promise<JsonPostModel> in
            var jsonPost = self.convertDBModelToJSON(post: created)
            jsonPost.photo = path
            return Promise<JsonPostModel> { seal in seal.fulfill(jsonPost) }
        }.then { (jsonPost: JsonPostModel) -> Promise<JsonPostModel> in
            return self.postNetworkManager.create(token: token, post: jsonPost)
        }.done { (post: JsonPostModel) in
            try self.postCoreData.update(post: created, id: post.id, date: nil, place: nil, text: nil,
                                         indexPhoto: nil, lastUpdated: post.lastUpdated)
        }.catch { (error) in
            guard let error = error as? NetworkErr else {
                return self.promise = Promise { seal in seal.reject(PostViewModelErrors.unknown) }
            }
            switch error {
            case .noConnection:
                return self.promise = Promise { seal in seal.reject(PostViewModelErrors.noConnection) }
            case .unauthorized:
                return self.promise = Promise { seal in seal.reject(PostViewModelErrors.unauthorized) }
            case .notFound:
                return self.promise = Promise { seal in seal.reject(PostViewModelErrors.notFound) }
            case .noData:
                return self.promise = Promise { seal in seal.reject(PostViewModelErrors.noData) }
            default:
                Logger.log("unknown error")
                return self.promise = Promise { seal in seal.reject(PostViewModelErrors.unknown) }
            }
        }

        return Promise()
    }

    // MARK: - convert to json to upload on server
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

    // MARK: - update
    func update(post: Post, date: Date? = nil, place: String? = nil, text: String? = nil) -> Promise<Void> {
        guard promise.isResolved else { return promise }

        do {
            try self.postCoreData.update(post: post, id: post.id, date: date, place: place, text: text,
                                         indexPhoto: nil, lastUpdated: Date())
        } catch {
            Logger.log("error")
            return Promise(error: PostViewModelErrors.unknown)
        }

        guard let token = user?.token else {
            Logger.log("token in coredata is nil")
            return Promise(error: PostViewModelErrors.unauthorized)
        }
        var jsonPost = convertDBModelToJSON(post: post)
        jsonPost.photo = "" // don't update photo on server

        print("update vm")
        firstly {
            postNetworkManager.update(token: token, post: jsonPost)
        }.catch { (error) in
            Logger.log(error)
            guard let error = error as? NetworkErr else {
                self.promise = Promise { seal in seal.reject(PostViewModelErrors.unknown) }
                return
            }
            switch error {
            case .noData:
                return self.promise = Promise { seal in seal.reject(PostViewModelErrors.noData) }
            case .unauthorized:
                return self.promise = Promise { seal in seal.reject(PostViewModelErrors.unauthorized) }
            default:
                Logger.log("unknown error: \(error)")
                return self.promise = Promise { seal in seal.reject(PostViewModelErrors.unknown) }
            }
        }

        return self.promise
    }

    func subscribe(completion: @escaping (PostViewModelProtocol) -> Void) {
        notif_posts.append(completion)
    }

    // MARK: - delete
    func delete(atIndices: [Int]) -> Promise<Void> {
        guard promise.isResolved else { return promise }
        var uuids = [UUID]()
        for index in atIndices {
            let delPost = posts[index]
            uuids.append(delPost.id!)
            MyFileManager.deleteFile(filePath: delPost.photo!)

            do {
                try self.postCoreData.delete(post: delPost)
            } catch {
                Logger.log("error delete")
                return Promise(error: PostViewModelErrors.unknown)
            }
        }

        postCoreData.reinitIndices(posts: posts)

        guard let token = user?.token else {
            Logger.log("token in coredata is nil")
            return Promise(error: PostViewModelErrors.unauthorized)
        }

        firstly {
            self.postNetworkManager.delete(token: token, ids: uuids)
        }.catch { (error) in
            guard let error = error as? NetworkErr else {
                return self.promise = Promise { seal in seal.reject(PostViewModelErrors.unknown) }
            }
            switch error {
            case .noConnection:
                return self.promise = Promise { seal in seal.reject(PostViewModelErrors.noConnection) }
            case .unauthorized:
                return self.promise = Promise { seal in seal.reject(PostViewModelErrors.unauthorized) }
            case .notFound:
                return self.promise = Promise { seal in seal.reject(PostViewModelErrors.notFound) }
            default:
                return self.promise = Promise { seal in seal.reject(PostViewModelErrors.unknown) }
            }
        }
        return self.promise
    }

    // MARK: - swap
    func swap(source: Int, dest: Int) {
        postCoreData.swap(posts, source: source, dest: dest)

        guard let token = user?.token else { return }

        var forChange: ArraySlice<Post>

        if source < dest {
            forChange = posts[source...dest]
        } else {
            forChange = posts[dest...source]
        }

        forChange.forEach {
            var jsonPost: JsonPostModel
            jsonPost = convertDBModelToJSON(post: $0)
            jsonPost.photo = "" // don't update photo on server

            firstly {
                self.postNetworkManager.update(token: token, post: jsonPost)
            }.catch { (error) in
                Logger.log(error)
            }
        }
    }
}

extension PostViewModel: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        itemChanges.append((type, indexPath, newIndexPath))
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let fetched = fetcher.fetchedObjects else { return }
        posts = fetched

        delegatePosts?.didChanged(itemsChanged: self.itemChanges)

        for notify in notif_posts {
            notify(self)
        }
        self.itemChanges.removeAll()
    }
}
