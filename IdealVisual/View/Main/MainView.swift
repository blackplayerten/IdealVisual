//
//  MainView.swift
//  IdealVisual
//
//  Created by a.kurganova on 03/09/2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import UIKit
import Foundation
import MobileCoreServices
import CoreData

final class MainView: UIViewController {
    private var profileV: ProfileView?
    private var userViewModel: UserViewModelProtocol?
    private var postViewModel: PostViewModelProtocol?

    private var refreshControl = UIRefreshControl()

    private let helpText = UILabel()
    private let photo = UIButton()
    private var urlAva: String?
    private var editMode: Bool = false

    fileprivate var choose = UIImagePickerController()

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
        self.userViewModel = UserViewModel()
        self.postViewModel = PostViewModel()
        view.backgroundColor = .white
        let back = UIImageView(frame: CGRect(x: 0, y: view.bounds.height/2, width: view.bounds.width, height: 250))
        back.image = UIImage(named: "fon")
        view.addSubview(back)

        self.tabBarController?.delegate = self
        choose.delegate = self
        choose.sourceType = .photoLibrary
        choose.allowsEditing = true

        postViewModel?.subscribe(completion: { [weak self] (_) in
            DispatchQueue.main.async {
                self?.content.reloadData()
            }
        })

        profileV = ProfileView(profileDelegate: self)

        initContent()
        setNavTitle()
        setNavItems()
        checkPhotos()
    }

// MARK: - navigation items
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

        userViewModel?.getAvatar(completion: { (avatar, error) in
            DispatchQueue.main.async {
                if let error = error {
                    switch error {
                    case ErrorsUserViewModel.noData:
                        // TODO: ui
                        break
                    case ErrorsUserViewModel.notFound:
                        // TODO: ui, go to login
                        break
                        // more errors
                    default:
                        print("undefined error: \(error)"); return
                    }
                }

                guard let avatar = avatar else {
                    profileV.setBackgroundImage(UIImage(named: "default_profile"), for: .normal)
                    return
                }

                DispatchQueue.main.async {
                    profileV.setBackgroundImage(UIImage(contentsOfFile: avatar), for: .normal)
                }
            }
        })

        profileV.widthAnchor.constraint(equalToConstant: 33).isActive = true
        profileV.heightAnchor.constraint(equalToConstant: 33).isActive = true
        profileV.layer.cornerRadius = 10
        profileV.addTarget(self, action: #selector(profile), for: .touchUpInside)

        if postViewModel?.posts.count != 0 {
            guard let markEdit = UIImage(named: "edit_gray") else { return }
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: SubstrateButton(image: markEdit, side: 35,
                                                                                           target: self,
                                                                                           action: #selector(edit)
            ))
        } else { navigationItem.leftBarButtonItem = nil }
    }

    private func setNavEditItems() {
        guard let markClose = UIImage(named: "close_gray") else { return }
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: SubstrateButton(image: markClose,
                                                                                   side: 33,
                                                                                   target: self,
                                                                                   action: #selector(no)
        ))

        guard let markYes = UIImage(named: "yes_yellow") else { return }
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: SubstrateButton(image: markYes,
                                                                                   side: 33,
                                                                                   target: self,
                                                                                   action: #selector(save)
        ))
    }

// MARK: - init collection view
    private func initContent() {
        content.translatesAutoresizingMaskIntoConstraints = false
        content.delegate = self
        content.dataSource = self
        content.dragInteractionEnabled = true
        content.dragDelegate = self
        content.dropDelegate = self
        content.register(PhotoCell.self, forCellWithReuseIdentifier: "cell")
        view.addSubview(content)
        content.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        content.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        content.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        content.layer.backgroundColor = UIColor.white.cgColor

        content.refreshControl = refreshControl
        refreshControl.tintColor = Colors.lightBlue
        refreshControl.addTarget(self, action: #selector(startLoading), for: .valueChanged)
    }

    @objc private func startLoading() {
        _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(tick),
                                 userInfo: nil, repeats: false)
    }

    @objc private func tick() {
        refreshControl.endRefreshing()
    }
}

// MARK: - picker
extension MainView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    internal func showAlert(alert: UIAlertController) { present(alert, animated: true) }

    private func openGallery() { present(choose, animated: true, completion: nil) }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            if let selected = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                let photoName = url.lastPathComponent
                postViewModel?.create(photoName: photoName,
                                      photoData: selected.jpegData(compressionQuality: 1.0),
                                      date: Date(timeIntervalSince1970: 0),
                                      place: "", text: "",
                    completion: { (error) in
                        DispatchQueue.main.async {
                            if let error = error {
                                switch error {
                                case ErrorsUserViewModel.noData:
                                    // TODO: ui
                                    break
                                default:
                                    print("undefined error: \(error)")
                                }
                            }
                            self.setNavItems()
                            self.checkPhotos()
                        }
                })
            }
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

// MARK: - delegate
extension MainView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if editMode == true {
            let cell = collectionView.cellForItem(at: indexPath)
            if let selectCell = cell as? PhotoCell { selectCell.selectedImage.isHidden = false }
        } else {
            guard let postViewModel = postViewModel else { return }
            let post = postViewModel.posts[indexPath.item]

            guard let path = post.photo else { return }

            let detailPhoto = PostView()

            DispatchQueue.main.async {
                detailPhoto.photo.image = UIImage(contentsOfFile: postViewModel.getPhoto(path: path))
            }

            detailPhoto.publication = post

            self.navigationController?.pushViewController(detailPhoto, animated: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        if editMode == true {
            let cell = collectionView.cellForItem(at: indexPath)
            if let selectCell = cell as? PhotoCell { selectCell.selectedImage.isHidden = true }
            return true
        }
        return false
    }
}

