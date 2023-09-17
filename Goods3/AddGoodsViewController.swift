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
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.datePickerMode = .date
        } else {
            // Fallback on earlier versions
            datePicker.datePickerMode = UIDatePicker.Mode.date
        }
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
        navigationBar.delegate = self
        navigationBar.tintColor = .white
        navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Kano", size: 20), .foregroundColor: UIColor.black]
        
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

    // カテゴリー選択画面に遷移
    @IBAction func selectCategory() {
    
    }
    

    @IBAction func saveGoods(){
        if let text = titleTextField.text, !text.isEmpty, categoryLabel.text != "Select Category" {
            // titleTextField.textがnilでなく、かつ空でない、かつカテゴリーが選択されている場合の保存処理
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
            } else if categoryLabel.text == "Select Category" {
                // カテゴリー未選択の場合
                alertTitle = "Categoryを選択してください"
            }
            
            let okAction = UIAlertAction(title: "OK", style: .default)
            showAlert(title: alertTitle, message: alertMessage, actions: [okAction])
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
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
        let okAction = UIAlertAction(title: "戻る", style: .destructive) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
        showAlert(title: "GOODS一覧に戻りますか？", message: "入力した内容は保存されません", actions: [cancelAction, okAction])
    }
}

