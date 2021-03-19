//
//  AppLoader.swift
//  IdealVisual
//
//  Created by a.kurganova on 02.01.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

class AppLoader: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let alert = UIAlertController(title: nil, message: "Идет загрузка...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.color = Colors.lightBlue
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()

        alert.view.addSubview(loadingIndicator)
        view.backgroundColor = .white

        present(alert, animated: true, completion: { [weak self] in
            DispatchQueue.main.async {
                let userViewModel: iUserWork? = UserViewModel()
                userViewModel?.get(completion: { (_, error) in
                    if let error = error {
                        switch error {
                        case .noData:
                            let signIn = SignIn()
                            self?.view.window!.rootViewController = signIn
                        default:
                            Logger.log("unknown error: \(error)")
                            fatalError()
                        }
                    } else {
                        let tabBar = TabBar()
                        self?.view.window!.rootViewController = tabBar
                    }
                    self?.dismiss(animated: false, completion: nil)
                })
            }
        })
    }
}
