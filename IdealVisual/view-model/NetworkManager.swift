//
//  Network.swift
//  IdealVisual
//
//  Created by a.kurganova on 13.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

typealias ResponseError = String

final class NetworkManager {
    static func createUser(newUser: JsonUserModel, completion: ((JsonUserModel?, ResponseError?) -> Void)?) {
        let urlStr = "http://127.0.0.1:8080/signup"
        guard let url = URL(string: urlStr) else {
            fatalError("invalid url: \(urlStr)")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(newUser)
            request.httpBody = jsonData
            request.timeoutInterval = 5

            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("error localized: \(error.localizedDescription)")
                    completion?(nil, ResponseError(error.localizedDescription))
                    return
                }

                if let response = response as? HTTPURLResponse {
                    let status = response.statusCode
                    print("response code: \(status)")
                    switch status {
                    case 200:
                        break
                    case 409:
                        completion?(nil, "User already exists")
                        return
                    default:
                        completion?(nil, "Unknown error: \(response.statusCode)")
                        return
                    }
                }

                guard let data = data else {
                    print("no data")
                    completion?(nil, "Server returned no data")
                    return
                }

                let decoder = JSONDecoder()

                do {
                    let user = try decoder.decode(JsonUserModel.self, from: data)
                    completion?(user, nil)
                } catch let error {
                    print("error localized: \(error.localizedDescription)")
                    completion?(nil, "Cannot encode JSON: \(error.localizedDescription)")
                }
            }.resume()
        } catch let error {
            print("error localized: \(error.localizedDescription)")
            completion?(nil, "Error while request processing: \(error.localizedDescription)")
        }
    }

    static func getPhotos(complition: (([JsonPostModel]?) -> Void)?) {
        let urlStr = "json/photos/from/back"
        guard let url = URL(string: urlStr) else {
            fatalError("invalid url: \(urlStr)")
        }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("error localized: \(error.localizedDescription)")
                complition?(nil)
                return
            }

            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200..<300:
                    print("status code: \(response.statusCode), work")
                case 300..<400:
                    print("status code: \(response.statusCode), redirect")
                case 400..<500:
                    print("status code: \(response.statusCode), client")
                case 500..<526:
                print("status code: \(response.statusCode), server")
                default:
                    print("status code: \(response.statusCode)")
                }
            }

            guard let data = data else {
                print("no data")
                complition?(nil)
                return
            }

            do {
                // decode information from json
                let posts = try JSONDecoder().decode([JsonPostModel].self, from: data)
                complition?(posts)
            } catch let error {
                print("error localized: \(error.localizedDescription)")
                complition?(nil)
            }
        }.resume()
    }
}
