//
//  EditRecordViewController.swift
//  Goods
//
//  Created by 工藤彩名 on 2019/07/06.
//  Copyright © 2019 Kudo Ayana. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseStorageUI
import FirebaseDatabase

class EditRecordViewController: UIViewController,  UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate{
    
    @IBOutlet var recordsImageView: UIImageView!
    @IBOutlet var haikeiImageView: UIImageView!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var dateTextField: UITextField!
    @IBOutlet var resultTextField: UITextField!
    @IBOutlet var placeTextField: UITextField!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var commentTextView: UITextView!
    
    @IBOutlet var selectedEmotion1Button: UIButton!
    @IBOutlet var selectedEmotion2Button: UIButton!
    @IBOutlet var selectedEmotion3Button: UIButton!
    @IBOutlet var selectedEmotion4Button: UIButton!
    @IBOutlet var selectedEmotion5Button: UIButton!
    
    // firebaseにStringで保存しているのでIntに直すのが難しいため一旦Stringの変数を用意
    var emotionNumberString = ""
    
    // ボタンに割り振られたタグの定義
    enum actionTag: Int {
        case action1 = 1
        case action2 = 2
        case action3 = 3
        case action4 = 4
        case action5 = 5
    }
    
    var datePicker: UIDatePicker = UIDatePicker()
    
    var emotionsNameArray = [String]()
    
    // うけわたされるRecord
    var record: Record?
    var records: [Record] = []
    
    // 画像を保存するための元となる画像
    var recordsImage: UIImage!
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    
    // userのidはuid
    let uid = Auth.auth().currentUser?.uid
    
    // くるくるに必要なやつ
    var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        // viewwillappearで呼び出すと変更できなくなるからここに入れる
        // ViewControllerから受け取ったrecordを入れる
        titleTextField.text = record?.title
        dateTextField.text = record?.date
        resultTextField.text = record?.result
        placeTextField.text = record?.place
        commentTextView.text = record?.comment
        categoryLabel.text = record?.category
        emotionNumberString = record?.emotion ?? ""
        let reference = storageRef.child(uid!).child(record?.image ?? "")
        recordsImageView.sd_setImage(with: reference)
        
        
        
        emotionsNameArray = ["1", "2", "3", "4", "5"]
        
        // stringの日付をDate型に直す
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.locale = Locale(identifier: "ja_JP")
        // 元の日付をDatePickerに代入する
        let date = formatter.date(from: dateTextField.text!)
        
