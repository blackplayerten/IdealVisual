//
//  PhotoView.swift
//  IdealVisual
//
//  Created by a.kurganova on 24.10.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

enum BlockPostType {
    case datePicker
    case textView
}

final class PostView: UIViewController {
    private var viewModel: PostViewModelProtocol?
    var publication: Post?
    let photo = UIImageView()
    private var scroll = UIScrollView()
    let margin: CGFloat = 30.0
    var date: BlockPost? = nil, post: BlockPost? = nil, place: BlockPost? = nil

    private var un: UIError?

    // MARK: - methods lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.barStyle = .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.un = UIError(text: "", place: view, color: Colors.red)

        self.viewModel = PostViewModel(delegat: nil)
        view.backgroundColor = .white
        setInteraction()
        setupNavItems()
        setBlocks()

        // MARK: - keyboard
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        // MARK: kostyl при переходе на новый пост почему-то не удалялся старый пост и
        // он принимал события клавиатуры, деинит не помог, где-то сохранилась ссылка?
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - keyboard
    private var activeField: BlockPost?

    @objc
    func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo!
        guard let rect: CGRect = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let kbSize = rect.size

        let insets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
        scroll.contentInset = insets
        scroll.scrollIndicatorInsets = insets

        guard let activeField = activeField else { return }

        let visible_screen_without_keyboard = scroll.bounds.height - kbSize.height

        let tr = scroll.convert(activeField.frame, to: nil)

