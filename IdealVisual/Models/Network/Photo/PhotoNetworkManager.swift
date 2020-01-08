//
//  PhotoNetworkManager.swift
//  IdealVisual
//
//  Created by a.kurganova on 26.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation

final class PhotoNetworkManager: PhotoNetworkManagerProtocol {
    func get(path: String, completion: ((Data?, NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.staticURL?.appendingPathComponent(path) else {
            Logger.log("invalid static url '\(String(describing: NetworkURLS.staticURL))' and append path '\(path)'")
            completion?(nil, NetworkError(name: ErrorsNetwork.noData))
            return
        }

        var request = URLRequest(url: url)
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
                Logger.log("data error: \(ErrorsNetwork.noData)")
                completion?(nil, NetworkError(name: ErrorsNetwork.noData))
                return
            }
            completion?(data, nil)
        }.resume()
    }

    func upload(token: String, data: Data, name: String, completion: ((String?, NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.upload else {
            Logger.log("invalid static url: \(String(describing: NetworkURLS.upload))")
            completion?(nil, NetworkError(name: ErrorsNetwork.noData))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethods.post
        request.addValue(Authorization.getBearerToken(token: token), forHTTPHeaderField: HTTPHeaders.authorization)

        request.timeoutInterval = 5

        let boundary = UUID().uuidString
        request.setValue(MultipartFormData.getContentTypeValue(boundary: boundary),
                         forHTTPHeaderField: HTTPHeaders.contentType)

        let body = MultipartFormData.createBody(parameters: [String: String](),
                                                boundary: boundary,
                                                data: data,
                                                mimeType: URL(fileURLWithPath: name).pathExtension,
                                                filename: name)

        request.httpBody = body

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
                Logger.log("data error: \(ErrorsNetwork.noData)")
                completion?(nil, NetworkError(name: ErrorsNetwork.noData))
                return
            }

            var uploadedPath: String?
            do {
                let tmp = try JSONDecoder().decode(JsonUploadedPhotoTo.self, from: data)
                if tmp.path != "" {
                    uploadedPath = tmp.path
                }
            } catch let error {
                Logger.log("unknown  error: \(error.localizedDescription)")
                completion?(nil, NetworkError(name: error.localizedDescription))
            }
            completion?(uploadedPath, nil)
        }.resume()
    }
}
