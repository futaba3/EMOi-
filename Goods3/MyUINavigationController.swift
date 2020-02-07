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
        //　ナビゲーションバーの背景色
        navigationBar.barTintColor = UIColor.init(red: 239/255, green: 96/255, blue: 49/255, alpha: 100/100)
        // ナビゲーションバーのアイテムの色　（戻る　＜　とか　読み込みゲージとか）
        navigationBar.tintColor = .white
        // ナビゲーションバーのフォントと色
        navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Kano", size: 20), .foregroundColor: UIColor.white]
    }
    
}

// navigationの入った画面はステータスバーの文字色を白にする
extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
