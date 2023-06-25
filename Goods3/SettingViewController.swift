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
                // ログアウトしますかアラート
                let alert: UIAlertController = UIAlertController(title: "ログアウトしますか？", message: "YESを押すとログアウトします", preferredStyle: .alert)
                // ログアウトボタン
                alert.addAction(
                    UIAlertAction(
                        title: "YES",
                        style: .destructive,
                        handler: { action in
                            
                            do {
                                try Auth.auth().signOut()
                            }
                            // エラーの時
                            catch {
                                print("error")
                            }
                            
                            // ログイン画面に遷移
                            // 同じstororyboard内であることを定義
                            let storyboard: UIStoryboard = self.storyboard!
                            // 移動先のstoryboard
                            let login = storyboard.instantiateViewController(withIdentifier: "login")
                            login.modalPresentationStyle = .fullScreen
                            self.present(login, animated: true, completion: nil)
                            
                            print("ログアウトボタンが押されました！")
                    }
                    )
                )
                // キャンセルボタン
                alert.addAction(
                    UIAlertAction(
                        title: "NO",
                        style: .cancel,
                        handler: {action in
                            // tableviewのcellの選択解除
                            self.table.indexPathsForSelectedRows?.forEach {
                                self.table.deselectRow(at: $0, animated: true)
                            }
                            print("NOボタンが押されました！")
                    }
                    )
                )
                present(alert, animated: true, completion: nil)
                
            // 退会
            case 1:
                // 退会しますかアラート
                let alert: UIAlertController = UIAlertController(title: "退会しますか？", message: "退会するとgoodsとrecordsのデータが削除され、復元することはできません。", preferredStyle: .alert)
                
                // 退会ボタン
                alert.addAction(
                    UIAlertAction(
                        title: "退会する",
                        style: .destructive,
                        handler: { action in
                            // ユーザーを削除
                            self.user?.delete { error in
                                if let error = error {
                                    // An error happened.
                                } else {
                                    // Account deleted.
                                }
                            }
                            
                            // ログイン画面に遷移
                            // 同じstororyboard内であることを定義
                            let storyboard: UIStoryboard = self.storyboard!
                            // 移動先のstoryboard
                            let login = storyboard.instantiateViewController(withIdentifier: "login")
                            login.modalPresentationStyle = .fullScreen
                            self.present(login, animated: true, completion: nil)
                            
                            print("退会ボタンが押されました！")
                        }
                    )
                )
                // キャンセルボタン
                alert.addAction(
                    UIAlertAction(
                        title: "NO",
                        style: .cancel,
                        handler: {action in
                            // tableviewのcellの選択解除
                            self.table.indexPathsForSelectedRows?.forEach {
                                self.table.deselectRow(at: $0, animated: true)
                            }
                            print("NOボタンが押されました！")
                        }
                    )
                )
                present(alert, animated: true, completion: nil)
                
            // 何もしないbreak
            default:
                break
            }
        }
        
    }
    
    
   
}
