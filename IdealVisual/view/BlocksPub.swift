//
//  BlocksPub.swift
//  IdealVisual
//
//  Created by a.kurganova on 25.10.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

class BlockPost: UIView {
    private var icon: SubstrateButton
    private var iconImage: UIImage
    private let checkLabel = UILabel()
    private var lineTop = Line()
    private var lineBottom = Line()
    private var buttonSave = AddComponentsButton(text: "Сохранить")
    private var textView: TextViewComponent?
    private var datePicker: DatePickerComponent? // kostyl
    private var bottomAnchorSelf: NSLayoutConstraint?
    private var addButton: AddComponentsButton?
    private var blockPostType: BlockPostType

    // MARK: init
    init(value: String? = nil, iconImage: UIImage, buttonIext: String, datePicker: DatePickerComponent? = nil,
         view: UIView, blockPostType: BlockPostType) {
        self.iconImage = iconImage
        self.blockPostType = blockPostType

        if value != nil || datePicker != nil {
            icon = SubstrateButton(image: self.iconImage, side: 45, substrateColor: Colors.blue)
        } else {
            icon = SubstrateButton(image: self.iconImage, side: 45, substrateColor: Colors.darkGray)
            addButton = AddComponentsButton(text: "Добавить \(buttonIext)")
            addButton?.setColor(state: false)
        }
        super.init(frame: .zero)
        view.addSubview(self)
        renderSubstrateIcon()

        if blockPostType == .datePicker {
            if datePicker == nil {
                renderAddButton()
            } else {
                renderDatePicker(datePicker: datePicker, editingMode: false)
            }
        } else if blockPostType == .textView {
            if value == nil {
                renderAddButton()
            } else {
                renderTextView(value: value, editingMode: false)
            }
        }
    }

    // MARK: @objc func for enable editing mode on blocks (duclicate internal func editBlocks)
    @objc private func objc_SetEditingBlock() {
        if blockPostType == .datePicker {
            renderEditingDatePicker()
        } else if blockPostType == .textView {
            renderEditingTextView()
        }
    }

    // MARK: func for enable editing mode on blocks
    func setEditingBlock() {
        if blockPostType == .datePicker {
            renderEditingDatePicker()
        } else if blockPostType == .textView {
            renderEditingTextView()
        }
    }

    // MARK: render substrate button (left blue button next to textfield)
    private func renderSubstrateIcon() {
        addSubview(icon)
        icon.topAnchor.constraint(equalTo: self.topAnchor, constant: 60).isActive = true
        icon.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
    }

    // MARK: render AddComponent button (button with underline text, e.g. add date/place/post)
    private func renderAddButton() {
        guard let btn = addButton else { return }
        addSubview(btn)

        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20).isActive = true
        btn.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
        btn.addTarget(self, action: #selector(objc_SetEditingBlock), for: .touchUpInside)
        btn.setColor(state: false)
    }

    // MARK: render decoration for editing: top and bootom lines
    private func renderDecorateForEditing() {
        [lineTop, lineBottom, checkLabel, buttonSave].forEach {
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        lineTop.topAnchor.constraint(equalTo: self.topAnchor).isActive = true

        if blockPostType == .textView {

            if textView?.text == nil {
               lineBottom.bottomAnchor.constraint(equalTo: icon.bottomAnchor).isActive = true
            } else {
                lineBottom.bottomAnchor.constraint(equalTo: textView!.bottomAnchor).isActive = true
            }
            checkLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
            checkLabel.topAnchor.constraint(equalTo: lineTop.bottomAnchor, constant: 5).isActive = true
            checkLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            checkLabel.font = UIFont(name: "PingFang-SC-Regular", size: 14)

            guard let textViewCount = textView?.text.count else { return }
            checkLabel.text = "\(textViewCount) / 2200"
            if textViewCount <= 2200 {
                checkLabel.textColor = Colors.darkGray
            } else {
                checkLabel.textColor = .red
            }
        } else if blockPostType == .datePicker {
            if datePicker == nil {
                lineBottom.bottomAnchor.constraint(equalTo: icon.bottomAnchor, constant: 100).isActive = true
            } else {
                lineBottom.bottomAnchor.constraint(equalTo: datePicker!.bottomAnchor).isActive = true
            }
        }
        renderSaveButton()
    }

    // MARK: render save button (yellow button with underline text "save")
    private func renderSaveButton() {
        buttonSave.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -1).isActive = true
        buttonSave.topAnchor.constraint(equalTo: lineBottom.bottomAnchor, constant: 5).isActive = true
        buttonSave.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 3).isActive = true
        buttonSave.addTarget(self, action: #selector(saveTVContent), for: .touchUpInside)
        buttonSave.setColor(state: true)

        if let bottomAnchorSelf = bottomAnchorSelf { bottomAnchorSelf.isActive = false }
        bottomAnchorSelf = self.bottomAnchor.constraint(equalTo: buttonSave.bottomAnchor)
        bottomAnchorSelf!.isActive = true
    }

