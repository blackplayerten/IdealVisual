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
    let addView = UIView()
    
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
        view.backgroundColor = .white
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: ImageButton(image: default_profile_pic,
                                                                                    side: barButtonSide,
                                                                                    target: self,
                                                                                    action: #selector(profile)
        ))
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: ImageButton(image: edit_pic,
                                                                                   side: barButtonSide,
                                                                                   target: self,
                                                                                   action: #selector(add)
        ))
        
        view.addSubview(addView)
        addView.translatesAutoresizingMaskIntoConstraints = false
        addView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        addView.heightAnchor.constraint(equalToConstant: 110).isActive = true
        addView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        addView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        addView.backgroundColor = .white
        addView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        addView.layer.cornerRadius = 30
        addView.layer.borderColor = Colors.dark_gray.cgColor
        addView.layer.borderWidth = 1
        let add_button = UIButton()
        addView.addSubview(add_button)
        add_button.translatesAutoresizingMaskIntoConstraints = false
        add_button.centerXAnchor.constraint(equalTo: addView.safeAreaLayoutGuide.centerXAnchor).isActive = true
        add_button.centerYAnchor.constraint(equalTo: addView.safeAreaLayoutGuide.centerYAnchor).isActive = true
        guard let add_pic = UIImage(named: "add") else { return }
        add_button.addSubview(ImageButton(image: add_pic, side: 35, target: self, action: #selector(choose_photo), buttonColor: Colors.orange))
        
        swipes()
        initContent()
    }
    
    @objc private func profile() {
        print("profile handler")
    }

    @objc private func add() {
        print("add handler")
    }
    
    @objc private func choose_photo() {
        let alert = UIAlertController(title: "Выберите изображение", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Галерея", style: .default, handler: { _ in self.openGallery() }))
        alert.addAction(UIAlertAction(title: "Отменить", style: UIAlertAction.Style.cancel, handler: nil))
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
        content.translatesAutoresizingMaskIntoConstraints = false
        content.delegate = self
        content.dataSource = self
        content.dragInteractionEnabled = true
        content.register(PhotoCell.self, forCellWithReuseIdentifier: "cell")
        content.reloadData()
        view.addSubview(content)
        content.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        content.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        content.bottomAnchor.constraint(equalTo: addView.topAnchor).isActive = true
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
