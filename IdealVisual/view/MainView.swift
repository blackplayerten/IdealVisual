//
//  VirtualVC.swift
//  IdealVisual
//
//  Created by a.kurganova on 03/09/2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import UIKit
import Foundation

class MainView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITabBarControllerDelegate, ProfileDelegate {
    private let choose = UIImagePickerController()
    private let photo = UIButton()
    private var photos = [UIImage]()
    private var profileV: ProfileView?
    
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
        self.tabBarController?.delegate = self
        profileV = ProfileView()
        profileV?.delegateProfile = self
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

        if photos.isEmpty {
            content.isHidden = true
            let helpText = UILabel()
            view.addSubview(helpText)
            helpText.translatesAutoresizingMaskIntoConstraints = false
            helpText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            helpText.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -110).isActive = true
            helpText.widthAnchor.constraint(equalToConstant: 300).isActive = true
            helpText.font = UIFont(name: "OpenSans-Regular", size: 18)
            helpText.numberOfLines = 0
            helpText.textAlignment = .center
            helpText.textColor = Colors.dark_gray
            helpText.text = """
            Здесь будут размещены Ваши фото \n\n
            Чтобы начать свой путь к созданию идеальной ленты или блога \
            добавьте свою первую фотографию нажав на +
            """
        }
        
        swipes()
        initContent()
    }
    
    @objc internal func profile() {
        guard let pr = profileV else { return }
        view.addSubview(pr)
        pr.translatesAutoresizingMaskIntoConstraints = false
        let currentWindow: UIWindow? = UIApplication.shared.keyWindow
        currentWindow?.addSubview(pr)
        pr.heightAnchor.constraint(equalToConstant: 400).isActive = true
        pr.widthAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.widthAnchor).isActive = true
        pr.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        pr.layer.cornerRadius = 20
        pr.topAnchor.constraint(equalTo: (self.navigationController?.navigationBar.topAnchor)!).isActive = true
        pr.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        pr.backgroundColor = Colors.dark_gray
        pr.setup()
    }


    @objc private func add() {
        print("add handler")
    }
    
    func choose_photo() {
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
        content.isHidden = false
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
        content.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        content.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        content.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
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
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if self.tabBarController?.selectedIndex == 0 {
            self.choose_photo()
        }
    }
}
