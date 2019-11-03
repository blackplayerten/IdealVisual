//
// Created by a.kurganova on 10/09/2019.
// Copyright (c) 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

class PhotoCell : UICollectionViewCell {
    var picture = UIImageView()
    var selectedImage = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(picture)
        picture.translatesAutoresizingMaskIntoConstraints = false
        picture.widthAnchor.constraint(equalToConstant: contentView.bounds.width).isActive = true
        picture.heightAnchor.constraint(equalToConstant: contentView.bounds.width).isActive = true
        picture.image = UIImage()
        
        picture.addSubview(selectedImage)
        selectedImage.isHidden = true
        selectedImage.translatesAutoresizingMaskIntoConstraints = false
        selectedImage.image = UIImage(named: "yes")
        selectedImage.widthAnchor.constraint(equalToConstant: 50).isActive = true
        selectedImage.heightAnchor.constraint(equalToConstant: 50).isActive = true
        selectedImage.centerXAnchor.constraint(equalTo: picture.centerXAnchor).isActive = true
        selectedImage.centerYAnchor.constraint(equalTo: picture.centerYAnchor).isActive = true
        selectedImage.backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
