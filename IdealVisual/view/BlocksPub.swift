//
//  BlocksPub.swift
//  IdealVisual
//
//  Created by a.kurganova on 25.10.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

protocol BlockDelegate: class {
    func updateBlock(from: BlockPost)
}

final class BlockPost: UIView {
    private let delegatePost: BlockDelegate?
    private var icon: SubstrateButton
    private var iconImage: UIImage
    private let checkLabel = UILabel()
    private var lineTop = Line()
    private var lineBottom = Line()
    private var buttonSave = AddComponentsButton(text: "Сохранить")
    var textView: TextViewComponent?
    var datePicker: DatePickerComponent?
    private var topAnchorTextOrPicker: NSLayoutConstraint?
    private var bottomAnchorTextOrPicker: NSLayoutConstraint?
    private var addButton: AddComponentsButton?
    private var blockPostType: BlockPostType

    struct State {
        var date = Date(timeIntervalSince1970: 0)
        var place = ""
        var post = ""
    }

    private var state = State()

// MARK: - init
    init(textValue: String? = nil, iconImage: UIImage, buttonIext: String, datePicker: DatePickerComponent? = nil,
         view: UIView, blockPostType: BlockPostType, delegatePost: BlockDelegate? = nil) {
        self.iconImage = iconImage
        self.blockPostType = blockPostType

        if textValue != nil && textValue != "" ||
            datePicker != nil && datePicker?.date != Date(timeIntervalSince1970: 0) {
            icon = SubstrateButton(image: self.iconImage, side: 45, substrateColor: Colors.blue)
        } else {
            icon = SubstrateButton(image: self.iconImage, side: 45, substrateColor: Colors.darkGray)
            addButton = AddComponentsButton(text: buttonIext)
            addButton?.setColor(state: false)
        }
        self.delegatePost = delegatePost
        super.init(frame: .zero)

        view.addSubview(self)
        renderSubstrateIcon()

        switch blockPostType {
        case .datePicker:
            if datePicker == nil || datePicker?.date == Date(timeIntervalSince1970: 0) {
                renderAddButton()
                return
            }
        case .textView:
            if textValue == nil || textValue == "" {
                renderAddButton()
                return
            }
        }

        setBlockElement(value: textValue, editingMode: false)
    }

// MARK: - add button
    private func renderAddButton() {
        guard let addButton = addButton else { return }
        addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false

        addButton.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20).isActive = true
        addButton.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true

        addButton.addTarget(self, action: #selector(objc_SetEditingBlock), for: .touchUpInside)
        addButton.setColor(state: false)
    }

    // MARK: - render block elemnts: datePicker or textView without editing mode
    private func setBlockElement(value: String? = nil, editingMode: Bool) {
        var alreadyInited = false
        let view: UIView
        switch blockPostType {
        case .textView:
            if textView == nil {
                textView = TextViewComponent(text: value)
            } else {
                alreadyInited = true
            }
            textView?.changeTextViewColorWhileEditing(editingMode: editingMode)
            guard let textView = textView else { return }
            view = textView
        case .datePicker:
            if datePicker == nil {
                datePicker = DatePickerComponent(datePicker: datePicker)
            } else {
                alreadyInited = true
            }
            guard let datePicker = datePicker else { return }
            view = datePicker
        }

        view.isUserInteractionEnabled = editingMode
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false

        reinitLeftAndRightConstraints(view: view)

        if alreadyInited {
            return
        }

        if let topAnchorTextOrPicker = topAnchorTextOrPicker {
            self.removeConstraint(topAnchorTextOrPicker)
        }
        topAnchorTextOrPicker = view.topAnchor.constraint(equalTo: topAnchor)
        topAnchorTextOrPicker?.isActive = true

        if let bottomAnchorTextOrPicker = bottomAnchorTextOrPicker {
            self.removeConstraint(bottomAnchorTextOrPicker)
        }
        bottomAnchorTextOrPicker = view.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottomAnchorTextOrPicker?.isActive = true
    }

    private func reinitLeftAndRightConstraints(view: UIView) {
        view.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }

