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

final class ProfileView: UIView, InputFieldDelegate {
    private var dataState = State()

    private weak var delegateProfile: ProfileDelegate?
    private var userViewModel: UserViewModelProtocol?

    private let scroll: UIScrollView = UIScrollView()
    private var navBar: UIView? = UIView()

    private var height: NSLayoutConstraint?

    private var username: InputFields
    private var email: InputFields
    private var password: InputFields
    private var repeatPassword: InputFields
    private var activeField: InputFields?

    private var settings: SubstrateButton?
    private var substrateLogout: SubstrateButton?
    private var yes: SubstrateButton?
    private var substrateNot: SubstrateButton?

    private var testAva: UIImagePickerController = UIImagePickerController()
    private let ava: UIImageView = UIImageView()
    private var avaContent: Data? // for saving
    private var avaName: String?

    // MARK: - init
    init(profileDelegate: ProfileDelegate) {
        // MARK: text fields
        self.delegateProfile = profileDelegate
        self.userViewModel = UserViewModel()
        self.username = InputFields(tag: 0)
        self.email = InputFields(tag: 1)
        self.password = InputFields(tag: 2)
        self.repeatPassword = InputFields(tag: 3)
        super.init(frame: CGRect())

        // MARK: nav bar
        guard let nav = navBar else {
            Logger.log("no navigation bar in profile")
            return
        }
        addSubview(nav)
        nav.translatesAutoresizingMaskIntoConstraints = false
        nav.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        nav.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        nav.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        nav.heightAnchor.constraint(equalToConstant: 45).isActive = true

        // MARK: nav bar buttons
        guard let markSettings = UIImage(named: "settings") else { return }
        self.settings = SubstrateButton(image: markSettings, side: 33, target: self, action: #selector(setEdit),
                                       substrateColor: Colors.lightBlue)

        guard let markLogout = UIImage(named: "logout") else { return }
        self.substrateLogout = SubstrateButton(image: markLogout, side: 33, target: self,
                                              action: #selector(logout), substrateColor: Colors.darkGray)

        guard let markYes = UIImage(named: "yes") else { return }
        self.yes = SubstrateButton(image: markYes, side: 33, target: self, action: #selector(save_settings),
                                  substrateColor: Colors.yellow)

        guard let markNo = UIImage(named: "close") else { return }
        self.substrateNot = SubstrateButton(image: markNo, side: 33, target: self, action: #selector(no_settings),
                                           substrateColor: Colors.darkGray)

        // MARK: user settings view-model
        userViewModel?.get(completion: { [weak self] (user, error) in
            DispatchQueue.main.async {
                if let error = error {
                    switch error {
                    case .noData:
                        Logger.log(error)
                        self?._error(text: "Упс, что-то пошло не так.")
                    default:
                        Logger.log(error)
                        self?._error(text: "Упс, что-то пошло не так.")
                    }
                }

                guard let user = user else {
                    return
                }

                self?.username = InputFields(tag: 0, labelImage: UIImage(named: "login"),
                                                   text: user.username, placeholder: nil,
                                                   validator: checkValidUsername, inputDelegate: self)
                self?.email = InputFields(tag: 1, labelImage: UIImage(named: "email"),
                                                text: user.email, placeholder: nil,
                                                validator: checkValidEmail, inputDelegate: self)
                self?.password = InputFields(tag: 2, labelImage: UIImage(named: "password"), text: nil,
                                             placeholder: "Пароль", textContentType: .newPassword,
                                             validator: checkValidPassword, inputDelegate: self)
                self?.repeatPassword = InputFields(tag: 3, labelImage: UIImage(named: "password"),
                                                   text: nil, placeholder: "Повторите пароль",
                                                   textContentType: .newPassword, validator: checkValidPassword,
                                                   inputDelegate: self)
            }
        })
    }

    // MARK: - setup view
    func setup() {
        setupView()
    }

    private func setupView() {
        guard let superview = superview else {
            Logger.log("no superview")
            return
        }

        self.translatesAutoresizingMaskIntoConstraints = false
        let currentWindow: UIWindow? = UIApplication.shared.keyWindow
        currentWindow?.addSubview(self)

        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.layer.cornerRadius = 20
        self.backgroundColor = .white
        self.layer.shadowColor = Colors.darkGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        self.layer.shadowOpacity = 50.0
        self.layer.shadowRadius = 1.0
        self.layer.masksToBounds = false

        let paddingtop = UIApplication.shared.windows.first?.safeAreaInsets.top
        self.topAnchor.constraint(equalTo: superview.topAnchor, constant: paddingtop ?? 0).isActive = true
        self.widthAnchor.constraint(equalToConstant: superview.frame.width).isActive = true

        height = self.heightAnchor.constraint(equalToConstant: 420)

        guard let _height = height else {
            Logger.log("no height")
            return
        }
        _height.isActive = true

        guard let navigationBar = navBar else {
            Logger.log("no navigation bar")
            return
        }

        addSubview(scroll)
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.topAnchor.constraint(equalTo: navigationBar.bottomAnchor).isActive = true
        scroll.widthAnchor.constraint(equalToConstant: superview.frame.width).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true

        let hideKey: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(taped))
        scroll.addGestureRecognizer(hideKey)

        setNoEdit()

        dataState.username = username.textField.text ?? ""
        dataState.email = email.textField.text ?? ""
        dataState.oldAva = ava.image

        NotificationCenter.default.addObserver(self,
                selector: #selector(keyboardWillShow(_:)),
                name: UIResponder.keyboardWillShowNotification,
                object: nil)
        NotificationCenter.default.addObserver(self,
                selector: #selector(keyboardWillHide(_:)),
                name: UIResponder.keyboardWillHideNotification,
                object: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }



    @objc
    func taped() {
        scroll.endEditing(true)
    }

// MARK: - no edit mode
    private func setNoEdit() {
        testAva.delegate = self
        testAva.allowsEditing = true
        ava.isUserInteractionEnabled = false

        setNavButtons(edit_mode: false)
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
        setNavButtons(edit_mode: true)

        height = self.heightAnchor.constraint(equalToConstant: 560)
        guard let _height = height else {
            Logger.log("no height in edit mode!")
            return
        }
        _height.isActive = true

        // MARK: - SCROLL CONTENT PROFILE
//        scroll.updateContentView()

        let tap = UITapGestureRecognizer()
        ava.isUserInteractionEnabled = true
        ava.addGestureRecognizer(tap)
        tap.addTarget(self, action: #selector(chooseAva))

        [username, email, password, repeatPassword].forEach {
            $0.setEditFields(state: true)
        }
        setPassword()
    }

    // MARK: - save settings
    @objc
    private func save_settings() {
        if dataState.email == email.textField.text &&
            dataState.username == username.textField.text &&
            dataState.oldAva == ava.image &&
            password.textField.text?.count == 0 &&
            repeatPassword.textField.text?.count == 0 {

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
        else {
            Logger.log("no text in textfields")
            return
        }

        guard let navigationBar = navBar, let _height = height else {
            Logger.log("no navigtion bar and height")
            return
        }

        if usrInput == "" && emlInput == "" && pasInput == "" && avaContent == nil {
            return
        }

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: navigationBar.frame.width / 2 + 70,
                                                                     y: 0,
                                                                     width: 50, height: 50))
        loadingIndicator.color = Colors.blue
        loadingIndicator.hidesWhenStopped = true
        navigationBar.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()

        userViewModel?.update(username: usrInput, email: emlInput, ava: avaContent, avaName: avaName,
                              password: pasInput, completion: { [weak self] (error) in
            DispatchQueue.main.async {
                if let error = error {
                    switch error {
                    case .usernameAlreadyExists:
                        self?.username.setError(text: "Такое имя пользователя уже занято")
                    case .usernameLengthIsWrong:
                        self?.username.setError(text: "Неверная длина имени пользователя, минимум: 4")
                    case .emailFormatIsWrong:
                        self?.email.setError(text: "Неверный формат почты")
                    case .emailAlreadyExists:
                        self?.email.setError(text: "Такая почта уже занята")
                    case .passwordLengthIsWrong:
                        self?.password.setError(text: "Неверная длина пароля")
                    case .noConnection:
                        self?._error(text: "Нет соединения с интернетом", color: Colors.darkGray)
                    case .unauthorized:
                        Logger.log(error)
                        self?._error(text: "Вы не авторизованы")
                        sleep(3)
                        self?.delegateProfile?.logOut()
                    case .noData:
                        Logger.log(error)
                        self?._error(text: "Невозможно загрузить данные", color: Colors.darkGray)
                    case .notFound:
                        Logger.log(error)
                        self?._error(text: "Такого пользователя нет")
                        sleep(3)
                        self?.delegateProfile?.logOut()
                    default:
                        Logger.log(error)
                        self?._error(text: "Упс, что-то пошло не так.")
                    }
                    loadingIndicator.stopAnimating()
                    return
                }

                self?.password.textField.text = ""
                self?.password.clearState()
                self?.repeatPassword.textField.text = ""
                self?.repeatPassword.clearState()

                loadingIndicator.stopAnimating()
                _height.isActive = false
                self?.setupView()

                guard let a = self?.ava.image else { return }
                self?.delegateProfile?.updateAvatar(image: a)
            }
        })
    }

    // MARK: - don't save settings
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

        guard let _height = height else {
            Logger.log("height of view is nil")
            return
        }
        removeConstraint(_height)
        setupView()
    }

