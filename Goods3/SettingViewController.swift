//
//  SettingViewController.swift
//  Goods2
//
//  Created by 工藤彩名 on 2019/07/20.
//  Copyright © 2019 Kudo Ayana. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseEmailAuthUI
import FirebaseOAuthUI
import FirebaseStorage
import FirebaseDatabase

class SettingViewController: UIViewController, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, FUIAuthDelegate {
    
    @IBOutlet var table: UITableView!
    
    //項目を入れるための配列
    var sectionArray1 = [String]()
    var sectionArray2 = [String]()
    var sectionTitles = [String]()
    
    var authUI: FUIAuth { get { return FUIAuth.defaultAuthUI()!}}
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    
    // userのidはuid
    let uid = Auth.auth().currentUser?.uid
    
    let user = Auth.auth().currentUser
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        
        table.dataSource = self
        table.delegate = self
        
        sectionArray1 = ["Edit Category"]
        sectionArray2 = ["ログアウト", "退会"]
        sectionTitles = ["", "アカウント"]
        
        self.authUI.delegate = self
        
        
    }
    
    // セクションの数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // セクションのタイトルを設定
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    // 一つのセクションに入れるセルの数を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return sectionArray1.count
        }else if section == 1 {
            return sectionArray2.count
        }else{
            return 0
        }
    }
    
    // ID付きのセルを取得して、セルに情報を表示する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        // sectionで表示内容わける
        if indexPath.section == 0 {
            cell?.textLabel?.text = sectionArray1[indexPath.row]
        }else if indexPath.section == 1{
            cell?.textLabel?.text = sectionArray2[indexPath.row]
        }
        // セルのフォントを変更する
        cell?.textLabel?.font = UIFont(name: "Kano", size: 17)
        
        return cell!
    }
    
    // セルが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // sectionで表示内容わける
        if indexPath.section == 0 {
            switch indexPath.row {
                // カテゴリー画面に飛ぶ
            case 0:
                // セルの選択を解除
                tableView.deselectRow(at: indexPath, animated: true)
                // segue
                performSegue(withIdentifier: "toEditCategory", sender: nil)
                
            default:
                break
                
            }
        } else if indexPath.section == 1 {
            
            switch indexPath.row {
                // ログアウト
            case 0:
                let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { [weak self] _ in
                    // セルの選択解除
                    self?.table.indexPathsForSelectedRows?.forEach {
                        self?.table.deselectRow(at: $0, animated: true)
                    }
                }
                let okAction = UIAlertAction(title: "ログアウト", style: .destructive) { _ in
                    self.logout()
                    self.showAutoDismissAlert(title: "ログアウトしました", message: "ログイン画面に移動します") {
                        self.presentLoginVC()
                    }
                }
                showAlert(title: "ログアウトしますか？", message: "", actions: [cancelAction, okAction])
                
                // 退会
            case 1:
                // 退会確認画面に進むアラート
                let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { _ in
                    self.table.indexPathsForSelectedRows?.forEach {
                        self.table.deselectRow(at: $0, animated: true)
                    }
                }
                let okAction = UIAlertAction(title: "退会する", style: .destructive) { _ in
                    // 確認画面で退会処理
                    self.showDeleteAccontConfirmAlert()
                }
                showAlert(title: "退会しますか？", message: "退会するを押すと確認画面に進みます", actions: [cancelAction, okAction])

            default:
                break
            }
        }
        
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print("error")
        }
        
        print("ログアウトボタンが押されました！")
    }
    
    func showDeleteAccontConfirmAlert() {
        // 退会確認画面に進むアラート
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { _ in
            self.table.indexPathsForSelectedRows?.forEach {
                self.table.deselectRow(at: $0, animated: true)
            }
        }
        let okAction = UIAlertAction(title: "退会する", style: .destructive) { [weak self] _ in
            // ユーザーを削除
            self?.user?.delete { error in
                if let error = error {
                    // An error happened.
                } else {
                    // Account deleted.
                }
            }
            self?.showAutoDismissAlert(title: "ご利用いただき\nありがとうございました", message: "ログイン画面に移動します") {
                self?.presentLoginVC()
            }
            print("退会が押されました！")
        }
        showAlert(title: "本当に退会しますか？", message: "退会するとアプリに登録した全てのデータが削除され、復元することはできません", actions: [cancelAction, okAction])
    }
    
    func presentLoginVC() {
        // 同じstororyboard内であることを定義
        let storyboard: UIStoryboard = self.storyboard!
        // 移動先のstoryboard
        let login = storyboard.instantiateViewController(withIdentifier: "login")
        login.modalPresentationStyle = .fullScreen
        self.present(login, animated: true, completion: nil)
    }
    
}
