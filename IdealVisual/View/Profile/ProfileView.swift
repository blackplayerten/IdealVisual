//
//  ProfileView.swift
//  IdealVisual
//
//  Created by a.kurganova on 03/10/2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import CoreData
import Foundation
import UIKit
import Photos

final class ProfileView: UIView {
    private var dataState = State()

    private weak var delegateProfile: ProfileDelegate?
    private var userViewModel: UserViewModelProtocol?

    private let scroll = UIScrollView()
    private var height: NSLayoutConstraint?

    private var username: InputFields
    private var email: InputFields
    private var password: InputFields
    private var repeatPassword: InputFields

    private var testAva = UIImagePickerController()
    private let ava = UIImageView()
    private var avaContent: Data? // for saving
    private var avaName: String?

    init(profileDelegate: ProfileDelegate) {
        self.delegateProfile = profileDelegate
        self.userViewModel = UserViewModel()
        self.username = InputFields()
        self.email = InputFields()
        self.password = InputFields()
        self.repeatPassword = InputFields()
        super.init(frame: CGRect())

        userViewModel?.get(completion: { (user, error) in
            DispatchQueue.main.async {
                if let error = error {
                    switch error {
                    case ErrorsUserViewModel.noData:
                        // TODO: ui
                        break
                    default:
                        print("undefined error: \(error)"); return
                    }
                }

                guard let user = user else {
                    return
                }

                self.username = InputFields(labelImage: UIImage(named: "login"),
                                                   text: user.username,
                                                   placeholder: nil, validator: checkValidUsername)
                self.email = InputFields(labelImage: UIImage(named: "email"),
                                                text: user.email,
                                                placeholder: nil, validator: checkValidEmail)
                self.password = InputFields(labelImage: UIImage(named: "password"),
                                                   text: nil, placeholder: "Пароль",
                                                   textContentType: .newPassword, validator: checkValidPassword)
                self.repeatPassword = InputFields(labelImage: UIImage(named: "password"),
                                                         text: nil, placeholder: "Повторите пароль",
                                                         textContentType: .newPassword, validator: checkValidPassword)
            }
        })
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

// MARK: - no edit mode
    private func setNoEdit() {
        testAva.delegate = self
        testAva.allowsEditing = true
        ava.isUserInteractionEnabled = false

        let swipe = UISwipeGestureRecognizer()
        swipe.direction = .up
        swipe.addTarget(self, action: #selector(closeProfile))
        self.addGestureRecognizer(swipe)

        setNavButtons()
        setAva()
        setFields()
        [username, email, password, repeatPassword].forEach {
            $0.setEditFields(state: false)
        }
        password.isHidden = true
        repeatPassword.isHidden = true
        renderBottomLine()
    }

// MARK: - edit mode
    @objc
    private func setEdit() {
        dataState.username = username.textField.text ?? ""
        dataState.email = email.textField.text ?? ""
        dataState.oldAva = ava.image

        height?.isActive = false
        setNavEditButtons()

        height = self.heightAnchor.constraint(equalToConstant: self.bounds.height + 155)
        height?.isActive = true

        let tap = UITapGestureRecognizer()
        ava.isUserInteractionEnabled = true
        ava.addGestureRecognizer(tap)
        tap.addTarget(self, action: #selector(chooseAva))

        [username, email, password, repeatPassword].forEach {
            $0.setEditFields(state: true)
        }
        setPassword()
    }

    @objc
    func closeProfile() {
        height?.isActive = false
        removeFromSuperview()
        delegateProfile?.enableTabBarButton()
    }

    @objc
    private func logout() {
        delegateProfile?.logOut()
    }

    @objc
    private func hide() {
        self.endEditing(true)
    }

// MARK: - save/not save settings
    @objc
    private func save_settings() {
        if dataState.email == email.textField.text &&
            dataState.username == username.textField.text &&
            dataState.oldAva == ava.image &&
            password.textField.text?.count == 0 &&
            repeatPassword.textField.text?.count == 0 {
            Logger.log("no changes")

            password.textField.text = ""
            password.clearState()
            repeatPassword.textField.text = ""
            repeatPassword.clearState()

            setupView()

            return
        }

        let usernameIsValid = username.isValid()
        let emailIsValid = email.isValid()
        var pairIsValid = true
        if password.textField.text?.count != 0 || repeatPassword.textField.text?.count != 0 {
            pairIsValid = checkValidPasswordPair(field: password, fieldRepeat: repeatPassword)
        }

        if !(usernameIsValid && emailIsValid && pairIsValid) {
            return
        }

        guard let usrInput = username.textField.text,
            let emlInput = email.textField.text,
            let pasInput = password.textField.text
        else { return }

        if usrInput == "" && emlInput == "" && pasInput == "" && avaContent == nil {
            return
        }

        userViewModel?.update(username: usrInput, email: emlInput, ava: avaContent, avaName: avaName,
                              password: pasInput, completion: { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    switch error {
//                    case ErrorsUserViewModel.alreadyExists:
                        // TODO: ui
//                        break
                    case ErrorsUserViewModel.notFound:
                        // TODO: ui
                        break
                    default:
                        print("undefined error: \(error)"); return
                    }
                }
            }
        })

        password.textField.text = ""
        password.clearState()
        repeatPassword.textField.text = ""
        repeatPassword.clearState()

        setupView()
    }

    @objc
    private func no_settings() {
        username.textField.text = dataState.username
        email.textField.text = dataState.email
        password.textField.text = ""
        repeatPassword.textField.text = ""

        username.clearState()
        email.clearState()
        password.clearState()
        repeatPassword.clearState()

        if let oldAvaImage = dataState.oldAva {
            ava.image = oldAvaImage
        }

        removeConstraint(height!)
        setupView()
    }
}

// MARK: - add view
extension ProfileView {
    func setup() {
        setupView()
    }

    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        let currentWindow: UIWindow? = UIApplication.shared.keyWindow
        currentWindow?.addSubview(self)
        self.widthAnchor.constraint(equalTo: (superview?.safeAreaLayoutGuide.widthAnchor)!).isActive = true
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.layer.cornerRadius = 20
        self.topAnchor.constraint(equalTo: (superview?.topAnchor)!).isActive = true
        self.leftAnchor.constraint(equalTo: (superview?.safeAreaLayoutGuide.leftAnchor)!).isActive = true
        self.backgroundColor = .white
        self.layer.shadowColor = Colors.darkDarkGray.cgColor
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 50.0
        height = self.heightAnchor.constraint(equalToConstant: 465)
        height?.isActive = true
        setNoEdit()
    }
}

