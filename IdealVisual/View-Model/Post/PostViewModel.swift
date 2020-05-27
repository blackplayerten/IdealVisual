import Foundation
import CoreData

final class PostViewModel: NSObject, PostViewModelProtocol, MainViewAddPostsDelegate {
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

    // swiftlint:disable cyclomatic_complexity
    func sync(completion: ((PostViewModelErrors?) -> Void)?) {
        guard let user = user, let token = user.token else {
            Logger.log("token in coredata is nil")
            completion?(PostViewModelErrors.unauthorized)
            return
        }

        postNetworkManager.get(token: token, completion: { (jsposts, error) in
            if let err = error {
                switch err {
                case .unauthorized:
                    completion?(PostViewModelErrors.unauthorized)
                case .noConnection:
                    completion?(PostViewModelErrors.noConnection)
                default:
                    Logger.log("unknown: \(String(describing: err))")
                    completion?(PostViewModelErrors.unknown)
                }

                return
            }

            guard var jsposts = jsposts else { return }

            if jsposts.count == 0 {
                self.posts.forEach {
                    do {
                        try self.postCoreData.delete(post: $0)
                    } catch {
                        completion?(PostViewModelErrors.unknown)
                    }
                }

                completion?(PostViewModelErrors.notFound)
                return
            }

            jsposts = jsposts.sorted(by: { (first, second) in
                return first.photoIndex ?? 0 < second.photoIndex ?? 0
            })

            var foundArray: [UUID] = [UUID]() // массив айдишек для синка постов (разница постов в бд и на сервере)
            let posts = self.posts // make a copy, because posts will change
            for post in posts {
                if post.id != UUID(uuid: UUID_NULL) {
                    var found = false
                    for jspost in jsposts where post.id == jspost.id {
                        foundArray.append(jspost.id)
                        found = true
                        if post.date != jspost.date || post.place != jspost.place || post.text != jspost.text ||
                            post.indexPhoto != jspost.photoIndex ||
                            post.lastUpdated ?? Date(timeIntervalSince1970: 0) != jspost.lastUpdated {
                            if post.lastUpdated != nil && post.lastUpdated! <= jspost.lastUpdated {
                                // our post is old: sync in
                                var photoIndex: Int?
                                if let jsPhotoIndex = jspost.photoIndex {
                                    photoIndex = Int(jsPhotoIndex)
                                }
                                do {
                                    try self.postCoreData.update(post: post,
                                                                 id: jspost.id, date: jspost.date,
                                                                 place: jspost.place, text: jspost.text,
                                                                 indexPhoto: photoIndex,
                                                                 lastUpdated: jspost.lastUpdated)
                                } catch {
                                    completion?(PostViewModelErrors.unknown)
                                }
                            } else {
                                // post on server is old: sync out
                                var converted = self.convertDBModelToJSON(post: post)
                                converted.photo = ""
                                self.postNetworkManager.update(token: token, post: converted,
                                                          completion: { (_, error) in
                                    if let err = error {
                                        switch err {
                                        case .noConnection:
                                            completion?(PostViewModelErrors.noConnection)
                                        case .noData:
                                            completion?(PostViewModelErrors.noData)
                                        case .unauthorized:
                                            completion?(PostViewModelErrors.unauthorized)
                                        default:
                                            Logger.log("unknown error: \(err)")
                                            completion?(PostViewModelErrors.unknown)
                                        }
                                    }
                                })
                            }
                        }
                        break
                    }
                    if !found {
                        do {
                            try self.postCoreData.delete(post: post)
                        } catch {
                            completion?(PostViewModelErrors.unknown)
                        }
                    }
                } else { // если есть посты с 0 айди, значит они есть у нас, но их нет на сервере
                    guard let ph = post.photo,
                            let dataPhoto = MyFileManager.getFile(filePath: ph),
                            let namePhoto = URL(string: ph)?.lastPathComponent
                    else {
                        completion?(PostViewModelErrors.noData)
                        return
                    }

                    self.photoNetworkManager.upload(token: token, data: dataPhoto, name: namePhoto,
                                                    completion: { (uploaded, error) in
                        if let err = error {
                            switch err {
                            case .noConnection:
                                completion?(PostViewModelErrors.noConnection)
                            case .unauthorized:
                                completion?(PostViewModelErrors.unauthorized)
                            default:
                                Logger.log("unknown error: \(error)")
                                completion?(PostViewModelErrors.unknown)
                            }
                        }

                        guard let uploaded = uploaded else {
                            completion?(PostViewModelErrors.noData)
                            return
                        }

                        var converted = self.convertDBModelToJSON(post: post)
                        converted.photo = uploaded

                        self.postNetworkManager.create(token: token, post: converted, completion: { (created, error) in
                            if let err = error {
                                switch err {
                                case .noConnection:
                                    completion?(PostViewModelErrors.noConnection)
                                case .notFound:
                                    completion?(PostViewModelErrors.notFound)
                                case .unauthorized:
                                    completion?(PostViewModelErrors.unauthorized)
                                default:
                                    Logger.log("unknown error: \(error)")
                                    completion?(PostViewModelErrors.unknown)
                                }
                            }

                            guard let created = created else {
                                Logger.log("data error: \(PostViewModelErrors.noData)")
                                completion?(PostViewModelErrors.noData)
                                return
                            }

                            // меняем айди на айди поста сервера
                            do {
                                try self.postCoreData.update(post: post, id: created.id, date: nil, place: nil,
                                                             text: nil, indexPhoto: nil,
                                                             lastUpdated: created.lastUpdated)
                            } catch {
                                completion?(PostViewModelErrors.unknown)
                            }
                        })
                    })
                }
            }

            for jspost in jsposts {
                if foundArray.contains(jspost.id) {
                    continue
                }
                self.photoNetworkManager.get(path: jspost.photo, completion: { (photoData, error) in
                    if let err = error {
                        switch err {
                        case .noConnection:
                            completion?(PostViewModelErrors.noConnection)
                        case .unauthorized:
                            completion?(PostViewModelErrors.unauthorized)
                        case .notFound:
                            Logger.log("photo not found")
                            // skip this post
                        case .noData:
                            completion?(PostViewModelErrors.noData)
                        default:
                            Logger.log("unknown error: \(err)")
                            completion?(PostViewModelErrors.unknown)
                        }
                        return
                    }

                    guard let photoData = photoData else {
                        Logger.log("200 OK, but got nil photoData")
                        return
                    }

                    guard let photoName = URL(string: jspost.photo)?.lastPathComponent else {
                        Logger.log("can't get photo name with extension: \(jspost.photo)")
                        return
                    }

                    let photoPath: String = self.photoFolder + photoName
                    _ = MyFileManager.saveFile(data: photoData, filePath: photoPath)
                    _ = self.postCoreData.create(user: user, id: jspost.id,
                                                 photo: photoPath, date: jspost.date, place: jspost.place,
                                                 text: jspost.text, indexPhoto: Int(jspost.photoIndex ?? 0),
                                                 lastUpdated: jspost.date)
                })
            }
            if self.posts.count != 0 {
                completion?(nil)
            } else {
                completion?(PostViewModelErrors.notFound)
            }
        }
    )
}
    // swiftlint:enable cyclomatic_complexity

