//
//  UserViewModel.swift
//  IdealVisual
//
//  Created by a.kurganova on 24.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

final class UserViewModel: UserViewModelProtocol {
    private var userCoreData: UserCoreDataProtocol
    private var userNetworkManager: UserNetworkManagerProtocol
    private var photoNetworkManager: PhotoNetworkManagerProtocol
    var user: User?

    private let avaFolder = "avatars/"

    init() {
        self.userCoreData = UserCoreData()
        self.user = userCoreData.get() // try to get user, if he is logged in
        self.userNetworkManager = UserNetworkManager()
        self.photoNetworkManager = PhotoNetworkManager()
    }

    // MARK: - create
    func create(username: String, email: String, password: String,
                completion: ((UserViewModelErrors?) -> Void)?) {
        userNetworkManager.create(newUser: JsonUserModel(username: username, email: email,
                                                         password: password), completion: { (user, error) in
                if let error = error {
                    switch error {
                    case .wrongFields:
                        self.processWrongFields(error: error, completion: completion)
                    case .noConnection:
                        completion?(UserViewModelErrors.noConnection)
                    default:
                        Logger.log("unknown error: \(error)")
                        completion?(UserViewModelErrors.unknown)
                    }
                    return
                }

                guard let user = user else {
                    completion?(UserViewModelErrors.noData)
                    return
                }
                guard let token = user.token else {
                    Logger.log("got nil token from server, unauthorized")
                    completion?(UserViewModelErrors.unauthorized)
                    return
                }

                _ = self.userCoreData.create(token: token, username: user.username,
                                             email: user.email, ava: user.avatar)
                completion?(nil)
        })
    }

    // MARK: - login
    func login(email: String, password: String, completion: ((UserViewModelErrors?) -> Void)?) {
        userNetworkManager.login(user: JsonUserModel(email: email, password: password),
                                     completion: { (user, error) in
            if let error = error {
                switch error {
                case .forbidden:
                    completion?(UserViewModelErrors.wrongCredentials)
                case .noConnection:
                    completion?(UserViewModelErrors.noConnection)
                default:
                    Logger.log("unknown error: \(error)")
                    completion?(UserViewModelErrors.unknown)
                }
                return
            }

            guard var user = user else {
                Logger.log("data error: \(UserViewModelErrors.noData)")
                completion?(UserViewModelErrors.noData)
                return
            }

            guard let token = user.token else {
                Logger.log("got nil token from server, unauthorized")
                completion?(UserViewModelErrors.unauthorized)
                return
            }

            if let ava = user.avatar {
                if ava != "" {
                    firstly {
                        self.photoNetworkManager.get(path: ava)
                    }.done { (data: Data) in
                        let avaPath = self.avaFolder + ava
                        guard MyFileManager.saveFile(data: data, filePath: avaPath) != nil else {
                            // FIXME: надо ли возвращать ошибку?
                            return
                        }
                        user.avatar = avaPath

                        let user = self.userCoreData.create(token: token, username: user.username,
                                                            email: user.email, ava: user.avatar)
                        self.user = user
                    }.catch { (error) in
                        Logger.log(error)
                        switch error as? NetworkErr {
                        case .noData:
                            Logger.log("data error")
                            completion?(UserViewModelErrors.noData)
                        default:
                            Logger.log("cannot create core data user")
                            completion?(UserViewModelErrors.unknown)
                        }
                    }

//                    self.photoNetworkManager.get(path: ava, completion: { (data, error) in
//                        DispatchQueue.main.async {
//                            if let error = error {
//                                switch error.name {
//                                case ErrorsNetwork.notFound:
//                                    // assume user nas no ava, so we will log in with data without it
//                                    user.avatar = ""
//                                default:
//                                    Logger.log("cannot get avatar: \(error)")
//                                    completion?(ErrorsUserViewModel.unknownError)
//                                }
//                                return
//                            }
//
//                            if let data = data {
//                                let avaPath = self.avaFolder + ava
//                                guard MyFileManager.saveFile(data: data, filePath: avaPath) != nil else {
//                                    completion?(ErrorsUserViewModel.filesystemSave)
//                                    return
//                                }
//                                user.avatar = avaPath
//                            } else {
//                                Logger.log("data error: \(ErrorsUserViewModel.noData)")
//                                completion?(ErrorsUserViewModel.noData)
//                                return
//                            }
//
//                            guard let user = self.userCoreData.create(token: token, username: user.username,
//                                                                      email: user.email, ava: user.avatar)
//                            else {
//                                Logger.log("cannot create core data user")
//                                completion?(ErrorsUserViewModel.unknownError)
//                                return
//                            }
//                            self.user = user
//                            completion?(nil)
//                        }
//                    })
                }
            } else {
                guard let user = self.userCoreData.create(token: token, username: user.username,
                                                          email: user.email, ava: user.avatar)
                else {
                    completion?(UserViewModelErrors.unknown)
                    return
                }
                self.user = user
                completion?(nil)
            }
        })
    }

    // MARK: - get from core data
    func get(completion: ((User?, UserViewModelErrors?) -> Void)?) {
        if user != nil {
            completion?(user, nil)
            return
        }

        guard let user = self.userCoreData.get() else {
            Logger.log("data error")
            completion?(nil, UserViewModelErrors.noData)
            return
        }

        self.user = user
        completion?(user, nil)
    }

    // MARK: - get avatar from core data
    func getAvatar(completion: ((String?, UserViewModelErrors?) -> Void)?) {
        if var avaUsr = user!.ava {
            if avaUsr != "" {
                avaUsr = MyFileManager.resolveAbsoluteFilePath(filePath: avaUsr).path
                completion?(avaUsr, nil)
                return
            }
        }
        completion?(nil, nil)
    }

