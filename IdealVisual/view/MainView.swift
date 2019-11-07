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

class MainView: UIViewController {
    private let helpText = UILabel()
    fileprivate var choose = UIImagePickerController()
    private let photo = UIButton()
    private var photos = [Photo]()
    private var profileV: ProfileView?
    private var editMode: Bool = false
    
    lazy fileprivate var content: UICollectionView = {
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
        navigationController?.navigationBar.barTintColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // FIXME: stub
        for i in 1...11 {
            let strName = String(i)
            let mypath = "test/" + strName
            guard let img = UIImage(named: mypath) else { return }
            photos.append(Photo(photo: img))
        }
        
        self.tabBarController?.delegate = self
        choose.delegate = self
        choose.sourceType = .photoLibrary
        choose.allowsEditing = true
        profileV = ProfileView(profileDelegate: self)
        setNavTitle()
        setNavItems()
    }
    
    private func setNavTitle() {
        let titleV = UILabel()
        titleV.text = "Лента"
        titleV.font = UIFont(name: "Montserrat-Bold", size: 20)
        titleV.adjustsFontSizeToFitWidth = true
        navigationItem.titleView = titleV
    }
    
    private func setNavItems() {
        let profileV = UIButton()
        profileV.translatesAutoresizingMaskIntoConstraints = false
        profileV.clipsToBounds = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileV)
        profileV.setBackgroundImage(UIImage(named: "default_profile"), for: .normal)
        profileV.widthAnchor.constraint(equalToConstant: 33).isActive = true
        profileV.heightAnchor.constraint(equalToConstant: 33).isActive = true
        profileV.layer.cornerRadius = 10
        profileV.addTarget(self, action: #selector(profile), for: .touchUpInside)
        
        if photos.isEmpty == false {
            guard let edit_pic = UIImage(named: "edit_gray") else { return }
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: SubstrateButton(image: edit_pic,
                                                                                       side: 35,
                                                                                       target: self,
                                                                                       action: #selector(edit)
            ))
        } else { navigationItem.leftBarButtonItem = nil }
        checkPhotos()
        initContent()
    }
    
    private func setNavEditItems() {
        guard let close_pic = UIImage(named: "close_gray") else { return }
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: SubstrateButton(image: close_pic,
                                                                                   side: 33,
                                                                                   target: self,
                                                                                   action: #selector(no)
        ))
    
        guard let yes_pic = UIImage(named: "yes_yellow") else { return }
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: SubstrateButton(image: yes_pic,
                                                                                   side: 33,
                                                                                   target: self,
                                                                                   action: #selector(save)
        ))
    }
    
    private func initContent() {
        content.translatesAutoresizingMaskIntoConstraints = false
        content.delegate = self
        content.dataSource = self
        content.dragInteractionEnabled = true
        content.dragDelegate = self
        content.dropDelegate = self
        content.register(PhotoCell.self, forCellWithReuseIdentifier: "cell")
        content.reloadData()
        view.addSubview(content)
        content.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        content.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        content.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        content.layer.backgroundColor = UIColor.white.cgColor
    }
}

extension MainView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if editMode == true {
            let cell = collectionView.cellForItem(at: indexPath)
            if let selectCell = cell as? PhotoCell { selectCell.selectedImage.isHidden = false }
        } else {
            let detailPhoto = PhotoView()
            detailPhoto.publication = photos[indexPath.item]
            self.navigationController?.pushViewController(detailPhoto, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if editMode == true {
            let cell = collectionView.cellForItem(at: indexPath)
            if let selectCell = cell as? PhotoCell { selectCell.selectedImage.isHidden = true }
        }
    }
}

extension MainView {
    @objc private func edit() {
        editMode = true
        setNavEditItems()
        initContent()
        content.allowsMultipleSelection = true
        content.dragInteractionEnabled = false
    }
    
    @objc private func no() {
        setNavItems()
        editMode = false
    }
    
    @objc private func save() {
        if editMode == true {
            if let selectedCells = content.indexPathsForSelectedItems {
                let items = selectedCells.map{ $0.item }.sorted().reversed()
                for item in items { photos.remove(at: item) }
                content.deleteItems(at: selectedCells)
            }
            setNavItems()
        }
        editMode = false
    }
}

