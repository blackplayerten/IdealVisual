//
//  CategoriesView.swift
//  IdealVisual
//
//  Created by a.kurganova on 13.05.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation
import UIKit
import Photos

final class CategoriesView: UIViewController {
    private var classificationViewModel: CoreMLViewModelProtocol?
    private var classificationOneImageStruct = ImageWithNameStruct(imageName: "", image: UIImage())
    private var classificationStruct = ClassificationStruct(animal: [ImageWithNameStruct](),
                                                            food: [ImageWithNameStruct](),
                                                            people: [ImageWithNameStruct]())

    private weak var delegateCreatePosts: MainViewAddPostsDelegate?

    private var reusableview: UICollectionReusableView?
    private let countingChoosing = UILabel()

    lazy fileprivate var collectionWithCategories: UICollectionView = {
        let cellSide = view.bounds.width / 6 - 1
        let sizecell = CGSize(width: cellSide, height: cellSide)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = sizecell
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.scrollDirection = .vertical
        layout.sectionHeadersPinToVisibleBounds = true
        return UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
    }()

    // MARK: - loader init
    private let updateInfo = UILabel(frame: CGRect(x: 50, y: -2, width: 200, height: 50))

    lazy fileprivate var loader: UIAlertController = {
        let alert = UIAlertController(title: nil, message: "", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 5, y: -2, width: 50, height: 50))
        loadingIndicator.color = Colors.lightBlue
        loadingIndicator.hidesWhenStopped = true
        alert.view.addSubview(loadingIndicator)
        alert.view.addSubview(updateInfo)
        loadingIndicator.startAnimating()
        return alert
    }()

    init(postscreateDelegate: MainViewAddPostsDelegate?) {
        self.delegateCreatePosts = postscreateDelegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - view did load, ask permissions
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionWithCategories.register(PhotoCell.self, forCellWithReuseIdentifier: "cell")
        collectionWithCategories.register(CategoryViewSectionHeader.self,
                                          forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                          withReuseIdentifier: "header")

        let status = PHPhotoLibrary.authorizationStatus()
        view.backgroundColor = .white

        self.tabBarController?.tabBar.isHidden = true
        setupNavItems()

        // MARK: permissions
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        self.initModel()
                    } else {
                        self.noPermissionsAlert()
                    }
                }
            }
        case .authorized:
            initModel()
        case .denied, .restricted, .limited:
            noPermissionsAlert()
        }
    }

    // MARK: - create ML model
    private func initModel() {
        self.classificationViewModel = CoreMLViewModel()
            if classificationViewModel == nil {
                Logger.log("classification view-model is empty")
                return
            }

            classificationViewModel?.createMLModel(completion: { [weak self] (model, error) in
            if let err = error {
                switch err {
                case .createModel:
                   self?._error(text: "Внутренняя ошибка")
                default:
                    self?._error(text: "Упс, что-то пошло не так")
                }
            }

            if model == nil {
                Logger.log("MODEL IS NIL")
                self?._error(text: "Упс, что-то пошло не так")
                return
            }

            self?.getPhotos()
        })
    }

    // MARK: - navbar and swipe back
    private func setupNavItems() {
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()

        navigationItem.setHidesBackButton(true, animated: false)
        guard let buttonBack = UIImage(named: "previous_gray")?.withRenderingMode(.alwaysOriginal) else { return }
        let myBackButton = SubstrateButton(image: buttonBack, side: 35, target: self,
                                           action: #selector(close_controller), substrateColor: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: myBackButton)

        if let selectedCells = collectionWithCategories.indexPathsForSelectedItems {
            if !(selectedCells.count == 0) {
                guard let markYes = UIImage(named: "yes_yellow") else { return }
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: SubstrateButton(image: markYes,
                                                                                           side: 33,
                                                                                           target: self,
                                                                                           action: #selector(save)
                ))
                countingChoosing.isHidden = false
                countingChoosing.textColor = Colors.darkGray
                countingChoosing.font = UIFont(name: "PingFang-SC-SemiBold", size: 14)
                countingChoosing.translatesAutoresizingMaskIntoConstraints = false
                navigationController?.navigationBar.addSubview(countingChoosing)
                countingChoosing.centerYAnchor.constraint(
                    equalTo: (navigationController?.navigationBar.centerYAnchor)!).isActive = true
                countingChoosing.rightAnchor.constraint(equalTo: (navigationController?.navigationBar.rightAnchor)!,
                                                       constant: -50).isActive = true
                countingChoosing.widthAnchor.constraint(equalToConstant: 30).isActive = true
                countingChoosing.heightAnchor.constraint(equalToConstant: 30).isActive = true
                countingChoosing.text = String(describing:
                    (collectionWithCategories.indexPathsForSelectedItems?.count)!)
            } else {
                navigationItem.rightBarButtonItem = nil
                countingChoosing.isHidden = true
            }
        }

        let swipeBack = UISwipeGestureRecognizer(target: self, action: #selector(close_controller))
        swipeBack.direction = .right
        view.addGestureRecognizer(swipeBack)
    }

     // MARK: - get photos from gallery
    private func getPhotos() {
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.isNetworkAccessAllowed = false
        requestOptions.deliveryMode = .highQualityFormat

        var scaningImages = [ImageWithNameStruct]()
        let scaningMutex = NSLock()

        let results: PHFetchResult = PHAsset.fetchAssets(with: .image, options: nil)
        if results.count > 0 {
            self.present(loader, animated: true, completion: nil)
            var counterLoader = 0
            for i in 0..<results.count {
                let asset = results.object(at: i)
                let size = CGSize(width: 700, height: 700)
                manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill,
                                     options: requestOptions) { (image, _) in
                    if let image = image {
                        scaningMutex.lock()
                        scaningImages.append(ImageWithNameStruct(imageName: UUID().uuidString, image: image))
                        scaningMutex.unlock()
                    } else {
                        Logger.log("error asset to image")
                    }

                    counterLoader += 1
                    DispatchQueue.main.async {
                        self.updateLoaderInfo(tag: .scanning, currentImage: counterLoader, allImages: results.count)
                    }

                    if counterLoader == results.count {
                        print("scaning", scaningImages.count)
                        self.fillStruct(scaningImages: scaningImages)
                    }
                }
            }
        } else {
            Logger.log("no photos to display")
            self._error(text: "Нет фотографий", color: Colors.darkGray)
        }
    }

    // MARK: - Request to core ml
    private func fillStruct(scaningImages: [ImageWithNameStruct]) {
        var counterLoader = 0
        DispatchQueue.global().async {
            for (i, imageWithName) in scaningImages.enumerated() {
                self.classificationViewModel?.makeClassificationRequest(image: imageWithName.image,
                                                                   completion: { [weak self] (identifier, error) in
                    counterLoader += 1
                    DispatchQueue.main.async {
                    if let err = error {
                        switch err {
                        case .noResults:
                            self?._error(text: "Нет картинок для сравнения", color: Colors.darkGray)
                        case .emptyIdentifier:
                            self?._error(text: "Нет заданных категорий", color: Colors.darkGray)
                        default:
                            self?._error(text: "Упс, что-то пошло не так")
                        }
                    }

                    guard identifier != nil else {
                        Logger.log("empty identifier")
                        self?._error(text: "Нет заданных категорий")
                        return
                    }

                    switch identifier {
                    case .animal:
                        self?.classificationStruct.animal.append(imageWithName)
                    case .food:
                        self?.classificationStruct.food.append(imageWithName)
                    case .people:
                        self?.classificationStruct.people.append(imageWithName)
                    default:
                        Logger.log("unknown type")
                        self?._error(text: "Неизвестная категория")
                    }

                    self?.updateLoaderInfo(tag: .classifier, currentImage: counterLoader,
                                           allImages: scaningImages.count)

                    if i == scaningImages.count - 1 {
                        self?.dismiss(animated: true, completion: nil)
                        self?.setHelpTextAlert()
                        self?.setupCollection()
                    }
                }
            })
        }
        }
    }

    // MARK: - help alert
    private func setHelpTextAlert() {
        let textHelp = """
            \n Здесь будут отображаться фотографии с вашего телефона,
            разделенные на три категории: \n
            Животные Еда Люди \n
            Выберите понравившиеся фотографии и нажмите \u{2713},\t
            чтобы добавить их в ленту.
        """
        let helpAlert = UIAlertController(title: "Инструкция", message: textHelp, preferredStyle: .alert)
        helpAlert.addAction(UIAlertAction(title: "Понятно", style: .cancel, handler: nil))
        self.present(helpAlert, animated: true)
    }

    // MARK: - setup collection
    private func setupCollection() {
        view.addSubview(collectionWithCategories)
        collectionWithCategories.translatesAutoresizingMaskIntoConstraints = false
        collectionWithCategories.topAnchor.constraint(equalTo: view.topAnchor, constant: -100).isActive = true
        collectionWithCategories.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionWithCategories.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionWithCategories.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionWithCategories.backgroundColor = .white

        collectionWithCategories.delegate = self
        collectionWithCategories.dataSource = self

        collectionWithCategories.allowsMultipleSelection = true
    }

    // MARK: - copy photos to Main View
    @objc
    private func save() {
        if let selectedCells = collectionWithCategories.indexPathsForSelectedItems {
            if selectedCells.count == 0 {
                setupNavItems()
                return
            }

            selectedCells.forEach {
                collectionWithCategories.deselectItem(at: $0, animated: true)

                var imageWithName: ImageWithNameStruct
                switch $0.section {
                case 0:
                    imageWithName = classificationStruct.animal[$0.item]
                case 1:
                    imageWithName = classificationStruct.food[$0.item]
                case 2:
                    imageWithName = classificationStruct.people[$0.item]
                default:
                    Logger.log("unknown section: \($0.section)")
                    return
                }

                _ = delegateCreatePosts?.create(photoName: imageWithName.imageName,
                                                photoData: imageWithName.image.jpegData(compressionQuality: 1.0),
                                                date: Date(timeIntervalSince1970: 0), place: "", text: "",
                completion: { [weak self] (error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            switch error {
                            case .unauthorized:
                                Logger.log(error)
                                self?._error(text: "Вы не авторизованы")
                            case .notFound:
                                Logger.log(error)
                                self?._error(text: "Такого пользователя нет")
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
                    }
                })
            }
            self.close_controller()
        }
    }
}

