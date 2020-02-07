//
//  CustomCell.swift
//  Goods
//
//  Created by 工藤彩名 on 2019/05/18.
//  Copyright © 2019 Kudo Ayana. All rights reserved.
//

import UIKit
import FirebaseStorage

class CustomCell: UICollectionViewCell {
    
    @IBOutlet var goodsimg: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var date: UILabel!
    
    // imageviewの角を丸める
    override func awakeFromNib() {
//        goodsimg.layer.cornerRadius = 20
//        goodsimg.clipsToBounds = true
    }
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
}