    func create(photoName: String, photoData: Data?, date: Date? = nil, place: String? = nil,
                text: String? = nil, completion: ((PostViewModelErrors?) -> Void)?) {
        let photoPath: String = photoFolder + photoName
        _ = MyFileManager.saveFile(data: photoData!, filePath: photoPath)

        guard let photoData = photoData, let date = date, let place = place, let text = text else {
            completion?(PostViewModelErrors.noData)
            return
        }

        // for core data
        let indexPhoto = posts.count

        guard let user = user, let token = user.token else {
            Logger.log("error unautorized: \(PostViewModelErrors.cannotCreate)")
            completion?(PostViewModelErrors.unauthorized)
            return
        }

        guard let created = postCoreData.create(user: user, id: nil, photo: photoPath, date: date, place: place,
                                                text: text, indexPhoto: indexPhoto, lastUpdated: nil)
        else {
            Logger.log("error on create: \(PostViewModelErrors.cannotCreate)")
            completion?(PostViewModelErrors.cannotCreate)
            return
        }

        photoNetworkManager.upload(token: token, data: photoData, name: photoName,
                                   completion: { (path, error) in
            if let err = error {
                switch err {
                case .noConnection:
                    completion?(PostViewModelErrors.noConnection)
                case .unauthorized:
                    completion?(PostViewModelErrors.unauthorized)
                case .notFound:
                    completion?(PostViewModelErrors.notFound)
                default:
                    Logger.log(error)
                    completion?(PostViewModelErrors.unknown)
                }
                return
            }

            guard let path = path else {
                Logger.log("data error: \(PostViewModelErrors.noData)")
                return
            }

            var jsonPost = self.convertDBModelToJSON(post: created)
            jsonPost.photo = path

            self.postNetworkManager.create(token: token, post: jsonPost, completion: { (post, error) in
                if let err = error {
                    switch err {
                    case .noConnection:
                        completion?(PostViewModelErrors.noConnection)
                    case .unauthorized:
                        completion?(PostViewModelErrors.unauthorized)
                    default:
                        Logger.log("\(PostViewModelErrors.unknown)")
                        completion?(PostViewModelErrors.unknown)
                    }
                    return
                }

                guard let post = post else {
                    Logger.log("data error: \(PostViewModelErrors.noData)")
                    completion?(PostViewModelErrors.noData)
                    return
                }
                do {
                    _ = try self.postCoreData.update(post: created, id: post.id, date: nil, place: nil, text: nil,
                                                     indexPhoto: nil,
                                                     lastUpdated: post.lastUpdated)
                    completion?(nil)
                } catch {
                    completion?(PostViewModelErrors.unknown)
                }
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
                completion: ((PostViewModelErrors?) -> Void)?) {
        do {
            try postCoreData.update(post: post, id: post.id, date: date, place: place, text: text,
                                    indexPhoto: nil, lastUpdated: Date())
        } catch {
            completion?(PostViewModelErrors.unknown)
        }
        guard let token = user?.token else {
            Logger.log("token in coredata is nil")
            completion?(PostViewModelErrors.unauthorized)
            return
        }
        var jsonPost = convertDBModelToJSON(post: post)
        jsonPost.photo = "" // don't update photo on server
        postNetworkManager.update(token: token, post: jsonPost,
            completion: { (_, error) in
                if let err = error {
                    switch err {
                    case .noConnection:
                        completion?(PostViewModelErrors.noConnection)
                    case .noData:
                        completion?(PostViewModelErrors.noData)
                    case .unauthorized:
                        completion?(PostViewModelErrors.unauthorized)
                    default:
                        Logger.log("unknown error: \(err)")
                        completion?(PostViewModelErrors.unknown)
                    }
                }
                completion?(nil)
            }
        )
    }

    func subscribe(completion: @escaping (PostViewModelProtocol) -> Void) {
        notif_posts.append(completion)
    }

    func delete(atIndices: [Int], completion: ((PostViewModelErrors?) -> Void)?) {
        var uuids = [UUID]()
        for index in atIndices {
            let delPost = posts[index]
            uuids.append(delPost.id!)
            MyFileManager.deleteFile(filePath: delPost.photo!)

            do {
                try postCoreData.delete(post: delPost)
            } catch {
                completion?(PostViewModelErrors.unknown)
            }
        }

        postCoreData.reinitIndices(posts: posts)

        guard let token = user?.token else {
            Logger.log("token in coredata is nil")
            completion?(PostViewModelErrors.unauthorized)
            return
        }
        postNetworkManager.delete(token: token, ids: uuids, completion: { (error) in
            if let err = error {
                switch err {
                case .noConnection:
                    completion?(PostViewModelErrors.noConnection)
                case .notFound:
                    completion?(PostViewModelErrors.notFound)
                case .unauthorized:
                    completion?(PostViewModelErrors.unauthorized)
                default:
                    Logger.log("\(PostViewModelErrors.unknown)")
                    completion?(PostViewModelErrors.unknown)
                }
                return
            }
            completion?(nil)
        })
    }

    func swap(source: Int, dest: Int, completion: ((PostViewModelErrors?) -> Void)?) {
        postCoreData.swap(posts, source: source, dest: dest)

        guard let token = user?.token else {
            completion?(PostViewModelErrors.unauthorized)
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
                if let err = error {
                    switch err {
                    case .noConnection:
                        completion?(PostViewModelErrors.noConnection)
                    case .unauthorized:
                        completion?(PostViewModelErrors.unauthorized)
                    case .noData:
                        completion?(PostViewModelErrors.noData)
                    case .notFound:
                        completion?(PostViewModelErrors.notFound)
                    default:
                        completion?(PostViewModelErrors.unknown)
                    }
                    Logger.log(err)
                }
            })
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
