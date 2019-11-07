//
//  ProfileView.swift
//  IdealVisual
//
//  Created by a.kurganova on 03/10/2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit


protocol ProfileDelegate: class {
    func chooseAvatar(picker: UIImagePickerController)
    func showAlert(alert: UIAlertController)
    func dismissAlert()
    func enableTabBarButton()
    func logOut()
}

class ProfileView: UIView {
    private weak var delegateProfile: ProfileDelegate?
    private var testAva = UIImagePickerController()
    
    private var height = NSLayoutConstraint()
    
    
    private let logout_button = UIButton()
    
    private let ava = UIImageView()
    

    
    private let username = UITextField()
    private let email = UITextField()
    private let password = UITextField()
    private let repeat_password = UITextField()
    private let hide_keyboard = UITapGestureRecognizer(target: self, action: #selector(hide))
    
    init(profileDelegate: ProfileDelegate) {
        self.delegateProfile = profileDelegate
        super.init(frame: CGRect())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupElements() {
        testAva.delegate = self
        testAva.allowsEditing = true
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = .up
        swipe.addTarget(self, action: #selector(closeProfile))
        self.addGestureRecognizer(swipe)
        
        setNavButtons()
        setAva()
        
//        let k = UserTable(view: self)
//        addSubview(k)
//        k.translatesAutoresizingMaskIntoConstraints = false
//        k.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
//        k.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
//        k.topAnchor.constraint(equalTo: ava.bottomAnchor, constant: 27).isActive = true
//        k.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30).isActive = true
//        k.isScrollEnabled = false
//        k.backgroundColor = .white
        
        
        
//        password.isHidden = true
//        addSubview(password)
//        password.translatesAutoresizingMaskIntoConstraints = false
//        password.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//        password.topAnchor.constraint(equalTo: email.topAnchor, constant: 40).isActive = true
//        password.font = UIFont(name: "PingFang-SC-Regular", size: 14)
//        password.textAlignment = .center
//        password.textColor = .white
//        password.placeholder = "Пароль"
//        password.attributedPlaceholder = NSAttributedString(string: password.placeholder!,
//                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
//        )
//
//        repeat_password.isHidden = true
//        addSubview(repeat_password)
//        repeat_password.translatesAutoresizingMaskIntoConstraints = false
//        repeat_password.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//        repeat_password.topAnchor.constraint(equalTo: password.topAnchor, constant: 40).isActive = true
//        repeat_password.font = UIFont(name: "PingFang-SC-Regular", size: 14)
//        repeat_password.textAlignment = .center
//        repeat_password.textColor = .white
//        repeat_password.placeholder = "Подтвердите пароль"
//        repeat_password.attributedPlaceholder = NSAttributedString(string: repeat_password.placeholder!,
//                                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
//        )
    }
    
    @objc private func set_settings() {
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(hide_keyboard)
        
        setNavEditButtons()
        
        height.isActive = false
        let new_height = self.heightAnchor.constraint(equalToConstant: 440)
        new_height.isActive = true
        

        let tap = UITapGestureRecognizer()
        ava.isUserInteractionEnabled = true
        self.ava.addGestureRecognizer(tap)
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(chooseAva))
        
        username.isUserInteractionEnabled = true
        email.isUserInteractionEnabled = true
        password.isHidden = false
        password.allowsEditingTextAttributes = true
        repeat_password.isHidden = false
        repeat_password.allowsEditingTextAttributes = true
    }
    
    @objc func closeProfile() {
        removeFromSuperview()
        delegateProfile?.enableTabBarButton()
    }
    
    @objc private func hide() {
        self.endEditing(true)
    }
    
    @objc private func save_settings() {
        
    }
    
    @objc private func no_settings() {
        setup()
    }
    
    @objc private func logout() {
        delegateProfile?.logOut()
    }
}

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
        self.layer.shadowColor = Colors.dark_dark_gray.cgColor
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 50.0
        self.heightAnchor.constraint(greaterThanOrEqualToConstant: 460).isActive = true
        setupElements()
    }
}

