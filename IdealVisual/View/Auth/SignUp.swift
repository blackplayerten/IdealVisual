//
//  SignUp.swift
//  IdealVisual
//
//  Created by a.kurganova on 13.11.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit
import CoreData

final class SignUp: UIViewController {
    private var scroll = UIScrollView()
    private var titleView: UIView?

    private var userViewModel: UserViewModel?
    private var username: InputFields?
    private var email: InputFields?
    private var password: InputFields?
    private var repeatPassword: InputFields?

    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.titleView = UIView(frame: CGRect(x: 0, y: UIApplication.shared.keyWindow!.safeAreaInsets.top,
                                              width: self.view.bounds.width, height: 80))
        view.addSubview(titleView!)

        setNav()
        setScroll()
        self.userViewModel = UserViewModel()

        self.username = InputFields(tag: 0, labelImage: UIImage(named: "login"), text: nil, placeholder: "Логин",
                                    textContentType: .username, validator: checkValidUsername,
                                    inputDelegate: self)
        self.email = InputFields(tag: 1, labelImage: UIImage(named: "email"), text: nil, placeholder: "Почта",
                                 textContentType: .emailAddress, keyboardType: .emailAddress,
                                 validator: checkValidEmail, inputDelegate: self)
        self.password = InputFields(tag: 2, labelImage: UIImage(named: "password"), text: nil,
                                    placeholder: "Пароль", textContentType: .newPassword,
                                    validator: checkValidPassword, inputDelegate: self)
        self.repeatPassword = InputFields(tag: 3, labelImage: UIImage(named: "password"), text: nil,
                                          placeholder: "Повторите пароль",
                                          textContentType: .newPassword, validator: checkValidPassword,
                                          inputDelegate: self)
        setAuthFields()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    private var activeField: InputFields?

    // MARK: - scroll and keyboard
    private func setScroll() {
        view.addSubview(scroll)
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.topAnchor.constraint(equalTo: titleView!.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    @objc
    func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo!
        guard let rect: CGRect = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let kbSize = rect.size

        let insets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
        scroll.contentInset = insets
        scroll.scrollIndicatorInsets = insets

        guard let activeField = activeField else { return }

        let visible_screen_without_keyboard = scroll.bounds.height - kbSize.height

        let tr = scroll.convert(activeField.frame, to: nil)

        if tr.origin.y + tr.height > visible_screen_without_keyboard {
            let scrollPoint = CGPoint(x: 0, y: activeField.frame.origin.y - kbSize.height)
            scroll.setContentOffset(scrollPoint, animated: true)
        }
    }

    @objc
    func keyboardWillHide(_ notification: Notification) {
        scroll.contentInset = .zero
        scroll.scrollIndicatorInsets = .zero
    }

    // MARK: - navigation
    private func setNav() {
        let titleV = UILabel()
        titleView?.addSubview(titleV)
        titleV.text = "IdealVisual"
        titleV.translatesAutoresizingMaskIntoConstraints = false
        titleV.rightAnchor.constraint(equalTo: titleView!.rightAnchor, constant: -30).isActive = true
        titleV.topAnchor.constraint(equalTo: titleView!.topAnchor, constant: 20).isActive = true
        titleV.font = UIFont(name: "Montserrat-Bold", size: 35)
        titleV.adjustsFontSizeToFitWidth = true

        let logo = UIImageView()
        titleView?.addSubview(logo)
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.image = UIImage(named: "app")?.withRenderingMode(.alwaysOriginal)
        logo.widthAnchor.constraint(equalToConstant: 35).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 35).isActive = true
        logo.topAnchor.constraint(equalTo: titleView!.topAnchor, constant: 20).isActive = true
        logo.rightAnchor.constraint(equalTo: titleV.leftAnchor, constant: -20).isActive = true
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 10
    }

    // MARK: set fields
    private func setAuthFields() {
        let hideKey: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(taped))
        scroll.addGestureRecognizer(hideKey)

        guard
            let username = username,
            let email = email,
            let password = password,
            let repeatPassword = repeatPassword
        else {
            return
        }