// MARK: - scroll and keyboard
extension ProfileView {

}

// MARK: - nav
extension ProfileView {
    private func setNavButtons() {
        guard let markSettings = UIImage(named: "settings") else { return }
        let settings = SubstrateButton(image: markSettings, side: 33, target: self, action: #selector(setEdit),
                                       substrateColor: Colors.lightBlue)
        addSubview(settings)
        settings.translatesAutoresizingMaskIntoConstraints = false
        settings.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 7).isActive = true
        settings.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true

        guard let markLogout = UIImage(named: "logout") else { return }
        let substrateLogout = SubstrateButton(image: markLogout, side: 33, target: self, action: #selector(logout),
                                       substrateColor: Colors.darkGray)
        addSubview(substrateLogout)
        substrateLogout.translatesAutoresizingMaskIntoConstraints = false
        substrateLogout.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 7).isActive = true
        substrateLogout.rightAnchor.constraint(
            equalTo: self.safeAreaLayoutGuide.rightAnchor,
            constant: -20
        ).isActive = true
    }

    @objc
    private func setNavEditButtons() {
        guard let markYes = UIImage(named: "yes") else { return }
        let yes = SubstrateButton(image: markYes, side: 33, target: self, action: #selector(save_settings),
                                  substrateColor: Colors.yellow)
        addSubview(yes)
        yes.translatesAutoresizingMaskIntoConstraints = false
        yes.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 7).isActive = true
        yes.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true

        guard let markNo = UIImage(named: "close") else { return }
        let substrateNot = SubstrateButton(image: markNo, side: 33, target: self, action: #selector(no_settings),
                                 substrateColor: Colors.darkGray)
        addSubview(substrateNot)
        substrateNot.translatesAutoresizingMaskIntoConstraints = false
        substrateNot.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 7).isActive = true
        substrateNot.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
    }
}

