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
    func profile()
    func chooseAvatar(picker: UIImagePickerController)
    func showAlert(alert: UIAlertController)
    func dismissAlert()
}

class ProfileView: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private weak var delegateProfile: ProfileDelegate?
    
    private var height = NSLayoutConstraint()
    private let logout_button = UIButton()
    private let ava = UIImageView()
    private var testAva = UIImagePickerController()
    private let username = UITextField()
    private let email = UITextField()
    private let password = UITextField()
    private let repeat_password = UITextField()
    
    private let hide_keyboard = UITapGestureRecognizer(target: self, action: #selector(hide))
        
    //FIXME: fix tabbar flag
    var t = false
        
    init(profileDelegate: ProfileDelegate) {
        self.delegateProfile = profileDelegate
        super.init(frame: CGRect())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        height = self.heightAnchor.constraint(equalToConstant: 360)
        height.isActive = true
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = .up
        t = true
        swipe.addTarget(self, action: #selector(closeProfile))
        t = false
        self.addGestureRecognizer(swipe)
        
        guard let im_s = UIImage(named: "settings") else { return }
        let settings = ImageButton(image: im_s, side: 35, target: self, action: #selector(set_settings), buttonColor: Colors.orange)
        addSubview(settings)
        settings.translatesAutoresizingMaskIntoConstraints = false
        settings.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 17).isActive = true
        settings.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 17).isActive = true
        
        addSubview(logout_button)
        logout_button.translatesAutoresizingMaskIntoConstraints = false
        logout_button.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 17).isActive = true
        logout_button.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: -17).isActive = true
        logout_button.isUserInteractionEnabled = true
        logout_button.backgroundColor = Colors.dark_gray
        logout_button.titleLabel?.text = "Выйти"
        logout_button.setTitle(logout_button.titleLabel?.text, for: .normal)
        logout_button.setTitleColor(.white, for: .normal)
        logout_button.titleLabel?.textColor = .white
        logout_button.titleLabel?.attributedText = NSMutableAttributedString(string: "Выйти",
                                                                             attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        logout_button.titleLabel?.font = UIFont(name: "OpenSans-SemiBold", size: 18)
        logout_button.underlineText()
        logout_button.addTarget(self, action: #selector(logout), for: .touchUpInside)
        
        testAva.delegate = self
        testAva.allowsEditing = true
        
        addSubview(ava)
        ava.translatesAutoresizingMaskIntoConstraints = false
        ava.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        ava.topAnchor.constraint(equalTo: settings.topAnchor, constant: 60).isActive = true
        ava.widthAnchor.constraint(equalToConstant: 150).isActive = true
        ava.heightAnchor.constraint(equalToConstant: 150).isActive = true
        ava.image = UIImage(named: "test")?.withRenderingMode(.alwaysOriginal)
        ava.isUserInteractionEnabled = false
        
        addSubview(username)
        username.translatesAutoresizingMaskIntoConstraints = false
        username.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        username.topAnchor.constraint(equalTo: self.ava.topAnchor, constant: 170).isActive = true
        username.font = UIFont(name: "OpenSans-Bold", size: 24)
        username.textAlignment = .center
        username.textColor = .white
        username.text = "stub"
        username.isUserInteractionEnabled = false
        
        addSubview(email)
        email.translatesAutoresizingMaskIntoConstraints = false
        email.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        email.topAnchor.constraint(equalTo: username.topAnchor, constant: 50).isActive = true
        email.font = UIFont(name: "OpenSans-Regular", size: 14)
        email.textAlignment = .center
        email.textColor = .white
        email.text = "email@email.ru"
        email.isUserInteractionEnabled = false
        
        password.isHidden = true
        addSubview(password)
        password.translatesAutoresizingMaskIntoConstraints = false
        password.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        password.topAnchor.constraint(equalTo: email.topAnchor, constant: 40).isActive = true
        password.font = UIFont(name: "OpenSans-Regular", size: 14)
        password.textAlignment = .center
        password.textColor = .white
        password.placeholder = "Пароль"
        password.attributedPlaceholder = NSAttributedString(string: password.placeholder!,
                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        
        repeat_password.isHidden = true
        addSubview(repeat_password)
        repeat_password.translatesAutoresizingMaskIntoConstraints = false
        repeat_password.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        repeat_password.topAnchor.constraint(equalTo: password.topAnchor, constant: 40).isActive = true
        repeat_password.font = UIFont(name: "OpenSans-Regular", size: 14)
        repeat_password.textAlignment = .center
        repeat_password.textColor = .white
        repeat_password.placeholder = "Подтвердите пароль"
        repeat_password.attributedPlaceholder = NSAttributedString(string: repeat_password.placeholder!,
                                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
    }
    
    @objc private func set_settings() {
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(hide_keyboard)
        
        
        height.isActive = false
        let new_height = self.heightAnchor.constraint(equalToConstant: 440)
        new_height.isActive = true
        
        guard let im_yes = UIImage(named: "yes") else { return }
        let yes = ImageButton(image: im_yes, side: 35, target: self, action: #selector(save_settings), buttonColor: Colors.orange)
        addSubview(yes)
        yes.translatesAutoresizingMaskIntoConstraints = false
        yes.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 17).isActive = true
        yes.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 17).isActive = true
        
        logout_button.isHidden = true
        guard let im_no = UIImage(named: "close") else { return }
        let no = ImageButton(image: im_no, side: 35, target: self, action: #selector(no_settings), buttonColor: Colors.dark_dark_gray)
        addSubview(no)
        no.translatesAutoresizingMaskIntoConstraints = false
        no.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 17).isActive = true
        no.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: -17).isActive = true
        
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selected = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //FIXME: fix crop image
            ava.image = selected
            //TODO: save in photo library if camera
        }
        delegateProfile?.dismissAlert()
    }
    
    @objc private func save_settings() {
        
    }
    
    @objc private func no_settings() {
        removeFromSuperview()
    }
    
    @objc private func logout() {
        
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
    
    @objc func closeProfile() {
        t = false
        removeFromSuperview()
    }
    
    @objc private func hide() {
        self.endEditing(true)
    }
}

extension UIButton {
  func underlineText() {
    guard let title = title(for: .normal) else { return }
    let titleString = NSMutableAttributedString(string: title)
    titleString.addAttribute(
      .underlineStyle,
      value: NSUnderlineStyle.single.rawValue,
      range: NSRange(location: 0, length: title.count)
    )
    setAttributedTitle(titleString, for: .normal)
  }
}
