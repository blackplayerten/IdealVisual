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

    init(value: String? = nil, iconImage: UIImage, buttonIext: String, view: UIView) {
        self.iconImage = iconImage

        if value != nil {
            icon = SubstrateButton(image: self.iconImage, side: 45, substrateColor: Colors.blue)
        } else {
            icon = SubstrateButton(image: self.iconImage, side: 45, substrateColor: Colors.darkGray)
            addButton = AddComponentsButton(text: "Добавить \(buttonIext)")
            addButton?.setColor(state: false)
        }
        super.init(frame: .zero)
        view.addSubview(self)
        rerenderIcon(icon: icon)

        if value != nil {
            renderReadingTextView(value: value)
        } else {
            addSubview(addButton!)
            addButton?.translatesAutoresizingMaskIntoConstraints = false
            addButton?.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20).isActive = true
            addButton?.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
            self.heightAnchor.constraint(equalTo: icon.heightAnchor).isActive = true
            addButton?.addTarget(addButton, action: #selector(editTV), for: .touchUpInside)
        }
    }

    @objc private func editTV() {
        renderEditingTextView()
    }

    func editText() {
        renderEditingTextView()

        // edit one field separate
//        if textView?.text != nil {
//        icon = SubstrateButton(image: iconImage.self, side: 45, target: self, action: #selector(editTV),
//                               substrateColor: Colors.blue)
//        rerenderIcon(icon: icon)
//        }
    }

    private func renderEditingTextView() {
        if textView?.text != nil {
            [lineTop, lineBottom, checkLabel, buttonSave].forEach {
                self.addSubview($0)
                $0.translatesAutoresizingMaskIntoConstraints = false
            }
            lineTop.topAnchor.constraint(equalTo: self.topAnchor, constant: 1).isActive = true
            lineBottom.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 30).isActive = true

            checkLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
            checkLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
            checkLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            checkLabel.font = UIFont(name: "PingFang-SC-Regular", size: 14)

            checkLabel.text = "\(textView?.text.count ?? 0) / 2200"
            guard let textViewCount = textView?.text.count else { return }
            if textViewCount <= 2200 { checkLabel.textColor = Colors.darkGray } else { checkLabel.textColor = .red }

            buttonSave.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -1).isActive = true
            buttonSave.topAnchor.constraint(equalTo: lineBottom.bottomAnchor, constant: 1).isActive = true
            self.heightAnchor.constraint(equalTo: icon.heightAnchor).isActive = true
            buttonSave.addTarget(self, action: #selector(saveTVContent), for: .touchUpInside)
            buttonSave.setColor(state: true)

            addButton?.removeFromSuperview()
            icon.removeFromSuperview()
            guard let cancelImage = UIImage(named: "close") else { return }
            icon = SubstrateButton(image: cancelImage, side: 45, target: self, action: #selector(cancel),
                                   substrateColor: Colors.lightGray)
            rerenderIcon(icon: icon)
            textView?.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20).isActive = true
            textView?.setTVColor(state: true)
            setUIEnabled(state: true)
        } else {
            addSubview(addButton!)
        }
    }

    @objc private func cancel() {
        icon = SubstrateButton(image: self.iconImage, side: 45, substrateColor: Colors.blue)
        rerenderIcon(icon: icon)
        renderReadingTextView(value: textView?.text)
        // TODO: think about editing non-empty text
    }

    @objc private func saveTVContent() {
        icon = SubstrateButton(image: self.iconImage, side: 45, substrateColor: Colors.blue)
        rerenderIcon(icon: icon)
        renderReadingTextView(value: textView?.text)
   }

    private func rerenderIcon(icon: SubstrateButton) {
        addSubview(icon)
        icon.centerYAnchor.constraint(equalTo: self.topAnchor, constant: 60).isActive = true
        icon.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
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
        self.heightAnchor.constraint(equalTo: textView!.heightAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func setUIEnabled(state: Bool) {
        textView?.isUserInteractionEnabled = state
    }
}
