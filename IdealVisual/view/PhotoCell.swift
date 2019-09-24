//
// Created by a.kurganova on 10/09/2019.
// Copyright (c) 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

class PhotoCell : UICollectionViewCell {
    var picture = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(picture)
        picture.translatesAutoresizingMaskIntoConstraints = false
        picture.image = UIImage()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func fillCell() {
//        picture.image = UIImage(named: model.image)
//    }
    
}