// MARK: - collection delegate
extension CategoriesView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        self.reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: "header",
                                                                           for: indexPath)
        if let unwrapReusableView = reusableview as? CategoryViewSectionHeader {

            unwrapReusableView.sectionHeader.font = UIFont(name: "PingFang-SC-SemiBold", size: 18)
            switch indexPath.section {
            case 0:
                unwrapReusableView.sectionHeader.text = "Животные"
            case 1:
                unwrapReusableView.sectionHeader.text="Еда"
            case 2:
                unwrapReusableView.sectionHeader.text="Люди"
            default:
                unwrapReusableView.sectionHeader.text="Неизвестная секция"
            }
        }

        return self.reusableview!
    }

    // MARK: - cell for item at
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let unwrapCell = cell as? PhotoCell {
            unwrapCell.picture.frame = CGRect(x: 0, y: 0, width: view.bounds.width / 5 - 1,
                                      height: view.bounds.width / 5 - 1)
            unwrapCell.backgroundColor = .gray

            switch indexPath.section {
            case 0:
                unwrapCell.picture.image = classificationStruct.animal[indexPath.item].image
            case 1:
                unwrapCell.picture.image = classificationStruct.food[indexPath.item].image
            case 2:
                unwrapCell.picture.image = classificationStruct.people[indexPath.item].image
            default:
                Logger.log("unknown category")
                unwrapCell.picture.image = UIImage()
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setupNavItems()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        setupNavItems()
    }
}

