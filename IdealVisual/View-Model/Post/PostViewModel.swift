import Foundation
import CoreData

final class PostViewModel: iPostWork {
    private var user: User
    private var postNetworkManager: PostNetworkManagerProtocol

    private weak var delegatePosts: PostChangedDelegate?

    init(delegat: PostChangedDelegate?) {
        self.user = User()
        self.user.get()
        self.delegatePosts = delegat
        self.postNetworkManager = PostNetworkManager()
    }

    private func convertDBModelToJSON(post: Post) -> JsonPostModel {
        return JsonPostModel(
            id: post.id,
            photo: post.photo,
            photoIndex: Int64(post.indexPhoto),
            date: post.date ?? Date(timeIntervalSince1970: 0),
            place: post.place ?? "",
            text: post.text ?? "",
            lastUpdated: post.lastUpdated ?? Date(timeIntervalSince1970: 0)
        )
    }

    func getPhoto(path: String) -> String {
        return MyFileManager.resolveAbsoluteFilePath(filePath: path).path
    }

    func update(post: Post,
                date: Date? = nil, place: String? = nil, text: String? = nil,
                completion: ((PostViewModelErrors?) -> Void)?) {
        do {
            if let date = date {
                post.date = date
            }
            if let place = place {
                post.place = place
            }
            if let text = text {
                post.text = text
            }
            post.update()
        } catch {
            completion?(PostViewModelErrors.unknown)
        }
        guard let token = user.token else {
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
}
