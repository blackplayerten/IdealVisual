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

class SignUp: UIViewController {
    private let usernameField = InputFields(labelImage: UIImage(named: "login"), text: nil, placeholder: "Логин",
                                            textContentType: .username, validator: checkValidUsername)
    private let emailField = InputFields(labelImage: UIImage(named: "email"), text: nil, placeholder: "Почта",
                                         textContentType: .emailAddress, keyboardType: .emailAddress,
                                         validator: checkValidEmail)
    private let passwordField = InputFields(labelImage: UIImage(named: "password"), text: nil, placeholder: "Пароль",
                                            textContentType: .newPassword, validator: checkValidPassword)
    private let repeatPasswordField = InputFields(labelImage: UIImage(named: "password"), text: nil,
                                             placeholder: "Повторите пароль",
                                             textContentType: .newPassword, validator: checkValidPassword)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNav()
    }

    private func setNav() {
        let titleV = UILabel()
        view.addSubview(titleV)
        titleV.text = "IdealVisual"
        titleV.translatesAutoresizingMaskIntoConstraints = false
        titleV.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
        titleV.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        titleV.font = UIFont(name: "Montserrat-Bold", size: 35)
        titleV.adjustsFontSizeToFitWidth = true
        navigationController?.navigationItem.titleView = titleV

        let logo = UIImageView()
        view.addSubview(logo)
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.image = UIImage(named: "app")?.withRenderingMode(.alwaysOriginal)
        logo.widthAnchor.constraint(equalToConstant: 35).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 35).isActive = true
        logo.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 25).isActive = true
        logo.rightAnchor.constraint(equalTo: titleV.leftAnchor, constant: -20).isActive = true
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 10
        setAuthFields()
    }

    private func setAuthFields() {
        [usernameField, emailField, passwordField, repeatPasswordField].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 300).isActive = true
            $0.setEditFields(state: true)
        }
        usernameField.topAnchor.constraint(equalTo: view.topAnchor,
                                      constant: 200).isActive = true
        emailField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 40).isActive = true
        passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 40).isActive = true
        repeatPasswordField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 40).isActive = true
        setAuthButtons()
    }

    private func setAuthButtons() {
        let createAccountButton = AddComponentsButton(text: "Зарегистрироваться")
        let signInButton =  AddComponentsButton(text: "Войти")
        [createAccountButton, signInButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
            $0.layer.cornerRadius = 10
        }

        createAccountButton.topAnchor.constraint(equalTo: repeatPasswordField.bottomAnchor,
                                                 constant: 50).isActive = true
        createAccountButton.widthAnchor.constraint(equalToConstant: 210).isActive = true
        createAccountButton.setTitleColor(.white, for: .normal)
        createAccountButton.backgroundColor = Colors.blue
        createAccountButton.addTarget(self, action: #selector(createAccount), for: .touchUpInside)

        signInButton.topAnchor.constraint(equalTo: createAccountButton.bottomAnchor, constant: 20).isActive = true
        signInButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        signInButton.setColor(state: false)
        signInButton.addTarget(self, action: #selector(goToSignIn), for: .touchUpInside)
    }

    @objc private func createAccount() {
        if !checkValidInputs() {
            return
        }

        guard
            let username = usernameField.textField.text,
            let email = emailField.textField.text
        else {
            return
        }

        _ = CoreDataUser.createUser(username: username, email: email)
        autoLogin()
    }

    private func checkValidInputs() -> Bool {
        let usernameIsValid = usernameField.isValid()
        let emailIsValid = emailField.isValid()
        let pairIsValid = checkValidPasswordPair(field: passwordField, fieldRepeat: repeatPasswordField)
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
