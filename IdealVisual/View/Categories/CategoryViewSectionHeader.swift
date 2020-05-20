//
//  CategoryViewSectionHeader.swift
//  IdealVisual
//
//  Created by a.kurganova on 16.05.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

final class CategoryViewSectionHeader: UICollectionReusableView {
    let sectionHeader = UILabel()
    override init(frame: CGRect) {
        super.init(frame: .zero)
        sectionHeader.textAlignment = .left
        sectionHeader.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        sectionHeader.textColor = Colors.darkDarkGray

        self.addSubview(sectionHeader)
        sectionHeader.translatesAutoresizingMaskIntoConstraints = false
        sectionHeader.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).isActive = true
        sectionHeader.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        sectionHeader.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
