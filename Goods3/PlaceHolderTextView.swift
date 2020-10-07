//
//  PlaceHolderTextView.swift
//  Goods3
//
//  Created by 工藤彩名 on 2020/10/07.
//  Copyright © 2020 Kudo Ayana. All rights reserved.
//

import UIKit

// StoryboardのTextViewのclassをPlaceHolderTextView.swiftにしてStoryboardから直接placeholderを設定できる
@IBDesignable class PlaceHolderTextView: UITextView {

    // MARK: Stored Instance Properties

    @IBInspectable private var placeHolder: String = "" {
        willSet {
            self.placeHolderLabel.text = newValue
            self.placeHolderLabel.sizeToFit()
        }
    }
    
    // 本来持っているtextプロパティを上書きし、didSetをつけ、textが入っていたらplaceHolderを非表示にする
    public override var text: String! {
        didSet {
            self.placeHolderLabel.isHidden = !text.isEmpty
            self.placeHolderLabel.sizeToFit()
        }
    }

    private lazy var placeHolderLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 6.0, y: 6.0, width: 0.0, height: 0.0))
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = self.font
        label.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0980392, alpha: 0.22)
        label.backgroundColor = .clear
        self.addSubview(label)
        return label
    }()

    // MARK: Initializers

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: View Life-Cycle Methods

    override func awakeFromNib() {
        super.awakeFromNib()
        changeVisiblePlaceHolder()
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged),
                                               name: UITextView.textDidChangeNotification, object: nil)
    }

    // MARK: Other Private Methods

    private func changeVisiblePlaceHolder() {
        self.placeHolderLabel.alpha = (self.placeHolder.isEmpty || !self.text.isEmpty) ? 0.0 : 1.0
    }
    
    @objc private func textChanged(notification: NSNotification?) {
        changeVisiblePlaceHolder()
    }
    

}
