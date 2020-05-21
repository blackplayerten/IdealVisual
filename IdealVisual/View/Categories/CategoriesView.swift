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
    private var classificationStruct = ClassificationStruct(animal: [UIImage](), food: [UIImage](), people: [UIImage]())
    private var scaningImages = [UIImage]()
    private var scaningMutex = NSLock()

    private weak var delegateCreatePosts: MainViewAddPostsDelegate?

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

    init(postscreateDelegate: MainViewAddPostsDelegate?) {
        self.delegateCreatePosts = postscreateDelegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavItems()

        self.classificationViewModel = CoreMLViewModel()
        if classificationViewModel == nil {
            Logger.log("classification view-model is empty")
            return
        }

        getPhotos()
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

        let swipeBack = UISwipeGestureRecognizer(target: self, action: #selector(back))
        swipeBack.direction = .right
        view.addGestureRecognizer(swipeBack)
    }

    @objc
    private func back() {
        navigationController?.popViewController(animated: true)
    }

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

    private func fillStruct() {
        for (i, image) in self.scaningImages.enumerated() {
            self.classificationViewModel?.makeClassificationRequest(image: image,
                                                               completion: { [weak self] (identifier, error) in
            DispatchQueue.main.async {
                print(i)
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

                let alert = UIAlertController(title: nil, message: "Распознавание...", preferredStyle: .alert)
                let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                loadingIndicator.color = Colors.lightBlue
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.startAnimating()

                alert.view.addSubview(loadingIndicator)
                self?.present(alert, animated: true, completion: nil)
                
                print(image)

                if i == (self?.scaningImages.count)! - 1 { // FIXME: unwrap with guard
                    self?.setupCollection()
                    self?.dismiss(animated: true, completion: nil)
                }
                }
            })
        }
    }

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

    private func getPhotos() {
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.isNetworkAccessAllowed = false
        requestOptions.deliveryMode = .highQualityFormat

        let results: PHFetchResult = PHAsset.fetchAssets(with: .image, options: nil)
        if results.count > 0 {
            for i in 0..<results.count {
                let asset = results.object(at: i)
                let size = CGSize(width: 700, height: 700)
                manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill,
                                     options: requestOptions) { (image, _) in
                    if let image = image {
                        self.scaningMutex.lock()
                        self.scaningImages.append(image)
                        self.scaningMutex.unlock()
                    } else {
                        print("error asset to image")
                    }
                    if self.scaningImages.count == 500 { // FIXME: careful!
                        print("scaning", self.scaningImages.count)
                        self.fillStruct()
                    }
                }
            }
        } else {
            print("no photos to display")
        }
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

    func collectionView(_ collectionView: UICollectionView, cellForItemAt
        indexPath: IndexPath) -> UICollectionViewCell {
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
}

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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if let selectCell = cell as? PhotoCell {
            selectCell.selectedImage.isHidden = false

            setupNavItems()
        }
    }
}

extension CategoriesView {
    @objc
    private func close_controller() {
        self.dismiss(animated: true, completion: nil)
    }
}
