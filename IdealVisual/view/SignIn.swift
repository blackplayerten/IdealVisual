//
//  SignIn.swift
//  IdealVisual
//
//  Created by a.kurganova on 05.11.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

class SignIn: UIViewController {
    private let username = InputFields(labelText: "Логин", text: nil)
    private let password = InputFields(labelText: "Пароль", text: nil)

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
        titleV.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
        titleV.font = UIFont(name: "Montserrat-Bold", size: 35)
        titleV.adjustsFontSizeToFitWidth = true
        navigationController?.navigationItem.titleView = titleV

        let logo = UIImageView()
        view.addSubview(logo)
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.image = UIImage(named: "app")?.withRenderingMode(.alwaysOriginal)
        logo.widthAnchor.constraint(equalToConstant: 35).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 35).isActive = true
        logo.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 25).isActive = true
        logo.rightAnchor.constraint(equalTo: titleV.leftAnchor, constant: -20).isActive = true
        setAuthFields()
    }

    private func setAuthFields() {
        [username, password].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 300).isActive = true
            $0.setEditFields(state: true)
        }
        username.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                      constant: 300).isActive = true
        password.topAnchor.constraint(equalTo: username.bottomAnchor, constant: 30).isActive = true
        setAuthButtons()
    }

    private func setAuthButtons() {
        let signInButton = AddComponentsButton(text: "Войти")
        let signUpButton = AddComponentsButton(text: "Еще нет аккаунта")
        [signInButton, signUpButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }

        signInButton.topAnchor.constraint(equalTo: password.bottomAnchor, constant: 50).isActive = true
        signInButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        signInButton.setTitleColor(.white, for: .normal)
        signInButton.backgroundColor = Colors.blue
        signInButton.addTarget(self, action: #selector(goTosignIn), for: .touchUpInside)

        signUpButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 50).isActive = true
        signUpButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        signUpButton.setTitleColor(Colors.darkDarkGray, for: .normal)
        signUpButton.backgroundColor = .green
        signInButton.addTarget(self, action: #selector(goTosignUp), for: .touchUpInside)
    }

    @objc private func goTosignIn() {
//        let mainVC = MainView()
//        mainVC.modalPresentationStyle = .fullScreen
//        present(mainVC, animated: true, completion: nil)
    }

    @objc private func goTosignUp() {

    }
}
