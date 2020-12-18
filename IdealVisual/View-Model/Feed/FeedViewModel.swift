//
//  FeedViewModel.swift
//  IdealVisual
//
//  Created by Alexandra Kurganova on 29.11.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation

final class FeedViewModel: FeedViewModelProtocol, MainViewAddPostsDelegate {
    private var user: User
    private var postNetworkManager: PostNetworkManagerProtocol
    private var photoNetworkManager: PhotoNetworkManagerProtocol
    
    var posts = [Post]()
    private let photoFolder = "posts/"
    
    init() {
        self.user = User()
        self.user.get()
        self.posts = PostTable.all()
        self.postNetworkManager = PostNetworkManager()
        self.photoNetworkManager = PhotoNetworkManager()
    }
    
    private func convertDBModelToJSON(post: Post) -> JsonPostModel {
        return JsonPostModel(
            id: post.id,
            photo: post.photo,
            photoIndex: Int64(post.indexPhoto),
            date: post.date ?? Date(timeIntervalSince1970: 0),
            place: post.place ?? "",
            text: post.text ?? ""
        )
    }
    
    func create(photoName: String, photoData: Data?, date: Date? = nil, place: String? = nil,
                text: String? = nil, completion: ((PostViewModelErrors?) -> Void)?) {
        let photoPath: String = photoFolder + photoName
        _ = MyFileManager.saveFile(data: photoData!, filePath: photoPath)

        guard let photoData = photoData, let date = date, let place = place, let text = text else {
            completion?(PostViewModelErrors.noData)
            return
        }
        
        let indexPhoto = Int64(posts.count)

        guard let token = user.token else {
            Logger.log("error unautorized: \(PostViewModelErrors.cannotCreate)")
            completion?(PostViewModelErrors.unauthorized)
            return
        }

        let createdPost = Post(id: UUID(uuid: UUID_NULL), photo: photoPath, date: date, place: place, text: text, indexPhoto: indexPhoto, lastUpdated: nil)
        createdPost.create()

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

            
            var jsonPost = self.convertDBModelToJSON(post: createdPost)
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
                
                createdPost.id = post.id
                createdPost.changeID()
                createdPost.lastUpdated = post.lastUpdated
                createdPost.update()

                self.posts.append(createdPost)

                completion?(nil)
            })
        })
    }
    
    func delete(atIndices: [Int], completion: ((PostViewModelErrors?) -> Void)?) {
        var uuids = [UUID]()
        for (i, delIndex) in atIndices.sorted().enumerated() {
            let delPost = posts[delIndex - i]
            
            uuids.append(delPost.id)
            MyFileManager.deleteFile(filePath: delPost.photo)

            let post = Post(id: delPost.id, photo: delPost.photo, date: delPost.date, place: delPost.place, text: delPost.text, indexPhoto: delPost.indexPhoto, lastUpdated: delPost.lastUpdated)
            post.delete()

            posts.remove(at: delIndex - i)
        }

        guard let token = user.token else {
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
}
