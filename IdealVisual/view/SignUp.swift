//
//  SignUp.swift
//  IdealVisual
//
//  Created by a.kurganova on 13.11.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

class SignUp: UIViewController {
    private let username = InputFields(labelImage: UIImage(named: "login"), text: nil, placeholder: "Логин")
    private let email = InputFields(labelImage: UIImage(named: "email"), text: nil, placeholder: "Почта")
    private let password = InputFields(labelImage: UIImage(named: "password"), text: nil, placeholder: "Пароль")
    private let repeatPassword = InputFields(labelImage: UIImage(named: "password"), text: nil,
                                             placeholder: "Повторите пароль")
    private var user: User?

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
        [username, email, password, repeatPassword].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 300).isActive = true
            $0.setEditFields(state: true)
        }
        username.topAnchor.constraint(equalTo: view.topAnchor,
                                      constant: 200).isActive = true
        email.topAnchor.constraint(equalTo: username.bottomAnchor, constant: 40).isActive = true
        password.topAnchor.constraint(equalTo: email.bottomAnchor, constant: 40).isActive = true
        repeatPassword.topAnchor.constraint(equalTo: password.bottomAnchor, constant: 40).isActive = true
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

        createAccountButton.topAnchor.constraint(equalTo: repeatPassword.bottomAnchor, constant: 50).isActive = true
        createAccountButton.widthAnchor.constraint(equalToConstant: 210).isActive = true
        createAccountButton.setTitleColor(.white, for: .normal)
        createAccountButton.backgroundColor = Colors.blue
        createAccountButton.addTarget(self, action: #selector(createAccount), for: .touchUpInside)

        signInButton.topAnchor.constraint(equalTo: createAccountButton.bottomAnchor, constant: 20).isActive = true
        signInButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        signInButton.setColor(state: false)
        createAccountButton.addTarget(self, action: #selector(goTosignIn), for: .touchUpInside)
    }

    @objc private func createAccount() {

        if !checkValidInputs() {
            print("invalid")
            return
        }
        print("valid")

        user = User()
        user?.username = username.textField.text
        user?.email = email.textField.text
        user?.password = password.textField.text
    }

    private func checkValidInputs() -> Bool {

        let usernameMistake = CheckMistakeLabel()
        let emailMistake = CheckMistakeLabel()
        let passwordMistake = CheckMistakeLabel()
        let repeatPasswordMistake = CheckMistakeLabel()

        var areValid = true

        areValid = false

        [usernameMistake, emailMistake, passwordMistake, repeatPasswordMistake].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.leftAnchor.constraint(equalTo: username.leftAnchor, constant: 5).isActive = true
        }
        areValid = true
        usernameMistake.topAnchor.constraint(equalTo: username.bottomAnchor, constant: 3).isActive = true
        emailMistake.topAnchor.constraint(equalTo: email.bottomAnchor, constant: 3).isActive = true
        passwordMistake.topAnchor.constraint(equalTo: password.bottomAnchor, constant: 3).isActive = true
        repeatPasswordMistake.topAnchor.constraint(equalTo: repeatPassword.bottomAnchor, constant: 3).isActive = true

        [username, email].forEach {
            if $0.textField.text?.count != 0 {
                $0.layer.borderColor = Colors.lightBlue.cgColor
                usernameMistake.isHidden = true
                emailMistake.isHidden = true
                emailMistake.isHidden = true
            } else {
                $0.layer.borderColor = UIColor.red.cgColor
                usernameMistake.text = "Имя пользователя не может быть пустым"
                emailMistake.text = "Электронная почта не может быть пустой"
                usernameMistake.isHidden = false
                emailMistake.isHidden = false
                areValid = false
            }
        }

        var passwordsAreValid = true
        [password, repeatPassword].forEach {
            if $0.textField.text!.count < 8 {
                areValid = false
                passwordsAreValid = false
                passwordMistake.isHidden = false
                repeatPasswordMistake.isHidden = false
                passwordMistake.text = "Слабый пароль"
                repeatPasswordMistake.text = "Слабый пароль"
            }
        }

        if password.textField.text != repeatPassword.textField.text {
            areValid = false
            passwordsAreValid = false
            passwordMistake.isHidden = false
            repeatPasswordMistake.isHidden = false
            passwordMistake.text = "Пароли не совпадают"
            repeatPasswordMistake.text = "Пароли не совпадают"
        }

        if password.textField.text != repeatPassword.textField.text && password.textField.text!.count < 8 &&
            repeatPassword.textField.text!.count < 8 {
            areValid = false
            passwordsAreValid = false
            passwordMistake.isHidden = false
            repeatPasswordMistake.isHidden = false
            passwordMistake.text = "Слабый пароль, пароли не совпадают"
            repeatPasswordMistake.text = "Слабый пароль, пароли не совпадают"
        }

        [password, repeatPassword].forEach {
            if passwordsAreValid {
                $0.layer.borderColor = Colors.lightBlue.cgColor
                passwordMistake.isHidden = true
                repeatPasswordMistake.isHidden = true
            } else {
                $0.layer.borderColor = UIColor.red.cgColor
                passwordMistake.isHidden = false
                repeatPasswordMistake.isHidden = false
            }
        }

        return areValid
    }

    @objc private func goTosignIn() {
        let signInVC = SignIn()
//        signInVC.modalPresentationStyle = .fullScreen
//        self.dismiss(animated: true, completion: nil)
    }
}