        // dateピッカーの設定
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.datePickerMode = .date
        } else {
            // Fallback on earlier versions
            datePicker.datePickerMode = UIDatePicker.Mode.date
        }
        datePicker.timeZone = NSTimeZone.local
        datePicker.locale = Locale.current
        datePicker.date = date ?? Date()
        
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
    
    // 開く時に毎回読み込む
    override func viewWillAppear(_ animated: Bool) {
//        presentingViewController?.beginAppearanceTransition(false, animated: animated)
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let selectedText = appDelegate.selectedText {
            categoryLabel.text = selectedText
            // appDelegateのテキストを初期化
            appDelegate.selectedText = nil
        }
        if let commentText = appDelegate.commentText {
            print("あああああ")
            commentTextView.text = commentText
            // appDelegateのテキストを初期化
            appDelegate.commentText = nil
        }
        
        // recordsImageViewに画像が入っていない時、デフォルト画像を表示する
        if recordsImageView.image == nil {
            let image = UIImage(named: "bg_nangoku.png")
            haikeiImageView.image = image
        } else {
            // 画像が設定されたら裏のimageviewは非表示にする
            haikeiImageView.removeFromSuperview()
        }
        
        
        // emotionの番号に合わせてデフォルトで選択状態にする
        if record?.emotion == "1" {
            emotionNumberString = "1"
            selectedEmotion1Button.backgroundColor = UIColor.init(red: 255/255, green: 105/255, blue: 180/255, alpha: 100/100)
        } else if record?.emotion == "2" {
            emotionNumberString = "2"
            selectedEmotion2Button.backgroundColor = UIColor.init(red: 255/255, green: 140/255, blue: 0/255, alpha: 100/100)
        } else if record?.emotion == "3" {
            emotionNumberString = "3"
            selectedEmotion3Button.backgroundColor = UIColor.init(red: 255/255, green: 250/255, blue: 50/255, alpha: 100/100)
        } else if record?.emotion == "4" {
            emotionNumberString = "4"
            selectedEmotion4Button.backgroundColor = UIColor.init(red: 176/255, green: 236/255, blue: 205/255, alpha: 100/100)
        } else if record?.emotion == "5" {
            emotionNumberString = "5"
            selectedEmotion5Button.backgroundColor = UIColor.init(red: 65/255, green: 105/255, blue: 225/255, alpha: 100/100)
        }
            
        // tabbarを非表示
        self.tabBarController?.tabBar.isHidden = true
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
            picker.sourceType = .camera
            picker.delegate = self
            
            picker.allowsEditing = true
            
            present(picker, animated: true, completion: nil)
            // 画像が設定されたら裏のimageviewは非表示にする
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
    
    // 画面遷移の時にテキストを渡す
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
                    if emotionNumberString != "1" {
                        emotionNumberString = "1"
                        button.backgroundColor = UIColor.init(red: 255/255, green: 105/255, blue: 180/255, alpha: 100/100)
                    } else {
                        emotionNumberString = ""
                        button.backgroundColor = UIColor.white
                    }
                    // その他のボタンの背景色を白にする
                    self.selectedEmotion2Button.backgroundColor = UIColor.white
                    self.selectedEmotion3Button.backgroundColor = UIColor.white
                    self.selectedEmotion4Button.backgroundColor = UIColor.white
                    self.selectedEmotion5Button.backgroundColor = UIColor.white

                // 笑顔（オレンジ）
                case .action2:
                    if emotionNumberString != "2" {
                        emotionNumberString = "2"
                        button.backgroundColor = UIColor.init(red: 255/255, green: 140/255, blue: 0/255, alpha: 100/100)
                    } else {
                        emotionNumberString = ""
                        button.backgroundColor = UIColor.white
                    }
                    self.selectedEmotion1Button.backgroundColor = UIColor.white
                    self.selectedEmotion3Button.backgroundColor = UIColor.white
                    self.selectedEmotion4Button.backgroundColor = UIColor.white
                    self.selectedEmotion5Button.backgroundColor = UIColor.white

                // 驚き（黄色）
                case .action3:
                    if emotionNumberString != "3" {
                        emotionNumberString = "3"
                        button.backgroundColor = UIColor.init(red: 255/255, green: 250/255, blue: 50/255, alpha: 100/100)
                    } else {
                        emotionNumberString = ""
                        button.backgroundColor = UIColor.white
                    }
                    self.selectedEmotion1Button.backgroundColor = UIColor.white
                    self.selectedEmotion2Button.backgroundColor = UIColor.white
                    self.selectedEmotion4Button.backgroundColor = UIColor.white
                    self.selectedEmotion5Button.backgroundColor = UIColor.white

                // 真顔（緑）
                case .action4:
                    if emotionNumberString != "4" {
                        emotionNumberString = "4"
                        button.backgroundColor = UIColor.init(red: 176/255, green: 236/255, blue: 205/255, alpha: 100/100)
                    } else {
                        emotionNumberString = ""
                        button.backgroundColor = UIColor.white
                    }
                    self.selectedEmotion1Button.backgroundColor = UIColor.white
                    self.selectedEmotion2Button.backgroundColor = UIColor.white
                    self.selectedEmotion3Button.backgroundColor = UIColor.white
                    self.selectedEmotion5Button.backgroundColor = UIColor.white
                    
                // がっかり（青）
                case .action5:
                    if emotionNumberString != "5" {
                        emotionNumberString = "5"
                        button.backgroundColor = UIColor.init(red: 65/255, green: 105/255, blue: 225/255, alpha: 100/100)
                    } else {
                        emotionNumberString = ""
                        button.backgroundColor = UIColor.white
                    }
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
        if let text = titleTextField.text, !text.isEmpty, categoryLabel.text != " Select Category", !emotionNumberString.isEmpty {
            // titleTextField.textがnilでなく、かつ空でない、かつカテゴリーと感情が選択されている場合の保存処理
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
            let okAction = UIAlertAction(title: "保存する", style: .default) { [weak self] _ in
                self?.upload()
            }
            showAlert(title: "保存しますか？", message: text, actions: [cancelAction, okAction])
        } else {
            // 条件に合致しない場合の処理
            var alertTitle = ""
            var alertMessage = "保存に必要な情報が不足しています"
            
            if titleTextField.text == nil || titleTextField.text!.isEmpty {
                // タイトル未入力の場合
                alertTitle = "Titleを入力してください"
            } else if categoryLabel.text == " Select Category" {
                // カテゴリー未選択の場合
                alertTitle = "Categoryを選択してください"
            } else if emotionNumberString.isEmpty {
                alertTitle = "Emotion Stickerを選択してください"
            }
            
            let okAction = UIAlertAction(title: "OK", style: .default)
            showAlert(title: alertTitle, message: alertMessage, actions: [okAction])
        }
    }
    
    // 画像をアップロードして全部firebaseに保存する
    func upload() {
        // アニメーション開始
        activityIndicatorView.startAnimating()
        let recordid = record?.key
        
        
        if recordsImageView.image == nil {
            // 配列をfirebaseに保存する
            self.ref.child(uid!).child("records").child(recordid!).updateChildValues(
                [
                    "key": recordid,
                    "title": self.titleTextField.text!,
                    "date": self.dateTextField.text!,
                    "category": self.categoryLabel.text!,
                    "result": self.resultTextField.text!,
                    "place": self.placeTextField.text!,
                    "comment": self.commentTextView.text!,
                    "emotion": self.emotionNumberString,
                    "image": nil
                ]
            )
            // アニメーション終了
            self.activityIndicatorView.stopAnimating()
            // メイン画面に移動する
            self.navigationController?.popViewController(animated: true)
        } else{
            // 一旦保存済みの画像を削除
            let recordRef = self.storageRef.child(self.uid!).child(self.record!.image)
            recordRef.delete { error in
                if error != nil {
                    // Uh-oh, an error occurred!
                } else {
                    // File deleted successfully
                }
            }
            // 画像のupload
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            // UIImagePNGRepresentationでUIImageをNSDataに変換
            let data = recordsImageView.image!.pngData()!
            let imageURL = "images/" + UUID().uuidString + ".jpg"
            let reference = storageRef.child(self.uid!).child(imageURL)
            reference.putData(data, metadata: nil, completion: { metaData, error in
                // 配列をfirebaseに保存
                self.ref.child(self.uid!).child("records").child(recordid!).updateChildValues(
                    [
                        "key": recordid,
//                        "created": updated,
                        "title": self.titleTextField.text!,
                        "date": self.dateTextField.text!,
                        "category": self.categoryLabel.text!,
                        "result": self.resultTextField.text!,
                        "place": self.placeTextField.text!,
                        "comment": self.commentTextView.text!,
                        "emotion": self.emotionNumberString,
                        "image": imageURL
                    ]
                )
                // アニメーション終了
                self.activityIndicatorView.stopAnimating()
                // メイン画面に移動する
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    @IBAction func deleteRecordButton() {
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
        let okAction = UIAlertAction(title: "削除する", style: .destructive) { [weak self] _ in
            self?.deleteRecord()
            // メイン画面に移動
            self?.navigationController?.popViewController(animated: true)
        }
        showAlert(title: "削除しますか？", message: "削除したRECORDSは復元できません", actions: [cancelAction, okAction])
    }
    
    func deleteRecord() {
        // アニメーション開始
         self.activityIndicatorView.startAnimating()
         self.ref.child(self.uid!).child("records").child(self.record!.key).removeValue()
         // 画像も削除する
         let recordRef = self.storageRef.child(self.uid!).child(self.record!.image)
         recordRef.delete { error in
             if error != nil {
                 // Uh-oh, an error occurred!
             } else {
                 // File deleted successfully
             }
         }
         // アニメーション終了
         self.activityIndicatorView.stopAnimating()
    }
    
    
}
