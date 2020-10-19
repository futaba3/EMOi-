//
//  RecordTableViewCell.swift
//  Goods
//
//  Created by 工藤彩名 on 2019/06/27.
//  Copyright © 2019 Kudo Ayana. All rights reserved.
//

import UIKit

class RecordTableViewCell: UITableViewCell {
    
    @IBOutlet var emotion: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var place: UILabel!
    @IBOutlet var mainimg: UIImageView!
    @IBOutlet var result: UILabel!
    

    override func awakeFromNib() {
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    

}
