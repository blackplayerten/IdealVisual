//
//  PhotoCell.swift
//  Created by a.kurganova on 10/09/2019.
//  Copyright (c) 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

final class PhotoCell: UICollectionViewCell {
    var picture = UIImageView()
    var selectedImage = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(picture)
        picture.translatesAutoresizingMaskIntoConstraints = false
        picture.widthAnchor.constraint(equalToConstant: contentView.bounds.width).isActive = true
        picture.heightAnchor.constraint(equalToConstant: contentView.bounds.width).isActive = true
        picture.clipsToBounds = true
        picture.contentMode = .scaleAspectFill
        picture.backgroundColor = .white

        picture.addSubview(selectedImage)
        selectedImage.translatesAutoresizingMaskIntoConstraints = false
        selectedImage.widthAnchor.constraint(equalToConstant: 50).isActive = true
        selectedImage.heightAnchor.constraint(equalToConstant: 30).isActive = true
        selectedImage.topAnchor.constraint(equalTo: picture.topAnchor).isActive = true
        selectedImage.rightAnchor.constraint(equalTo: picture.rightAnchor).isActive = true
        selectedImage.backgroundColor = .clear
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        selectedImage.image = UIImage(named: "selected")
        selectedImage.isHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
