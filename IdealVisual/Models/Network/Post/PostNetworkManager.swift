//
//  PostNetworkManager.swift
//  IdealVisual
//
//  Created by a.kurganova on 01.01.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation

final class PostNetworkManager: PostNetworkManagerProtocol {
    func create(post: JsonPostModel, completion: ((NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.postsURL else {
            print("invalid posts url '\(String(describing: NetworkURLS.postsURL))'"); return
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethods.post

        let jsonData: Data
        do {
            jsonData = try JSONEncoder().encode(post)
        } catch {
            fatalError()
        }

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
                    break
                case HTTPCodes.unauthorized:
                    completion?(ErrorsNetwork.unauthorized); return
                default:
                    completion?("unknown error: \(response.statusCode)"); return
                }
            }

            guard let data = data else {
                completion?(ErrorsNetwork.noData); return
            }

            do {
                _ = try JSONDecoder().decode(JsonPostModel.self, from: data)
                completion?(nil)
            } catch let error {
                completion?(NetworkError(error.localizedDescription))
            }
        }.resume()
    }

    func get(completion: (([JsonPostModel]?, NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.postsURL else {
            print("invalid posts url '\(String(describing: NetworkURLS.postsURL))'"); return
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethods.get

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion?(nil, NetworkError(error.localizedDescription)); return
            }

            if let response = response as? HTTPURLResponse {
                let status = response.statusCode
                switch status {
                case HTTPCodes.okay:
                    break
                case HTTPCodes.unauthorized:
                    completion?(nil, ErrorsNetwork.unauthorized); return
                default:
                    completion?(nil, "unknown error: \(response.statusCode)"); return
                }
            }

            guard let data = data else {
                completion?(nil, ErrorsNetwork.noData); return
            }

            do {
                let posts = try JSONDecoder().decode([JsonPostModel].self, from: data)
                completion?(posts, nil)
            } catch let error {
                completion?(nil, NetworkError(error.localizedDescription))
            }
        }.resume()
    }

    func update(post: JsonPostModel, completion: ((NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.postsURL else {
            print("invalid posts url '\(String(describing: NetworkURLS.postsURL))'"); return
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethods.put

        let jsonData: Data
        do {
            jsonData = try JSONEncoder().encode(post)
        } catch {
            fatalError()
        }

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
                    break
                case HTTPCodes.unauthorized:
                    completion?(ErrorsNetwork.unauthorized); return
                default:
                    completion?("unknown error: \(response.statusCode)"); return
                }
            }

            if data != nil {
                completion?(nil)
            } else {
                completion?(ErrorsNetwork.noData); return
            }
        }.resume()
    }

    func delete(ids: [UUID], completion: ((NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.postsURL else {
            print(HTTPCodes.notFound); return
        }
        var c = URLComponents(url: url, resolvingAgainstBaseURL: true)
        for id in ids {
            c?.queryItems = [URLQueryItem(name: "id", value: id.uuidString)]
        }
        var request = URLRequest(url: c!.url!)
        request.httpMethod = HTTPMethods.delete
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
                case HTTPCodes.notFound:
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
    }
}
