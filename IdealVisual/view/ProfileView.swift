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
}

class ProfileView: UIView {
    weak var delegateProfile: ProfileDelegate?
    
    func setup() {
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = .up
        swipe.addTarget(self, action: #selector(closeProfile))
        self.addGestureRecognizer(swipe)
        
        guard let im_s = UIImage(named: "settings") else { return }
        let settings = ImageButton(image: im_s, side: 35, target: self, action: #selector(set_settings), buttonColor: Colors.orange)
        addSubview(settings)
        settings.translatesAutoresizingMaskIntoConstraints = false
        settings.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 17).isActive = true
        settings.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 17).isActive = true
        
        let logout_button = UIButton()
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
        
        let ava = UIImageView()
        addSubview(ava)
        ava.translatesAutoresizingMaskIntoConstraints = false
        ava.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        ava.topAnchor.constraint(equalTo: settings.topAnchor, constant: 60).isActive = true
        ava.widthAnchor.constraint(equalToConstant: 150).isActive = true
        ava.heightAnchor.constraint(equalToConstant: 150).isActive = true
        ava.image = UIImage(named: "test")?.withRenderingMode(.alwaysOriginal)
        
        let username = UILabel()
        addSubview(username)
        username.translatesAutoresizingMaskIntoConstraints = false
        username.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        username.topAnchor.constraint(equalTo: ava.topAnchor, constant: 170).isActive = true
        username.font = UIFont(name: "OpenSans-Bold", size: 24)
        username.textAlignment = .center
        username.textColor = .white
        username.text = "mary_autumn"
        
        let email = UILabel()
        addSubview(email)
        email.translatesAutoresizingMaskIntoConstraints = false
        email.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        email.topAnchor.constraint(equalTo: username.topAnchor, constant: 50).isActive = true
        email.font = UIFont(name: "OpenSans-Regular", size: 14)
        email.textAlignment = .center
        email.textColor = .white
        email.text = "mary1992@mail.ru"
    }
    
    @objc private func set_settings() {
        
    }
    
    @objc private func logout() {
        
    }
    
    @objc func closeProfile() {
        self.removeFromSuperview()
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
