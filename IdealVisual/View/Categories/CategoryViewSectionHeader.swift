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
        self.backgroundColor = .white
        sectionHeader.textAlignment = .left
        sectionHeader.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        sectionHeader.textColor = Colors.lightBlue

        self.addSubview(sectionHeader)
        sectionHeader.translatesAutoresizingMaskIntoConstraints = false
        sectionHeader.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        sectionHeader.centerYAnchor.constraint(equalTo: self.bottomAnchor, constant: -23).isActive = true
        sectionHeader.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }

    convenience init(buttonBack: SubstrateButton, selectedCounter: UILabel, selectedChechMark: SubstrateButton) {
        self.init()
        [buttonBack, selectedCounter, selectedChechMark].forEach {
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive =  true
        }
        buttonBack.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        selectedChechMark.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        selectedCounter.rightAnchor.constraint(equalTo: selectedChechMark.leftAnchor, constant: 10).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
