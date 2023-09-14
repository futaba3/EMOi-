//
//  MyUINavigationController.swift
//  Goods2
//
//  Created by 工藤彩名 on 2019/09/01.
//  Copyright © 2019 Kudo Ayana. All rights reserved.
//

import UIKit

class MyUINavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            // NavigationBarの背景色の設定
            appearance.backgroundColor = UIColor.init(red: 239/255, green: 96/255, blue: 49/255, alpha: 100/100)
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            // NavigationBarのタイトルの文字色の設定
            appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Kano", size: 20), .foregroundColor: UIColor.white]
            
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationBar.tintColor = .white
        } else {
            navigationBar.barTintColor = UIColor.init(red: 239/255, green: 96/255, blue: 49/255, alpha: 100/100)
            // ナビゲーションバーのアイテムの色　（戻る　＜　とか　読み込みゲージとか）
            navigationBar.tintColor = .white
            // ナビゲーションバーのテキストを変更する
            navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Kano", size: 20), .foregroundColor: UIColor.white]
        }
        
    }
    
}

// navigationの入った画面はステータスバーの文字色を白にする
extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
