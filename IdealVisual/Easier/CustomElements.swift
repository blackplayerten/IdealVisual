//
//  CustomElements.swift
//  IdealVisual
//
//  Created by a.kurganova on 03/10/2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

struct Colors {
    static let blue = UIColor(red: 0.008, green: 0.333, blue: 0.631, alpha: 1)
    static let lightBlue = UIColor(red: 0.094, green: 0.565, blue: 1, alpha: 1)
    static let yellow = UIColor(red: 0.98, green: 0.678, blue: 0.078, alpha: 1)
    static let lightGray = UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1)
    static let darkGray = UIColor(red: 0.741, green: 0.741, blue: 0.741, alpha: 1)
    static let darkDarkGray = UIColor(red: 0.23, green: 0.23, blue: 0.23, alpha: 1)
}

// MARK: - substrate button
final class SubstrateButton: UIView {
    init(image: UIImage, side: CGFloat = 35, target: Any? = nil, action: Selector? = nil,
         substrateColor: UIColor? = nil) {
        super.init(frame: .zero)
        let button = UIButton(type: .system)
        if let target = target, let action = action {
            button.addTarget(target, action: action, for: .touchUpInside)
        }
        let substrate = UIImageView()
        substrate.image = image
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: side).isActive = true
        heightAnchor.constraint(equalToConstant: side).isActive = true
        layer.cornerRadius = 10
        backgroundColor = substrateColor

        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        button.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        button.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true

        addSubview(substrate)
        substrate.translatesAutoresizingMaskIntoConstraints = false
        substrate.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        substrate.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        substrate.widthAnchor.constraint(equalToConstant: 0.7 * side).isActive = true
        substrate.heightAnchor.constraint(equalToConstant: 0.7 * side).isActive = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - add button
final class AddComponentsButton: UIButton {
    init(text: String) {
        super.init(frame: .zero)
        backgroundColor = .white
        titleLabel?.text = text
        setTitle(self.titleLabel?.text, for: .normal)
        titleLabel?.attributedText = NSMutableAttributedString(string: "",
                                attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 14)
        underlineText()
    }

