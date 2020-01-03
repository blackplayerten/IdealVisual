//
//  UserViewModel.swift
//  IdealVisual
//
//  Created by a.kurganova on 24.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

final class UserViewModel: UserViewModelProtocol {
    private var userCoreData: UserCoreDataProtocol
    private var userNetworkManager: UserNetworkManagerProtocol
    private var photoNetworkManager: PhotoNetworkManagerProtocol
    var user: User?

    init() {
        self.userCoreData = UserCoreData()
        self.userNetworkManager = UserNetworkManager()
        self.photoNetworkManager = PhotoNetworkManager()
    }

    // MARK: - create
    func create(username: String, email: String, password: String,
                completion: ((ErrorViewModel?) -> Void)?) {
        userNetworkManager.create(newUser: JsonUserModel(usernameStr: username, emailStr: email,
                                                         password: password), completion: { (user, error) in
                if let error = error {
                    switch error {
                    case ErrorsNetwork.alreadyExists:
                        completion?(ErrorsUserViewModel.alreadyExists); return
                    case ErrorsNetwork.notFound:
                        completion?(ErrorsUserViewModel.notFound); return
                    default:
                        print("undefined user error: \(error)"); return
                    }
                }

                guard let user = user else {
                    completion?(ErrorsUserViewModel.noData); return
                }

                _ = self.userCoreData.create(token: user.token, username: user.usernameStr,
                                             email: user.emailStr, ava: user.ava)
                completion?(nil)
        })
    }

    // MARK: - login
    func login(username: String, password: String, completion: ((ErrorViewModel?) -> Void)?) {
        userNetworkManager.login(user: JsonUserModel(usernameStr: username, password: password),
                                     completion: { (user, error) in
            if let error = error {
                switch error {
                case ErrorsNetwork.alreadyExists:
                    completion?(ErrorsUserViewModel.alreadyExists); return
                case ErrorsNetwork.notFound:
                    completion?(ErrorsUserViewModel.notFound); return
                case ErrorsNetwork.unauthorized:
                    completion?(ErrorsUserViewModel.unauthorized); return
                default:
                    print("undefined user error: \(error)"); return
                }
            }

            guard var user = user else {
                completion?(ErrorsUserViewModel.noData); return
            }

            if user.ava != "" {
                self.photoNetworkManager.get(path: user.ava, completion: { (data, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            switch error {
                            case ErrorsNetwork.notFound:
                                // assume user nas no ava, so we will log in with data without it
                                user.ava = ""
                            default:
                                print("undefined user error: \(error)"); return
                            }
                        }

                        if let data = data {
                            let savedAva = saveFile(data: data, filePath: user.ava)
                            guard let ava = savedAva else {
                                completion?(ErrorsUserViewModel.filesystemSave)
                                return
                            }
                            user.ava = ava.path
                        } else {
                            completion?(ErrorsUserViewModel.noData)
                            return
                        }
                    }
                })
            }

            _ = self.userCoreData.create(token: user.token, username: user.usernameStr,
                                         email: user.emailStr, ava: user.ava)
            completion?(nil)
        })
    }

    // MARK: - get from core data
    func get(completion: ((User?, ErrorViewModel?) -> Void)?) {
        guard let user = self.userCoreData.get() else {
            completion?(nil, ErrorsUserViewModel.noData); return
        }

        self.user = user
        completion?(user, nil)
    }

    // MARK: - get avatar from core data
    func getAvatar(completion: ((String?, ErrorViewModel?) -> Void)?) {
        if user == nil {
            get(completion: { (user, error) in
                if let error = error {
                    switch error {
                    case ErrorsNetwork.notFound:
                        completion?(nil, ErrorsUserViewModel.notFound)
                    default:
                        let undef = "undefined user error: \(error)"
                        print(undef)
                        completion?(nil, ErrorViewModel(undef))
                    }
                    return
                }

                self.user = user
            })
        }

        if var avaUsr = user!.ava {
            if avaUsr != "" {
                avaUsr = resolveAbsoluteFilePath(filePath: avaUsr).path
                completion?(avaUsr, nil)
                return
            }
        }
        completion?(nil, nil)
    }

    // MARK: - update
    func update(username: String?, email: String?, ava: Data?, avaName: String?, password: String?,
                completion: ((ErrorViewModel?) -> Void)?) {
        if username == nil && email == nil && ava == nil && password == nil {
            completion?(ErrorsUserViewModel.noData)
            return
        }

        var avaPath: String?
        if let ava = ava {
            if let avaName = avaName {
                avaPath = "avatars/" + avaName
                _ = saveFile(data: ava, filePath: avaPath!)
            }
        }
        // update in core data first, then upload to server, because we want offline first
        userCoreData.update(username: username, email: email, avatar: avaPath)

        if let ava = ava {
            photoNetworkManager.upload(data: ava, completion: { (uploadedPath, error) in
                if let error = error {
                    switch error {
                    case ErrorsNetwork.notFound:
                        completion?(ErrorsUserViewModel.notFound); return
                    default:
                        print("undefined user error: \(error)"); return
                    }
                }

                guard let uploadedPath = uploadedPath else {
                    return
                }

                avaPath = uploadedPath
            })
        }

        userNetworkManager.update(user: JsonUserModel(usernameStr: username ?? "", emailStr: email ?? "",
                                                      password: password ?? "", ava: avaPath ?? ""),
                                  completion: { (user, error) in
            if let error = error {
                switch error {
                case ErrorsNetwork.notFound:
                    completion?(ErrorsUserViewModel.notFound); return
                default:
                    print("undefined user error: \(error)"); return
                }
            }
            if user != nil {
                completion?(nil)
            } else {
                completion?(ErrorsUserViewModel.noData); return
            }
        })
    }

    // MARK: - delete
    func logout(completion: ((ErrorViewModel?) -> Void)?) {
        var token: String?
        if let tok = user?.token {
            token = tok
        } else {
            get(completion: { (user, error) in
                if let error = error {
                    switch error {
                    case ErrorsNetwork.notFound:
                        completion?(ErrorsUserViewModel.notFound); return
                    default:
                        print("undefined user error: \(error)"); return
                    }
                }
                guard let user = user else {
                    completion?(ErrorsUserViewModel.noData); return
                }
                token = user.token ?? ""
            })
        }

        guard let utoken = token else {
            return
        }

        userNetworkManager.logout(user: JsonUserModel(token: utoken), completion: { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    switch error {
                    case ErrorsNetwork.notFound:
                        completion?(ErrorsUserViewModel.notFound); return
                    default:
                        print("undefined user error: \(error)"); return
                    }
                }
            }
        })

        userCoreData.delete()
        completion?(nil)
    }
}
