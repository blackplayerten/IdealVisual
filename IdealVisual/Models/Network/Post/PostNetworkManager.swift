//
//  PostNetworkManager.swift
//  IdealVisual
//
//  Created by a.kurganova on 01.01.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation

final class PostNetworkManager: PostNetworkManagerProtocol {
    func create(token: String, post: JsonPostModel, completion: ((JsonPostModel?, NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.postsURL else {
            Logger.log("invalid posts url: \(String(describing: NetworkURLS.postsURL))")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethods.post
        request.addValue(Authorization.getBearerToken(token: token), forHTTPHeaderField: HTTPHeaders.authorization)
        request.addValue(MimeTypes.appJSON, forHTTPHeaderField: HTTPHeaders.contentType)

        let jsonData: Data
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            jsonData = try encoder.encode(post)
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
                case HTTPCodes.unauthorized:
                    completion?(nil, NetworkError(name: ErrorsNetwork.unauthorized))
                    return
                case HTTPCodes.notFound:
                    completion?(nil, NetworkError(name: ErrorsNetwork.notFound))
                    return
                default:
                    Logger.log("unknown status: \(status)")
                    completion?(nil, NetworkError(name: "unknown status: \(status)"))
                    return
                }
            }

            guard let data = data else {
                Logger.log("error data: \(ErrorsNetwork.noData)")
                completion?(nil, NetworkError(name: ErrorsNetwork.noData))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let post  = try decoder.decode(JsonPostModel.self, from: data)
                completion?(post, nil)
            } catch let error {
                Logger.log("unknown error: \(error.localizedDescription)")
                completion?(nil, NetworkError(name: error.localizedDescription))
            }
        }.resume()
    }

    func get(token: String, completion: (([JsonPostModel]?, NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.postsURL else {
            Logger.log("invalid posts url: \(String(describing: NetworkURLS.postsURL))")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethods.get
        request.addValue(Authorization.getBearerToken(token: token), forHTTPHeaderField: HTTPHeaders.authorization)

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
                case HTTPCodes.unauthorized:
                    completion?(nil, NetworkError(name: ErrorsNetwork.unauthorized))
                    return
                default:
                    Logger.log("unknown status code: \(status)")
                    completion?(nil, NetworkError(name: "unknown status code: \(status)"))
                    return
                }
            }

            guard let data = data else {
                Logger.log("error data: \(ErrorsNetwork.noData)")
                completion?(nil, NetworkError(name: ErrorsNetwork.noData))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let posts = try decoder.decode([JsonPostModel].self, from: data)
                completion?(posts, nil)
            } catch let error {
                Logger.log("unknown error: \(error.localizedDescription)")
                completion?(nil, NetworkError(name: error.localizedDescription))
            }
        }.resume()
    }

    func update(token: String, post: JsonPostModel, completion: ((JsonPostModel?, NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.postsURL else {
            Logger.log("invalid posts url: \(String(describing: NetworkURLS.postsURL))")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethods.put
        request.addValue(Authorization.getBearerToken(token: token), forHTTPHeaderField: HTTPHeaders.authorization)
        request.addValue(MimeTypes.appJSON, forHTTPHeaderField: HTTPHeaders.contentType)

        let jsonData: Data
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            jsonData = try encoder.encode(post)
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
                case HTTPCodes.unauthorized:
                    completion?(nil, NetworkError(name: ErrorsNetwork.unauthorized))
                    return
                case HTTPCodes.notFound:
                    completion?(nil, NetworkError(name: ErrorsNetwork.notFound))
                    return
                default:
                    Logger.log("unknown status code: \(status)")
                    completion?(nil, NetworkError(name: "unknown status code: \(status)"))
                    return
                }
            }

            guard let data = data else {
                Logger.log("error data: \(ErrorsNetwork.noData)")
                completion?(nil, NetworkError(name: ErrorsNetwork.noData))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let post  = try decoder.decode(JsonPostModel.self, from: data)
                completion?(post, nil)
            } catch let error {
                Logger.log("unknown error: \(error.localizedDescription)")
                completion?(nil, NetworkError(name: error.localizedDescription))
            }
        }.resume()
    }

    func delete(token: String, ids: [UUID], completion: ((NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.postsURL else {
            Logger.log("invalid post url: \(String(describing: NetworkURLS.postsURL))")
            return
        }
        var c = URLComponents(url: url, resolvingAgainstBaseURL: true)
        var queryids = [URLQueryItem]()
        for id in ids {
            queryids.append(URLQueryItem(name: "id", value: id.uuidString))
        }
        c?.queryItems = queryids
        var request = URLRequest(url: c!.url!)
        request.httpMethod = HTTPMethods.delete
        request.addValue(Authorization.getBearerToken(token: token), forHTTPHeaderField: HTTPHeaders.authorization)
        request.timeoutInterval = 5

        URLSession.shared.dataTask(with: request) { (_, response, error) in
            if let error = error {
                Logger.log("unknown error: \(error.localizedDescription)")
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
            }
        }.resume()
    }
}
