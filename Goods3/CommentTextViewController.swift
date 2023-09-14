//
//  CommentTextViewController.swift
//  Goods2
//
//  Created by 工藤彩名 on 2019/12/14.
//  Copyright © 2019 Kudo Ayana. All rights reserved.
//

import UIKit

class CommentTextViewController: UIViewController {
    
    @IBOutlet var commentTextView: UITextView!

    var comment = ""
    
    var toolbar: UIToolbar!
    
    // 遷移先の画面でviewwillappearを呼び出すためのやつ
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentingViewController?.endAppearanceTransition()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presentingViewController?.beginAppearanceTransition(true, animated: animated)
        presentingViewController?.endAppearanceTransition()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentingViewController?.beginAppearanceTransition(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTextView.text = comment
        commentTextView.becomeFirstResponder()
        
        // ステータスバーの文字色を黒くする
        setNeedsStatusBarAppearanceUpdate()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func done() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.commentText = commentTextView.text
        print(appDelegate.commentText)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cancel(){
    // 保存しますかアラートを出す
        let alert: UIAlertController = UIAlertController(title: "前の画面に戻りますか？", message: "編集している内容は保存されません", preferredStyle: .alert)
        // OKボタン
        alert.addAction(
            UIAlertAction(
                title: "はい",
                style: .destructive,
                handler: { action in
                    
                    self.dismiss(animated: true, completion: nil)
                    
                    print("はいボタンが押されました！")
            }
            )
        )
        // キャンセルボタン
        alert.addAction(
            UIAlertAction(
                title: "いいえ",
                style: .cancel,
                handler: {action in
                    print("いいえボタンが押されました！")
            }
            )
        )
        present(alert, animated: true, completion: nil)
    }

}
