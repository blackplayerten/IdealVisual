//
//  Buttons.swift
//  IdealVisual
//
//  Created by a.kurganova on 03/10/2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

struct Colors {
    static let orange = UIColor(red: 0.85, green: 0.41, blue: 0.28, alpha: 1)
    static let light_gray = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    static let dark_gray = UIColor(red: 0.32, green: 0.32, blue: 0.31, alpha: 1)
    static let dark_dark_gray = UIColor(red: 0.23, green: 0.23, blue: 0.23, alpha: 1)
}

class SubstrateButton: UIView {
    init(image: UIImage, side: CGFloat = 35, target: Any? = nil, action: Selector? = nil, substrate_color: UIColor? = nil) {
        super.init(frame: .zero)
        let button = UIButton(type: .system)
        if let t = target, let a = action {
            button.addTarget(t, action: a, for: .touchUpInside)
        }
        let substrate = UIImageView()
        substrate.image = image
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: side).isActive = true
        self.heightAnchor.constraint(equalToConstant: side).isActive = true
        self.layer.cornerRadius = 10
        self.backgroundColor = substrate_color
        
        self.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor).isActive = true
        button.widthAnchor.constraint(equalTo: self.safeAreaLayoutGuide.widthAnchor).isActive = true
        button.heightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.heightAnchor).isActive = true
        
        self.addSubview(substrate)
        substrate.translatesAutoresizingMaskIntoConstraints = false
        substrate.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor).isActive = true
        substrate.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor).isActive = true
        substrate.widthAnchor.constraint(equalToConstant: 0.7 * side).isActive = true
        substrate.heightAnchor.constraint(equalToConstant: 0.7 * side).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AddComponentsButton: UIButton {
    init(text: String) {
        super.init(frame: .zero)
        isUserInteractionEnabled = true
        backgroundColor = .white
        titleLabel?.text = text
        setTitle(self.titleLabel?.text, for: .normal)
        setTitleColor(Colors.dark_gray, for: .normal)
        titleLabel?.textColor = Colors.dark_gray
        titleLabel?.attributedText = NSMutableAttributedString(string: "",
                                                               attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 14)
        underlineText()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

class ContentField: UITextView {
    init(text: String? = nil) {
        super.init(frame: .zero, textContainer: nil)
        isScrollEnabled = false
        textContainer.lineBreakMode = NSLineBreakMode.byWordWrapping
        font = UIFont(name: "PingFang-SC-Regular", size: 14)
        self.text = text
        textAlignment = .left
        textColor = Colors.dark_gray
        isUserInteractionEnabled = false
        allowsEditingTextAttributes = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ProfileTable: UITableView, UITableViewDelegate, UITableViewDataSource {
    let identifyertableuser: String = "UserTableCell"
    let view: UIView
    var data = [User]()
    
    init(view: UIView) {
        self.view = view
        data = user
        super.init(frame: .zero, style: .plain)
        self.delegate = self
        self.dataSource = self
        self.register(UserTableCell.self, forCellReuseIdentifier: identifyertableuser)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifyertableuser, for: indexPath)
        if let mycell = cell as? UserTableCell {
            mycell.set()
            mycell.fill(with: data[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifyertableuser, for: indexPath) as! UserTableCell
        cell.editField()
    }
}

class UserTableCell: UITableViewCell {
    var usernameField = UITextField()
    var emailField = UILabel()
    var passwordField = UILabel()
    
    func fill(with model: User) {
        fillCells(with: model)
    }
    
    private func fillCells(with model: User) {
        usernameField.text = model.username
        emailField.text = model.email
        passwordField.text = model.password
    }
    
    func set() {
        setup()
    }
    
    private func setup() {
        self.backgroundColor = Colors.dark_gray
        self.isUserInteractionEnabled = true
        
        addSubview(usernameField)
        usernameField.isUserInteractionEnabled = false
        usernameField.translatesAutoresizingMaskIntoConstraints = false
        usernameField.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        usernameField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        addSubview(emailField)
        emailField.isUserInteractionEnabled = false
        emailField.translatesAutoresizingMaskIntoConstraints = false
        emailField.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        emailField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        addSubview(passwordField)
        passwordField.isUserInteractionEnabled = false
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        passwordField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    func editField() {
        edit()
    }
    
    private func edit() {
        self.backgroundColor = Colors.orange
        usernameField.isUserInteractionEnabled = true
        emailField.isUserInteractionEnabled = true
        passwordField.isUserInteractionEnabled = true
    }
}
