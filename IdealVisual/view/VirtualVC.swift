//
//  VirtualVC.swift
//  IdealVisual
//
//  Created by a.kurganova on 03/09/2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import UIKit
import Foundation

class VirtualVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate , UINavigationControllerDelegate, PopUpDelegate {
    private var add_content: PopUp?
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
        add_content = PopUp()
        add_content?.delegatePopUp = self
        setup()
    }
    
    private func setup() {
        view.backgroundColor = .white
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isTranslucent = false
        let titleV = UILabel()
        titleV.text = "Виртуальная лента"
        titleV.font = UIFont(name: "Comfortaa-Bold", size: 21)
        titleV.adjustsFontSizeToFitWidth = true
        navigationItem.titleView = titleV
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
        navigationItem.rightBarButtonItem?.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editItem))
        swipes()
        initContent()
    }

    @objc private func addItem() {
        guard let a = add_content else { return }
        a.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(a)
        a.heightAnchor.constraint(equalToConstant: 200).isActive = true
        a.widthAnchor.constraint(equalToConstant: 200).isActive = true
        a.layer.cornerRadius = 10
        a.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        a.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).isActive = true
        a.backgroundColor = .white
        a.show()
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
        add_content?.show()
        content.reloadData()
    }

    @objc private func editItem() {
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
        content.layer.backgroundColor = UIColor.darkGray.cgColor
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
