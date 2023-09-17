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
    
    func showAutoDismissAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    func showTextFieldAlert(title: String, message: String, placeholder: String, okTitle: String, completion: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = placeholder
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { _ in
            completion(nil) // キャンセル時はnilを返す
        }
        let okAction = UIAlertAction(title: okTitle, style: .default) { _ in
            if let textField = alert.textFields?.first, let text = textField.text, !text.isEmpty {
                completion(text)
            } else {
                completion(nil)
                self.showAutoDismissAlert(title: "カテゴリー名を\n入力してください", message: "")
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
}
