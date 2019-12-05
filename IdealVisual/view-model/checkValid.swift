//
//  checkValid.swift
//  IdealVisual
//
//  Created by a.kurganova on 05.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

typealias Validator = (InputFields, CheckMistakeLabel) -> Bool

func checkNotEmpty(field: InputFields, mistake: CheckMistakeLabel, message: String = "") -> Bool {
    let isValid = field.textField.text?.count != 0
    if isValid {
        field.setValidationState(isValid: true)
        mistake.isHidden = true
    } else {
        field.setValidationState(isValid: false)
        mistake.text = message
        mistake.isHidden = false
    }

    return isValid
}

func checkValidUsername(field: InputFields, mistake: CheckMistakeLabel) -> Bool {
    return checkNotEmpty(field: field, mistake: mistake, message: "Имя пользователя не может быть пустым")
}

func checkValidEmail(field: InputFields, mistake: CheckMistakeLabel) -> Bool {
    if !checkNotEmpty(field: field, mistake: mistake, message: "Электронная почта не может быть пустой") {
        return false
    }

    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)

    let isEmail = emailPred.evaluate(with: field.textField.text)
    if isEmail {
        field.setValidationState(isValid: true)
        mistake.isHidden = true
    } else {
        field.setValidationState(isValid: false)
        mistake.text = "Неверный формат почты"
        mistake.isHidden = false
    }

    return isEmail
}

func checkValidPassword(field: InputFields, mistake: CheckMistakeLabel) -> Bool {
    return checkNotEmpty(field: field, mistake: mistake, message: "Некорректный пароль")
}

func checkValidPasswordPair(field: InputFields, fieldRepeat: InputFields) -> Bool {
    var passwordsAreValid = true
    if field.textField.text != fieldRepeat.textField.text {
        passwordsAreValid = false

        if let mistakeLabel = field.mistakeLabel, let repeatMistakeLabel = fieldRepeat.mistakeLabel {
            if field.textField.text!.count < 8 {
                mistakeLabel.text = "Слабый пароль, пароли не совпадают"
            } else {
                mistakeLabel.text = "Пароли не совпадают"
            }
            if fieldRepeat.textField.text!.count < 8 {
                repeatMistakeLabel.text = "Слабый пароль, пароли не совпадают"
            } else {
                repeatMistakeLabel.text = "Пароли не совпадают"
            }
        }
    } else if field.textField.text!.count < 8 && fieldRepeat.textField.text!.count < 8 {
        passwordsAreValid = false

        if let mistakeLabel = field.mistakeLabel, let repeatMistakeLabel = fieldRepeat.mistakeLabel {
            mistakeLabel.text = "Слабый пароль"
            repeatMistakeLabel.text = "Слабый пароль"
        }
    }

    [field, fieldRepeat].forEach {
        if passwordsAreValid {
            $0.setValidationState(isValid: true)
        } else {
            $0.setValidationState(isValid: false)
        }
    }
    if let mistakeLabel = field.mistakeLabel, let repeatMistakeLabel = fieldRepeat.mistakeLabel {
        [mistakeLabel, repeatMistakeLabel].forEach {
            if passwordsAreValid {
                $0.isHidden = true
            } else {
                $0.isHidden = false
            }
        }
    }

    return passwordsAreValid
}
