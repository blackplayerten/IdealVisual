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
        setupNavItems()
        setBlocks()
        fill()
    }
    
    private func setupNavItems() {
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = .none
        
        navigationItem.setHidesBackButton(true, animated:false)
        guard let back_but = UIImage(named: "previous")?.withRenderingMode(.alwaysOriginal) else { return }
        let my_back_but = SubstrateButton(image: back_but, side: 35, target: self, action: #selector(back), substrate_color: Colors.dark_gray)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: my_back_but)
        setupPhoto()
    }
    
    private func setupPhoto() {
        view.addSubview(photo)
        photo.translatesAutoresizingMaskIntoConstraints = false
        photo.widthAnchor.constraint(equalToConstant: view.bounds.width).isActive = true
        photo.heightAnchor.constraint(equalToConstant: view.bounds.width).isActive = true
        photo.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        guard let i = UIImage(named: "edit")?.withRenderingMode(.alwaysOriginal) else { return }
        let edit = SubstrateButton(image: i, side: 35, target: self, action: #selector(editBlock), substrate_color: Colors.light_gray)
        photo.addSubview(edit)
        edit.translatesAutoresizingMaskIntoConstraints = false
        edit.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: -45).isActive = true
        edit.rightAnchor.constraint(equalTo: photo.rightAnchor, constant: -10).isActive = true
    }
    
    private func setBlocks() {
//        let date = BlocksPub(value: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", icon_image: UIImage(named: "date")!, button_text: "дату", view: view)
//        date.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: 50).isActive = true
//
//        let place = BlocksPub(icon_image: UIImage(named: "map")!, button_text: "местоположение", view: view)
//        place.topAnchor.constraint(equalTo: date.bottomAnchor, constant: 40).isActive = true
//
//        let post = BlocksPub(icon_image: UIImage(named: "post")!, button_text: "пост", view: view)
//        post.topAnchor.constraint(equalTo: place.bottomAnchor, constant: 40).isActive = true
//
//        for value in [BlocksPub](arrayLiteral: date, place, post) {
//            value.translatesAutoresizingMaskIntoConstraints = false
//            value.heightAnchor.constraint(equalToConstant: 70).isActive = true
//            value.leftAnchor.constraint(equalTo: view.leftAnchor, constant: margin).isActive = true
//            value.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -margin).isActive = true
//        }
    }
        
    
    private func fill() {
        photo.image = publication?.photo
    }
    
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func editBlock() {
        //slozna
    }
}
