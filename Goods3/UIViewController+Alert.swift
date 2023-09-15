//
//  UIViewController+Alert.swift
//  Goods3
//
//  Created by Ayana Kudo on 2023/09/16.
//  Copyright © 2023 Kudo Ayana. All rights reserved.
//

import UIKit

public extension UIViewController {
    func showAlert(title: String, message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // ViewControllerで指定したActionはactionsに配列として渡されるので、forEach文で配列内のActionをaddActionする
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
}