        if tr.origin.y + tr.height > visible_screen_without_keyboard {
            let scrollPoint = CGPoint(x: 0, y: activeField.frame.origin.y - kbSize.height)
            scroll.setContentOffset(scrollPoint, animated: true)
        }
    }

    @objc
    func keyboardWillHide(_ notification: Notification) {
        scroll.contentInset = .zero
        scroll.scrollIndicatorInsets = .zero
    }

    // MARK: - swipe and scroll
    private func setInteraction() {
        let swipeBack = UISwipeGestureRecognizer(target: self, action: #selector(back))
        swipeBack.direction = .right
        view.addGestureRecognizer(swipeBack)

        view.addSubview(scroll)
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        let hideKey: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(taped))
        scroll.addGestureRecognizer(hideKey)
    }

    @objc
    private func back() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - navbar
    private func setupNavItems() {
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = .none

        navigationItem.setHidesBackButton(true, animated: false)
        guard let buttonBack = UIImage(named: "previous_gray")?.withRenderingMode(.alwaysOriginal) else { return }
        let myBackButton = SubstrateButton(image: buttonBack, side: 35, target: self, action: #selector(back),
                                           substrateColor: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: myBackButton)

        setupPhoto()
    }

    // MARK: - photo
    private func setupPhoto() {
        scroll.addSubview(photo)
        photo.translatesAutoresizingMaskIntoConstraints = false
        photo.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        photo.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        photo.heightAnchor.constraint(equalToConstant: view.bounds.width).isActive = true
        photo.topAnchor.constraint(equalTo: scroll.topAnchor).isActive = true
        photo.contentMode = .scaleAspectFit

        guard let markEdit = UIImage(named: "edit")?.withRenderingMode(.alwaysOriginal) else { return }
        let edit = SubstrateButton(image: markEdit, side: 35, target: self, action: #selector(editBlock),
                                   substrateColor: Colors.darkGray)
        view.addSubview(edit)
        edit.translatesAutoresizingMaskIntoConstraints = false
        edit.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: -45).isActive = true
        edit.rightAnchor.constraint(equalTo: photo.rightAnchor, constant: -10).isActive = true
    }

    // MARK: - block
    private func setBlocks() {
        let blockPostType = BlockPostType.self

        var dcp: DatePickerComponent?
//        if let date = publication?.date {
//            if date != Date() {
//                dcp = DatePickerComponent()
//                dcp?.date = date
//            }
//        }
        date = BlockPost(
            textValue: nil,
            iconImage: UIImage(named: "date")!, buttonIext: "Добавить дату", datePicker: dcp, view: scroll,
            blockPostType: blockPostType.datePicker, delegatePost: self
        )
        guard let date = date else { return }

        place = BlockPost(
//            textValue: publication?.place,
            iconImage: UIImage(named: "map")!, buttonIext: "Добавить место", datePicker: nil, view: scroll,
            blockPostType: blockPostType.textView, delegatePost: self
        )
        guard let place = place else { return }

        post = BlockPost(
//            textValue: publication?.text,
            iconImage: UIImage(named: "post")!, buttonIext: "Добавить пост", datePicker: nil, view: scroll,
            blockPostType: blockPostType.textView, delegatePost: self
        )
        guard let post = post else { return }

        var prev = photo as UIView
        for value in [BlockPost](arrayLiteral: date, place, post) {
            value.translatesAutoresizingMaskIntoConstraints = false
            value.leftAnchor.constraint(equalTo: view.leftAnchor, constant: margin).isActive = true
            value.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -margin).isActive = true
            value.topAnchor.constraint(equalTo: prev.bottomAnchor, constant: 20).isActive = true
            value.heightAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true // magic value

            prev = value
        }
        // allows scroll view to resize dynamically
        prev.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -margin).isActive = true
    }

    @objc
    private func editBlock() {
        self.date?.setEditingBlock()
        self.post?.setEditingBlock()
        self.place?.setEditingBlock()
    }

    // MARK: - processing errors
    private func procError(error: PostViewModelErrors?) {
        if let error = error {
            switch error {
            case .noConnection:
                Logger.log(error)
                unErr(text: "Нет соединения с интернетом", color: Colors.darkGray)
            case .unauthorized:
                unErr(text: "Вы не авторизованы")
            case .noData:
                unErr(text: "Невозможно отобразить данные")
            default:
                unErr(text: "Упс, что-то пошло не так.")
            }
        }
    }

     // MARK: ui error
    private func unErr(text: String, color: UIColor? = Colors.red) {
        self.un = UIError(text: text, place: view, color: color)
        view.addSubview(un!)
        un!.translatesAutoresizingMaskIntoConstraints = false
        un!.topAnchor.constraint(equalTo: (navigationController?.navigationBar.bottomAnchor)!).isActive = true
        un!.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
        un!.rightAnchor.constraint(equalTo: scroll.rightAnchor).isActive = true

        // hide keyboard
        let tapp = UITapGestureRecognizer()
        scroll.addGestureRecognizer(tapp)
        tapp.addTarget(self, action: #selector(taped))
       }

       @objc
       func taped() {
            scroll.endEditing(true)
       }
}

extension PostView: BlockProtocol {
    func updateBlock(from: BlockPost) {
        guard let publication = publication else { return }
        switch from {
        case self.post:
            viewModel?.update(post: publication, date: nil, place: nil, text: post?.textView?.text,
                             completion: { [weak self] (error) in
                                DispatchQueue.main.async {
                                    self?.procError(error: error)
                                }
            })
        case self.place:
            viewModel?.update(post: publication, date: nil, place: place?.textView?.text, text: nil,
                             completion: { [weak self] (error) in
                                DispatchQueue.main.async {
                                    self?.procError(error: error)
                                }
                            })
        case self.date:
            viewModel?.update(post: publication, date: date?.datePicker?.date, place: nil, text: nil,
                             completion: { [weak self] (error) in
                                DispatchQueue.main.async {
                                    self?.procError(error: error)
                                }
                            })
        default: break
        }
    }

    func textViewShouldBeginEditing(block: BlockPost) {
        activeField = block
    }

    func textViewShouldEndEditing(block: BlockPost) {
        // FIXME: при фокусе на новый текст филд сначала отрабатывает ShouldBegin нового,
        // а потом ShouldEnd старого, валится на guard'e activeField'а
//        activeField = nil
    }
}
