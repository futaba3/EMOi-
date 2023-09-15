//
//  AddRecordViewController.swift
//  Goods
//
//  Created by 工藤彩名 on 2019/06/27.
//  Copyright © 2019 Kudo Ayana. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class AddRecordViewController: UIViewController, UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate{
    
    @IBOutlet var recordsImageView: UIImageView!
    @IBOutlet var haikeiImageView: UIImageView!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var dateTextField: UITextField!
    @IBOutlet var resultTextField: UITextField!
    @IBOutlet var placeTextField: UITextField!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var emotionLabel: UILabel!
    @IBOutlet var commentTextView: UITextView!
    @IBOutlet var navigationBar: UINavigationBar!
    
    @IBOutlet var selectedEmotion1Button: UIButton!
    @IBOutlet var selectedEmotion2Button: UIButton!
    @IBOutlet var selectedEmotion3Button: UIButton!
    @IBOutlet var selectedEmotion4Button: UIButton!
    @IBOutlet var selectedEmotion5Button: UIButton!
    // ボタンに割り振られたタグの定義
    enum actionTag: Int {
        case action1 = 1
        case action2 = 2
        case action3 = 3
        case action4 = 4
        case action5 = 5
    }
    
    
    
    var datePicker: UIDatePicker = UIDatePicker()
    
    // 画像を保存するための元となる画像
    var recordsImage: UIImage!
    
    
    // userのidはuid
    let uid = Auth.auth().currentUser?.uid
    var ref: DatabaseReference!
    
    // くるくるに必要なやつ
    var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        // dateピッカーの設定
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.datePickerMode = .date
        } else {
            // Fallback on earlier versions
            datePicker.datePickerMode = UIDatePicker.Mode.date
            datePicker.timeZone = NSTimeZone.local
            datePicker.locale = Locale.current
        }
        
        // 日付決定バーの生成
        let datetoolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let datespacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let datedoneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(datedone))
        datetoolbar.setItems([datespacelItem, datedoneItem], animated: true)
        
        // インプットビュー設定
        dateTextField.inputView = datePicker
        dateTextField.inputAccessoryView = datetoolbar
        
        // 終わったらキーボードが閉じる
        titleTextField.delegate = self
        dateTextField.delegate = self
        resultTextField.delegate = self
        placeTextField.delegate = self
        
        navigationBar.delegate = self
        navigationBar.tintColor = .black
        navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Kano", size: 20), .foregroundColor: UIColor.black]
        
        // emotionボタンの角を丸める
        selectedEmotion1Button.layer.cornerRadius = 30
        selectedEmotion2Button.layer.cornerRadius = 30
        selectedEmotion3Button.layer.cornerRadius = 30
        selectedEmotion4Button.layer.cornerRadius = 30
        selectedEmotion5Button.layer.cornerRadius = 30
        
        // 更新中にくるくるするやつ
        activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicatorView.center = view.center
        // クルクルをストップした時に非表示する
        activityIndicatorView.hidesWhenStopped = true
        // 色の設定
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = UIColor.init(red: 41/255, green: 94/255, blue: 164/255, alpha: 100/100)
        self.view.addSubview(activityIndicatorView)
    }
    // 名前入力後にキーボードが閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // 日付決定ボタン押す
    @objc func datedone() {
        dateTextField.endEditing(true)
        
        // 日付のフォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.M.d"
        dateTextField.text = "\(formatter.string(from: datePicker.date))"
    }
    

    // 開く時に毎回読み込む
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let selectedText = appDelegate.selectedText {
            categoryLabel.text = selectedText
            // appDelegateのテキストを初期化
            appDelegate.selectedText = nil
        }
        if let commentText = appDelegate.commentText {
            commentTextView.text = commentText
            // appDelegateのテキストを初期化
            appDelegate.commentText = nil
        }
        
        // recordsImageViewに画像が入っていない時、デフォルト画像を表示する
        if recordsImageView.image == nil {
            let image = UIImage(named: "bg_nangoku.png")
            haikeiImageView.image = image
        }
        
        // tabbarを非表示
        self.tabBarController?.tabBar.isHidden = true
    }
    

    
    
    //カメラ、カメラロールを使った時に選択した画像をアプリ内に表示するためのメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        recordsImageView.image = info[.editedImage] as? UIImage
        
        recordsImage = recordsImageView.image
        
        dismiss(animated: true, completion: nil)
    }
    
    // "撮影する"ボタンを押した時のメソッド
    @IBAction func takePhoto() {
        // アニメーション開始
        activityIndicatorView.startAnimating()
        // カメラが使えるかの確認
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // アニメーション終了
            self.activityIndicatorView.stopAnimating()
            
            // カメラを起動
            let picker = UIImagePickerController()
            picker.sourceType =  .camera
            picker.delegate = self
            
            picker.allowsEditing = true
            
            present(picker, animated: true, completion: nil)
            // 画像を設定したらhaikeiImageView非表示
            haikeiImageView.removeFromSuperview()
        } else {
            // カメラが使えない時エラーがコンソールに出ます
            print("error")
        }
    }
    
    // カメラロールにある画像を読み込む時のメソッド
    @IBAction func openAlbum() {
        // アニメーション開始
        activityIndicatorView.startAnimating()
        // カメラロールを使えるかの確認
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            // アニメーション終了
            self.activityIndicatorView.stopAnimating()
            // カメラロールの画像を選択して画像を表示するまでの一連の流れ
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            
            picker.allowsEditing = true
            
            present(picker, animated: true, completion: nil)
            haikeiImageView.removeFromSuperview()
        }
    }
    
    @IBAction func toBigCommentTextView() {
        
    }
    
    // senderにgoodを入れたことで使える画面遷移の時に配列を渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toComment" {
        if let viewController = segue.destination as? CommentTextViewController {
            viewController.comment = commentTextView.text
        }
       }
    }
    
    
    // 選んだボタンだけ色がつくようにする（outletは1:1の接続、actionは1:nで接続できる）
    @IBAction func buttonAction(_ sender: Any) {
        if let button = sender as? UIButton {
            // 押されたボタンのタグを取得して分岐させる
            if let tag = actionTag(rawValue: button.tag) {
                switch tag {
                // 目ハート（ピンク）
                case .action1:
                    // 1以外が選択されている場合
                    if emotionLabel.text != "1" {
                        emotionLabel.text = "1"
                        button.backgroundColor = UIColor.init(red: 255/255, green: 105/255, blue: 180/255, alpha: 100/100)
                    } else {
                        emotionLabel.text = ""
                        button.backgroundColor = UIColor.white
                    }
                    print(emotionLabel.text!)
                    // その他のボタンの背景色を白にする
                    self.selectedEmotion2Button.backgroundColor = UIColor.white
                    self.selectedEmotion3Button.backgroundColor = UIColor.white
                    self.selectedEmotion4Button.backgroundColor = UIColor.white
                    self.selectedEmotion5Button.backgroundColor = UIColor.white

                // 笑顔（オレンジ）
                case .action2:
                    if emotionLabel.text != "2" {
                        emotionLabel.text = "2"
                        button.backgroundColor = UIColor.init(red: 255/255, green: 140/255, blue: 0/255, alpha: 100/100)
                    } else {
                        emotionLabel.text = ""
                        button.backgroundColor = UIColor.white
                    }
                    print(emotionLabel.text!)
                    self.selectedEmotion1Button.backgroundColor = UIColor.white
                    self.selectedEmotion3Button.backgroundColor = UIColor.white
                    self.selectedEmotion4Button.backgroundColor = UIColor.white
                    self.selectedEmotion5Button.backgroundColor = UIColor.white

                // 驚き（黄色）
                case .action3:
                    if emotionLabel.text != "3" {
                        emotionLabel.text = "3"
                        button.backgroundColor = UIColor.init(red: 255/255, green: 250/255, blue: 50/255, alpha: 100/100)
                    } else {
                        emotionLabel.text = ""
                        button.backgroundColor = UIColor.white
                    }
                    print(emotionLabel.text!)
                    self.selectedEmotion1Button.backgroundColor = UIColor.white
                    self.selectedEmotion2Button.backgroundColor = UIColor.white
                    self.selectedEmotion4Button.backgroundColor = UIColor.white
                    self.selectedEmotion5Button.backgroundColor = UIColor.white

                // 真顔（緑）
                case .action4:
                    if emotionLabel.text != "4" {
                        emotionLabel.text = "4"
                        button.backgroundColor = UIColor.init(red: 176/255, green: 236/255, blue: 205/255, alpha: 100/100)
                    } else {
                        emotionLabel.text = ""
                        button.backgroundColor = UIColor.white
                    }
                    print(emotionLabel.text!)
                    self.selectedEmotion1Button.backgroundColor = UIColor.white
                    self.selectedEmotion2Button.backgroundColor = UIColor.white
                    self.selectedEmotion3Button.backgroundColor = UIColor.white
                    self.selectedEmotion5Button.backgroundColor = UIColor.white
                    
                // がっかり（青）
                case .action5:
                    if emotionLabel.text != "5" {
                        emotionLabel.text = "5"
                        button.backgroundColor = UIColor.init(red: 65/255, green: 105/255, blue: 225/255, alpha: 100/100)
                    } else {
                        emotionLabel.text = ""
                        button.backgroundColor = UIColor.white
                    }
                    print(emotionLabel.text!)
                    self.selectedEmotion1Button.backgroundColor = UIColor.white
                    self.selectedEmotion2Button.backgroundColor = UIColor.white
                    self.selectedEmotion3Button.backgroundColor = UIColor.white
                    self.selectedEmotion4Button.backgroundColor = UIColor.white
                }
            }
        }
    }
    
    
    
    // カテゴリー選択画面に遷移
    @IBAction func selectCategory() {
        
    }
    
    // 保存するメソッド
    @IBAction func saveRecords(){
        // なまえ入力されてないアラート
        if titleTextField.text == ""{
            let alert: UIAlertController = UIAlertController(title: "Stop!", message: "Titleを入力してください！", preferredStyle: .alert)
            alert.addAction(
                UIAlertAction(
                    title: "cancel",
                    style: .cancel,
                    handler: nil
                )
            )
            present(alert, animated: true, completion: nil)
        }else if categoryLabel.text == "Select Category"{
            let alert: UIAlertController = UIAlertController(title: "Stop!", message: "Categoryを選択してください！", preferredStyle: .alert)
            alert.addAction(
                UIAlertAction(
                    title: "cancel",
                    style: .cancel,
                    handler: nil
                )
            )
            present(alert, animated: true, completion: nil)
        }else if emotionLabel.text == ""{
                let alert: UIAlertController = UIAlertController(title: "Stop!", message: "Emotion Stickerを選択してください！", preferredStyle: .alert)
                alert.addAction(
                    UIAlertAction(
                        title: "cancel",
                        style: .cancel,
                        handler: nil
                    )
                )
                present(alert, animated: true, completion: nil)
        }else{
            // 保存しますかアラート
            let alert: UIAlertController = UIAlertController(title: "保存しますか？", message: titleTextField.text, preferredStyle: .alert)
            // OKボタン
            alert.addAction(
                UIAlertAction(
                    title: "yes",
                    style: .default,
                    handler: { action in
                        
                        self.upload()
                        
                        print("はいボタンが押されました！")
                }
                )
            )
            // キャンセルボタン
            alert.addAction(
                UIAlertAction(
                    title: "cancel",
                    style: .cancel,
                    handler: {action in
                        print("いいえボタンが押されました！")
                }
                )
            )
            present(alert, animated: true, completion: nil)
        }
    }
    
    // 画像をアップロードして全部firebaseに保存する
    func upload() {
        // アニメーション開始
        activityIndicatorView.startAnimating()
        let recordsChild = ref.child(uid!).child("records").childByAutoId()
        let recordid = recordsChild.key
        let created = ServerValue.timestamp()
        
        
        if recordsImageView.image == nil {
            // 配列をfirebaseに保存する
            self.ref.child(uid!).child("records").child(recordid!).setValue(
                [
                    "key": recordid,
                    "created": created,
                    "title": self.titleTextField.text!,
                    "date": self.dateTextField.text!,
                    "category": self.categoryLabel.text!,
                    "result": self.resultTextField.text!,
                    "place": self.placeTextField.text!,
                    "comment": self.commentTextView.text!,
                    "emotion": self.emotionLabel.text!,
                    "image": nil
                ]
            )
            // アニメーション終了
            self.activityIndicatorView.stopAnimating()
            // メイン画面に移動する
            self.dismiss(animated: true, completion: nil)
            
        } else{
            // 画像のupload
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            // UIImagePNGRepresentationでUIImageをNSDataに変換
            let data = recordsImageView.image!.pngData()!
            let imageURL = "images/" + UUID().uuidString + ".jpg"
            let reference = storageRef.child(uid!).child(imageURL)
            reference.putData(data, metadata: nil, completion: { metaData, error in
                
                // 配列をfirebaseに保存
                self.ref.child(self.uid!).child("records").child(recordid!).setValue(
                    [
                        "key": recordid,
                        "created": created,
                        "title": self.titleTextField.text!,
                        "date": self.dateTextField.text!,
                        "category": self.categoryLabel.text!,
                        "result": self.resultTextField.text!,
                        "place": self.placeTextField.text!,
                        "comment": self.commentTextView.text!,
                        "emotion": self.emotionLabel.text!,
                        "image": imageURL
                    ]
                )
                // アニメーション終了
                self.activityIndicatorView.stopAnimating()
                // メイン画面に移動する
                self.dismiss(animated: true, completion: nil)
            })
        }
        
    }
    
    @IBAction func cancel(){
    // 保存しますかアラートを出す
        let alert: UIAlertController = UIAlertController(title: "RECORDS一覧に戻りますか？", message: "内容は保存されません", preferredStyle: .alert)
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
