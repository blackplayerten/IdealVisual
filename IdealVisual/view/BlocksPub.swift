////
////  BlocksPub.swift
////  IdealVisual
////
////  Created by a.kurganova on 25.10.2019.
////  Copyright © 2019 a.kurganova. All rights reserved.
////

import Foundation
import UIKit

class BlocksPub: UIView {
    private var icon: SubstrateButton
    private var iconImage: UIImage
    private let checkLabel = UILabel()
    private var lineTop = Line()
    private var lineBottom = Line()
    private var buttonSave = AddComponentsButton(text: "Сохранить")
    private var textView: ContentField?
    private var addButton: AddComponentsButton?
    private var datePicker: DatePickerBlock?
    private var bottomA = NSLayoutConstraint()

    init(value: String? = nil, iconImage: UIImage, buttonIext: String, datePicker: DatePickerBlock? = nil,
         view: UIView) {
        self.iconImage = iconImage
        self.datePicker = datePicker

        if value != nil || datePicker != nil {
            icon = SubstrateButton(image: self.iconImage, side: 45, substrateColor: Colors.blue)
        } else {
            icon = SubstrateButton(image: self.iconImage, side: 45, substrateColor: Colors.darkGray)
            addButton = AddComponentsButton(text: "Добавить \(buttonIext)")
            addButton?.setColor(state: false)
        }
        super.init(frame: .zero)
        view.addSubview(self)
        rerenderIcon(icon: icon)

        if value != nil || datePicker != nil {
            if datePicker != nil {
                renderPicker(datePicker: datePicker)
            } else {
                renderReadingTextView(value: value)
            }
        } else {
            addSubview(addButton!)
            addButton?.translatesAutoresizingMaskIntoConstraints = false
            addButton?.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20).isActive = true
            addButton?.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
            addButton?.addTarget(self, action: #selector(editTV), for: .touchUpInside)
            bottomA = self.bottomAnchor.constraint(equalTo: icon.bottomAnchor, constant: 20)
            bottomA.isActive = true
        }
    }

    @objc private func editTV() {
        if datePicker != nil {
            renderEditingDate()
        } else {
            renderEditingTextView()
        }
    }

    func editBlocks() {
        if datePicker != nil {
            renderEditingDate()
        } else {
            renderEditingTextView()
        }
    }

    private func rerenderIcon(icon: SubstrateButton) {
        addSubview(icon)
        icon.centerYAnchor.constraint(equalTo: self.topAnchor, constant: 60).isActive = true
        icon.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
    }

    private func renderDecorateForEditing() {
         [lineTop, lineBottom, checkLabel, buttonSave].forEach {
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        lineTop.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        if textView?.text != nil {
            lineBottom.bottomAnchor.constraint(equalTo: textView!.bottomAnchor, constant: 3).isActive = true
            checkLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
            checkLabel.topAnchor.constraint(equalTo: lineTop.bottomAnchor, constant: 5).isActive = true
            checkLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            checkLabel.font = UIFont(name: "PingFang-SC-Regular", size: 14)

            checkLabel.text = "\(textView?.text.count ?? 0) / 2200"
            guard let textViewCount = textView?.text.count else { return }
            if textViewCount <= 2200 { checkLabel.textColor = Colors.darkGray } else { checkLabel.textColor = .red }
        } else {
            lineBottom.bottomAnchor.constraint(equalTo: datePicker!.bottomAnchor, constant: 3).isActive = true
        }
        buttonSave.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -1).isActive = true
        buttonSave.topAnchor.constraint(equalTo: lineBottom.bottomAnchor, constant: 1).isActive = true
        buttonSave.addTarget(self, action: #selector(saveTVContent), for: .touchUpInside)
        buttonSave.setColor(state: true)
    }

    private func renderReadingTextView(value: String? = nil) {
        setUIEnabled(state: false)
        [lineTop, checkLabel, lineBottom, buttonSave].forEach { $0.removeFromSuperview() }

        textView = ContentField(text: value)
        textView?.setTVColor(state: false)
        textView?.font = UIFont(name: "PingFang-SC-Regular", size: 14)
        addSubview(textView!)
        textView?.translatesAutoresizingMaskIntoConstraints = false
        textView?.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20).isActive = true
        textView?.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textView?.topAnchor.constraint(equalTo: self.topAnchor, constant: 25).isActive = true

        self.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bottomA = self.bottomAnchor.constraint(equalTo: textView!.bottomAnchor)
        bottomA.isActive = true
    }

