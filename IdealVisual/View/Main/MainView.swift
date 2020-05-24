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
    private var helpCategories: MainViewAddPostsDelegate?

    private let refreshOnSwipeView: UIScrollView = UIScrollView()
    private let helpText: UILabel = UILabel()
    private let photo: UIButton = UIButton()
    private var urlAva: String?
    private var editMode: Bool = false

    private let profileB: UIButton = UIButton()
    private var avaUser: UIImage = UIImage()
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
        navigationController?.navigationBar.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.userViewModel = UserViewModel()
        let postVM = PostViewModel(delegat: self)
        self.postViewModel = postVM
        self.helpCategories = postVM
        view.backgroundColor = .white

        self.tabBarController?.delegate = self
        choose.delegate = self
        choose.sourceType = .photoLibrary
        choose.allowsEditing = true

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 5,
                                                                     y: 5,
                                                                     width: 5, height: 5))
        loadingIndicator.color = Colors.blue
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: loadingIndicator)

        userViewModel?.getAvatar(completion: { [weak self] (avatar, error) in
            DispatchQueue.main.async {
                if let error = error {
                    switch error {
                    case .noData:
                        Logger.log(error)
                        self?._error(text: "Невозможно загрузить данные", color: Colors.darkGray)
                    default:
                        Logger.log(error)
                        self?._error(text: "Упс, что-то пошло не так.", color: Colors.red)
                    }
                }

                if avatar != nil {
                    self?.avaUser = UIImage(contentsOfFile: avatar!)!
                } else {
                    self?.avaUser = UIImage(named: "default_profile")!
                }

                loadingIndicator.stopAnimating()
                self?.setNavItems()
            }
        })

        profileV = ProfileView(profileDelegate: self)
        setNavTitle()
        initContent()
        setupHelpAndRefreshView()
        checkPhotos()

        self.postViewModel?.subscribe(completion: { [weak self] (_) in
                DispatchQueue.main.async {
                    self?.checkPhotos()
                    self?.setNavItems()
                }
            })

        postViewModel?.sync(completion: { [weak self] (error) in
            DispatchQueue.main.async {
                if let error = error {
                    switch error {
                    case .unauthorized:
                        self?._error(text: "Вы не авторизованы", color: Colors.red)
                        sleep(3)
                        self?.logOut()
                    case .notFound:
                        // only manual sync triggers alert
                        break
                    case .noConnection:
                        self?._error(text: "Нет соединения с интернетом", color: Colors.darkGray)
                    default:
                        self?._error(text: "Ошибка синхронизации", color: Colors.red)
                    }
                    Logger.log("cannot sync: \(error)")
                }
            }
        })
    }


    // MARK: ui error
    private func _error(text: String, color: UIColor? = Colors.red) {
        let un = UIError(text: text, place: view, color: color)
        view.addSubview(un)
        un.translatesAutoresizingMaskIntoConstraints = false
        un.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -view.bounds.width / 2).isActive = true
        un.centerYAnchor.constraint(equalTo: content.topAnchor).isActive = true
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
        profileB.translatesAutoresizingMaskIntoConstraints = false
        profileB.clipsToBounds = true
        profileB.contentMode = .center
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileB)

        profileB.setBackgroundImage(avaUser, for: .normal) //ava from cache

        profileB.widthAnchor.constraint(equalToConstant: 33).isActive = true
        profileB.heightAnchor.constraint(equalToConstant: 33).isActive = true
        profileB.layer.cornerRadius = 10
        profileB.addTarget(self, action: #selector(profile), for: .touchUpInside)

        if postViewModel?.posts.count != 0 {
            guard let markEdit = UIImage(named: "edit_gray") else { return }
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: SubstrateButton(image: markEdit, side: 35,
                                                                                           target: self,
                                                                                           action: #selector(edit)
            ))
        } else {
            navigationItem.leftBarButtonItem = nil
        }
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

        let refreshControl = UIRefreshControl()
        content.refreshControl = refreshControl
        refreshControl.tintColor = Colors.lightBlue
        refreshControl.addTarget(self, action: #selector(doSync(_:)), for: .valueChanged)
    }

    // MARK: - synchronization posts
    @objc private func doSync(_ sender: UIRefreshControl) {
        postViewModel?.sync(completion: { [weak self] (error) in
            DispatchQueue.main.async {
                if let error = error {
                    switch error {
                    case .unauthorized:
                        self?._error(text: "Вы не авторизованы")
                        sleep(3)
                        self?.logOut()
                    case .notFound:
                        self?._error(text: "Посты не найдены", color: Colors.darkGray)
                    case .noConnection:
                        self?._error(text: "Нет соединения с интернетом", color: Colors.darkGray)
                    default:
                        self?._error(text: "Ошибка синхронизации")
                    }
                    Logger.log("cannot sync: \(error)")
                }
                sender.endRefreshing()
            }
        })
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
                completion: { [weak self] (error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            switch error {
                            case .unauthorized:
                                Logger.log(error)
                                self?._error(text: "Вы не авторизованы")
                                sleep(3)
                                self?.logOut()
                            case .notFound:
                                Logger.log(error)
                                self?._error(text: "Такого пользователя нет")
                                sleep(3)
                                self?.logOut()
                            case .cannotCreate:
                                Logger.log(error)
                                self?._error(text: "Невозможно создать пост", color: Colors.darkGray)
                            case .noData:
                                Logger.log(error)
                                self?._error(text: "Невозможно загрузить данные", color: Colors.darkGray)
                            default:
                                Logger.log(error)
                                self?._error(text: "Упс, что-то пошло не так.")
                            }
                        }
                        self?.setNavItems()
                        self?.checkPhotos()
                    }
            })
            self.setNavItems()
            self.checkPhotos()
            }
        }
        dismissAlert()
    }

    func dismissAlert() { dismiss(animated: true, completion: nil) }

    func chooseAvatar(picker: UIImagePickerController) { present(picker, animated: true, completion: nil) }

    // MARK: - alerts
    @objc private func choose_photo() {
        let alert = UIAlertController(title: "Выберите изображение", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Галерея", style: .default, handler: { _ in self.openGallery() }))
        alert.addAction(UIAlertAction(title: "Помощь", style: .default, handler: { _ in
            let categories = CategoriesView(postscreateDelegate: self.helpCategories)
            categories.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(categories, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Отменить", style: UIAlertAction.Style.cancel, handler: nil))
        present(alert, animated: true)
    }
}

// MARK: - delegate
extension MainView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if editMode == false {
            content.indexPathsForSelectedItems?.forEach {
                content.deselectItem(at: $0, animated: true)
            }
            
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

            unwrapCell.picture.frame = CGRect(x: 0, y: 0, width: view.bounds.width / 3 - 1,
                                      height: view.bounds.width / 3 - 1)

            unwrapCell.backgroundColor = .gray

            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 50,
                                                                         y: 50,
                                                                         width: 50, height: 50))
            loadingIndicator.color = Colors.blue
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.startAnimating()
            unwrapCell.addSubview(loadingIndicator)

            DispatchQueue.main.async {
                loadingIndicator.stopAnimating()
                unwrapCell.picture.image = UIImage(contentsOfFile: postViewModel.getPhoto(path: path))
            }
        }
        return cell
    }

    // MARK: - set refresh and help
    private func setupHelpAndRefreshView() {
        let refreshControl = UIRefreshControl()
        refreshOnSwipeView.refreshControl = refreshControl
        refreshControl.tintColor = Colors.lightBlue
        refreshControl.addTarget(self, action: #selector(doSync(_:)), for: .valueChanged)

        helpText.font = UIFont(name: "PingFang-SC-Regular", size: 18)
        helpText.numberOfLines = 0
        helpText.textAlignment = .center
        helpText.textColor = Colors.darkGray
        helpText.layer.masksToBounds = true
        helpText.layer.cornerRadius = 20
        helpText.backgroundColor = UIColor(white: 1, alpha: 0.8)
    }

    private func showHelp() {
        view.addSubview(refreshOnSwipeView)
        refreshOnSwipeView.translatesAutoresizingMaskIntoConstraints = false
        refreshOnSwipeView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        refreshOnSwipeView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        refreshOnSwipeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        refreshOnSwipeView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        refreshOnSwipeView.addSubview(helpText)

        helpText.translatesAutoresizingMaskIntoConstraints = false
        helpText.centerXAnchor.constraint(equalTo: refreshOnSwipeView.centerXAnchor).isActive = true
        helpText.topAnchor.constraint(equalTo: refreshOnSwipeView.topAnchor,
                                     constant: 50).isActive = true
        helpText.widthAnchor.constraint(equalToConstant: 300).isActive = true

        let back = UIImageView()
        back.image = UIImage(named: "fon")
        refreshOnSwipeView.addSubview(back)
        back.translatesAutoresizingMaskIntoConstraints = false
        back.widthAnchor.constraint(equalToConstant: view.bounds.width).isActive = true
        back.heightAnchor.constraint(equalToConstant: 250).isActive = true
        back.topAnchor.constraint(equalTo: helpText.bottomAnchor, constant: 100).isActive = true
        back.bottomAnchor.constraint(equalTo: refreshOnSwipeView.bottomAnchor).isActive = true
    }

    // MARK: - check photos
    private func checkPhotos() {
        if postViewModel?.posts.count != 0 {
            content.isHidden = false
            refreshOnSwipeView.removeFromSuperview()
        } else {
            content.isHidden = true
            showHelp()
            helpText.text = """
            Здесь будут размещены Ваши фото \n
            Чтобы начать свой путь к созданию идеальной ленты или блога \
            добавьте свою первую фотографию нажав на +
            """
        }
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
                let destinationIndexPath = coordinator.destinationIndexPath,
                let viewModel = postViewModel
            else { return }

            postViewModel?.swap(source: sourceIndexPath.item, dest: destinationIndexPath.item,
                                completion: { [weak self] (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        switch error {
                        case .unauthorized:
                            self?._error(text: "Вы не авторизованы")
                            sleep(3)
                            self?.logOut()
                        case .notFound:
                            self?._error(text: "Ошибка синхронизации", color: Colors.darkGray)
                        case .notFound:
                            self?._error(text: "Невозможно отобразить данные", color: Colors.darkGray)
                        default:
                            self?._error(text: "Упс, что-то пошло не так.")
                        }
                    }
                }
            })
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

        content.indexPathsForSelectedItems?.forEach {
            content.deselectItem(at: $0, animated: true)
        }

        content.allowsMultipleSelection = false
        content.dragInteractionEnabled = true

        editMode = false
    }

    @objc
    private func save() {
        if editMode {
            editMode = false

            if let selectedCells = content.indexPathsForSelectedItems {
                if selectedCells.count == 0 {
                    self.setNavItems()
                    self.checkPhotos()
                    return
                }

                let items = selectedCells.map { $0.item }.sorted().reversed()
                content.indexPathsForSelectedItems?.forEach {
                    content.deselectItem(at: $0, animated: true)
                }

                postViewModel?.delete(atIndices: [Int](items),
                                      completion: { [weak self] (error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            switch error {
                            case .unauthorized:
                                Logger.log(error)
                                self?._error(text: "Вы не авторизованы")
                                sleep(3)
                                self?.logOut()
                            case .noData:
                                Logger.log(error)
                                self?._error(text: "Невозможно загрузить данные", color: Colors.darkGray)
                            case .notFound:
                                Logger.log(error)
                                self?._error(text: "Пост для удаления не найден", color: Colors.darkGray)
                            default:
                                Logger.log(error)
                                self?._error(text: "Упс, что-то пошло не так.")
                            }
                        }
                        self?.setNavItems()
                        self?.checkPhotos()
                    }
                })
            }

            content.allowsMultipleSelection = false
            content.dragInteractionEnabled = true
        }
    }
}

