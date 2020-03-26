//
//  UserNetworkManager.swift
//  IdealVisual
//
//  Created by a.kurganova on 24.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import Alamofire

final class UserNetworkManager: UserNetworkManagerProtocol {
    func create(newUser: JsonUserModel, completion: ((JsonUserModel?, NetworkErr?) -> Void)?) {
        guard let url = NetworkURLS.accountURL else {
            Logger.log("invalid create url: '\(String(describing: NetworkURLS.accountURL))'")
            return
        }

        AF.request(url, method: .post, parameters: newUser, encoder: JSONParameterEncoder(encoder: JSONEncoder()),
                   headers: [.accept(MimeTypes.appJSON)])
            .validate(contentType: [MimeTypes.appJSON])
            .responseData { response in
                if let error = response.error {
                    if let err = error.underlyingError as? URLError, err.code == URLError.Code.notConnectedToInternet {
                        completion?(nil, NetworkErr.noConnection)
                    } else {
                        Logger.log("unknown error: \(error.localizedDescription)")
                        completion?(nil, NetworkErr.unknown)
                    }
                    return
                }

                if let status = response.response?.statusCode {
                    switch status {
                    case HTTPCodes.okay:
                        break
                    case HTTPCodes.unprocessableEntity:
                        guard let data = response.value else {
                            completion?(nil, NetworkErr.noData)
                            return
                        }
                        do {
                            let errors = try JSONDecoder().decode(JsonError.self, from: data)
                            completion?(nil, NetworkErr.wrongFields(
                                WrongFieldsNetworkEror(name: "wrongFields", description: errors.errors)))
                        } catch let error {
                            Logger.log("unknown network error: \(error.localizedDescription)")
                            completion?(nil, NetworkErr.unknown)
                        }
                        return
                    default:
                        Logger.log("unknown status code: \(status))")
                        completion?(nil, NetworkErr.unknown)
                        return
                    }
                }

                guard let data = response.value else {
                    completion?(nil, NetworkErr.noData)
                    return
                }

                do {
                    let user = try JSONDecoder().decode(JsonUserModel.self, from: data)
                    completion?(user, nil)
                } catch let error {
                    Logger.log("unknown network error: \(error.localizedDescription)")
                    completion?(nil, NetworkErr.unknown)
                }
        }.resume()
    }

    func login(user: JsonUserModel, completion: ((JsonUserModel?, NetworkErr?) -> Void)?) {
        guard let url = NetworkURLS.sessionURL else {
            Logger.log("invalid login url: '\(String(describing: NetworkURLS.sessionURL))'")
            return
        }

        AF.request(url, method: .post, parameters: user, encoder: JSONParameterEncoder(encoder: JSONEncoder()),
                   headers: [.accept(MimeTypes.appJSON)])
            .validate(contentType: [MimeTypes.appJSON])
            .responseDecodable(of: JsonUserModel.self) { response in
                if let error = response.error {
                    if let status = response.response?.statusCode {
                        switch status {
                        case HTTPCodes.forbidden:
                            completion?(nil, NetworkErr.forbidden)
                        default:
                            Logger.log("unknown staus code: \(status))")
                            completion?(nil, NetworkErr.unknown)
                        }
                        return
                    }

                    if let err = error.underlyingError as? URLError, err.code == URLError.Code.notConnectedToInternet {
                        completion?(nil, NetworkErr.noConnection)
                    } else {
                        Logger.log("unknown error: \(error.localizedDescription)")
                        completion?(nil, NetworkErr.unknown)
                    }
                    return
                }

                guard let user = response.value else {
                    Logger.log("error data")
                    completion?(nil, NetworkErr.noData)
                    return
                }
                completion?(user, nil)
        }.resume()
    }

    func update(token: String, user: JsonUserModel, completion: ((JsonUserModel?, NetworkErr?) -> Void)?) {
        guard let url = NetworkURLS.accountURL else {
            Logger.log("invalid update url: '\(String(describing: NetworkURLS.accountURL))'")
            return
        }

        AF.request(url, method: .put, parameters: user, encoder: JSONParameterEncoder(encoder: JSONEncoder()),
                   headers: [.accept(MimeTypes.appJSON), .authorization(bearerToken: token)])
            .validate(contentType: [MimeTypes.appJSON])
            .responseData { response in
                if let error = response.error {
                    if let status = response.response?.statusCode {
                        switch status {
                        case HTTPCodes.unauthorized:
                            completion?(nil, NetworkErr.unauthorized)
                            return
                        case HTTPCodes.notFound:
                            completion?(nil, NetworkErr.notFound)
                            return
                        default:
                            Logger.log("unknown staus code: \(status))")
                            completion?(nil, NetworkErr.unknown)
                            return
                        }
                    }

                    if let err = error.underlyingError as? URLError, err.code == URLError.Code.notConnectedToInternet {
                        completion?(nil, NetworkErr.noConnection)
                    } else {
                        Logger.log("unknown error: \(error.localizedDescription)")
                        completion?(nil, NetworkErr.unknown)
                    }
                    return
                }

                if let status = response.response?.statusCode {
                    switch status {
                    case HTTPCodes.okay:
                        break
                    case HTTPCodes.unprocessableEntity:
                        guard let data = response.value else {
                            Logger.log("error data")
                            completion?(nil, NetworkErr.noData)
                            return
                        }
                        do {
                            let errors = try JSONDecoder().decode(JsonError.self, from: data)
                            completion?(nil, NetworkErr.wrongFields(
                                WrongFieldsNetworkEror(name: "wrongFields", description: errors.errors)))
                        } catch let error {
                            Logger.log("unknown network error: \(error.localizedDescription)")
                            completion?(nil, NetworkErr.unknown)
                        }
                        return
                    default:
                        Logger.log("unknown staus code: \(status))")
                        completion?(nil, NetworkErr.unknown)
                        return
                    }
                }

                guard let data = response.value else {
                    Logger.log("error data")
                    completion?(nil, NetworkErr.noData)
                    return
                }

                do {
                    let user = try JSONDecoder().decode(JsonUserModel.self, from: data)
                    completion?(user, nil)
                } catch let error {
                    Logger.log("unknown network error: \(error.localizedDescription)")
                    completion?(nil, NetworkErr.unknown)
                }
        }.resume()
    }

    func logout(token: String, completion: ((NetworkErr?) -> Void)?) {
        guard let url = NetworkURLS.sessionURL else {
            Logger.log("invalid login url: '\(String(describing: NetworkURLS.sessionURL))'")
            return
        }

        AF.request(url, method: .delete, headers: [.authorization(bearerToken: token)])
            .response { response in
                if let error = response.error {
                    if let err = error.underlyingError as? URLError, err.code == URLError.Code.notConnectedToInternet {
                        completion?(NetworkErr.noConnection)
                    } else {
                        Logger.log("unknown error: \(error.localizedDescription)")
                        completion?(NetworkErr.unknown)
                    }
                    return
                }

                if let status = response.response?.statusCode {
                    switch status {
                    case HTTPCodes.okay:
                        completion?(nil)
                    default:
                        Logger.log("unknown status code: \(status)")
                        completion?(NetworkErr.unknown)
                    }
                }
        }.resume()
    }
}
