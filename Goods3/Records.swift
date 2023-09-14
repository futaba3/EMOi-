//
//  Records.swift
//  Goods
//
//  Created by 工藤彩名 on 2019/07/06.
//  Copyright © 2019 Kudo Ayana. All rights reserved.
//

import Foundation

// Recordのクラス（設計図、中身は空）
struct Record {
    
    let key: String
    let title: String
    let date: String
    let result: String
    let place: String
    let category: String
    let comment: String
    let emotion: String
    let image: String
    
    // 初期化
    init(key: String, title: String, date: String, category: String, result: String, place: String, comment: String, emotion: String, image: String) {
        self.key = key
        self.title = title
        self.date = date
        self.category = category
        self.result = result
        self.place = place
        self.comment = comment
        self.emotion = emotion
        self.image = image
    }
    
}
