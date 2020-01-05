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
        guard let url = NetworkURLS.createUserURL else {
            print("invalid create user url '\(String(describing: NetworkURLS.createUserURL))'"); return
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethods.post

        let jsonData: Data
        do {
            jsonData = try JSONEncoder().encode(newUser)
        } catch {
            fatalError()
        }

        request.httpBody = jsonData
        request.timeoutInterval = 5

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion?(nil, NetworkError(error.localizedDescription)); return
            }

            if let response = response as? HTTPURLResponse {
                let status = response.statusCode
                switch status {
                case HTTPCodes.okay:
                    break
                case HTTPCodes.alreadyExists:
                    completion?(nil, ErrorsNetwork.alreadyExists); return
                default:
                    completion?(nil, "unknown error: \(response.statusCode)"); return
                }
            }

            guard let data = data else {
                completion?(nil, ErrorsNetwork.noData); return
            }

            do {
                let user = try JSONDecoder().decode(JsonUserModel.self, from: data)
                completion?(user, nil)
            } catch let error {
                completion?(nil, NetworkError(error.localizedDescription))
            }
        }.resume()
    }

    func login(user: JsonUserModel, completion: ((JsonUserModel?, NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.loginUserURL else {
            print("invalid login url: '\(String(describing: NetworkURLS.loginUserURL))'"); return
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethods.post

        let jsonData = try? JSONEncoder().encode(user)

        request.httpBody = jsonData
        request.timeoutInterval = 5

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion?(nil, NetworkError(error.localizedDescription)); return
            }

            if let response = response as? HTTPURLResponse {
                let status = response.statusCode
                switch status {
                case HTTPCodes.okay:
                    break
                    // FIXME: 403, not 404
                case HTTPCodes.notFound:
                    completion?(nil, ErrorsNetwork.notFound); return
                default:
                    completion?(nil, "unknown status code: \(status)"); return
                }
            }

            guard let data = data else {
                completion?(nil, ErrorsNetwork.noData); return
            }

            do {
                let user = try JSONDecoder().decode(JsonUserModel.self, from: data)
                completion?(user, nil)
            } catch let error {
                completion?(nil, NetworkError(error.localizedDescription))
            }
        }.resume()
    }

    func update(user: JsonUserModel, completion: ((JsonError?, NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.updateUserURL else {
            print(HTTPCodes.notFound); return
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethods.put

        do {
            let jsonData = try JSONEncoder().encode(user)

            request.httpBody = jsonData
            request.timeoutInterval = 5

            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion?(nil, NetworkError(error.localizedDescription)); return
                }

                if let response = response as? HTTPURLResponse {
                    let status = response.statusCode
                    switch status {
                    case HTTPCodes.okay:
                        completion?(nil, nil); return
                    case HTTPCodes.unauthorized: completion?(nil, nil); return
                    case 404:
                        completion?(nil, ErrorsNetwork.notFound); return
                    default:
                        completion?(nil, "unknown status code: \(status)"); return
                    }
                }

                guard let data = data else {
                    completion?(nil, ErrorsNetwork.noData); return
                }

                do {
                    let errorJson = try JSONDecoder().decode(JsonError.self, from: data)
                    completion?(errorJson, nil)
                } catch let error {
                    completion?(nil, NetworkError(error.localizedDescription))
                }
            }.resume()
        } catch let error {
            print("error: \(error.localizedDescription)")
        }
    }

    func logout(user: JsonUserModel, completion: ((NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.deleteUserURL else {
            print(HTTPCodes.notFound); return
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethods.delete

        do {
            let jsonData = try JSONEncoder().encode(user)

            request.httpBody = jsonData
            request.timeoutInterval = 5

            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion?(NetworkError(error.localizedDescription)); return
                }

                if let response = response as? HTTPURLResponse {
                    let status = response.statusCode
                    switch status {
                    case HTTPCodes.okay:
                        completion?(nil); return
                    case 404:
                        completion?(ErrorsNetwork.notFound); return
                    default:
                        completion?("unknown status code: \(status)"); return
                    }
                }

                if data != nil {
                    completion?(nil); return
                } else {
                    completion?(ErrorsNetwork.noData); return
                }
            }.resume()
        } catch let error {
            print("error: \(error.localizedDescription)")
        }
    }
}
