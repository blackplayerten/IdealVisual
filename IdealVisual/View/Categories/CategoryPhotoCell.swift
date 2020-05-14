//
//  PhotoCell.swift
//  IdealVisual
//
//  Created by a.kurganova on 13.05.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

final class CategoryCell: UICollectionViewCell {
    var picture = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(picture)
        picture.translatesAutoresizingMaskIntoConstraints = false
        picture.widthAnchor.constraint(equalToConstant: contentView.bounds.width).isActive = true
        picture.heightAnchor.constraint(equalToConstant: contentView.bounds.width).isActive = true
        picture.clipsToBounds = true
        picture.contentMode = .scaleAspectFill
        picture.backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
