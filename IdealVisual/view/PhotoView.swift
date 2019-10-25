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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavItems()
        DateBlock()
        GeoBlock()
        PostBlock()
        fill()
    }
    
    private func setupNavItems() {
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = .none
        
        navigationItem.setHidesBackButton(true, animated:false)
        guard let back_but = UIImage(named: "previous")?.withRenderingMode(.alwaysOriginal) else { return }
        let my_back_but = ImageButton(image: back_but, side: 35, target: self, action: #selector(back), buttonColor: Colors.dark_gray)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: my_back_but)
        setupPhoto()
    }
    
    private func setupPhoto() {
        view.addSubview(photo)
        photo.translatesAutoresizingMaskIntoConstraints = false
        photo.widthAnchor.constraint(equalToConstant: 375).isActive = true
        photo.heightAnchor.constraint(equalToConstant: 375).isActive = true
        photo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        guard let i = UIImage(named: "edit")?.withRenderingMode(.alwaysOriginal) else { return }
        let edit = ImageButton(image: i, side: 35, target: self, action: #selector(editBlock), buttonColor: Colors.light_gray)
        photo.addSubview(edit)
        edit.translatesAutoresizingMaskIntoConstraints = false
        edit.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: -55).isActive = true
        edit.rightAnchor.constraint(equalTo: photo.rightAnchor, constant: -10).isActive = true
    }
    
    private func DateBlock() {
        var date = UIView()
        guard let d = UIImage(named: "date")?.withRenderingMode(.alwaysOriginal) else { return }
        
        if publication?.photo == nil {
            date = ImageButton(image: d, side: 45, target: self, action: #selector(editBlock), buttonColor: Colors.light_gray)
            let set_date = AddButton(text: "Добавить дату")
            photo.addSubview(set_date)
            set_date.translatesAutoresizingMaskIntoConstraints = false
            set_date.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: 70).isActive = true
            set_date.leftAnchor.constraint(equalTo: photo.leftAnchor, constant: 161).isActive = true
            set_date.addTarget(self, action: #selector(editBlock), for: .touchUpInside)
        } else {
            date = ImageButton(image: d, side: 45, target: self, action: #selector(editBlock), buttonColor: Colors.orange)
            let lineView = UIView(frame: CGRect(x: 31, y: 400, width: 300, height: 60.0))
            lineView.layer.borderWidth = 0.3
            lineView.layer.borderColor = Colors.dark_gray.cgColor
            view.addSubview(lineView)
            lineView.addSubview(date)
            let map_field = ForEdit(text: "ekfeklr", width: 200, height: 30)
            lineView.addSubview(map_field)
            map_field.translatesAutoresizingMaskIntoConstraints = false
            map_field.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: 50).isActive = true
            map_field.leftAnchor.constraint(equalTo: photo.leftAnchor, constant: 101).isActive = true
            lineView.addSubview(map_field)
        }

        view.addSubview(date)
        date.translatesAutoresizingMaskIntoConstraints = false
        date.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 350).isActive = true
        date.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 31).isActive = true
    }
    
    
    private func GeoBlock() {
        var geo = UIView()
        
        guard let g = UIImage(named: "map")?.withRenderingMode(.alwaysOriginal) else { return }
        
        if publication?.geo == nil {
            geo = ImageButton(image: g, side: 45, target: self, action: #selector(editBlock), buttonColor: Colors.light_gray)
            let set_geo = AddButton(text: "Добавить геолокацию")
            photo.addSubview(set_geo)
            set_geo.translatesAutoresizingMaskIntoConstraints = false
            set_geo.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: 145).isActive = true
            set_geo.leftAnchor.constraint(equalTo: photo.leftAnchor, constant: 196).isActive = true
            set_geo.addTarget(self, action: #selector(editBlock), for: .touchUpInside)
        } else {
            geo = ImageButton(image: g, side: 45, target: self, action: #selector(editBlock), buttonColor: Colors.orange)
        }
            photo.addSubview(geo)
            geo.translatesAutoresizingMaskIntoConstraints = false
            geo.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: 122).isActive = true
            geo.leftAnchor.constraint(equalTo: photo.leftAnchor, constant: 31).isActive = true
    }
    
    private func PostBlock() {
        var post = UIView()
        guard let p = UIImage(named: "post")?.withRenderingMode(.alwaysOriginal) else { return }
        
        if publication?.post == nil {
            post = ImageButton(image: p, side: 45, target: self, action: #selector(editBlock), buttonColor: Colors.light_gray)
            let set_post = AddButton(text: "Добавить пост")
            photo.addSubview(set_post)
            set_post.translatesAutoresizingMaskIntoConstraints = false
            set_post.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: 220).isActive = true
            set_post.leftAnchor.constraint(equalTo: photo.leftAnchor, constant: 161).isActive = true
            set_post.addTarget(self, action: #selector(editBlock), for: .touchUpInside)
        } else {
            post = ImageButton(image: p, side: 45, target: self, action: #selector(editBlock), buttonColor: Colors.orange)
        }
        
        photo.addSubview(post)
        post.translatesAutoresizingMaskIntoConstraints = false
        post.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: 197).isActive = true
        post.leftAnchor.constraint(equalTo: photo.leftAnchor, constant: 31).isActive = true
    }
    
    private func fill() {
        photo.image = publication?.photo
        
    }
    
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func editBlock() {
        
    }
}
