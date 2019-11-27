//
//  PhotoView.swift
//  IdealVisual
//
//  Created by a.kurganova on 24.10.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

class PhotoView: UIViewController {
    var publication: Photo?
    let photo = UIImageView()
    var scroll = UIScrollView()
    let margin: CGFloat = 30.0
    var date: BlocksPub? = nil, post: BlocksPub? = nil, place: BlocksPub? = nil

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setInteraction()
        setupNavItems()
        setBlocks()
        fill()
    }

    private func setInteraction() {
        let swipeBack = UISwipeGestureRecognizer(target: self, action: #selector(back))
        swipeBack.direction = .right
        view.addGestureRecognizer(swipeBack)

        view.addSubview(scroll)
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        scroll.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        // FIXME: height content on 7
        scroll.contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height + 1970)
    }

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

    private func setupPhoto() {
        let marginTop = (navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height

        scroll.addSubview(photo)
        photo.translatesAutoresizingMaskIntoConstraints = false
        photo.widthAnchor.constraint(equalToConstant: view.bounds.width).isActive = true
        photo.heightAnchor.constraint(equalToConstant: view.bounds.width).isActive = true
        photo.topAnchor.constraint(equalTo: scroll.topAnchor, constant: -marginTop).isActive = true
        photo.contentMode = .scaleAspectFit

        guard let markEdit = UIImage(named: "edit")?.withRenderingMode(.alwaysOriginal) else { return }
        let edit = SubstrateButton(image: markEdit, side: 35, target: self, action: #selector(editBlock),
                                   substrateColor: Colors.darkGray)
        self.view.addSubview(edit)
        edit.translatesAutoresizingMaskIntoConstraints = false
        edit.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: -45).isActive = true
        edit.rightAnchor.constraint(equalTo: photo.rightAnchor, constant: -10).isActive = true
    }

    private func setBlocks() {
        let datPicker = DatePickerBlock()
        date = BlocksPub(iconImage: UIImage(named: "date")!, buttonIext: "дату", datePicker: datPicker, view: scroll)
        guard let date = date else { return }
        date.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: 5).isActive = true
        date.bottomAnchor.constraint(equalTo: photo.bottomAnchor, constant: 270).isActive = true
        place = BlocksPub(
            value: """
                Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore
                et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut
                aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum
                dolore eu fugiatnulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui
                officia deserunt mollit anim id est laborum.
                Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et
                dolore magna
                aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
                consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
                pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit
                anim id est laborum.
            """,

            iconImage: UIImage(named: "map")!, buttonIext: "место", datePicker: nil, view: scroll)
            guard let place = place else { return }
            place.topAnchor.constraint(equalTo: date.bottomAnchor, constant: 10).isActive = true
            post = BlocksPub(
                value: """
                Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut
                labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris
                nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit
                esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt
                in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur
                adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad
                minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
                Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
                pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit
                anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
                incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco
                laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate
                velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
                proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet,
                consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim
                ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
                Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
                Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est
                laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut
                labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi
                ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
                cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa
                qui officia deserunt mollit anim id est laborum.
                """,

                iconImage: UIImage(named: "post")!, buttonIext: "пост", datePicker: nil, view: scroll)
            guard let post = post else { return }
            post.topAnchor.constraint(equalTo: place.bottomAnchor, constant: 10).isActive = true

            for value in [BlocksPub](arrayLiteral: date, place, post) {
                value.translatesAutoresizingMaskIntoConstraints = false
                value.leftAnchor.constraint(equalTo: view.leftAnchor, constant: margin).isActive = true
                value.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -margin).isActive = true
            }
    }

    private func fill() {
        photo.image = publication?.photo
    }

    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func editBlock() {
        self.date?.editBlocks()
        self.post?.editBlocks()
        self.place?.editBlocks()
    }
}