    @objc
    private func objc_SetEditingBlock() {
        addButton?.removeFromSuperview()

        icon.removeFromSuperview()
        icon = SubstrateButton(image: UIImage(named: "close")!, side: 45, target: self,
                               action: #selector(cancel), substrateColor: Colors.lightGray)
        renderSubstrateIcon()

        setBlockElement(editingMode: true)

        renderEditElements()
    }

    func setEditingBlock() {
        objc_SetEditingBlock()
    }

    private func renderSubstrateIcon() {
        addSubview(icon)

        icon.topAnchor.constraint(equalTo: self.topAnchor, constant: 60).isActive = true
        icon.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
    }

// MARK: - render editing elements
    private func renderEditElements() {
        [lineTop, lineBottom, buttonSave].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        guard var topAnchorTextOrPicker = topAnchorTextOrPicker,
                var bottomAnchorTextOrPicker = bottomAnchorTextOrPicker
        else { return }
        [topAnchorTextOrPicker, bottomAnchorTextOrPicker].forEach {$0.isActive = false }
        removeConstraints([topAnchorTextOrPicker, bottomAnchorTextOrPicker])

        lineTop.topAnchor.constraint(equalTo: topAnchor).isActive = true

        let view: UIView
        switch blockPostType {
        case .textView:
            guard let textView = textView else { return }
            view = textView
            renderCheckLabel()

            topAnchorTextOrPicker = view.topAnchor.constraint(equalTo: checkLabel.bottomAnchor)
        case .datePicker:
            guard let datePicker = datePicker else { return }
            view = datePicker

            topAnchorTextOrPicker = view.topAnchor.constraint(equalTo: lineTop.bottomAnchor)
        }

        topAnchorTextOrPicker.isActive = true

        bottomAnchorTextOrPicker = view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -45)
        bottomAnchorTextOrPicker.isActive = true

        renderSaveButton()
        lineBottom.bottomAnchor.constraint(equalTo: buttonSave.topAnchor, constant: -5).isActive = true
    }

// MARK: checklabel
    private func renderCheckLabel() {
        addSubview(checkLabel)
        checkLabel.translatesAutoresizingMaskIntoConstraints = false

        checkLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        checkLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        checkLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        guard let charactersCount = textView?.text.count else { return }
        checkLabel.text = "\(charactersCount) / 2200"
        if charactersCount <= 2200 {
            checkLabel.textColor = Colors.darkGray
        } else {
            checkLabel.textColor = .red
        }
    }

// MARK: save button
    private func renderSaveButton() {
        buttonSave.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        buttonSave.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3).isActive = true
        buttonSave.addTarget(self, action: #selector(save), for: .touchUpInside)
        buttonSave.setColor(state: true)
    }

    // MARK: - cancel or save editing, set constraints to initial values
    @objc private func save() {
        finishEditing(commitChanges: true)
    }

    @objc private func cancel() {
        finishEditing(commitChanges: false)
    }

    private func finishEditing(commitChanges: Bool) {
        removeDecorateElements()

        icon.removeFromSuperview()

        var contentIsNotNil = true
        switch blockPostType {
        case .datePicker:
            guard let datePicker = datePicker else { return }
            // TODO: get date picker input value
            if true {
                contentIsNotNil = false
            }
            if commitChanges {
                delegatePost?.updateBlock(from: self)
            } else {
                datePicker.date = state.date
            }
        case .textView:
            guard let textView = textView else { return }
            if textView.text == nil || textView.text.count == 0 { // check
                contentIsNotNil = false
            }
            if commitChanges {
                // save
                delegatePost?.updateBlock(from: self)
            } else {
//                textView.text = state.text
            }
        }

        // content is not nil: render blue icon, set block element with non-editing mode
        if contentIsNotNil {
            icon = SubstrateButton(image: self.iconImage, side: 45, substrateColor: Colors.blue)
            renderSubstrateIcon()

            setBlockElement(editingMode: false)
        } else {
            removeBlockElement()

            icon = SubstrateButton(image: self.iconImage, side: 45, substrateColor: Colors.darkGray)
            renderSubstrateIcon()

            renderAddButton()
        }
    }

    private func removeBlockElement() {
        switch blockPostType {
        case .textView:
            textView?.removeFromSuperview()
            textView = nil
        case .datePicker:
            datePicker?.removeFromSuperview()
            datePicker = nil
        }
        removeConstraints([topAnchorTextOrPicker!, bottomAnchorTextOrPicker!])
    }

    private func removeDecorateElements() {
        [lineTop, checkLabel, lineBottom, buttonSave].forEach { $0.removeFromSuperview() }

        guard var topAnchorTextOrPicker = topAnchorTextOrPicker,
                var bottomAnchorTextOrPicker = bottomAnchorTextOrPicker
        else { return }
        [topAnchorTextOrPicker, bottomAnchorTextOrPicker].forEach { $0.isActive = false }

        let view: UIView
        switch blockPostType {
        case .textView:
            guard let textView = textView else { return }
            view = textView
        case .datePicker:
            guard let datePicker = datePicker else { return }
            view = datePicker
        }

        topAnchorTextOrPicker = view.topAnchor.constraint(equalTo: topAnchor)
        bottomAnchorTextOrPicker = view.bottomAnchor.constraint(equalTo: bottomAnchor)

        [topAnchorTextOrPicker, bottomAnchorTextOrPicker].forEach { $0.isActive = true }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
