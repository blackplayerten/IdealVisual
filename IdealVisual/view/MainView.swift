//
//  VirtualVC.swift
//  IdealVisual
//
//  Created by a.kurganova on 03/09/2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import UIKit
import Foundation

class MainView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let choose = UIImagePickerController()
    private let photo = UIButton()
    private var photos = [UIImage]()
    
    private lazy var content: UICollectionView = {
        let cellSide = view.bounds.width / 3 - 1
        let sizecell = CGSize(width: cellSide, height: cellSide)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = sizecell
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.scrollDirection = .vertical
        return UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isTranslucent = false
        let titleV = UILabel()
        titleV.text = "Лента"
        titleV.font = UIFont(name: "OpenSans-Bold", size: 21)
        titleV.adjustsFontSizeToFitWidth = true
        navigationItem.titleView = titleV
        guard let default_profile_pic = UIImage(named: "default_profile") else { return }
        guard let edit_pic = UIImage(named: "edit_black") else { return }
        guard let barButtonSide = navigationController?.navigationBar.frame.size.height else { return }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: ImageButton(image: default_profile_pic, side: barButtonSide, target: self, action: #selector(profile)))
        navigationItem.rightBarButtonItem?.target = self
        navigationItem.rightBarButtonItem?.action = #selector(profile)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: ImageButton(image: edit_pic, side: barButtonSide, target: self, action: #selector(add)))
        swipes()
        initContent()
    }
    
    @objc func profile() {
        print("profile handler")
    }

    @objc private func add() {
        print("add handler")
    }
    
    func choose_photo() {
        let alert = UIAlertController(title: "Выберите изображение", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Галерея", style: .default, handler: { _ in self.openGallery() }))
        present(alert, animated: true)
    }

    private func openGallery() {
        choose.delegate = self
        choose.sourceType = .photoLibrary
        choose.allowsEditing = true
        present(choose, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selected = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            photos.append(selected)
            print("photos", photos)
         }
        dismiss(animated: true, completion: nil)
        content.reloadData()
    }

    @objc private func edit() {
        print("edit")
    }

    private func swipes() {
        let swipeToInst = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        swipeToInst.direction = .right
        view.addGestureRecognizer(swipeToInst)
    }

    @objc func swipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            self.tabBarController?.selectedIndex -= 1
        }
    }

    private func initContent() {
        content.delegate = self
        content.dataSource = self
        content.dragInteractionEnabled = true
        content.register(PhotoCell.self, forCellWithReuseIdentifier: "cell")
        content.reloadData()
        view.addSubview(content)
        content.bounds = view.bounds
        content.layer.backgroundColor = UIColor.white.cgColor
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCell
        cell.backgroundColor = .gray
        cell.picture.image = photos[indexPath.item]
        cell.picture.frame = CGRect(x: 0, y: 0, width: view.bounds.width / 3 - 1, height: view.bounds.width / 3 - 1)
        return cell
    }
}