// MARK: - collection data source
extension CategoriesView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return classificationStruct.animal.count
        case 1:
            return classificationStruct.food.count
        case 2:
            return classificationStruct.people.count
        default:
            Logger.log("no struct images")
            return 0
        }
    }
}

// MARK: - update loader info
enum StateLoader {
    case scanning
    case classifier
}

extension CategoriesView {
    private func updateLoaderInfo(tag: StateLoader, currentImage: Int? = 0, allImages: Int? = 0) {
        var stateName: String
        switch tag {
        case .scanning:
            stateName = "Сканирование"
        case .classifier:
            stateName = "Распознавание"
        }
        updateInfo.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .bold)
        updateInfo.text = "\(stateName): \(currentImage!) / \(allImages!)"
    }
}

// MARK: ui error
extension CategoriesView {
    private func _error(text: String, color: UIColor? = Colors.red) {
        let un = UIError(text: text, place: view, color: color)
        view.addSubview(un)
        un.translatesAutoresizingMaskIntoConstraints = false
        un.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -view.bounds.width / 2).isActive = true
        un.centerYAnchor.constraint(equalTo: collectionWithCategories.topAnchor).isActive = true
    }
}

// MARK: exit
extension CategoriesView {
    @objc
    private func close_controller() {
        countingChoosing.isHidden = true
        navigationController?.popViewController(animated: true)
    }

    private func noPermissionsAlert() {
        let alert = UIAlertController(title: nil, message: "Нет доступа к галерее",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default,
                                      handler: {_ in self.close_controller() }
        ))
        self.present(alert, animated: true)
    }
}
