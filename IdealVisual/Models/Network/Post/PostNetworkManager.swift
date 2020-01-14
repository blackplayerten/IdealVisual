//
//  PostNetworkManager.swift
//  IdealVisual
//
//  Created by a.kurganova on 01.01.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation
import Alamofire

final class PostNetworkManager: PostNetworkManagerProtocol {
    func create(token: String, post: JsonPostModel, completion: ((JsonPostModel?, NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.postsURL else {
            Logger.log("invalid posts url: \(String(describing: NetworkURLS.postsURL))")
            return
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        AF.request(url, method: .post, parameters: post, encoder: JSONParameterEncoder(encoder: encoder),
                   headers: [.accept(MimeTypes.appJSON), .authorization(bearerToken: token)])
            .validate(contentType: [MimeTypes.appJSON])
            .responseDecodable(of: JsonPostModel.self, decoder: decoder) { response in
                if let error = response.error {
                    if let status = response.response?.statusCode {
                        switch status {
                        case HTTPCodes.unauthorized:
                            completion?(nil, NetworkError(name: ErrorsNetwork.unauthorized))
                        case HTTPCodes.notFound:
                            completion?(nil, NetworkError(name: ErrorsNetwork.notFound))
                        default:
                            Logger.log("unknown status: \(status)")
                            completion?(nil, NetworkError(name: "unknown status: \(status)"))
                        }
                        return
                    }

                    Logger.log("unknown error: \(error.localizedDescription)")
                    completion?(nil, NetworkError(name: error.localizedDescription))
                    return
                }

                guard let post = response.value else {
                    Logger.log("error data: \(ErrorsNetwork.noData)")
                    completion?(nil, NetworkError(name: ErrorsNetwork.noData))
                    return
                }
                completion?(post, nil)
        }.resume()
    }

    func get(token: String, completion: (([JsonPostModel]?, NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.postsURL else {
            Logger.log("invalid posts url: \(String(describing: NetworkURLS.postsURL))")
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        AF.request(url, method: .get, headers: [.accept(MimeTypes.appJSON), .authorization(bearerToken: token)])
            .validate(contentType: [MimeTypes.appJSON])
            .responseDecodable(of: [JsonPostModel].self, decoder: decoder) { response in
                if let error = response.error {
                    if let status = response.response?.statusCode {
                        switch status {
                        case HTTPCodes.unauthorized:
                            completion?(nil, NetworkError(name: ErrorsNetwork.unauthorized))
                        default:
                            Logger.log("unknown status code: \(status)")
                            completion?(nil, NetworkError(name: "unknown status code: \(status)"))
                        }
                        return
                    }

                    Logger.log("unknown error: \(error.localizedDescription)")
                    completion?(nil, NetworkError(name: error.localizedDescription))
                    return
                }

                guard let posts = response.value else {
                    Logger.log("error data: \(ErrorsNetwork.noData)")
                    completion?(nil, NetworkError(name: ErrorsNetwork.noData))
                    return
                }
                completion?(posts, nil)
        }.resume()
    }

    func update(token: String, post: JsonPostModel, completion: ((JsonPostModel?, NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.postsURL else {
            Logger.log("invalid posts url: \(String(describing: NetworkURLS.postsURL))")
            return
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        AF.request(url, method: .put, parameters: post, encoder: JSONParameterEncoder(encoder: encoder),
                   headers: [.accept(MimeTypes.appJSON), .authorization(bearerToken: token)])
            .validate(contentType: [MimeTypes.appJSON])
            .responseDecodable(of: JsonPostModel.self, decoder: decoder) { response in
                if let error = response.error {
                    if let status = response.response?.statusCode {
                        switch status {
                        case HTTPCodes.unauthorized:
                            completion?(nil, NetworkError(name: ErrorsNetwork.unauthorized))
                        case HTTPCodes.notFound:
                            completion?(nil, NetworkError(name: ErrorsNetwork.notFound))
                        default:
                            Logger.log("unknown status: \(status)")
                            completion?(nil, NetworkError(name: "unknown status: \(status)"))
                        }
                        return
                    }

                    Logger.log("unknown error: \(error.localizedDescription)")
                    completion?(nil, NetworkError(name: error.localizedDescription))
                    return
                }

                guard let post = response.value else {
                    Logger.log("error data: \(ErrorsNetwork.noData)")
                    completion?(nil, NetworkError(name: ErrorsNetwork.noData))
                    return
                }
                completion?(post, nil)
        }.resume()
    }

    func delete(token: String, ids: [UUID], completion: ((NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.postsURL else {
            Logger.log("invalid post url: \(String(describing: NetworkURLS.postsURL))")
            return
        }

        let encoder = URLEncodedFormParameterEncoder(encoder: URLEncodedFormEncoder(arrayEncoding: .noBrackets))
        AF.request(url, method: .delete, parameters: ["id": ids.map { $0.uuidString }], encoder: encoder,
                   headers: [.accept(MimeTypes.appJSON), .authorization(bearerToken: token)])
            .validate(contentType: [MimeTypes.appJSON]).response { response in
                if let error = response.error {
                    if let status = response.response?.statusCode {
                        switch status {
                        case HTTPCodes.unauthorized:
                            completion?(NetworkError(name: ErrorsNetwork.unauthorized))
                        default:
                            Logger.log("unknown status: \(status)")
                            completion?(NetworkError(name: "unknown status: \(status)"))
                        }
                        return
                    }

                    Logger.log("unknown error: \(error.localizedDescription)")
                    completion?(NetworkError(name: error.localizedDescription))
                    return
                }

                completion?(nil)
        }.resume()
    }
}