    // MARK: - ui error
    private func _error(text: String, color: UIColor? = Colors.red) {
        guard let navigationBar = navBar else {
            Logger.log("no navigation bar")
            return
        }

        let er = UIError(text: text, place: scroll, color: color)
        scroll.addSubview(er)
        er.translatesAutoresizingMaskIntoConstraints = false
        er.leftAnchor.constraint(equalTo: navigationBar.leftAnchor).isActive = true
        er.rightAnchor.constraint(equalTo: navigationBar.rightAnchor).isActive = true
        er.topAnchor.constraint(equalTo: navigationBar.bottomAnchor).isActive = true
    }
}

// MARK: - navigation bar
extension ProfileView {
    private func setNavButtons(edit_mode: Bool) {
        guard let navigationBar = navBar else { return }
        guard let settings = settings, let substrateLogout = substrateLogout,
            let yes = yes, let substrateNot = substrateNot
        else { return }

        if !edit_mode {
            yes.removeFromSuperview()
            substrateNot.removeFromSuperview()

            navigationBar.addSubview(settings)
            navigationBar.addSubview(substrateLogout)

            settings.translatesAutoresizingMaskIntoConstraints = false
            settings.topAnchor.constraint(equalTo: navigationBar.topAnchor, constant: 7).isActive = true
            settings.leftAnchor.constraint(equalTo: navigationBar.leftAnchor, constant: 20).isActive = true

            substrateLogout.translatesAutoresizingMaskIntoConstraints = false
            substrateLogout.topAnchor.constraint(equalTo: navigationBar.topAnchor, constant: 7).isActive = true
            substrateLogout.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -20).isActive = true
        } else {
             settings.removeFromSuperview()
             substrateLogout.removeFromSuperview()

            navigationBar.addSubview(yes)
            navigationBar.addSubview(substrateNot)

            yes.translatesAutoresizingMaskIntoConstraints = false
            yes.topAnchor.constraint(equalTo: navigationBar.topAnchor, constant: 7).isActive = true
            yes.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -20).isActive = true

