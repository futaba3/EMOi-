//
//  Goods.swift
//  Goods
//
//  Created by 工藤彩名 on 2019/06/08.
//  Copyright © 2019 Kudo Ayana. All rights reserved.
//

import Foundation
import FirebaseDatabase


// Goodのインスタンス（設計図、中身は空）
struct Good {
    
    let key: String
    let title: String
    let date: String
    let category: String
    let place: String
    let image: String
    
    // 初期化
    
    init(key: String, title: String, date: String, category: String, place: String, image: String) {
        self.key = key
        self.title = title
        self.date = date
        self.category = category
        self.place = place
        self.image = image
    }
    
}