// MARK: - set username, email
extension ProfileView {
    private func setFields() {
        [username, email].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 300).isActive = true
        }
        username.topAnchor.constraint(equalTo: ava.bottomAnchor, constant: 30).isActive = true
        email.topAnchor.constraint(equalTo: username.bottomAnchor, constant: 30).isActive = true
    }
}

// MARK: - passwords
extension ProfileView {
    private func setPassword() {
        [password, repeatPassword].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 300).isActive = true
            $0.isHidden = false
        }
        password.topAnchor.constraint(equalTo: email.bottomAnchor, constant: 30).isActive = true
        repeatPassword.topAnchor.constraint(equalTo: password.bottomAnchor, constant: 30).isActive = true
    }
}

// MARK: - ava
extension ProfileView {
    private func setAva() {
        addSubview(ava)
        ava.translatesAutoresizingMaskIntoConstraints = false
        ava.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        ava.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 33+30+7).isActive = true
        ava.widthAnchor.constraint(equalToConstant: 170).isActive = true
        ava.heightAnchor.constraint(equalToConstant: 170).isActive = true
        ava.contentMode = .scaleAspectFill
        ava.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner,
                                   .layerMinXMaxYCorner, .layerMinXMinYCorner]
        ava.layer.cornerRadius = 10
        ava.layer.masksToBounds = true

        userViewModel?.getAvatar(completion: { (avatar, error) in
            DispatchQueue.main.async {
                if let error = error {
                    switch error {
                    case ErrorsUserViewModel.noData:
                        // TODO: ui
                        break
                    case ErrorsUserViewModel.notFound:
                        // TODO: ui
                        break
                    default:
                        print("undefined error: \(error)"); return
                    }
                }

                guard let avatar = avatar else {
                    self.ava.image = UIImage(named: "default_profile")
                    return
                }
                self.ava.image = UIImage(contentsOfFile: avatar)
            }
        })
    }
}

// MARK: - picker
extension ProfileView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            if let selected = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                dataState.oldAva = ava.image
                ava.image = selected

                avaName = url.lastPathComponent
                avaContent = selected.jpegData(compressionQuality: 1.0)
            }
        }
        delegateProfile?.dismissAlert()
    }

    @objc private func chooseAva() {
        let alert = UIAlertController(title: "Выберите изображение",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Галерея",
                                      style: .default,
                                      handler: { _ in { self.testAva.sourceType = .photoLibrary
                                                        self.delegateProfile?.chooseAvatar(picker: self.testAva) }() }
            ))
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            alert.addAction(UIAlertAction(title: "Камера",
                                          style: .default,
                                          handler: { _ in { self.testAva.sourceType = .camera
                                                            self.testAva.cameraCaptureMode = .photo
                                                            self.delegateProfile?.chooseAvatar(picker: self.testAva)
                                            }() }
            ))
        }
        alert.addAction(UIAlertAction(title: "Отменить", style: UIAlertAction.Style.cancel, handler: nil))
        delegateProfile?.showAlert(alert: alert)
    }
}

// MARK: - bottom line
extension ProfileView {
    private func renderBottomLine() {
        let lineBottom = LineClose()
        addSubview(lineBottom)
        lineBottom.translatesAutoresizingMaskIntoConstraints = false
        lineBottom.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
        lineBottom.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: -23).isActive = true
    }
}
