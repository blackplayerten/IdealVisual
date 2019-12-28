//
//  PhotoNetworkManager.swift
//  IdealVisual
//
//  Created by a.kurganova on 26.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation

final class PhotoNetworkManager: PhotoNetworkManagerProtocol {
    func getPhoto(path: String, completion: ((Data?, NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.staticURL?.appendingPathComponent(path) else {
            print("invalid static url '\(String(describing: NetworkURLS.staticURL))' and append path '\(path)'"); return
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethods.post

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
                case HTTPCodes.notFound:
                    completion?(nil, ErrorsNetwork.notFound); return
                default:
                    completion?(nil, "unknown status code: \(status)"); return
                }
            }

            guard let data = data else {
                completion?(nil, ErrorsNetwork.noData); return
            }
            completion?(data, nil)
        }.resume()
    }

    func upload(data: Data, completion: ((String?, NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.upload else {
            print("invalid static url '\(String(describing: NetworkURLS.upload))'"); return
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethods.post

        request.timeoutInterval = 5

        request.httpBody = data

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion?(nil, NetworkError(error.localizedDescription)); return
            }

            if let response = response as? HTTPURLResponse {
                let status = response.statusCode
                switch status {
                case HTTPCodes.okay:
                    break
                case HTTPCodes.notFound:
                    completion?(nil, ErrorsNetwork.notFound); return
                default:
                    completion?(nil, "unknown status code: \(status)"); return
                }
            }

            guard let data = data else {
                completion?(nil, ErrorsNetwork.noData); return
            }

            struct UploadedTo: Decodable {
                var path: String
            }

            var uploadedPath: String?
            do {
                let tmp = try JSONDecoder().decode(UploadedTo.self, from: data)
                if tmp.path != "" {
                    uploadedPath = tmp.path
                }
            } catch let error {
                completion?(nil, NetworkError(error.localizedDescription))
            }
            completion?(uploadedPath, nil)
        }.resume()
    }
}