        [username, email, password, repeatPassword].forEach {
            scroll.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: scroll.centerXAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 300).isActive = true
            $0.setEditFields(state: true)
        }
        username.centerYAnchor.constraint(equalTo: scroll.topAnchor, constant: 200).isActive = true
        email.topAnchor.constraint(equalTo: username.bottomAnchor, constant: 40).isActive = true
        password.topAnchor.constraint(equalTo: email.bottomAnchor, constant: 40).isActive = true
        repeatPassword.topAnchor.constraint(equalTo: password.bottomAnchor, constant: 40).isActive = true
        setAuthButtons()
    }

    // MARK: - auth buttons
    private func setAuthButtons() {
        let createAccountButton = AddComponentsButton(text: "Зарегистрироваться")
        let signInButton =  AddComponentsButton(text: "Войти")
        [createAccountButton, signInButton].forEach {
            scroll.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: scroll.centerXAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
            $0.layer.cornerRadius = 10
        }

        guard let repeatPassword = repeatPassword else { return }

        createAccountButton.topAnchor.constraint(equalTo: repeatPassword.bottomAnchor,
                                                 constant: 50).isActive = true
        createAccountButton.widthAnchor.constraint(equalToConstant: 210).isActive = true
        createAccountButton.backgroundColor = Colors.blue
        createAccountButton.addTarget(self, action: #selector(createAccount), for: .touchUpInside)

        signInButton.topAnchor.constraint(equalTo: createAccountButton.bottomAnchor, constant: 20).isActive = true
        signInButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        signInButton.bottomAnchor.constraint(equalTo: scroll.bottomAnchor).isActive = true
        signInButton.setColor(state: false)
        signInButton.addTarget(self, action: #selector(goToSignIn), for: .touchUpInside)
    }

    // MARK: ui error
    private func _error(text: String, color: UIColor? = Colors.red) {
        let er = UIError(text: text, place: scroll, color: color)
        scroll.addSubview(er)
        er.translatesAutoresizingMaskIntoConstraints = false
        er.leftAnchor.constraint(equalTo: titleView!.leftAnchor, constant: 0).isActive = true
        er.rightAnchor.constraint(equalTo: titleView!.rightAnchor, constant: 0).isActive = true
        er.topAnchor.constraint(equalTo: titleView!.bottomAnchor).isActive = true
    }

    @objc
    func taped() {
        scroll.endEditing(true)
    }

    // MARK: - func create account
    @objc
    private func createAccount() {
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 45,
                                                                     y: 515,
                                                                     width: 50, height: 50))
        loadingIndicator.color = Colors.blue
        loadingIndicator.hidesWhenStopped = true
        scroll.addSubview(loadingIndicator)

        if !checkValidInputs() {
            return
        }

        guard
            let username = username?.textField.text,
            let email = email?.textField.text,
            let password = password?.textField.text
        else { return }

        loadingIndicator.startAnimating()
        userViewModel?.create(username: username, email: email, password: password,
                              completion: { [weak self] (error) in
            DispatchQueue.main.async {
                if let error = error {
                    switch error {
                    case .noConnection:
                        self?._error(text: "Нет соединения с интернетом", color: Colors.darkGray)
                    case .usernameAlreadyExists:
                        self?.username?.setError(text: "Такое имя пользователя уже занято")
                    case .usernameLengthIsWrong:
                        self?.username?.setError(text: "Неверная длина имени пользователя, минимум: 4")
                    case .emailFormatIsWrong:
                        self?.email?.setError(text: "Неверный формат почты")
                    case .emailAlreadyExists:
                        self?.email?.setError(text: "Такая почта уже занята")
                    case .passwordLengthIsWrong:
                        self?.password?.setError(text: "Неверная длина пароля")
                    default:
                        Logger.log("unknown error: \(error)")
                        self?._error(text: "Упс, что-то пошло не так")
                    }
                    loadingIndicator.stopAnimating()
                } else {
                    loadingIndicator.stopAnimating()
                    self?.autoLogin()
                }
            }
        })
    }

    // MARK: - func check validation
    private func checkValidInputs() -> Bool {
        guard
            let username = username,
            let email = email,
            let password = password,
            let repeatPassword = repeatPassword
        else {
            return false
        }

        let usernameIsValid = username.isValid()
        let emailIsValid = email.isValid()
        let pairIsValid = checkValidPasswordPair(field: password, fieldRepeat: repeatPassword)
        return usernameIsValid && emailIsValid && pairIsValid
    }

    private func autoLogin() {
        let tabBar = TabBar()
        tabBar.modalPresentationStyle = .fullScreen
        present(tabBar, animated: true, completion: nil)
    }

    @objc
    private func goToSignIn() {
        let signIn = SignIn()
        signIn.modalPresentationStyle = .fullScreen
        present(signIn, animated: true, completion: nil)
    }
}

// MARK: inputs delegate for keyboard
extension SignUp: InputFieldDelegate {
    func setActiveField(inputField: InputFields) {
        activeField = inputField
    }
}
