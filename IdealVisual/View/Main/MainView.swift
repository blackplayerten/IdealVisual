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
    private var postFetcher: NSFetchedResultsController<Post>?
    private var userViewModel: UserViewModelProtocol?

    private var refreshControl = UIRefreshControl()

    private let helpText = UILabel()
    private let photo = UIButton()
    private var urlAva: String?
    private var editMode: Bool = false

    fileprivate var choose = UIImagePickerController()

    private var sectionChanges = [(type: NSFetchedResultsChangeType, sectionIndex: Int)]()
    private var itemChanges = [(type: NSFetchedResultsChangeType, indexPath: IndexPath?, newIndexPath: IndexPath?)]()

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
        view.backgroundColor = .white
        let back = UIImageView(frame: CGRect(x: 0, y: view.bounds.height/2, width: view.bounds.width, height: 250))
        back.image = UIImage(named: "fon")
        view.addSubview(back)

        self.tabBarController?.delegate = self
        choose.delegate = self
        choose.sourceType = .photoLibrary
        choose.allowsEditing = true

        profileV = ProfileView(profileDelegate: self)

        // TODO: view-model
        postFetcher = PostCoreData.getAll()
        postFetcher?.delegate = self

        do {
            try postFetcher?.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Save Note")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }

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
                    // TODO: ui
                    return
                }
                profileV.setBackgroundImage(UIImage(contentsOfFile: avatar), for: .normal)
            }
        })

        profileV.widthAnchor.constraint(equalToConstant: 33).isActive = true
        profileV.heightAnchor.constraint(equalToConstant: 33).isActive = true
        profileV.layer.cornerRadius = 10
        profileV.addTarget(self, action: #selector(profile), for: .touchUpInside)

        initContent()
        if postFetcher?.fetchedObjects?.count != 0 {
            guard let markEdit = UIImage(named: "edit_gray") else { return }
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: SubstrateButton(image: markEdit,
                                                                                           side: 35,
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
        content.prefetchDataSource = self
        content.register(PhotoCell.self, forCellWithReuseIdentifier: "cell")
        content.reloadData()
        view.addSubview(content)
        content.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        content.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        content.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        content.layer.backgroundColor = UIColor.white.cgColor

        content.refreshControl = refreshControl
        refreshControl.tintColor = Colors.lightBlue
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
                let fileName = url.lastPathComponent
                _ = savePhoto(photo: selected, typePhoto: .post, fileName: fileName)
                guard var indexPhoto = postFetcher?.fetchedObjects?.count else { return }
                indexPhoto += 1
                _ = PostCoreData.createPost( photo: getFolderName(typePhoto: .post) + "/" + fileName,
                                             date: Date(timeIntervalSince1970: 0), place: "", text: "",
                                             indexPhoto: indexPhoto
                )
            }
            setNavItems()
            checkPhotos()
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
            let detailPhoto = PostView()
            guard let posts = postFetcher?.fetchedObjects else { return }
            let post = posts[indexPath.item]
            detailPhoto.publication = post
            detailPhoto.photo.image = getPhoto(namePhoto: post.photo!, typePhoto: .post)
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

// MARK: - data source
extension MainView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = postFetcher?.sections else {
            return 0
        }

        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->
        UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            if let unwrapCell = cell as? PhotoCell {
                guard let post = postFetcher?.object(at: indexPath) else { fatalError() }

                unwrapCell.backgroundColor = .gray

                unwrapCell.picture.image = getPhoto(namePhoto: post.photo!,
                                                    typePhoto: .post)
                unwrapCell.picture.frame = CGRect(x: 0, y: 0, width: view.bounds.width / 3 - 1,
                                          height: view.bounds.width / 3 - 1)
            }
        return cell
    }

    private func checkPhotos() {
        if postFetcher?.fetchedObjects?.count != 0 {
            content.isHidden = false
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
        guard let imageURL = postFetcher?.fetchedObjects?[indexPath.row].photo,
              let image = getPhoto(namePhoto: imageURL, typePhoto: .post)
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
            guard let sourceIndexPath = item.sourceIndexPath else { return }
            guard let destinationIndexPath = coordinator.destinationIndexPath else { return }

            collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath) // kostyl
            guard let posts = postFetcher?.fetchedObjects else { return }
            PostCoreData.swap(posts, source: sourceIndexPath.item, dest: destinationIndexPath.item)
        }
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?) ->
        UICollectionViewDropProposal {
           return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
}

// MARK: - fetchResultControllerDelegate
extension MainView: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        sectionChanges.append((type, sectionIndex))
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        itemChanges.append((type, indexPath, newIndexPath))
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.content.performBatchUpdates({
            for change in self.itemChanges {
                switch change.type {
                case .insert: self.content.insertItems(at: [change.newIndexPath!])
                case .delete: self.content.deleteItems(at: [change.indexPath!])
                case .update: self.content.reloadItems(at: [change.indexPath!])
                case .move:
                    self.content.deleteItems(at: [change.indexPath!])
                    self.content.insertItems(at: [change.newIndexPath!])
                @unknown default:
                    fatalError()
                }
            }
            self.itemChanges.removeAll()
        })
    }
}

// MARK: - edit collection view
extension MainView {
    @objc
    private func edit() {
        editMode = true
        setNavEditItems()
        initContent()
        content.allowsMultipleSelection = true
        content.dragInteractionEnabled = false
    }

    @objc
    private func no() {
        setNavItems()
        checkPhotos()

        editMode = false
    }

    // TODO: view-model
    @objc
    private func save() {
        if editMode {
            if let selectedCells = content.indexPathsForSelectedItems {
                let items = selectedCells.map { $0.item }.sorted().reversed()
                for item in items {
                    guard let posts = postFetcher?.fetchedObjects else { fatalError() }
                    let delPost = posts[item]
                    let photoPath = delPost.photo ?? ""
                    PostCoreData.delete(post: delPost)
                    deleteFile(filePath: photoPath)
                }
            }
            setNavItems()
            checkPhotos()
            editMode = false
        }
    }
}

// MARK: - refresh control
extension MainView: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(tick),
                                 userInfo: nil, repeats: true)
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    }

    @objc private func tick() {
        refreshControl.endRefreshing()
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
                    switch error {
                    case ErrorsUserViewModel.notFound:
                        // TODO: ui
                        break
                    default:
                        print("undefined error: \(error)"); return
                    }
                }
            }
        })
    auth()
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