    // MARK: render textView without editing
    private func renderTextView(value: String? = nil, editingMode: Bool) {
        removeDecorateElements()

        textView = TextViewComponent(text: value)
        textView?.changeTextViewColorWhileEditing(editingMode: false)
        textView?.isUserInteractionEnabled = editingMode
        addSubview(textView!)
        textView?.translatesAutoresizingMaskIntoConstraints = false

        textView?.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20).isActive = true
        textView?.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true

        textView?.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        textView?.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true

        bottomAnchorSelf = textView?.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        bottomAnchorSelf!.isActive = true
    }

    private func removeDecorateElements() {
        [lineTop, checkLabel, lineBottom, buttonSave].forEach { $0.removeFromSuperview() }
    }

    private func removeAddButton() {
        addButton?.removeFromSuperview()
        icon.removeFromSuperview()
    }

    // MARK: render textView with editing mode
    private func renderEditingTextView() {
        removeAddButton()
        icon = SubstrateButton(image: UIImage(named: "close")!, side: 45, target: self,
                               action: #selector(cancel), substrateColor: Colors.lightGray)
        renderSubstrateIcon()

        if textView?.text == nil {
            renderTextView(value: nil, editingMode: true)
        }

        textView?.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20).isActive = true
        textView?.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true

        textView?.changeTextViewColorWhileEditing(editingMode: true)
        textView?.isUserInteractionEnabled = true

        if let bottomAnchorSelf = bottomAnchorSelf { bottomAnchorSelf.isActive = false }
        bottomAnchorSelf = textView?.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        bottomAnchorSelf!.isActive = true

        renderDecorateForEditing()
    }

    // MARK: render date picker without editing mode
    private func renderDatePicker(datePicker: DatePickerComponent? = nil, editingMode: Bool) {
        removeDecorateElements()

        let datePicker = DatePickerComponent(datePicker: datePicker)
        datePicker.isUserInteractionEnabled = editingMode
        addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        datePicker.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20).isActive = true
        datePicker.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true

        datePicker.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        datePicker.heightAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true

        bottomAnchorSelf = datePicker.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        bottomAnchorSelf!.isActive = true
    }

    // MARK: render date picker with editing
    private func renderEditingDatePicker() {
        removeAddButton()
        icon = SubstrateButton(image: UIImage(named: "close")!, side: 45, target: self,
                               action: #selector(cancel), substrateColor: Colors.lightGray)
        renderSubstrateIcon()

        if datePicker == nil {
            renderDatePicker(datePicker: nil, editingMode: true)
        }

        datePicker?.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20).isActive = true
        datePicker?.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true

        datePicker?.isUserInteractionEnabled = true

        if let bottomAnchorSelf = bottomAnchorSelf { bottomAnchorSelf.isActive = false }
        bottomAnchorSelf = datePicker?.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        bottomAnchorSelf?.isActive = true

        renderDecorateForEditing()
    }

    // MARK: save changes after editing
    @objc private func saveTVContent() {
         print("save")
         icon = SubstrateButton(image: self.iconImage, side: 45, substrateColor: Colors.blue)
         renderSubstrateIcon()
         if datePicker != nil {
             renderDatePicker(datePicker: datePicker, editingMode: false)
         } else if textView?.text == "" {
//            [lineTop, checkLabel, lineBottom, buttonSave, icon].forEach { $0.removeFromSuperview() }
            icon = SubstrateButton(image: self.iconImage, side: 45, target: nil, action: nil,
                                   substrateColor: Colors.darkGray)
            renderSubstrateIcon()
            textView?.isUserInteractionEnabled = false
            renderAddButton()
        } else {
            renderTextView(value: textView?.text, editingMode: false)
        }
        removeDecorateElements() // check
    }

    // MARK: don't save changes after editing
    @objc private func cancel() {
        icon = SubstrateButton(image: self.iconImage, side: 45, substrateColor: Colors.blue)
        renderSubstrateIcon()
        if datePicker != nil {
            renderDatePicker(datePicker: datePicker, editingMode: false)
        } else {
            if textView?.text == "" {
                [lineTop, checkLabel, lineBottom, buttonSave, icon].forEach { $0.removeFromSuperview() }
                icon = SubstrateButton(image: self.iconImage, side: 45, target: nil, action: nil,
                                       substrateColor: Colors.darkGray)
                renderSubstrateIcon()
                textView?.isUserInteractionEnabled = false
                renderAddButton()
            } else {
                renderTextView(value: textView?.text, editingMode: false)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