// MARK: - tab bar
extension MainView: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if self.tabBarController?.selectedIndex == 0 { self.choose_photo() }
    }

    internal func disableTabBarButton() { grayTabBarButton() }

    private func grayTabBarButton() {
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

extension MainView: PostChangedDelegate {
    // MARK: - posts changet (collection view)
    internal func didChanged(itemsChanged: [(type: NSFetchedResultsChangeType,
                                           indexPath: IndexPath?, newIndexPath: IndexPath?)]) {
        content.performBatchUpdates({
            for change in itemsChanged {

                switch change.type {
                case .insert: self.content.insertItems(at: [change.newIndexPath!])
                case .delete: self.content.deleteItems(at: [change.indexPath!])
                case .update: self.content.reloadItems(at: [change.indexPath!])
                case .move:
                    self.content.deleteItems(at: [change.indexPath!])
                    self.content.insertItems(at: [change.newIndexPath!])
                @unknown default:
                    return
                }
            }
        })
    }
}

// MARK: - profile delegate
extension MainView: ProfileDelegate {
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    internal func updateAvatar(image: UIImage) {
        avaUser = image
        profileB.setBackgroundImage(avaUser, for: .normal) //ava from profile view (updated)
    }

    internal func logOut() {
        profileV?.removeFromSuperview()

        userViewModel?.logout(completion: { [weak self] (error) in
            DispatchQueue.main.async {
                if let error = error {
                    switch error {
                    case .noConnection:
                        self?._error(text: "Нет соединения с интернетом", color: Colors.darkGray)
                    default:
                        Logger.log(error)
                        self?._error(text: "Упс, что-то пошло не так.")
                    }
                }
                self?.auth()
            }
        })
    }

    private func auth() {
        let authVC = SignIn()
        authVC.modalPresentationStyle = .fullScreen
        present(authVC, animated: true, completion: nil)
    }

    @objc
    internal func profile() {
        show_profile()
    }

    @objc
    private func show_profile() {
        disableTabBarButton()
        guard let profileV = profileV else { return }
        view.addSubview(profileV)
        profileV.setup()
    }
}

protocol PostChangedDelegate: class {
    func didChanged(itemsChanged: [(type: NSFetchedResultsChangeType,
                    indexPath: IndexPath?, newIndexPath: IndexPath?)])
}
