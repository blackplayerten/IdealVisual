//
//  VirtualVC.swift
//  IdealVisual
//
//  Created by a.kurganova on 03/09/2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import UIKit
import Foundation
import MobileCoreServices

class MainView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDragDelegate, UICollectionViewDropDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITabBarControllerDelegate, ProfileDelegate {
    
    var choose = UIImagePickerController()
    
    private let photo = UIButton()
    private var photos = [Photo]()
    private var profileV: ProfileView?
    
     lazy var content: UICollectionView = {
        let cellSide = view.bounds.width / 3 - 1
        let sizecell = CGSize(width: cellSide, height: cellSide)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = sizecell
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.scrollDirection = .vertical
        return UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = self

        self.content.dragDelegate = self
        self.content.dropDelegate = self
        self.content.dragInteractionEnabled = true
        
        choose.delegate = self
        choose.sourceType = .photoLibrary
        choose.allowsEditing = true
        
        profileV = ProfileView(profileDelegate: self)
        setup()
    }
    
    private func setup() {
        view.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false

        let titleV = UILabel()
        titleV.text = "Лента"
        titleV.font = UIFont(name: "OpenSans-SemiBold", size: 20)
        titleV.adjustsFontSizeToFitWidth = true
        navigationItem.titleView = titleV

        let profileV = UIButton()
        profileV.translatesAutoresizingMaskIntoConstraints = false
        profileV.clipsToBounds = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileV)
        profileV.setBackgroundImage(UIImage(named: "test"), for: .normal)
        profileV.widthAnchor.constraint(equalToConstant: 33).isActive = true
        profileV.heightAnchor.constraint(equalToConstant: 33).isActive = true
        profileV.layer.cornerRadius = 10
        profileV.addTarget(self, action: #selector(profile), for: .touchUpInside)
        
        guard let edit_pic = UIImage(named: "edit_black") else { return }
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: ImageButton(image: edit_pic,
                                                                                   side: 35,
                                                                                   target: self,
                                                                                   action: #selector(edit)
        ))

        if photos.isEmpty {
            content.isHidden = true
            let helpText = UILabel()
            view.addSubview(helpText)
            helpText.translatesAutoresizingMaskIntoConstraints = false
            helpText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            helpText.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
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
        disableTabBarButton()
        guard let pr = profileV else { return }
        view.addSubview(pr)
        pr.translatesAutoresizingMaskIntoConstraints = false
        let currentWindow: UIWindow? = UIApplication.shared.keyWindow
        currentWindow?.addSubview(pr)
        pr.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        pr.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        pr.layer.cornerRadius = 20
        pr.topAnchor.constraint(equalTo: (self.navigationController?.navigationBar.topAnchor)!).isActive = true
        pr.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        pr.backgroundColor = Colors.dark_gray
        pr.setup()
    }
    
    private func disableTabBarButton() {
        guard let block_tabbar = UIImage(named: "block_tabbar")?.withRenderingMode(.alwaysOriginal) else { return }
        tabBarItem = UITabBarItem(title: nil, image: block_tabbar, selectedImage: block_tabbar)
        tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        tabBarController?.tabBar.isUserInteractionEnabled = false
        content.isUserInteractionEnabled = false
    }
    
    internal func enableTabBarButton() {
        guard let add_tabbar = UIImage(named: "add_tabbar")?.withRenderingMode(.alwaysOriginal) else { return }
                  tabBarItem = UITabBarItem(title: nil, image: add_tabbar, selectedImage: add_tabbar)
                   tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        tabBarController?.tabBar.isUserInteractionEnabled = true
        content.isUserInteractionEnabled = true
    }


    internal func chooseAvatar(picker: UIImagePickerController) {
        present(picker, animated: true, completion: nil)
    }
    
    @objc func choose_photo_for_feed() {
        let alert = UIAlertController(title: "Выберите изображение", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Галерея", style: .default, handler: { _ in self.openGallery() }))
        alert.addAction(UIAlertAction(title: "Отменить", style: UIAlertAction.Style.cancel, handler: nil))
        present(alert, animated: true)
    }
    
    internal func showAlert(alert: UIAlertController) {
        present(alert, animated: true)
    }

    private func openGallery() {
        present(choose, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selected = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //FIXME: fix crop image
            photos.append(Photo(photo: selected))
            content.isHidden = false
            content.reloadData()
        }
        dismissAlert()
    }
    
    internal func dismissAlert() {
        dismiss(animated: true, completion: nil)
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
        cell.picture.image = photos[indexPath.item].photo
        cell.picture.frame = CGRect(x: 0, y: 0, width: view.bounds.width / 3 - 1, height: view.bounds.width / 3 - 1)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailPhoto = PhotoView()
        detailPhoto.publication = photos[indexPath.item]
        self.navigationController?.pushViewController(detailPhoto, animated: true)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if self.tabBarController?.selectedIndex == 0 {
            self.choose_photo_for_feed()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let provider = NSItemProvider(object: photos[indexPath.row].photo)
        let dragItem = UIDragItem(itemProvider: provider)
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.hasItemsConforming(toTypeIdentifiers: [kUTTypeImage as String])
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        
        switch coordinator.proposal.operation {
            case .copy:
                let items = coordinator.items
                for item in items {
                    item.dragItem.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (newImage, error)  -> Void in
                        if var image = newImage as? UIImage {
                            if image.size.width > 200 {
                                image = self.scaleImage(image: image, width: 200)
                            }
//                        self.photos.insert(image, at: destinationIndexPath.item)
                        DispatchQueue.main.async { collectionView.insertItems(at: [destinationIndexPath]) }
                        }
                    }
            )
                }

            case .move:
                      
                       let items = coordinator.items
                       
                       for item in items {
                           guard let sourceIndexPath = item.sourceIndexPath
                                       else { return }
                           
                           collectionView.performBatchUpdates({
                               
                               let moveImage = photos[sourceIndexPath.item]
                               photos.remove(at: sourceIndexPath.item)
                               photos.insert(moveImage, at: destinationIndexPath.item)
                               
                               content.deleteItems(at: [sourceIndexPath])
                               content.insertItems(at: [destinationIndexPath])
                           })
                           coordinator.drop(item.dragItem,
                           toItemAt: destinationIndexPath)
                       }
            
            default: return
        }
    }
    
    
    func scaleImage (image:UIImage, width: CGFloat) -> UIImage {
        let oldWidth = image.size.width
        let scaleFactor = width / oldWidth


        let newHeight = image.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor


        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x:0, y:0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate
      session: UIDropSession, withDestinationIndexPath destinationIndexPath:
       IndexPath?) -> UICollectionViewDropProposal {
        
        if session.localDragSession != nil {
            return UICollectionViewDropProposal(operation: .move,
                    intent: .insertAtDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .copy,
                    intent: .insertAtDestinationIndexPath)
        }
    }
    
}