     private func renderEditingTextView() {
            if textView?.text != nil {
                addButton?.removeFromSuperview()
                icon.removeFromSuperview()
                renderDecorateForEditing()
                guard let cancelImage = UIImage(named: "close") else { return }
                icon = SubstrateButton(image: cancelImage, side: 45, target: self, action: #selector(cancel),
                                       substrateColor: Colors.lightGray)
                rerenderIcon(icon: icon)
                textView?.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20).isActive = true
                textView?.setTVColor(state: true)
                setUIEnabled(state: true)

                bottomA.isActive = false
                bottomA = self.bottomAnchor.constraint(equalTo: buttonSave.bottomAnchor)
                bottomA.isActive = true
            } else {
    //            //TODO: textview on tap edit
    //            addButton?.removeFromSuperview()
    //            icon.removeFromSuperview()
    //            renderDecorateForEditing()
    //            guard let cancelImage = UIImage(named: "close") else { return }
    //            icon = SubstrateButton(image: cancelImage, side: 45, target: self, action: #selector(cancel),
    //                                   substrateColor: Colors.lightGray)
    //            rerenderIcon(icon: icon)
    //            textView?.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20).isActive = true
    //            textView?.setTVColor(state: true)
    //            setUIEnabled(state: true)
    //
    //            bottomA.isActive = false
    //            bottomA = self.bottomAnchor.constraint(equalTo: buttonSave.bottomAnchor)
    //            bottomA.isActive = true
            }
        }

    private func renderPicker(datePicker: DatePickerBlock? = nil) {
            [lineTop, checkLabel, lineBottom, buttonSave].forEach { $0.removeFromSuperview() }
            if datePicker != nil {
                guard let datePicker = datePicker else { return }
                addSubview(datePicker)
                datePicker.translatesAutoresizingMaskIntoConstraints = false
                datePicker.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20).isActive = true
                datePicker.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
                datePicker.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
                datePicker.setEditingMode(state: false)
            }
        }

    private func renderEditingDate() {
        if datePicker != nil {
            addButton?.removeFromSuperview()
            icon.removeFromSuperview()
            guard let cancelImage = UIImage(named: "close") else { return }
            icon = SubstrateButton(image: cancelImage, side: 45, target: self, action: #selector(cancel),
                                   substrateColor: Colors.lightGray)
            rerenderIcon(icon: icon)
            renderDecorateForEditing()
            datePicker?.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20).isActive = true
            datePicker?.setEditingMode(state: true)

            bottomA.isActive = false
            bottomA = self.bottomAnchor.constraint(equalTo: buttonSave.bottomAnchor)
            bottomA.isActive = true
        }
    }

    @objc private func saveTVContent() {
         print("save")
         icon = SubstrateButton(image: self.iconImage, side: 45, substrateColor: Colors.blue)
         rerenderIcon(icon: icon)
         if datePicker != nil {
             renderPicker(datePicker: datePicker)
         } else {
            renderReadingTextView(value: textView?.text)
        }
    }

    @objc private func cancel() {

        icon = SubstrateButton(image: self.iconImage, side: 45, substrateColor: Colors.blue)
        rerenderIcon(icon: icon)
        if datePicker != nil {
            renderPicker(datePicker: datePicker)
        } else {
            renderReadingTextView(value: textView?.text)
        }
           // TODO: think about editing non-empty text
       }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func setUIEnabled(state: Bool) {
        textView?.isUserInteractionEnabled = state
    }
}
