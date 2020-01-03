//
//  Start.swift
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

        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating()

        alert.view.addSubview(loadingIndicator)
        view.backgroundColor = .white

        present(alert, animated: true, completion: {
            let userViewModel: UserViewModelProtocol? = UserViewModel()
            userViewModel?.get(completion: { (_, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        switch error {
                        case ErrorsUserViewModel.noData:
                            print("user nil, show signin")
                            let signIn = SignIn()
                            self.view.window!.rootViewController = signIn
                        default:
                            print("unknown error: \(error)")
                            fatalError()
                        }
                    } else {
                        print("user ne nill, show main")
                        let tabBar = TabBar()
                        self.view.window!.rootViewController = tabBar
                    }
                    self.dismiss(animated: false, completion: nil)
                }
            })
        })
    }
}