            substrateNot.translatesAutoresizingMaskIntoConstraints = false
            substrateNot.topAnchor.constraint(equalTo: navigationBar.topAnchor, constant: 7).isActive = true
            substrateNot.leftAnchor.constraint(equalTo: navigationBar.leftAnchor, constant: 20).isActive = true
        }
    }
}

// MARK: - set username, email
extension ProfileView {
    private func setFields() {
        [username, email].forEach {
            scroll.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: scroll.centerXAnchor).isActive = true
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
            scroll.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: scroll.centerXAnchor).isActive = true
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
        scroll.addSubview(ava)
        ava.translatesAutoresizingMaskIntoConstraints = false
        ava.centerXAnchor.constraint(equalTo: scroll.centerXAnchor).isActive = true
        ava.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 10).isActive = true
        ava.widthAnchor.constraint(equalToConstant: 170).isActive = true
        ava.heightAnchor.constraint(equalToConstant: 170).isActive = true
        ava.contentMode = .scaleAspectFill
        ava.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner,
                                   .layerMinXMaxYCorner, .layerMinXMinYCorner]
        ava.layer.cornerRadius = 10
        ava.layer.masksToBounds = true

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 60,
                                                                     y: 60,
                                                                     width: 50, height: 50))
        ava.addSubview(loadingIndicator)
        loadingIndicator.color = Colors.blue
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()

        userViewModel?.getAvatar(completion: { [weak self] (avatar, error) in
            DispatchQueue.main.async {
                loadingIndicator.stopAnimating()
                if let error = error {
                    switch error {
                    case .noData:
                        Logger.log(error)
                        self?._error(text: "Невозможно загрузить фотографию", color: Colors.darkGray)
                    default:
                        Logger.log(error)
                        self?._error(text: "Упс, что-то пошло не так.")
                    }
                    return
                }

                guard let avatar = avatar else {
                    self?.ava.image = UIImage(named: "default_profile")
                    return
                }
                self?.ava.image = UIImage(contentsOfFile: avatar)
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
        guard let superview = superview  else {
            Logger.log("no superview")
            return
        }

        let swipeView = UIView()
        addSubview(swipeView)
        swipeView.translatesAutoresizingMaskIntoConstraints = false
        swipeView.topAnchor.constraint(equalTo: scroll.bottomAnchor).isActive = true
        swipeView.widthAnchor.constraint(equalToConstant: superview.frame.width).isActive = true
        swipeView.heightAnchor.constraint(equalToConstant: 30).isActive = true

        let lineBottom = LineClose()
        swipeView.addSubview(lineBottom)
        lineBottom.translatesAutoresizingMaskIntoConstraints = false
        lineBottom.centerYAnchor.constraint(equalTo: swipeView.centerYAnchor).isActive = true
        lineBottom.centerXAnchor.constraint(equalTo: swipeView.centerXAnchor, constant: -23).isActive = true
        lineBottom.bottomAnchor.constraint(equalTo: swipeView.bottomAnchor, constant: -15).isActive = true

        let swipe = UISwipeGestureRecognizer()
        swipe.direction = .up
        swipe.addTarget(self, action: #selector(closeProfile))
        swipeView.addGestureRecognizer(swipe)
    }

    // MARK: close profile
    @objc
    func closeProfile() {
        guard let _heigt = height else {
            Logger.log("no height")
            return
        }

        username.clearState()
        email.clearState()
        password.clearState()
        repeatPassword.clearState()

        _heigt.isActive = false
        removeFromSuperview()
        delegateProfile?.enableTabBarButton()
    }

    // MARK: logout
    @objc
    private func logout() {
        delegateProfile?.logOut()
    }
}

// MARK: - keyboard
extension ProfileView {
    func setActiveField(inputField: InputFields) {
        activeField = inputField
    }

    @objc
    func keyboardWillShow(_ notification: Notification) {
        guard let activeField = activeField else {
            Logger.log("no active InputField")
            return
        }

        let info = notification.userInfo!

        guard let rect: CGRect = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            Logger.log("no keyboard size")
            return
        }
        let kbSize = rect.size

        let insets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
        scroll.contentInset = insets
        scroll.scrollIndicatorInsets = insets

        let visible_screen_without_keyboard = scroll.bounds.height - kbSize.height

        let tr = scroll.convert(activeField.frame, to: nil)

        if tr.origin.y > visible_screen_without_keyboard {
            let scrollPoint = CGPoint(x: 0, y: activeField.frame.origin.y - kbSize.height)
            scroll.setContentOffset(scrollPoint, animated: true)
        }
    }

    @objc
    func keyboardWillHide(_ notification: Notification) {
        scroll.contentInset = .zero
        scroll.scrollIndicatorInsets = .zero
    }
}