extension MainView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return photos.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCell
        cell.backgroundColor = .gray
        cell.picture.image = photos[indexPath.item].photo
        cell.picture.frame = CGRect(x: 0, y: 0, width: view.bounds.width / 3 - 1, height: view.bounds.width / 3 - 1)
        return cell
    }
    
    private func checkPhotos() {
        if photos.isEmpty {
            content.isHidden = true
            setHelp()
            helpText.text = """
            Здесь будут размещены Ваши фото \n\n
            Чтобы начать свой путь к созданию идеальной ленты или блога \
            добавьте свою первую фотографию нажав на +
            """
        }
    }
        
    private func setHelp() {
        view.addSubview(helpText)
        helpText.translatesAutoresizingMaskIntoConstraints = false
        helpText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        helpText.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
        helpText.widthAnchor.constraint(equalToConstant: 300).isActive = true
        helpText.font = UIFont(name: "PingFang-SC-Regular", size: 18)
        helpText.numberOfLines = 0
        helpText.textAlignment = .center
        helpText.textColor = Colors.dark_gray
    }
}

extension MainView: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let image = photos[indexPath.row].photo
        let provider = NSItemProvider(object: image)
        let dragItem = UIDragItem(itemProvider: provider)
        return [dragItem]
    }
}

extension MainView: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .move)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let items = coordinator.items
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in items {
            guard let sourceIndexPath = item.sourceIndexPath else { return }
            collectionView.performBatchUpdates({
                let moveImage = photos[sourceIndexPath.item]
                photos.remove(at: sourceIndexPath.item)
                photos.insert(moveImage, at: destinationIndexPath.item)
                
                content.deleteItems(at: [sourceIndexPath])
                content.insertItems(at: [destinationIndexPath])
            })
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
           return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
}

extension MainView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    internal func showAlert(alert: UIAlertController) { present(alert, animated: true) }
    
    private func openGallery() { present(choose, animated: true, completion: nil) }
    
   func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selected = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //FIXME: fix crop image
            photos.append(Photo(photo: selected))
            content.isHidden = false
            content.reloadData()
            setNavItems()
        }
        dismissAlert()
    }
    
    func dismissAlert() { dismiss(animated: true, completion: nil) }
    
    func chooseAvatar(picker: UIImagePickerController) { present(picker, animated: true, completion: nil) }
    
    @objc private func choose_photo() {
        let alert = UIAlertController(title: "Выберите изображение", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Галерея", style: .default, handler: { _ in self.openGallery() }))
        alert.addAction(UIAlertAction(title: "Отменить", style: UIAlertAction.Style.cancel, handler: nil))
        present(alert, animated: true)
    }
}

extension MainView: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if self.tabBarController?.selectedIndex == 0 { self.choose_photo() }
    }
    
    private func disableTabBarButton() {
        guard let block_tabbar = UIImage(named: "block_tabbar")?.withRenderingMode(.alwaysOriginal) else { return }
        tabBarItem = UITabBarItem(title: nil, image: block_tabbar, selectedImage: block_tabbar)
        tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        tabBarController?.tabBar.isUserInteractionEnabled = false
        content.isUserInteractionEnabled = false
    }
    
    internal func enableTabBarButton() { orangeTabBarButton() }
    
    private func orangeTabBarButton() {
        guard let add_tabbar = UIImage(named: "add_tabbar")?.withRenderingMode(.alwaysOriginal) else { return }
        tabBarItem = UITabBarItem(title: nil, image: add_tabbar, selectedImage: add_tabbar)
        tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        tabBarController?.tabBar.isUserInteractionEnabled = true
        content.isUserInteractionEnabled = true
    }
}

extension MainView: ProfileDelegate {
    internal func logOut() { auth() }
    
    private func auth() {
        let authVC = SignIn()
//        authVC.modalPresentationStyle = .fullScreen
        present(authVC, animated: true, completion: nil)
    }
    
    @objc internal func profile() { show_profile() }
    
    @objc private func show_profile() {
        disableTabBarButton()
        guard let pr = profileV else { return }
        view.addSubview(pr)
        pr.setup()
    }
}
