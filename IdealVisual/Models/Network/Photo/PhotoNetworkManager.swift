//
//  PhotoNetworkManager.swift
//  IdealVisual
//
//  Created by a.kurganova on 26.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

final class PhotoNetworkManager: PhotoNetworkManagerProtocol {
    func get(path: String) -> Promise<Data> {
        guard let url = NetworkURLS.staticURL?.appendingPathComponent(path) else {
            Logger.log("invalid static url '\(String(describing: NetworkURLS.staticURL))' and append path '\(path)'")
            return Promise<Data> { seal in seal.reject(NetworkError(name: "bug")) }
        }

        return Promise<Data> { seal in
            AF.download(url).responseData { response in
                if let error = response.error {
                    if let status = response.response?.statusCode {
                        switch status {
                        case HTTPCodes.notFound:
                            return seal.reject(NetworkError(name: ErrorsNetwork.notFound))
                        default:
                            Logger.log("unknown status code: \(status)")
                            return seal.reject(NetworkError(name: "unknown status code: \(status)"))
                        }
                    }

                    Logger.log("unknown error: \(error.localizedDescription)")
                    return seal.reject(NetworkError(name: error.localizedDescription))
                }

                if let status = response.response?.statusCode {
                    switch status {
                    case HTTPCodes.okay:
                        break
                    case HTTPCodes.notFound:
                        return seal.reject(NetworkError(name: ErrorsNetwork.notFound))
                    default:
                        Logger.log("unknown status code: \(status)")
                        return seal.reject(NetworkError(name: "unknown status code: \(status)"))
                    }
                }

                guard let data = response.value else {
                    Logger.log("data error: \(ErrorsNetwork.noData)")
                    return seal.reject(NetworkError(name: ErrorsNetwork.noData))
                }
                return seal.fulfill(data)
            }
        }
    }

    func upload(token: String, data: Data, name: String) -> Promise<String> {
        guard let url = NetworkURLS.upload else {
            Logger.log("invalid static url: \(String(describing: NetworkURLS.upload))")
            return Promise<String> { seal in seal.reject(NetworkError(name: "bug")) }
        }

        let mimeType = MimeTypes.getFromExtension(ext: URL(fileURLWithPath: name).pathExtension)

        return Promise<String> { seal in
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(data, withName: "file", fileName: name, mimeType: mimeType)
            }, to: url, headers: [.authorization(bearerToken: token)])
            .responseDecodable(of: JsonUploadedPhotoTo.self) { response in
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

                    Logger.log("unknown error: \(error.localizedDescription)")
                    return seal.reject(NetworkError(name: error.localizedDescription))
                }

                guard let uploadedPath = response.value else {
                    Logger.log("data error: \(ErrorsNetwork.noData)")
                    return seal.reject(NetworkError(name: ErrorsNetwork.noData))
                }
                return seal.fulfill(uploadedPath.path)
            }
        }
    }
}
