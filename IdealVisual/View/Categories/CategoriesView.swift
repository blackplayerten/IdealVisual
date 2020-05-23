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

protocol DisableTabBarDelegate: class {
    func enableTabBarButton()
    func disableTabBarButton()
}

final class CategoriesView: UIViewController {
    private var classificationViewModel: CoreMLViewModelProtocol?
    private var classificationStruct = ClassificationStruct(animal: [UIImage](), food: [UIImage](), people: [UIImage]())
    private var scaningImages = [UIImage]()
    private var scaningMutex = NSLock()

    private weak var delegateCreatePosts: MainViewAddPostsDelegate?
    private weak var disableTabBar: DisableTabBarDelegate?

    lazy fileprivate var collectionWithCategories: UICollectionView = {
        let cellSide = view.bounds.width / 3 - 1
        let sizecell = CGSize(width: cellSide, height: cellSide)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = sizecell
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.scrollDirection = .vertical
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

    init(postscreateDelegate: MainViewAddPostsDelegate?, disableTabBarDelegate: DisableTabBarDelegate?) {
        self.delegateCreatePosts = postscreateDelegate
        self.disableTabBar = disableTabBarDelegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        disableTabBar?.disableTabBarButton()
        setupNavItems()

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
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = .none

        navigationItem.setHidesBackButton(true, animated: false)
        guard let buttonBack = UIImage(named: "previous_gray")?.withRenderingMode(.alwaysOriginal) else { return }
        let myBackButton = SubstrateButton(image: buttonBack, side: 35, target: self, action: #selector(back),
                                           substrateColor: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: myBackButton)

        if let selectedCells = collectionWithCategories.indexPathsForSelectedItems {
            if !(selectedCells.count == 0) {
                guard let markYes = UIImage(named: "yes_yellow") else { return }
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: SubstrateButton(image: markYes,
                                                                                           side: 33,
                                                                                           target: self,
                                                                                           action: #selector(save)
                ))
            } else {
                navigationItem.rightBarButtonItem = nil
            }
        }

        let swipeBack = UISwipeGestureRecognizer(target: self, action: #selector(close_controller))
        swipeBack.direction = .right
        view.addGestureRecognizer(swipeBack)
    }

    @objc
    private func back() {
        navigationController?.popViewController(animated: true)
    }

     // MARK: - get photos from gallery
    private func getPhotos() {
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.isNetworkAccessAllowed = false
        requestOptions.deliveryMode = .highQualityFormat

        let results: PHFetchResult = PHAsset.fetchAssets(with: .image, options: nil)
        if results.count > 0 {
            self.present(loader, animated: true, completion: nil)
            var counterLoader = 0
            for i in 0..<1237 {
                let asset = results.object(at: i)
                let size = CGSize(width: 700, height: 700)
                manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill,
                                     options: requestOptions) { (image, _) in
                    if let image = image {
                        self.scaningMutex.lock()
                        self.scaningImages.append(image)
                        self.scaningMutex.unlock()
                    } else {
                        Logger.log("error asset to image")
                    }
                    counterLoader += 1

                    self.updateLoaderInfo(currentImage: counterLoader, allImages: 1237)

                    if counterLoader == 1237 {
                        print("scaning", self.scaningImages.count)
                        self.fillStruct()
                    }
                }
            }
        } else {
            Logger.log("no photos to display")
            self._error(text: "Нет фотографий", color: Colors.darkGray)
        }
    }

    // MARK: - Request to core ml
    private func fillStruct() {
        for (i, image) in self.scaningImages.enumerated() {
            self.classificationViewModel?.makeClassificationRequest(image: image,
                                                               completion: { [weak self] (identifier, error) in
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
                    self?.classificationStruct.animal.append(image)
                case .food:
                    self?.classificationStruct.food.append(image)
                case .people:
                    self?.classificationStruct.people.append(image)
                default:
                    Logger.log("unknown type")
                    self?._error(text: "Неизвестная категория")
                }

                guard let allPhotos = self?.scaningImages.count else {
                    Logger.log("NO SCANING PHOTOS")
                    self?._error(text: "Нет фотографий")
                    return
                }

                if i == allPhotos - 1 {
                    self?.dismiss(animated: true, completion: nil)
                    self?.setupCollection()
                }
                }
            })
        }
    }

    // MARK: - setup collection
    private func setupCollection() {
        view.addSubview(collectionWithCategories)
        collectionWithCategories.translatesAutoresizingMaskIntoConstraints = false
        collectionWithCategories.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionWithCategories.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionWithCategories.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionWithCategories.bottomAnchor.constraint(equalTo:
            view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        collectionWithCategories.backgroundColor = .white

        collectionWithCategories.delegate = self
        collectionWithCategories.dataSource = self

        collectionWithCategories.register(PhotoCell.self, forCellWithReuseIdentifier: "cell")
        collectionWithCategories.register(CategoryViewSectionHeader.self,
                                          forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                          withReuseIdentifier: "header")
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
                guard let cell = collectionWithCategories.cellForItem(at: $0) as? PhotoCell else { return }
                cell.selectedImage.isHidden = true
                delegateCreatePosts?.create(photoName: "photoName",
                                            photoData: cell.picture.image!.jpegData(compressionQuality: 1.0),
                                            date: Date(timeIntervalSince1970: 0), place: "", text: "")
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
        return CGSize(width: self.view.frame.width, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: "header",
                                                                           for: indexPath)
        if let unwrapReusableView = reusableview as? CategoryViewSectionHeader {
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
        return reusableview
    }

    // MARK: - cell for item at
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let unwrapCell = cell as? PhotoCell {
            unwrapCell.picture.frame = CGRect(x: 0, y: 0, width: view.bounds.width / 3 - 1,
                                      height: view.bounds.width / 3 - 1)
            unwrapCell.backgroundColor = .gray

            switch indexPath.section {
            case 0:
                unwrapCell.picture.image = classificationStruct.animal[indexPath.item]
            case 1:
                unwrapCell.picture.image = classificationStruct.food[indexPath.item]
            case 2:
                unwrapCell.picture.image = classificationStruct.people[indexPath.item]
            default:
                Logger.log("unknown category")
                unwrapCell.picture.image = UIImage()
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if let selectCell = cell as? PhotoCell {
            selectCell.selectedImage.isHidden = false
            setupNavItems()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if let selectCell = cell as? PhotoCell {
            selectCell.selectedImage.isHidden = true
            setupNavItems()
        }
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
extension CategoriesView {
    private func updateLoaderInfo(currentImage: Int? = 0, allImages: Int? = 0) {
        updateInfo.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        updateInfo.text = "Сканирование \(currentImage!) / \(allImages!)"
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

extension CategoriesView {
    @objc
    private func close_controller() {
        disableTabBar?.enableTabBarButton()
        navigationController?.popViewController(animated: true)
    }
}
