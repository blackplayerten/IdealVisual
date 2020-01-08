//
//  UserNetworkManager.swift
//  IdealVisual
//
//  Created by a.kurganova on 24.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation

final class UserNetworkManager: UserNetworkManagerProtocol {
    func create(newUser: JsonUserModel, completion: ((JsonUserModel?, NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.accountURL else {
            Logger.log("invalid create url: '\(String(describing: NetworkURLS.accountURL))'")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethods.post
        request.addValue(MimeTypes.appJSON, forHTTPHeaderField: HTTPHeaders.contentType)

        let jsonData: Data
        do {
            jsonData = try JSONEncoder().encode(newUser)
        } catch {
            Logger.log("can't encode data")
            completion?(nil, NetworkError(name: ErrorsNetwork.noData))
            return
        }

        request.httpBody = jsonData
        request.timeoutInterval = 5

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                Logger.log("unknown error: \(error.localizedDescription)")
                completion?(nil, NetworkError(name: error.localizedDescription))
                return
            }

            if let response = response as? HTTPURLResponse {
                let status = response.statusCode
                switch status {
                case HTTPCodes.okay:
                    break
                case HTTPCodes.unprocessableEntity:
                    guard let data = data else {
                        completion?(nil, NetworkError(name: ErrorsNetwork.noData))
                        return
                    }
                    do {
                        let errors = try JSONDecoder().decode(JsonError.self, from: data)
                        completion?(nil, NetworkError(name: ErrorsNetwork.wrongFields, description: errors.errors))
                    } catch let error {
                        Logger.log("unknown network error: \(error.localizedDescription)")
                        completion?(nil, NetworkError(name: error.localizedDescription))
                    }
                    return
                default:
                    Logger.log("unknown staus code: \(status))")
                    completion?(nil, NetworkError(name: "unknown status code: \(status)"))
                    return
                }
            }

            guard let data = data else {
                completion?(nil, NetworkError(name: ErrorsNetwork.noData))
                return
            }

            do {
                let user = try JSONDecoder().decode(JsonUserModel.self, from: data)
                completion?(user, nil)
            } catch let error {
                Logger.log("unknown network error: \(error.localizedDescription)")
                completion?(nil, NetworkError(name: error.localizedDescription))
            }
        }.resume()
    }

    func login(user: JsonUserModel, completion: ((JsonUserModel?, NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.sessionURL else {
            Logger.log("invalid login url: '\(String(describing: NetworkURLS.sessionURL))'")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethods.post
        request.addValue(MimeTypes.appJSON, forHTTPHeaderField: HTTPHeaders.contentType)

        let jsonData = try? JSONEncoder().encode(user)

        request.httpBody = jsonData
        request.timeoutInterval = 5

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                Logger.log("unknown network error: \(error.localizedDescription)")
                completion?(nil, NetworkError(name: error.localizedDescription))
                return
            }

            if let response = response as? HTTPURLResponse {
                let status = response.statusCode
                switch status {
                case HTTPCodes.okay:
                    break
                case HTTPCodes.forbidden:
                    completion?(nil, NetworkError(name: ErrorsNetwork.forbidden))
                    return
                default:
                    Logger.log("unknown staus code: \(status))")
                    completion?(nil, NetworkError(name: "unknown status code: \(status)"))
                    return
                }
            }

            guard let data = data else {
                Logger.log("data error: \(ErrorsNetwork.noData)")
                completion?(nil, NetworkError(name: ErrorsNetwork.noData))
                return
            }

            do {
                let user = try JSONDecoder().decode(JsonUserModel.self, from: data)
                completion?(user, nil)
            } catch let error {
                Logger.log("unknown network error: \(error.localizedDescription)")
                completion?(nil, NetworkError(name: error.localizedDescription))
            }
        }.resume()
    }

    func update(token: String, user: JsonUserModel, completion: ((JsonUserModel?, NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.accountURL else {
            Logger.log("invalid update url: '\(String(describing: NetworkURLS.accountURL))'")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethods.put
        request.addValue(Authorization.getBearerToken(token: token), forHTTPHeaderField: HTTPHeaders.authorization)
        request.addValue(MimeTypes.appJSON, forHTTPHeaderField: HTTPHeaders.contentType)

        do {
            let jsonData = try JSONEncoder().encode(user)

            request.httpBody = jsonData
            request.timeoutInterval = 5

            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    Logger.log("unknown network error: \(error.localizedDescription)")
                    completion?(nil, NetworkError(name: error.localizedDescription))
                    return
                }

                if let response = response as? HTTPURLResponse {
                    let status = response.statusCode
                    switch status {
                    case HTTPCodes.okay:
                        break
                    case HTTPCodes.unauthorized:
                        completion?(nil, NetworkError(name: ErrorsNetwork.unauthorized))
                        return
                    case HTTPCodes.notFound:
                        completion?(nil, NetworkError(name: ErrorsNetwork.notFound))
                        return
                    case HTTPCodes.unprocessableEntity:
                        guard let data = data else {
                            Logger.log("data error: \(ErrorsNetwork.noData)")
                            completion?(nil, NetworkError(name: ErrorsNetwork.noData))
                            return
                        }
                        do {
                            let errors = try JSONDecoder().decode(JsonError.self, from: data)
                            completion?(nil, NetworkError(name: ErrorsNetwork.wrongFields,
                                                          description: errors.errors))
                        } catch let error {
                            Logger.log("unknown network error: \(error.localizedDescription)")
                            completion?(nil, NetworkError(name: error.localizedDescription))
                        }
                        return
                    default:
                        Logger.log("unknown staus code: \(response.statusCode))")
                        completion?(nil, NetworkError(name: "unknown status code: \(status)"))
                        return
                    }
                }

                guard let data = data else {
                    Logger.log("data error: \(ErrorsNetwork.noData)")
                    completion?(nil, NetworkError(name: ErrorsNetwork.noData))
                    return
                }

                do {
                    let user = try JSONDecoder().decode(JsonUserModel.self, from: data)
                    completion?(user, nil)
                } catch let error {
                    Logger.log("unknown network error: \(error.localizedDescription)")
                    completion?(nil, NetworkError(name: error.localizedDescription))
                }
            }.resume()
        } catch let error {
            Logger.log("unknown network error: \(error.localizedDescription)")
            completion?(nil, NetworkError(name: error.localizedDescription))
        }
    }

    func logout(token: String, completion: ((NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.sessionURL else {
            Logger.log("invalid login url: '\(String(describing: NetworkURLS.sessionURL))'")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethods.delete
        request.addValue(Authorization.getBearerToken(token: token), forHTTPHeaderField: HTTPHeaders.authorization)

        request.timeoutInterval = 5

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                Logger.log("unknown network error: \(error.localizedDescription)")
                completion?(NetworkError(name: error.localizedDescription))
                return
            }

            if let response = response as? HTTPURLResponse {
                let status = response.statusCode
                switch status {
                case HTTPCodes.okay:
                    completion?(nil)
                default:
                    Logger.log("unknown status code: \(status)")
                    completion?(NetworkError(name: "unknown status code: \(status)"))
                }
                return
            }

            if data != nil {
                completion?(nil)
            } else {
                Logger.log("data error: \(ErrorsNetwork.noData)")
                completion?(NetworkError(name: ErrorsNetwork.noData))
            }
        }.resume()
    }
}