// MARK: - data source
extension MainView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postViewModel?.posts.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->
        UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let unwrapCell = cell as? PhotoCell {
            guard let postViewModel = postViewModel else { return cell }

            guard let path = postViewModel.posts[indexPath.item].photo else { return cell }

            // FIXME: что-то тут не так
//            DispatchQueue.main.async {
                unwrapCell.picture.image = UIImage(contentsOfFile: postViewModel.getPhoto(path: path))
//            }
            unwrapCell.picture.frame = CGRect(x: 0, y: 0, width: view.bounds.width / 3 - 1,
                                      height: view.bounds.width / 3 - 1)

            unwrapCell.backgroundColor = .gray
        }
        return cell
    }

    private func checkPhotos() {
        if postViewModel?.posts.count != 0 {
            content.isHidden = false
            helpText.removeFromSuperview()
        } else {
            content.isHidden = true
            setHelp()
            helpText.text = """
            Здесь будут размещены Ваши фото \n
            Чтобы начать свой путь к созданию идеальной ленты или блога \
            добавьте свою первую фотографию нажав на +
            """
        }
    }

    private func setHelp() {
        view.addSubview(helpText)
        helpText.translatesAutoresizingMaskIntoConstraints = false
        helpText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        helpText.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        helpText.widthAnchor.constraint(equalToConstant: 300).isActive = true
        helpText.font = UIFont(name: "PingFang-SC-Regular", size: 18)
        helpText.numberOfLines = 0
        helpText.textAlignment = .center
        helpText.textColor = Colors.darkGray
        helpText.layer.masksToBounds = true
        helpText.layer.cornerRadius = 20
        helpText.backgroundColor = UIColor(white: 1, alpha: 0.8)
    }
}

// MARK: - drag & drop
extension MainView: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        guard let cell = content.cellForItem(at: indexPath) as? PhotoCell,
            let image = cell.picture.image
        else { fatalError() }

        let provider = NSItemProvider(object: image)
        let dragItem = UIDragItem(itemProvider: provider)
        return [dragItem]
    }
}

extension MainView: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }

    func collectionView(_ collectionView: UICollectionView,
                        performDropWith coordinator: UICollectionViewDropCoordinator) {
        let items = coordinator.items
        for item in items {
            guard let sourceIndexPath = item.sourceIndexPath,
                let destinationIndexPath = coordinator.destinationIndexPath
            else { return }

            collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
            postViewModel?.swap(source: sourceIndexPath.item, dest: destinationIndexPath.item)
        }
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?) ->
        UICollectionViewDropProposal {
           return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
}

// MARK: - edit collection view
extension MainView {
    @objc
    private func edit() {
        editMode = true
        setNavEditItems()
        content.allowsMultipleSelection = true
        content.dragInteractionEnabled = false
    }

    @objc
    private func no() {
        setNavItems()
        checkPhotos()
        content.allowsMultipleSelection = false
        content.dragInteractionEnabled = true

        content.indexPathsForSelectedItems?.forEach {
            guard let cell = content.cellForItem(at: $0) as? PhotoCell else { return }
            cell.selectedImage.isHidden = true
            content.deselectItem(at: $0, animated: true)
        }

        editMode = false
    }

    @objc
    private func save() {
        if editMode {
            if let selectedCells = content.indexPathsForSelectedItems {
                let items = selectedCells.map { $0.item }.sorted().reversed()
                postViewModel?.delete(atIndices: [Int](items),
                                      completion: { (error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            switch error {
                            case ErrorsUserViewModel.noData:
                                // TODO: ui
                                break
                            case ErrorsUserViewModel.notFound:
                                Logger.log("not found")
                            default:
                                print("undefined error: \(error)")
                            }
                        }
                        self.setNavItems()
                        self.checkPhotos()
                        self.editMode = false
                    }
                })
            }
        }
    }
}

// MARK: - tab bar
extension MainView: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if self.tabBarController?.selectedIndex == 0 { self.choose_photo() }
    }

    private func disableTabBarButton() {
        guard let markBlockTB = UIImage(named: "block_tabbar")?.withRenderingMode(.alwaysOriginal) else { return }
        tabBarItem = UITabBarItem(title: nil, image: markBlockTB, selectedImage: markBlockTB)
        tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        tabBarController?.tabBar.isUserInteractionEnabled = false
        content.isUserInteractionEnabled = false
    }

    internal func enableTabBarButton() { orangeTabBarButton() }

    private func orangeTabBarButton() {
        guard let markAddTB = UIImage(named: "add_tabbar")?.withRenderingMode(.alwaysOriginal) else { return }
        tabBarItem = UITabBarItem(title: nil, image: markAddTB, selectedImage: markAddTB)
        tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        tabBarController?.tabBar.isUserInteractionEnabled = true
        content.isUserInteractionEnabled = true
    }
}

// MARK: - profile delegate
extension MainView: ProfileDelegate {
    internal func logOut() {
        profileV?.removeFromSuperview()

        userViewModel?.logout(completion: { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    Logger.log("unknown error: \(error)")
                    // TODO: ui
                    return
                }
                self.auth()
            }
        })
    }

    private func auth() {
        let authVC = SignIn()
        authVC.modalPresentationStyle = .fullScreen
        present(authVC, animated: true, completion: nil)
    }

    @objc
    internal func profile() { show_profile() }

    @objc
    private func show_profile() {
        disableTabBarButton()
        guard let profileV = profileV else { return }
        view.addSubview(profileV)
        profileV.setup()
    }
}