    func setColor(state: Bool) {
        if state == true {
            titleLabel?.textColor = Colors.yellow
        } else {
            titleLabel?.textColor = Colors.darkGray
        }
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

// MARK: - date picker
final class DatePickerComponent: UIDatePicker {
    init(datePicker: UIDatePicker? = nil) {
        super.init(frame: .zero)
        locale = Locale(identifier: "ru")
        addTarget(self, action: #selector(chooseDate(_:)), for: .valueChanged)
    }

    @objc func chooseDate(_ sender: UIDatePicker) {
        _ = Calendar.current.dateComponents([.day, .month, .timeZone], from: sender.date)
        minimumDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
        layer.cornerRadius = 20
    }

    func setEditingMode(state: Bool) {
        if state == true {
            isUserInteractionEnabled = true
        } else {
            isUserInteractionEnabled = false
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - text view
final class TextViewComponent: UITextView, UITextViewDelegate {
    private let countCB: (Int) -> Void
    private let beginEditing: () -> Void
    private let endEditing: () -> Void

    init(text: String? = nil, countCB: @escaping (Int) -> Void,
         beginEditing: @escaping () -> Void, endEditing: @escaping () -> Void) {
        self.countCB = countCB
        self.beginEditing = beginEditing
        self.endEditing = endEditing
        super.init(frame: .zero, textContainer: nil)
        self.delegate = self
        isScrollEnabled = false
        textContainer.lineBreakMode = NSLineBreakMode.byWordWrapping
        font = UIFont(name: "PingFang-SC-Regular", size: 14)
        self.text = text
        textAlignment = .left
        allowsEditingTextAttributes = true
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        beginEditing()
        return true
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        endEditing()
        return true
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = (textView.text!.count + text.count) - range.length
        countCB(newLength)

        return true
    }

    func changeTextViewColorWhileEditing(editingMode: Bool) {
        if editingMode == true {
            textColor = Colors.darkDarkGray
        } else {
            textColor = Colors.darkGray
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - top/botto line in block post
final class Line: UIView {
    init() {
        super.init(frame: .zero)
        let line = CGRect(x: 0, y: 0, width: 355, height: 1.0)
        let view = UIView(frame: line)
        view.backgroundColor = Colors.lightGray
        addSubview(view)
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - line for swipe in profile view
final class LineClose: UIView {
    init() {
        super.init(frame: .zero)
        let line = CGRect(x: 0, y: 0, width: 50, height: 4.0)
        let view = UIView(frame: line)
        view.backgroundColor = Colors.darkGray
        addSubview(view)
        view.heightAnchor.constraint(equalToConstant: 4).isActive = true
        view.layer.cornerRadius = 3
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - text field
final class InputFields: UIView, UITextFieldDelegate {
    let blockView = UIView()

    let textField = UITextField()
    let labelMode = UILabel()
    let labelImage = UIImage()

    let mistakeLabel: CheckMistakeLabel?
    private let validator: Validator?

    init(labelImage: UIImage? = nil, text: String? = nil, placeholder: String? = nil,
         textContentType: UITextContentType? = nil, keyboardType: UIKeyboardType = .default,
         validator: Validator? = nil) {
        self.validator = validator
        if validator != nil {
            self.mistakeLabel = CheckMistakeLabel()
        } else {
            self.mistakeLabel = nil
        }

        super.init(frame: .zero)
        addSubview(blockView)
        blockView.translatesAutoresizingMaskIntoConstraints = false
        blockView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        blockView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        blockView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        blockView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        [textField, labelMode].forEach {
            blockView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.borderWidth = 0.5
        layer.cornerRadius = 10

        let font1 = UIFont(name: "PingFang-SC-SemiBold", size: 14)
        let font2 = UIFont(name: "PingFang-SC-Regular", size: 14)

        textField.delegate = self
        textField.text = text
        textField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        textField.font = font2
        textField.textAlignment = .left
        textField.setContentHuggingPriority(UILayoutPriority(rawValue: 1), for: .horizontal)
        textField.placeholder = placeholder
        let attrPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: [
            NSAttributedString.Key.foregroundColor: Colors.lightGray,
            NSAttributedString.Key.font: font1 as Any
        ])
        textField.attributedPlaceholder = attrPlaceholder

        textField.textContentType = textContentType
        textField.keyboardType = keyboardType
        if textContentType == .password || textContentType == .newPassword {
            textField.isSecureTextEntry = true
        }
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none

        labelMode.leftAnchor.constraint(equalTo: textField.rightAnchor, constant: 10).isActive = true
        guard let tvCount = textField.text?.count else { return }
        labelMode.text = "\(tvCount)/50"
        labelMode.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        labelMode.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        labelMode.heightAnchor.constraint(equalToConstant: 30).isActive = true
        labelMode.textColor = Colors.darkGray
        labelMode.font = font2
        labelMode.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 2000), for: .horizontal)

        if let mistakeLabel = mistakeLabel {
            addSubview(mistakeLabel)
            mistakeLabel.translatesAutoresizingMaskIntoConstraints = false

            mistakeLabel.topAnchor.constraint(equalTo: bottomAnchor).isActive = true
            mistakeLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
        }

        let labelIV = UIImageView()
        addSubview(labelIV)
        labelIV.translatesAutoresizingMaskIntoConstraints = false
        labelIV.image = labelImage
        labelIV.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        labelIV.rightAnchor.constraint(equalTo: textField.leftAnchor, constant: -30).isActive = true
        labelIV.layer.masksToBounds = true
        labelIV.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        labelIV.heightAnchor.constraint(equalToConstant: 20).isActive = true
        labelIV.widthAnchor.constraint(equalToConstant: 20).isActive = true
        labelIV.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 2000), for: .horizontal)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let text = textField.text {
            let currentString: NSString = text as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString

            textField.text = newString as String

            _ = isValid()

            textField.text = currentString as String
        }

        let newLength = (textField.text!.count + string.count) - range.length
        if newLength <= 50 {
            self.labelMode.text = "\(newLength)/50"
            return true
        } else {
            return false
        }
    }

    func isValid() -> Bool {
        var success = true
        if let validator = validator {
            guard let mistakeLabel = mistakeLabel else { return true }
            success = validator(self, mistakeLabel)
        }

        return success
    }

    func setEditFields(state: Bool) {
        if state {
            layer.borderColor = Colors.lightBlue.cgColor
        } else {
            layer.borderColor = Colors.darkGray.cgColor
        }
        labelMode.isHidden = !state
        textField.isUserInteractionEnabled = state
    }

    func setValidationState(isValid: Bool) {
        if isValid {
            layer.borderColor = Colors.lightBlue.cgColor
        } else {
            layer.borderColor = UIColor.red.cgColor
        }
    }

    func clearState() {
        if let text = textField.text {
            self.labelMode.text = "\(text.count)/50"
        } else {
            self.labelMode.text = String(50)
        }
        mistakeLabel?.isHidden = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - mistakes on text field
final class CheckMistakeLabel: UILabel {
    init(text: String? = nil) {
        super.init(frame: .zero)
        heightAnchor.constraint(equalToConstant: 20).isActive = true
        widthAnchor.constraint(equalToConstant: 300).isActive = true
        self.text = text
        font = UIFont(name: "PingFang-SC-SemiBold", size: 12)
        textColor = .red
        textAlignment = .left
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
