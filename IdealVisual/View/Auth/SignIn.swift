//
//  SignIn.swift
//  IdealVisual
//
//  Created by a.kurganova on 05.11.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

final class SignIn: UIViewController {
    private var scroll = UIScrollView()
    private var titleView: UIView?

    private var userViewModel: UserViewModelProtocol?
    private var email: InputFields?
    private var password: InputFields?
    private var activeField: InputFields?

    // MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isTranslucent = false

        view.backgroundColor = .white
        self.titleView = UIView(frame: CGRect(x: 0, y: UIApplication.shared.keyWindow!.safeAreaInsets.top,
                                              width: self.view.bounds.width, height: 80))
        view.addSubview(titleView!)

        setNav()
        setScroll()

        self.userViewModel = UserViewModel()

        self.email = InputFields(tag: 0, labelImage: UIImage(named: "email"), text: nil, placeholder: "Почта",
                                 textContentType: .emailAddress, keyboardType: .emailAddress,
                                 validator: checkValidEmail, inputDelegate: self)
        self.password = InputFields(tag: 1, labelImage: UIImage(named: "password"), text: nil, placeholder: "Пароль",
                                    textContentType: .password, validator: checkValidPassword,
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
        titleV.backgroundColor = .white
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
        logo.topAnchor.constraint(equalTo: titleView!.topAnchor, constant: 25).isActive = true
        logo.rightAnchor.constraint(equalTo: titleV.leftAnchor, constant: -20).isActive = true
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 10
    }

    // MARK: - set fields
    private func setAuthFields() {
        let hideKey: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(taped))
        scroll.addGestureRecognizer(hideKey)

        guard
            let email = email,
            let password = password
        else {
            return
        }

        [email, password].forEach {
            scroll.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: scroll.centerXAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 300).isActive = true
            $0.setEditFields(state: true)
        }
        email.centerYAnchor.constraint(equalTo: scroll.centerYAnchor, constant: -150).isActive = true
        password.topAnchor.constraint(equalTo: email.bottomAnchor, constant: 30).isActive = true

        setAuthButtons()
    }

    // MARK: - auth buttons
    private func setAuthButtons() {
        let signInButton = AddComponentsButton(text: "Войти")
        let signUpButton = AddComponentsButton(text: "Еще нет аккаунта")
        [signInButton, signUpButton].forEach {
            scroll.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: scroll.centerXAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
            $0.layer.cornerRadius = 10
        }

        guard let password = password else { return }

        signInButton.topAnchor.constraint(equalTo: password.bottomAnchor, constant: 50).isActive = true
        signInButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        signInButton.backgroundColor = Colors.blue
        signInButton.addTarget(self, action: #selector(checkAuth), for: .touchUpInside)

        signUpButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 20).isActive = true
        signUpButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        signUpButton.bottomAnchor.constraint(equalTo: scroll.bottomAnchor).isActive = true
        signUpButton.setColor(state: false)
        signUpButton.addTarget(self, action: #selector(goTosignUp), for: .touchUpInside)
    }

    // MARK: ui error
    private func _error(text: String, color: UIColor? = Colors.red) {
        let er = UIError(text: text, place: scroll, color: color)
        scroll.addSubview(er)
        er.translatesAutoresizingMaskIntoConstraints = false
        er.leftAnchor.constraint(equalTo: titleView!.leftAnchor).isActive = true
        er.rightAnchor.constraint(equalTo: titleView!.rightAnchor).isActive = true
        er.topAnchor.constraint(equalTo: titleView!.bottomAnchor).isActive = true
    }

    @objc
    func taped() {
        scroll.endEditing(true)
    }

    // MARK: - func check authentification
    @objc
    private func checkAuth() {
        guard
            let emailField = email,
            let passwordField = password
        else {
            return
        }

        let emailIsValid = emailField.isValid()
        let passwordIsValid = passwordField.isValid()
        if !emailIsValid && !passwordIsValid {
            return
        }

        guard let email = email?.textField.text,
            let password = password?.textField.text
        else {
            return
        }

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 90,
                                                                     y: 380,
                                                                     width: 50, height: 50))
        loadingIndicator.color = Colors.blue
        loadingIndicator.hidesWhenStopped = true
        scroll.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()

        userViewModel?.login(email: email, password: password, completion: { [weak self] (error) in
            DispatchQueue.main.async {
                if let error = error {
                    switch error {
                    case .noConnection:
                        self?._error(text: "Нет соединения с интернетом", color: Colors.darkGray)
                    case .wrongCredentials:
                        self?.password?.setError(text: "Неправильная почта или пароль")
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

    private func autoLogin() {
        let tabBar = TabBar()
        tabBar.modalPresentationStyle = .fullScreen
        present(tabBar, animated: true, completion: nil)
    }

    @objc
    private func goTosignUp() {
        let signUpVc = SignUp()
        signUpVc.modalPresentationStyle = .fullScreen
        present(signUpVc, animated: true, completion: nil)
    }
}

// MARK: inputs delegate for keyboard
extension SignIn: InputFieldDelegate {
    func setActiveField(inputField: InputFields) {
        activeField = inputField
    }
}