extension ProfileView {
    private func setNavButtons() {
        guard let im_s = UIImage(named: "settings") else { return }
        let settings = SubstrateButton(image: im_s, side: 33, target: self, action: #selector(set_settings), substrate_color: Colors.yellow)
        addSubview(settings)
        settings.translatesAutoresizingMaskIntoConstraints = false
        settings.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 7).isActive = true
        settings.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true

        guard let im_logout = UIImage(named: "logout") else { return }
        let logout_b = SubstrateButton(image: im_logout, side: 33, target: self, action: #selector(logout), substrate_color: Colors.dark_gray)
        addSubview(logout_b)
        logout_b.translatesAutoresizingMaskIntoConstraints = false
        logout_b.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 7).isActive = true
        logout_b.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
    }

    @objc private func setNavEditButtons() {
        guard let im_yes = UIImage(named: "yes") else { return }
        let yes = SubstrateButton(image: im_yes, side: 33, target: self, action: #selector(save_settings), substrate_color: Colors.yellow)
        addSubview(yes)
        yes.translatesAutoresizingMaskIntoConstraints = false
        yes.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 7).isActive = true
        yes.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true

        guard let im_no = UIImage(named: "close") else { return }
        let no = SubstrateButton(image: im_no, side: 33, target: self, action: #selector(no_settings), substrate_color: Colors.dark_gray)
        addSubview(no)
        no.translatesAutoresizingMaskIntoConstraints = false
        no.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 7).isActive = true
        no.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
    }
}

extension ProfileView {
    private func setAva() {
        addSubview(ava)
        ava.translatesAutoresizingMaskIntoConstraints = false
        ava.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        ava.topAnchor.constraint(equalTo: self.topAnchor, constant: 120).isActive = true
        ava.widthAnchor.constraint(equalToConstant: 150).isActive = true
        ava.heightAnchor.constraint(equalToConstant: 150).isActive = true
        ava.contentMode = .scaleAspectFill
        ava.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        ava.layer.cornerRadius = 10
        ava.layer.masksToBounds = true
        ava.image = UIImage(named: "default_profile")?.withRenderingMode(.alwaysOriginal)
        ava.isUserInteractionEnabled = false
    }
}

//extension ProfileView {
//    private func setUsername() {
//        addSubview(username)
//        username.translatesAutoresizingMaskIntoConstraints = false
//        username.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//        username.topAnchor.constraint(equalTo: self.ava.bottomAnchor, constant: 70).isActive = true
//        username.font = UIFont(name: "Montserrat-Bold", size: 24)
//        username.textAlignment = .center
//        username.textColor = .white
//        username.text = "stub"
//        username.isUserInteractionEnabled = false
//    }
//}

//extension ProfileView {
//    private func setEmail() {
//        addSubview(email)
//        email.translatesAutoresizingMaskIntoConstraints = false
//        email.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//        email.topAnchor.constraint(equalTo: username.topAnchor, constant: 50).isActive = true
//        email.font = UIFont(name: "PingFang-SC-Regular", size: 14)
//        email.textAlignment = .center
//        email.textColor = .white
//        email.text = "email@email.ru"
//        email.isUserInteractionEnabled = false
//    }
//}



extension ProfileView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selected = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            ava.image = selected
            //TODO: save in photo library if camera
        }
        delegateProfile?.dismissAlert()
    }
    
    @objc private func chooseAva() {
        let alert = UIAlertController(title: "Выберите изображение",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Галерея",
                                      style: .default,
                                      handler: { _ in { self.testAva.sourceType = .photoLibrary;
                                                        self.delegateProfile?.chooseAvatar(picker: self.testAva) }() }
            ))
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            alert.addAction(UIAlertAction(title: "Камера",
                                          style: .default,
                                          handler: { _ in { self.testAva.sourceType = .camera;
                                                            self.testAva.cameraCaptureMode = .photo
                                                            self.delegateProfile?.chooseAvatar(picker: self.testAva) }() }
            ))
        }
        alert.addAction(UIAlertAction(title: "Отменить", style: UIAlertAction.Style.cancel, handler: nil))
        delegateProfile?.showAlert(alert: alert)
    }
}
