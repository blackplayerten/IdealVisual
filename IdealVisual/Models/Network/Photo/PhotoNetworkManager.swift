//
//  PhotoNetworkManager.swift
//  IdealVisual
//
//  Created by a.kurganova on 26.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import Alamofire

final class PhotoNetworkManager: PhotoNetworkManagerProtocol {
    func get(path: String, completion: ((Data?, NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.staticURL?.appendingPathComponent(path) else {
            Logger.log("invalid static url '\(String(describing: NetworkURLS.staticURL))' and append path '\(path)'")
            completion?(nil, NetworkError.noData)
            return
        }

        AF.download(url).responseData { response in
            if let error = response.error {
                if let status = response.response?.statusCode {
                    switch status {
                    case HTTPCodes.notFound:
                        completion?(nil, NetworkError.notFound)
                        return
                    default:
                        Logger.log("unknown status code: \(status)")
                        completion?(nil, NetworkError.unknown)
                        return
                    }
                }

                Logger.log("unknown error: \(error.localizedDescription)")
                completion?(nil, NetworkError.unknown)
                return
            }

            if let status = response.response?.statusCode {
                switch status {
                case HTTPCodes.okay:
                    break
                case HTTPCodes.notFound:
                    completion?(nil, NetworkError.notFound)
                    return
                default:
                    Logger.log("unknown status code: \(status)")
                    completion?(nil, NetworkError.unknown)
                    return
                }
            }

            guard let data = response.value else {
                Logger.log("data error: \(NetworkError.noData)")
                completion?(nil, NetworkError.noData)
                return
            }
            completion?(data, nil)
        }.resume()
    }

    func upload(token: String, data: Data, name: String, completion: ((String?, NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.upload else {
            Logger.log("invalid static url: \(String(describing: NetworkURLS.upload))")
            completion?(nil, NetworkError.noData)
            return
        }

        let mimeType = MimeTypes.getFromExtension(ext: URL(fileURLWithPath: name).pathExtension)

        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(data, withName: "file", fileName: name, mimeType: mimeType)
        }, to: url, headers: [.authorization(bearerToken: token)])
            .responseDecodable(of: JsonUploadedPhotoTo.self) { response in
                if let error = response.error {
                    if let status = response.response?.statusCode {
                        switch status {
                        case HTTPCodes.unauthorized:
                            completion?(nil, NetworkError.unauthorized)
                            return
                        default:
                            Logger.log("unknown status code: \(status)")
                            completion?(nil, NetworkError.unknown)
                            return
                        }
                    }

                    Logger.log("unknown error: \(error.localizedDescription)")
                    completion?(nil, NetworkError.unknown)
                    return
                }

                guard let uploadedPath = response.value else {
                    Logger.log("data error: \(NetworkError.noData)")
                    completion?(nil, NetworkError.noData)
                    return
                }
                completion?(uploadedPath.path, nil)
        }.resume()
    }
}
