//
//  MyUITabBarController.swift
//  Goods2
//
//  Created by 工藤彩名 on 2019/09/24.
//  Copyright © 2019 Kudo Ayana. All rights reserved.
//

import UIKit

class MyUITabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            // 背景色
            appearance.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 100/100)
            
            let barItemAppearance = UITabBarItemAppearance()
            // .normal, .selected, .disacled, .focusedがある
            // 非選択時の色とフォント
            barItemAppearance.normal.titleTextAttributes = [ .font : UIFont.init(name: "Kano", size: 10), .foregroundColor : UIColor.darkGray ]
            // 選択時の色とフォント
            barItemAppearance.selected.iconColor = UIColor.init(red: 239/255, green: 96/255, blue: 49/255, alpha: 100/100)
            barItemAppearance.selected.titleTextAttributes = [ .font : UIFont.init(name: "Kano", size: 10), .foregroundColor : UIColor.init(red: 239/255, green: 96/255, blue: 49/255, alpha: 100/100)]
            
            appearance.stackedLayoutAppearance = barItemAppearance
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            self.tabBarController?.tabBar.standardAppearance = appearance
            self.tabBarController?.tabBar.scrollEdgeAppearance = appearance
            
        } else {
            // 背景色
            UITabBar.appearance().barTintColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 100/100)
            // 選択時の画像と文字の色
            UITabBar.appearance().tintColor = UIColor.init(red: 239/255, green: 96/255, blue: 49/255, alpha: 100/100)
            // 非選択時の色とフォント
            UITabBarItem.appearance().setTitleTextAttributes( [ .font : UIFont.init(name: "Kano", size: 10), .foregroundColor : UIColor.darkGray ], for: .normal)
            // 選択時の色とフォント
            UITabBarItem.appearance().setTitleTextAttributes( [ .font : UIFont.init(name: "Kano", size: 10), .foregroundColor : UIColor.init(red: 239/255, green: 96/255, blue: 49/255, alpha: 100/100)], for: .selected)
        }

    }
    

}
