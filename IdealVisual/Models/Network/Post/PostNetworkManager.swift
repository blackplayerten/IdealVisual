//
//  PostNetworkManager.swift
//  IdealVisual
//
//  Created by a.kurganova on 01.01.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

final class PostNetworkManager: PostNetworkManagerProtocol {
    func create(token: String, post: JsonPostModel) -> Promise<JsonPostModel> {
        guard let url = NetworkURLS.postsURL else {
            Logger.log("invalid posts url: \(String(describing: NetworkURLS.postsURL))")
            return Promise<JsonPostModel> { seal in seal.reject(NetworkError(name: "bug"))}
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return Promise<JsonPostModel> { seal in
            AF.request(url, method: .post, parameters: post, encoder: JSONParameterEncoder(encoder: encoder),
                   headers: [.accept(MimeTypes.appJSON), .authorization(bearerToken: token)])
                .validate(contentType: [MimeTypes.appJSON])
                .responseDecodable(of: JsonPostModel.self, decoder: decoder) { response in
                    if let error = response.error {
                        if let status = response.response?.statusCode {
                            switch status {
                            case HTTPCodes.unauthorized:
                                return seal.reject(NetworkError(name: ErrorsNetwork.unauthorized))
                            case HTTPCodes.notFound:
                                return seal.reject(NetworkError(name: ErrorsNetwork.notFound))
                            default:
                                Logger.log("unknown status: \(status)")
                                return seal.reject(NetworkError(name: "unknown status: \(status)"))
                            }
                        }

                        if let err = error.underlyingError as? URLError,
                            err.code == URLError.Code.notConnectedToInternet {
                            return seal.reject(NetworkError(name: ErrorsNetwork.noConnection))
                        } else {
                            Logger.log("unknown error: \(error.localizedDescription)")
                            return seal.reject(NetworkError(name: error.localizedDescription))
                        }
                    }

                    guard let post = response.value else {
                        Logger.log("error data: \(ErrorsNetwork.noData)")
                        return seal.reject(NetworkError(name: ErrorsNetwork.noData))
                    }
                return seal.fulfill(post)
            }
        }
    }

    func get(token: String) -> Promise<[JsonPostModel]> {
        guard let url = NetworkURLS.postsURL else {
            Logger.log("invalid posts url: \(String(describing: NetworkURLS.postsURL))")
            return Promise<[JsonPostModel]> { seal in return seal.reject(NetworkError(name: "bug"))}
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return Promise<[JsonPostModel]> { seal in
            AF.request(url, method: .get, headers: [.accept(MimeTypes.appJSON), .authorization(bearerToken: token)])
                .validate(contentType: [MimeTypes.appJSON])
                .responseDecodable(of: [JsonPostModel].self, decoder: decoder) { response in
                    if let error = response.error {
                        if let status = response.response?.statusCode {
                            switch status {
                            case HTTPCodes.unauthorized:
                                return seal.reject(NetworkError(name: ErrorsNetwork.unauthorized))
                            default:
                                Logger.log("unknown status code: \(status)")
                                return seal.reject(NetworkError(name: "unknown status code: \(status)"))
                            }
                        }

                        if let err = error.underlyingError as? URLError,
                            err.code == URLError.Code.notConnectedToInternet {
                            return seal.reject(NetworkError(name: ErrorsNetwork.noConnection))
                        } else {
                            Logger.log("unknown error: \(error.localizedDescription)")
                            return seal.reject(NetworkError(name: error.localizedDescription))
                        }
                    }

                    guard let posts = response.value else {
                        Logger.log("error data: \(ErrorsNetwork.noData)")
                        return seal.reject(NetworkError(name: ErrorsNetwork.noData))
                    }
                return seal.fulfill(posts)
            }
        }
    }

    func update(token: String, post: JsonPostModel) -> Promise<JsonPostModel> {
        guard let url = NetworkURLS.postsURL else {
            Logger.log("invalid posts url: \(String(describing: NetworkURLS.postsURL))")
            return Promise<JsonPostModel> { seal in seal.reject(NetworkError(name: "bug"))}
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return Promise<JsonPostModel> { seal in
            AF.request(url, method: .put, parameters: post, encoder: JSONParameterEncoder(encoder: encoder),
                   headers: [.accept(MimeTypes.appJSON), .authorization(bearerToken: token)])
                .validate(contentType: [MimeTypes.appJSON])
                .responseDecodable(of: JsonPostModel.self, decoder: decoder) { response in
                    if let error = response.error {
                        if let status = response.response?.statusCode {
                            switch status {
                            case HTTPCodes.unauthorized:
                                return seal.reject(NetworkError(name: ErrorsNetwork.unauthorized))
                            case HTTPCodes.notFound:
                                return seal.reject(NetworkError(name: ErrorsNetwork.notFound))
                            default:
                                Logger.log("unknown status: \(status)")
                                return seal.reject(NetworkError(name: "unknown status: \(status)"))
                            }
                        }

                        if let err = error.underlyingError as? URLError,
                            err.code == URLError.Code.notConnectedToInternet {
                            return seal.reject(NetworkError(name: ErrorsNetwork.noConnection))
                        } else {
                            Logger.log("unknown error: \(error.localizedDescription)")
                            return seal.reject(NetworkError(name: error.localizedDescription))
                        }
                    }

                    guard let post = response.value else {
                        Logger.log("error data: \(ErrorsNetwork.noData)")
                        return seal.reject(NetworkError(name: ErrorsNetwork.noData))
                    }
                return seal.fulfill(post)
            }
        }
    }

    func delete(token: String, ids: [UUID]) -> Promise<NetworkError> {
        guard let url = NetworkURLS.postsURL else {
            Logger.log("invalid post url: \(String(describing: NetworkURLS.postsURL))")
            return Promise<NetworkError> { seal in seal.reject(NetworkError(name: "bug"))}
        }

        let encoder = URLEncodedFormParameterEncoder(encoder: URLEncodedFormEncoder(arrayEncoding: .noBrackets))

        return Promise<NetworkError> { seal in
            AF.request(url, method: .delete, parameters: ["id": ids.map { $0.uuidString }], encoder: encoder,
                   headers: [.accept(MimeTypes.appJSON), .authorization(bearerToken: token)])
            .validate(contentType: [MimeTypes.appJSON]).response { response in
                if let error = response.error {
                    if let status = response.response?.statusCode {
                        switch status {
                        case HTTPCodes.unauthorized:
                            return seal.reject(NetworkError(name: ErrorsNetwork.unauthorized))
                        default:
                            Logger.log("unknown status: \(status)")
                            return seal.reject(NetworkError(name: "unknown status: \(status)"))
                        }
                    }

                    if let err = error.underlyingError as? URLError, err.code == URLError.Code.notConnectedToInternet {
                        return seal.reject(NetworkError(name: ErrorsNetwork.noConnection))
                    } else {
                        Logger.log("unknown error: \(error.localizedDescription)")
                        return seal.reject(NetworkError(name: error.localizedDescription))
                    }
                }
            }
        }
    }
}
