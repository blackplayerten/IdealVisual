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
//    private var line: Line?

    private var text_view: ContentField?
    private var add: AddComponentsButton?

    init(value: String? = nil, icon_image: UIImage, button_text: String, view: UIView) {
        self.icon_image = icon_image

        if value != nil {
            icon = SubstrateButton(image: self.icon_image, side: 45, substrate_color: Colors.blue)
        } else {
            icon = SubstrateButton(image: self.icon_image, side: 45, substrate_color: Colors.light_gray)
            add = AddComponentsButton(text: "Добавить \(button_text)")
            add?.addTarget(add, action: #selector(write_textview), for: .touchUpInside)
        }
        super.init(frame: .zero)
        view.addSubview(self)

        addSubview(icon)
        icon.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        icon.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true

        if value != nil {
            renderReadingTextView(value: value)
            let tap = UITapGestureRecognizer(target: icon, action: #selector(write_textview))
            icon.addGestureRecognizer(tap)
        } else {
            addSubview(add!)
            add?.translatesAutoresizingMaskIntoConstraints = false
            add?.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20).isActive = true
            add?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        }
    }

    @objc private func write_textview() {
        add?.removeFromSuperview()
        icon.removeFromSuperview()
        guard let cancelImage = UIImage(named: "close") else { return }
        icon = SubstrateButton(image: cancelImage, side: 45, target: icon, action: #selector(cancel), substrate_color: Colors.light_gray)
//        line
        renderReadingTextView()
//        line
    }

    @objc private func cancel() {
        text_view?.removeFromSuperview()
        // TODO: think about editing non-empty text
    }

    private func renderReadingTextView(value: String? = nil) {
//        renderLines()
        text_view = ContentField(text: value)
        addSubview(text_view!)
        text_view?.translatesAutoresizingMaskIntoConstraints = false
        text_view?.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20).isActive = true
        text_view?.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        text_view?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
//        renderLines()
    }

//    private func renderLines() {
//        line = Line()
//        addSubview(line!)
//        line?.translatesAutoresizingMaskIntoConstraints = false
//        line?.topAnchor.constraint(equalTo: text_view!.topAnchor, constant: 1).isActive = true
//        line?.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
//        line?.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
//    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUIEnabled(state: Bool) {
        text_view?.isUserInteractionEnabled = state
    }
}
