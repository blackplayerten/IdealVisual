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
    let tap_choose_block = UITapGestureRecognizer()
    let margin: CGFloat = 30.0
    
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
        let tap = UISwipeGestureRecognizer(target: self, action: #selector(back))
        tap.direction = .right
        view.addGestureRecognizer(tap)
        
        view.addSubview(scroll)
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        scroll.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        //FIXME: height content on 7
        scroll.contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height + 470)
    }

    private func setupNavItems() {
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = .none
        
        navigationItem.setHidesBackButton(true, animated:false)
        guard let back_but = UIImage(named: "previous_gray")?.withRenderingMode(.alwaysOriginal) else { return }
        let my_back_but = SubstrateButton(image: back_but, side: 35, target: self, action: #selector(back), substrate_color: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: my_back_but)
        
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
        
        guard let i = UIImage(named: "edit")?.withRenderingMode(.alwaysOriginal) else { return }
        let edit = SubstrateButton(image: i, side: 35, target: self, action: #selector(editBlock), substrate_color: Colors.dark_gray)
        photo.addSubview(edit)
        edit.translatesAutoresizingMaskIntoConstraints = false
        edit.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: -45).isActive = true
        edit.rightAnchor.constraint(equalTo: photo.rightAnchor, constant: -10).isActive = true
    }
    
    private func setBlocks() {
        let date = BlocksPub(value: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. kbjvefndvbldfknbkzsfnbevnjdfnjfnjkfdndfndfj nklfnkldf nk d`nk fdn fnk fnknkf ", icon_image: UIImage(named: "date")!, button_text: "дату", view: scroll)
        date.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: 40).isActive = true

        let place = BlocksPub(value: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. kbjvefndvbldfknbkzsfnbevnjdfnjfnjkfdndfndfj nklfnkldf nk d`nk fdn fnk fnknkf ", icon_image: UIImage(named: "map")!, button_text: "местоположение", view: scroll)
        place.topAnchor.constraint(equalTo: date.bottomAnchor, constant: 40).isActive = true
    
        let post = BlocksPub(value: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. kbjvefndvbldfknbkzsfnbevnjdfnjfnjkfdndfndfj nklfnkldf nk d`nk fdn fnk fnknkf ", icon_image: UIImage(named: "post")!, button_text: "пост", view: scroll)
        post.topAnchor.constraint(equalTo: place.bottomAnchor, constant: 40).isActive = true
        
        for value in [BlocksPub](arrayLiteral: date, place, post) {
            value.translatesAutoresizingMaskIntoConstraints = false
            value.leftAnchor.constraint(equalTo: view.leftAnchor, constant: margin).isActive = true
            value.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -margin).isActive = true
        }
    }
        
    private func fill() {
        photo.image = publication?.photo
    }
    
    @objc private func back() { navigationController?.popViewController(animated: true) }
    
    @objc private func editBlock() {
        //slozna
    }
}
