//
//  RecordViewModel.swift
//  Goods3
//
//  Created by Ayana Kudo on 2023/09/20.
//  Copyright © 2023 Kudo Ayana. All rights reserved.
//

import UIKit

final class RecordViewModel {
    func getImage(record: Record) -> UIImage? {
        // cellに表示するemotionの命名規則に合わせてemotionの数字を渡す
        // .init(named:)の意味：Creates an image object from the specified named asset.アセットの名前から画像とってくる
        .init(named: "\(record.emotion)_color")
    }
}
