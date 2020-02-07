//
//  ViewController.swift
//  Goods
//
//  Created by 工藤彩名 on 2019/05/11.
//  Copyright © 2019 Kudo Ayana. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class AddGoodsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet var goodsImageView: UIImageView!
    @IBOutlet var haikeiImageView: UIImageView!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var dateTextField: UITextField!
    @IBOutlet var placeTextField: UITextField!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var navigationBar: UINavigationBar!
    
    var datePicker: UIDatePicker = UIDatePicker()
    
    // 画像を保存するための元となる画像
    var goodsImage: UIImage!

    // くるくるに必要なやつ
    var activityIndicatorView: UIActivityIndicatorView!
    
    var ref: DatabaseReference!
    
    // userのidはuid
    let uid = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ref = Database.database().reference()
        
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
        
        // ナビゲーションバーのフォントと色
        navigationBar.tintColor = .black
        navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Kano", size: 20), .foregroundColor: UIColor.black]
        
//        // imageviewの角を丸める
//        self.goodsImageView.layer.cornerRadius = 20
//        self.haikeiImageView.layer.cornerRadius = 20
        
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

    
    
    //カメラ、カメラロールを使った時に選択した画像をアプリ内に表示するためのメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        goodsImageView.image = info[.editedImage] as? UIImage
        
        goodsImage = goodsImageView.image
        
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
            
        }else if self.dateTextField.text == ""{
            let alert: UIAlertController = UIAlertController(title: "Stop!", message: "Dateを選択してください！", preferredStyle: .alert)
            alert.addAction(
                UIAlertAction(
                    title: "cancel",
                    style: .cancel,
                    handler: nil
                )
            )
            present(alert, animated: true, completion: nil)
            
        }else{
            // 保存しますかアラートを出す
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
        let goodsChild = ref.child(uid!).child("goods").childByAutoId()
        let goodid = goodsChild.key
        let created = ServerValue.timestamp()

        
        if goodsImageView.image == nil {
            // 配列をfirebaseに保存する
            self.ref.child(self.uid!).child("goods").child(goodid!).setValue(
                [
                    "key": goodid,
                    "created": created,
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
            self.dismiss(animated: true, completion: nil)

        } else {
        // 画像のupload
        let storage = Storage.storage()
        let storageRef = storage.reference()
            
        // UIImagePNGRepresentationでUIImageをNSDataに変換
            let data = goodsImageView.image!.pngData()!
            let imageURL = "images/" + UUID().uuidString + ".jpg"
            let reference = storageRef.child(self.uid!).child(imageURL)
            reference.putData(data, metadata: nil, completion: { metaData, error in
                // 配列をfirebaseに保存
                self.ref.child(self.uid!).child("goods").child(goodid!).setValue(
                    [
                        "key": goodid!,
                        "created": created,
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
                self.dismiss(animated: true, completion: nil)
            })
        }
        
    }
    
    @IBAction func cancel(){
    // 保存しますかアラートを出す
        let alert: UIAlertController = UIAlertController(title: "GOODS一覧に戻りますか？", message: "内容は保存されません", preferredStyle: .alert)
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

