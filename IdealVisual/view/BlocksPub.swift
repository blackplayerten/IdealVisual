////
////  FieldView.swift
////  IdealVisual
////
////  Created by a.kurganova on 25.10.2019.
////  Copyright © 2019 a.kurganova. All rights reserved.
////

import Foundation
import UIKit

class BlocksPub: UIView {
    private var icon: SubstrateButton
    private var icon_image: UIImage
    private let checkLabel = UILabel()
    private var lineTop = Line()
    private var lineBottom = Line()
    private var text_view: ContentField?
    private var add: AddComponentsButton?

    init(value: String? = nil, icon_image: UIImage, button_text: String, view: UIView) {
        self.icon_image = icon_image

        if value != nil {
            icon = SubstrateButton(image: self.icon_image, side: 45, substrate_color: Colors.blue)
        } else {
            icon = SubstrateButton(image: self.icon_image, side: 45, substrate_color: Colors.light_gray)
            add = AddComponentsButton(text: "Добавить \(button_text)")
            add?.addTarget(add, action: #selector(add32432), for: .touchUpInside)
        }
        super.init(frame: .zero)
        view.addSubview(self)
        
        addSubview(icon)
        icon.centerYAnchor.constraint(equalTo: self.topAnchor, constant: 60).isActive = true
        icon.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        
        if value != nil {
            renderReadingTextView(value: value)
        } else {
            addSubview(add!)
            add?.translatesAutoresizingMaskIntoConstraints = false
            add?.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20).isActive = true
            add?.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
            self.heightAnchor.constraint(equalTo: icon.heightAnchor).isActive = true
        }
    }
    
    @objc func add32432() {
        renderEditingTextView()
    }
    
    func editText() {
        renderEditingTextView()
    }

    private func renderEditingTextView() {
        add?.removeFromSuperview()
        icon.removeFromSuperview()
        guard let cancelImage = UIImage(named: "close") else { return }
        icon = SubstrateButton(image: cancelImage, side: 45, target: self, action: #selector(cancel), substrate_color: Colors.light_gray)
        addSubview(icon)
        icon.centerYAnchor.constraint(equalTo: self.topAnchor, constant: 60).isActive = true
        icon.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        text_view?.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20).isActive = true
        renderLines()
        setCheckLabel()
        setUIEnabled(state: true)
    }

    @objc private func cancel() {
        text_view?.removeFromSuperview()
        // TODO: think about editing non-empty text
    }

    private func renderReadingTextView(value: String? = nil) {
        text_view = ContentField(text: value)
        text_view?.font = UIFont(name: "PingFang-SC-Regular", size: 14)
        addSubview(text_view!)
        text_view?.translatesAutoresizingMaskIntoConstraints = false
        text_view?.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20).isActive = true
        text_view?.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        text_view?.topAnchor.constraint(equalTo: self.topAnchor, constant: 25).isActive = true
        self.heightAnchor.constraint(equalTo: text_view!.heightAnchor).isActive = true
    }

    private func renderLines() {
        [lineTop, lineBottom].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        lineTop.topAnchor.constraint(equalTo: self.topAnchor, constant: 1).isActive = true
        lineBottom.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 30).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func setUIEnabled(state: Bool) {
        text_view?.isUserInteractionEnabled = state
    }
    
    private func setCheckLabel() {
        self.addSubview(checkLabel)
        checkLabel.translatesAutoresizingMaskIntoConstraints = false
        checkLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        checkLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        checkLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        checkLabel.font = UIFont(name: "PingFang-SC-Regular", size: 14)
        
        checkLabel.text = "\(text_view?.text.count ?? 0) / 2200"
        guard let t = text_view?.text.count else { return }
        if t <= 2200 { checkLabel.textColor = Colors.dark_gray }
        else {
            checkLabel.textColor = .red
            text_view?.textColor = .red
        }
    }
}
