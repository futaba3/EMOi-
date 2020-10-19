//
//  EditGoodsViewController.swift
//  Goods
//
//  Created by 工藤彩名 on 2019/07/06.
//  Copyright © 2019 Kudo Ayana. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class EditGoodsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,  UITextFieldDelegate {
    
    @IBOutlet var goodsImageView: UIImageView!
    @IBOutlet var haikeiImageView: UIImageView!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var dateTextField: UITextField!
    @IBOutlet var placeTextField: UITextField!
    @IBOutlet var categoryLabel: UILabel!
    
    var datePicker: UIDatePicker = UIDatePicker()
    
    // うけわたされるGood
    var good: Good?
    var goods: [Good] = []
    
    // 画像を保存するための元となる画像
    var goodsImage: UIImage!
    
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    
    // userのidはuid
    let uid = Auth.auth().currentUser?.uid
    
    // くるくるに必要なやつ
    var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        // viewwillappearで呼び出すと変更できなくなるからここに入れる
        // ViewControllerから受け取ったgoodを入れる
        titleTextField.text = good?.title
        dateTextField.text = good?.date
        placeTextField.text = good?.place
        categoryLabel.text = good?.category
        let reference = storageRef.child(uid!).child(good!.image)
        goodsImageView.sd_setImage(with: reference)
        
        // dateピッカーの設定
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.timeZone = NSTimeZone.local
        datePicker.locale = Locale.current
        
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
        placeTextField.delegate = self
        
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
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let selectedText = appDelegate.selectedText {
            categoryLabel.text = selectedText
            // appDelegateのテキストを初期化
            appDelegate.selectedText = nil
        }
        
        // goodsImageViewに画像が入っていない時、デフォルト画像を表示する
        if goodsImageView.image == nil {
            let image = UIImage(named: "trading_goods.png")
            haikeiImageView.image = image
        } else {
            // 画像が設定されたら裏のimageviewは非表示にする
            haikeiImageView.removeFromSuperview()
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
        
        goodsImageView.image = info[.editedImage] as? UIImage
        
        goodsImage = goodsImageView.image
        
        dismiss(animated: true, completion: nil)
    }
    
    // "撮影する"ボタンを押した時のメソッド
    @IBAction func takePhoto() {
        // カメラが使えるかの確認
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
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
        // カメラロールを使えるかの確認
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            // カメラロールの画像を選択して画像を表示するまでの一連の流れ
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            
            picker.allowsEditing = true
            
            present(picker, animated: true, completion: nil)
            haikeiImageView.removeFromSuperview()
        }
    }
    
    // カテゴリー選択画面に遷移
    @IBAction func selectCategory() {
        
    }
    
    
    // 保存するメソッド
    @IBAction func saveGoods(){
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
        let goodid = good?.key
        
        if goodsImageView.image == nil {
            // 配列をfirebaseに保存する
            self.ref.child(uid!).child("goods").child(goodid!).updateChildValues(
                [
                    "key": goodid,
                    "title": self.titleTextField.text!,
                    "date": self.dateTextField.text!,
                    "place": self.placeTextField.text!,
                    "category": self.categoryLabel.text!,
                    "image": nil
                ]
            )
            // アニメーション終了
            self.activityIndicatorView.stopAnimating()
            // メイン画面に移動する
            self.navigationController?.popViewController(animated: true)
            
        } else {
            // 一旦画像を削除する
            let goodRef = self.storageRef.child(self.uid!).child(self.good!.image)
            goodRef.delete { error in
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
            let data = goodsImageView.image!.pngData()!
            let imageURL = "images/" + UUID().uuidString + ".jpg"
            let reference = storageRef.child(self.uid!).child(imageURL)
            reference.putData(data, metadata: nil, completion: { metaData, error in
                // 配列をfirebaseに保存
                self.ref.child(self.uid!).child("goods").child(goodid!).updateChildValues(
                    [
                        "key": goodid,
//                        "created": updated,
                        "title": self.titleTextField.text!,
                        "date": self.dateTextField.text!,
                        "place": self.placeTextField.text!,
                        "category": self.categoryLabel.text!,
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
    
    @IBAction func deleteGoods() {
        // 削除しますかアラート
        let alert: UIAlertController = UIAlertController(title: "削除しますか？", message: titleTextField.text, preferredStyle: .alert)
        // OKボタン
        alert.addAction(
            UIAlertAction(
                title: "delete",
                style: .destructive,
                handler: { action in
                    
                    // アニメーション開始
                    self.activityIndicatorView.startAnimating()
                    
                    self.ref.child(self.uid!).child("goods").child(self.good!.key).removeValue()
                    // 画像も削除する
                    let goodRef = self.storageRef.child(self.uid!).child(self.good!.image)
                    goodRef.delete { error in
                        if error != nil {
                            // Uh-oh, an error occurred!
                        } else {
                            // File deleted successfully
                        }
                    }
                    // アニメーション終了
                    self.activityIndicatorView.stopAnimating()
                    // メイン画面に移動
                    self.navigationController?.popViewController(animated: true)
                    
                    print("削除ボタンが押されました！")
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


