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
            return Promise<Any> { seal in seal.reject(ErrorsUserViewModel.notFound) }
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
                return Promise<Any> { seal in
                    firstly {
                        self.postNetworkManager.update(token: token, post: converted)
                    }.done { _ in
                    }.catch { (error) in
                        guard let error = error as? NetworkError else {
                            return seal.reject(ErrorsPostViewModel.unknownError)
                        }
                        switch error.name {
                        case ErrorsNetwork.noData:
                            return seal.reject(ErrorsPostViewModel.noData)
                        case ErrorsNetwork.unauthorized:
                            return seal.reject(ErrorsPostViewModel.unauthorized)
                        default:
                            Logger.log("unknown error: \(error)")
                            return seal.reject(ErrorsPostViewModel.unknownError)
                        }
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
        guard let ph = post.photo, let dataPhoto = MyFileManager.getFile(filePath: ph),
            let namePhoto = URL(string: ph)?.lastPathComponent
        else {
            return Promise<Any> { seal in seal.reject(ErrorsPostViewModel.noData) }
        }

        guard let user = self.user, let token = user.token else {
            return Promise<Any> { seal in seal.reject(ErrorsUserViewModel.notFound) }
        }

        return Promise<Any> { seal in
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
                guard let error = error as? NetworkError else {
                    return seal.reject(ErrorsPostViewModel.unknownError)
                }
                switch error.name {
                case ErrorsNetwork.noConnection:
                    return seal.reject(ErrorsPostViewModel.noConnection)
                case ErrorsNetwork.unauthorized:
                    return seal.reject(ErrorsUserViewModel.unauthorized)
                case ErrorsNetwork.notFound:
                    return seal.reject(ErrorsPostViewModel.notFound)
                default:
                    return seal.reject(ErrorsPostViewModel.unknownError)
                }
            }
        }

//        self.photoNetworkManager.upload(token: token, data: dataPhoto, name: namePhoto,
//                                                completion: { (uploaded, error) in
//                    if let error = error {
//                        switch error.name {
//                        case ErrorsNetwork.unauthorized:
//                            completion?(ErrorsPostViewModel.unauthorized)
//                        default:
//                            Logger.log("unknown error: \(error)")
//                            completion?(ErrorsPostViewModel.unknownError)
//                        }
//                    }
//
//                    guard let uploaded = uploaded else {
//                        completion?(ErrorsPostViewModel.noData)
//                        return
//                    }
//
//                    var converted = self.convertDBModelToJSON(post: post)
//                    converted.photo = uploaded
//
//                    self.postNetworkManager.create(token: token, post: converted, completion: { (created, error) in
//                        if let error = error {
//                            switch error.name {
//                            case ErrorsNetwork.notFound:
//                                completion?(ErrorsUserViewModel.notFound)
//                            case ErrorsNetwork.unauthorized:
//                                completion?(ErrorsPostViewModel.unauthorized)
//                            default:
//                                Logger.log("unknown error: \(error)")
//                                completion?(ErrorsPostViewModel.unknownError)
//                            }
//                        }
//
//                        guard let created = created else {
//                            Logger.log("data error: \(ErrorsPostViewModel.noData)")
//                            completion?(ErrorsPostViewModel.noData)
//                            return
//                        }
//
//                        // меняем айди на айди поста сервера
//                        self.postCoreData.update(post: post, id: created.id, date: nil, place: nil, text: nil,
//                                                 indexPhoto: nil,
//                                                 lastUpdated: created.lastUpdated)
//                    })
//                })
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

    func sync() {
        guard let user = self.user, let token = user.token else {
            Logger.log("token in coredata is nil")
            return
        }

        firstly {
            postNetworkManager.get(token: token)
        }.then { (jsposts: [JsonPostModel]) -> Promise<[JsonPostModel]> in
            if jsposts.count == 0 {
                try self.posts.forEach {
                    try self.postCoreData.delete(post: $0)
                }
                return Promise<[JsonPostModel]> { seal in seal.reject(ErrorsPostViewModel.notFound) }
            }

            let sorted_posts = jsposts.sorted(by: { (first, second) in
                first.photoIndex ?? 0 < second.photoIndex ?? 0
            })

            return Promise<[JsonPostModel]> { seal in seal.fulfill(sorted_posts) }

        }.then { (jsposts: [JsonPostModel]) -> Promise<[Any]> in
            when(fulfilled: self.foundPosts(jsposts: jsposts)) // TODO: выпилить ретерн промиса от жспостов
        }.done { (_: [Any]) in
        }.catch { (error) in
            Logger.log(error)
        }

//        postNetworkManager.get(token: token, completion: { (jsposts, error) in
//            if let error = error {
//                switch error.name {
//                case ErrorsNetwork.unauthorized:
//                    completion?(ErrorsPostViewModel.unauthorized)
//                case ErrorsNetwork.noConnection:
//                    completion?(ErrorsPostViewModel.noConnection)
//                default:
//                    Logger.log("unknown: \(String(describing: error.name))")
//                    completion?(ErrorsPostViewModel.unknownError)
//                }
//
//                return
//            }
//
//            guard var jsposts = jsposts else { return }
//
//            if jsposts.count == 0 {
//                self.posts.forEach {
//                    self.postCoreData.delete(post: $0)
//                }
//
//                completion?(ErrorsPostViewModel.notFound)
//                return
//            }
//
//            jsposts = jsposts.sorted(by: { (first, second) in
//                return first.photoIndex ?? 0 < second.photoIndex ?? 0
//            })
//
//            var foundArray: [UUID] = [UUID]() // массив айдишек для синка постов (разница постов в бд и на сервере)
//            let posts = self.posts // make a copy, because posts will change
//            for post in posts {
//                if post.id != UUID(uuid: UUID_NULL) {
//                    var found = false
//                    for jspost in jsposts where post.id == jspost.id {
//                        foundArray.append(jspost.id)
//                        found = true
//                        if post.date != jspost.date || post.place != jspost.place || post.text != jspost.text ||
//                            post.indexPhoto != jspost.photoIndex ||
//                            post.lastUpdated ?? Date(timeIntervalSince1970: 0) != jspost.lastUpdated {
//                            if post.lastUpdated != nil && post.lastUpdated! <= jspost.lastUpdated {
//                                // our post is old: sync in
//                                var photoIndex: Int?
//                                if let jsPhotoIndex = jspost.photoIndex {
//                                    photoIndex = Int(jsPhotoIndex)
//                                }
//                                self.postCoreData.update(post: post,
//                                                         id: jspost.id, date: jspost.date,
//                                                         place: jspost.place, text: jspost.text,
//                                                         indexPhoto: photoIndex,
//                                                         lastUpdated: jspost.lastUpdated)
//                            } else {
//                                // post on server is old: sync out
//                                var converted = self.convertDBModelToJSON(post: post)
//                                converted.photo = ""
//                                self.postNetworkManager.update(token: token, post: converted,
//                                                          completion: { (_, error) in
//                                    if let error = error {
//                                        switch error.name {
//                                        case ErrorsNetwork.noData:
//                                            completion?(ErrorsPostViewModel.noData)
//                                        case ErrorsNetwork.unauthorized:
//                                            completion?(ErrorsPostViewModel.unauthorized)
//                                        default:
//                                            Logger.log("unknown error: \(error)")
//                                            completion?(ErrorsPostViewModel.unknownError)
//                                        }
//                                    }
//                                })
//                            }
//                        }
//                        break
//                    }
//                    if !found {
//                        self.postCoreData.delete(post: post)
//                    }
//                } else { // если есть посты с 0 айди, значит они есть у нас, но их нет на сервере
//                    guard let ph = post.photo,
//                            let dataPhoto = MyFileManager.getFile(filePath: ph),
//                            let namePhoto = URL(string: ph)?.lastPathComponent
//                    else {
//                        completion?(ErrorsPostViewModel.noData)
//                        return
//                    }
//
//                    self.photoNetworkManager.upload(token: token, data: dataPhoto, name: namePhoto,
//                                                    completion: { (uploaded, error) in
//                        if let error = error {
//                            switch error.name {
//                            case ErrorsNetwork.unauthorized:
//                                completion?(ErrorsPostViewModel.unauthorized)
//                            default:
//                                Logger.log("unknown error: \(error)")
//                                completion?(ErrorsPostViewModel.unknownError)
//                            }
//                        }
//
//                        guard let uploaded = uploaded else {
//                            completion?(ErrorsPostViewModel.noData)
//                            return
//                        }
//
//                        var converted = self.convertDBModelToJSON(post: post)
//                        converted.photo = uploaded
//
//                        self.postNetworkManager.create(token: token, post: converted, completion: { (created, error) in
//                            if let error = error {
//                                switch error.name {
//                                case ErrorsNetwork.notFound:
//                                    completion?(ErrorsUserViewModel.notFound)
//                                case ErrorsNetwork.unauthorized:
//                                    completion?(ErrorsPostViewModel.unauthorized)
//                                default:
//                                    Logger.log("unknown error: \(error)")
//                                    completion?(ErrorsPostViewModel.unknownError)
//                                }
//                            }
//
//                            guard let created = created else {
//                                Logger.log("data error: \(ErrorsPostViewModel.noData)")
//                                completion?(ErrorsPostViewModel.noData)
//                                return
//                            }
//
//                            // меняем айди на айди поста сервера
//                            self.postCoreData.update(post: post, id: created.id, date: nil, place: nil, text: nil,
//                                                     indexPhoto: nil,
//                                                     lastUpdated: created.lastUpdated)
//                        })
//                    })
//                }
//            }
//
//            for jspost in jsposts {
//                if foundArray.contains(jspost.id) {
//                    continue
//                }
//                self.photoNetworkManager.get(path: jspost.photo, completion: { (photoData, error) in
//                    if let error = error {
//                        switch error.name {
//                        case ErrorsNetwork.unauthorized:
//                            completion?(ErrorsPostViewModel.unauthorized)
//                        case ErrorsNetwork.notFound:
//                            Logger.log("photo not found")
//                            // skip this post
//                        case ErrorsNetwork.noData:
//                            completion?(ErrorsPostViewModel.noData)
//                        default:
//                            Logger.log("unknown error: \(error)")
//                            completion?(ErrorsPostViewModel.unknownError)
//                        }
//                        return
//                    }
//
//                    guard let photoData = photoData else {
//                        Logger.log("200 OK, but got nil photoData")
//                        return
//                    }
//
//                    guard let photoName = URL(string: jspost.photo)?.lastPathComponent else {
//                        Logger.log("can't get photo name with extension: \(jspost.photo)")
//                        return
//                    }
//
//                    let photoPath: String = self.photoFolder + photoName
//                    _ = MyFileManager.saveFile(data: photoData, filePath: photoPath)
//                    _ = self.postCoreData.create(user: user, id: jspost.id,
//                                                 photo: photoPath, date: jspost.date, place: jspost.place,
//                                                 text: jspost.text, indexPhoto: Int(jspost.photoIndex ?? 0),
//                                                 lastUpdated: jspost.date)
//                })
//            }
//            if self.posts.count != 0 {
//                completion?(nil)
//            } else {
//                completion?(ErrorsPostViewModel.notFound)
//            }
//        }
//    )
    }

    // FIXME: какой промис возвращать?

    // MARK: - create post
    func create(photoName: String, photoData: Data?, date: Date? = nil, place: String? = nil,
                text: String? = nil) -> Promise<Void> {
        let photoPath: String = photoFolder + photoName
        _ = MyFileManager.saveFile(data: photoData!, filePath: photoPath)

        return Promise<Void> { seal in
            guard let photoData = photoData, let date = date, let place = place, let text = text else {
                return seal.reject(ErrorsPostViewModel.noData)
            }

            // for core data
            let indexPhoto = posts.count

            guard let user = user, let token = user.token else {
                Logger.log("error unautorized: \(ErrorsPostViewModel.cannotCreate)")
                return seal.reject(ErrorsPostViewModel.unauthorized)
            }

            guard let created = postCoreData.create(user: user, id: nil, photo: photoPath, date: date, place: place,
                                                    text: text, indexPhoto: indexPhoto, lastUpdated: nil)
            else {
                Logger.log("error on create: \(ErrorsPostViewModel.cannotCreate)")
                return seal.reject(ErrorsPostViewModel.cannotCreate)
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
                guard let error = error as? NetworkError else {
                    return seal.reject(ErrorsPostViewModel.unknownError)
                }
                switch error.name {
                case ErrorsNetwork.noConnection:
                    seal.reject(ErrorsPostViewModel.noConnection)
                case ErrorsNetwork.unauthorized:
                    seal.reject(ErrorsPostViewModel.unauthorized)
                case ErrorsNetwork.notFound:
                    seal.reject(ErrorsPostViewModel.notFound)
                case ErrorsNetwork.noData:
                    seal.reject(ErrorsPostViewModel.noData)
                default:
                    Logger.log("unknown error: \(error)")
                    seal.reject(ErrorsPostViewModel.unknownError)
                }
            }
        }

//        photoNetworkManager.upload(token: token, data: photoData, name: photoName,
//                                   completion: { (path, error) in
//            if let error = error {
//                switch error.name {
//                case ErrorsNetwork.unauthorized:
//                    completion?(ErrorsPostViewModel.unauthorized)
//                case ErrorsNetwork.notFound:
//                    completion?(ErrorsUserViewModel.notFound)
//                default:
//                    Logger.log(error)
//                    completion?(ErrorsPostViewModel.unknownError)
//                }
//                return
//            }
//
//            guard let path = path else {
//                Logger.log("data error: \(ErrorsPostViewModel.noData)")
//                return
//            }
//
//            var jsonPost = self.convertDBModelToJSON(post: created)
//            jsonPost.photo = path
//
//            self.postNetworkManager.create(token: token, post: jsonPost, completion: { (post, error) in
//                if let error = error {
//                    switch error.name {
//                    case ErrorsNetwork.unauthorized:
//                        completion?(ErrorsPostViewModel.unauthorized)
//                    default:
//                        Logger.log("\(ErrorsPostViewModel.unknownError)")
//                        completion?(ErrorsPostViewModel.unknownError)
//                    }
//                    return
//                }
//
//                guard let post = post else {
//                    Logger.log("data error: \(ErrorsPostViewModel.noData)")
//                    completion?(ErrorsPostViewModel.noData)
//                    return
//                }
//
//                _ = self.postCoreData.update(post: created, id: post.id, date: nil, place: nil, text: nil,
//                                             indexPhoto: nil,
//                                             lastUpdated: post.lastUpdated)
//                completion?(nil)
//            })
//        })
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
        do {
            try self.postCoreData.update(post: post, id: post.id, date: date, place: place, text: text,
                                         indexPhoto: nil, lastUpdated: Date())
        } catch {
            Logger.log("error")
            return Promise<Void> { seal in seal.reject(ErrorsPostViewModel.unknownError) }
        }

        guard let token = user?.token else {
            Logger.log("token in coredata is nil")
            return Promise<Void> { seal in seal.reject(ErrorsPostViewModel.unauthorized)}
        }
        var jsonPost = convertDBModelToJSON(post: post)
        jsonPost.photo = "" // don't update photo on server

        return Promise<Void> { seal in
            firstly {
                postNetworkManager.update(token: token, post: jsonPost)
            }.catch { (error) in
                Logger.log(error)
                guard let error = error as? NetworkError else {
                    return seal.reject(ErrorsPostViewModel.unknownError)
                }
                switch error.name {
                case ErrorsNetwork.noData:
                    seal.reject(ErrorsPostViewModel.noData)
                case ErrorsNetwork.unauthorized:
                    seal.reject(ErrorsPostViewModel.unauthorized)
                default:
                    Logger.log("unknown error: \(error)")
                    seal.reject(ErrorsPostViewModel.unknownError)
                }
            }
        }

//        postNetworkManager.update(token: token, post: jsonPost,
//            completion: { (_, error) in
//                if let error = error {
//                    switch error.name {
//                    case ErrorsNetwork.noData:
//                        completion?(ErrorsPostViewModel.noData)
//                    case ErrorsNetwork.unauthorized:
//                        completion?(ErrorsPostViewModel.unauthorized)
//                    default:
//                        Logger.log("unknown error: \(error)")
//                        completion?(ErrorsPostViewModel.unknownError)
//                    }
//                }
//                completion?(nil)
//            }
//        )
    }

    func subscribe(completion: @escaping (PostViewModelProtocol) -> Void) {
        notif_posts.append(completion)
    }

    // MARK: - delete
    func delete(atIndices: [Int]) -> Promise<Void> {
        var uuids = [UUID]()
        for index in atIndices {
            let delPost = posts[index]
            uuids.append(delPost.id!)
            MyFileManager.deleteFile(filePath: delPost.photo!)

            do {
                try self.postCoreData.delete(post: delPost)
            } catch {
                Logger.log("error delete")
            }
        }

        postCoreData.reinitIndices(posts: posts)

        guard let token = user?.token else {
            Logger.log("token in coredata is nil")
            return Promise<Void> { seal in seal.reject(ErrorsPostViewModel.unauthorized) }
        }

        return Promise<Void> { seal in
            firstly {
                self.postNetworkManager.delete(token: token, ids: uuids)
            }.catch { (error) in
                guard let error = error as? NetworkError else {
                    return seal.reject(ErrorsPostViewModel.unknownError)
                }
                switch error.name {
                case ErrorsNetwork.noConnection:
                    seal.reject(ErrorsPostViewModel.noConnection)
                case ErrorsNetwork.unauthorized:
                    seal.reject(ErrorsUserViewModel.unauthorized)
                case ErrorsNetwork.notFound:
                    seal.reject(ErrorsPostViewModel.notFound)
                default:
                    seal.reject(ErrorsPostViewModel.unknownError)
                }
            }
        }

//        postNetworkManager.delete(token: token, ids: uuids, completion: { (error) in
//            if let error = error {
//                switch error.name {
//                case ErrorsNetwork.notFound:
//                    completion?(ErrorsPostViewModel.notFound)
//                case ErrorsNetwork.unauthorized:
//                    completion?(ErrorsPostViewModel.unauthorized)
//                default:
//                    Logger.log("\(ErrorsPostViewModel.unknownError)")
//                    completion?(ErrorsPostViewModel.unknownError)
//                }
//                return
//            }
//            completion?(nil)
//        })
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

//            postNetworkManager.update(token: token, post: jsonPost, completion: { (_, error) in
//                if let error = error {
//                    switch error.name {
//                    case ErrorsNetwork.unauthorized:
//                        completion?(ErrorsPostViewModel.unauthorized)
//                    case ErrorsNetwork.noData:
//                        completion?(ErrorsPostViewModel.noData)
//                    case ErrorsNetwork.notFound:
//                        completion?(ErrorsPostViewModel.notFound)
//                    default:
//                        completion?(ErrorsPostViewModel.unknownError)
//                    }
//                    Logger.log(error)
//                }
//            })
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