    // MARK: - update
    func update(username: String?, email: String?, ava: Data?, avaName: String?, password: String?,
                completion: ((UserViewModelErrors?) -> Void)?) {
        if username == nil && email == nil && ava == nil && password == nil {
            Logger.log("data error: \(UserViewModelErrors.noData)")
            completion?(UserViewModelErrors.noData)
            return
        }

        var avaPath: String?
        if let ava = ava {
            if let avaName = avaName {
                avaPath = self.avaFolder + avaName
                _ = MyFileManager.saveFile(data: ava, filePath: avaPath!)
            }
        }
        // update in core data first, then upload to server, because we want offline first
        userCoreData.update(username: username, email: email, avatar: avaPath)

        guard let token = user?.token else {
            Logger.log("token in coredata is nil")
            completion?(UserViewModelErrors.unauthorized)
            return
        }

        let updateServerInfo = {
            self.userNetworkManager.update(token: token,
                                            user: JsonUserModel(username: username ?? "", email: email ?? "",
                                                                password: password ?? "", avatar: avaPath ?? ""),
                                            completion: { (user, error) in
                if let error = error {
                    switch error {
                    case .wrongFields:
                        self.processWrongFields(error: error, completion: completion)
                    case .unauthorized:
                        completion?(UserViewModelErrors.unauthorized)
                    case .notFound:
                        completion?(UserViewModelErrors.notFound)
                    case .noConnection:
                        completion?(UserViewModelErrors.noConnection)
                    default:
                        Logger.log("unknown")
                        completion?(UserViewModelErrors.unknown)
                    }
                    return
                }

                if user != nil {
                    completion?(nil)
                } else {
                    Logger.log("no data")
                    completion?(UserViewModelErrors.noData)
                }
            })
        }

        if let ava = ava {
            if let avaName = avaName {
                firstly {
                    self.photoNetworkManager.upload(token: token, data: ava, name: avaName)
                }.done { (uploadedPath: String) in
                    avaPath = uploadedPath
                    updateServerInfo()
                }.catch { (error) in
                    Logger.log(error)
                }

//                photoNetworkManager.upload(token: token, data: ava, name: avaName,
//                                           completion: { (uploadedPath, error) in
//                    if let error = error {
//                        switch error.name {
//                        case ErrorsNetwork.notFound:
//                            completion?(ErrorsUserViewModel.notFound)
//                        default:
//                            Logger.log("unknown error: \(error)")
//                            completion?(ErrorsUserViewModel.unknownError)
//                        }
//                        return
//                    }
//
//                    guard let uploadedPath = uploadedPath else { return }
//
//                    avaPath = uploadedPath
//
//                    updateServerInfo()
//                })
            }
        } else {
            updateServerInfo()
        }
    }

    // MARK: - delete
    func logout(completion: ((UserViewModelErrors?) -> Void)?) {
        guard let token = user?.token else {
            Logger.log("token in coredata is nil")
            completion?(UserViewModelErrors.unauthorized)
            return
        }

        self.userNetworkManager.logout(token: token, completion: { (error) in
            if let error = error {
                switch error {
                case .noConnection:
                    completion?(UserViewModelErrors.noConnection)
                default:
                    Logger.log("unknown error: \(error)")
                    completion?(UserViewModelErrors.unknown)
                }
                return
            }

            self.userCoreData.delete()
            MyFileManager.deleteDirectoriesFromAppDirectory()
            completion?(nil)
        })
    }

    private func processWrongFields(error: NetworkErr, completion: ((UserViewModelErrors?) -> Void)?) {
        let fieldErrors: [JsonFieldError]
        switch error {
        case .wrongFields(let st):
            guard let flEr = st.description as? [JsonFieldError] else {
                Logger.log("unknown error")
                completion?(UserViewModelErrors.unknown)
                return
            }
            fieldErrors = flEr
        default:
            Logger.log("unexpected network error")
            return
        }
//        guard let fieldErrors = error.description as? [JsonFieldError] else {
//            Logger.log("unknown fields")
//            completion?(UserViewModelErrors.unknown)
//            return
//        }

        fieldErrors.forEach { (err) in
            switch err.field {
            case SignUpInFields.username:
                err.reasons.forEach { (reason) in
                    switch reason {
                    case SignUpInReasons.alreadyExists:
                        completion?(UserViewModelErrors.usernameAlreadyExists)
                    case SignUpInReasons.wrongLength:
                        completion?(UserViewModelErrors.usernameLengthIsWrong)
                    default:
                        Logger.log("unknown error: \(error)")
                        completion?(UserViewModelErrors.unknown)
                    }
                }
            case SignUpInFields.email:
                err.reasons.forEach { (reason) in
                    switch reason {
                    case SignUpInReasons.alreadyExists:
                        completion?(UserViewModelErrors.emailAlreadyExists)
                    case SignUpInReasons.wrongEmail:
                        completion?(UserViewModelErrors.emailFormatIsWrong)
                    default:
                        Logger.log("unknown error: \(error)")
                        completion?(UserViewModelErrors.unknown)
                    }
                }
            case SignUpInFields.password:
                err.reasons.forEach { (reason) in
                    switch reason {
                    case SignUpInReasons.wrongLength:
                        completion?(UserViewModelErrors.passwordLengthIsWrong)
                    default:
                        Logger.log("unknown error: \(error)")
                        completion?(UserViewModelErrors.unknown)
                    }
                }
            default:
                Logger.log("error field: \(err.field)")
                completion?(UserViewModelErrors.unknown)
            }
        }
    }
}
