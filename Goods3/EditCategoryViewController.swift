//
//  EditCategoryViewController.swift
//  Goods2
//
//  Created by 工藤彩名 on 2020/01/25.
//  Copyright © 2020 Kudo Ayana. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class EditCategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var table: UITableView!
    
    var goods: [Good] = []
    var records: [Record] = []
    var categories:[String] = []
    
    var ref: DatabaseReference!
    
    // userのidはuid
    let uid = Auth.auth().currentUser?.uid

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

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        table.dataSource = self
        table.delegate = self
    }
    
    // 開いた時に毎回読み込まれる
    override func viewWillAppear(_ animated: Bool) {
        presentingViewController?.beginAppearanceTransition(false, animated: animated)
        super.viewWillAppear(animated)
        // firebaseからデータを読み込む
        ref.child(uid!).child("categories").observeSingleEvent(of: .value, with: { (snapshot) in
//            print(snapshot.value as! [String])
            self.categories.removeAll()
            // valueの中身が空の時は空の配列を入れる
            let values = snapshot.value as? [String] ?? []
            for title in values {
                self.categories.append(title)
            }
            // categoriesに未分類が含まれているとfoundはtrueになる
            let found = self.categories.contains("未分類")
            // foundがfalseなら未分類を追加して保存する
            if found == false {
                self.categories.append("未分類")
                self.ref.child(self.uid!).child("categories").setValue(self.categories)
            }
            self.table.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
        // tabbarを非表示
        self.tabBarController?.tabBar.isHidden = true

    }
    
    // cellの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    

    // cellの中身
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell")
        
        cell?.textLabel?.text = categories[indexPath.row]
        // セルのフォントを変更する
        cell?.textLabel?.font = UIFont(name: "Kano", size: 17)
        
        return cell!
    }
    
    // アラートにtextFieldを入れてカテゴリーを入力、セルを追加
    @IBAction func onAdd(_ sender: Any) {
        
        let alert: UIAlertController = UIAlertController(title: "Add Category",
                                                         message: "カテゴリー名を記入してください",
                                                         preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: { (textField:UITextField) -> Void in
            textField.placeholder = "ex) グループ、チーム、キャラクター名"
        })
        let okAction = UIAlertAction(title: "OK",
                                     style: UIAlertAction.Style.default,
                                     handler:{
                                        (action: UIAlertAction) -> Void in
                                        self.categories.insert(alert.textFields!.first!.text!, at: 0)
                                        // firebaseに保存する
                                        self.ref.child(self.uid!).child("categories").setValue(self.categories)
                                        // <ポイント>
                                        self.table.beginUpdates()
                                        self.table.insertRows(at: [IndexPath(row: 0, section: 0)],
                                                                  with: .automatic)
                                        self.table.endUpdates()
        })
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: UIAlertAction.Style.cancel,
                                         handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // セルの編集許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // 未分類を編集と削除できないようにする
        if indexPath.row == categories.count - 1 {
            return false
        } else {
            return true
        }
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == categories.count - 1 {
            return false
        } else {
            return true
        }
    }
    
    // 編集モード以外では削除ができないようにする
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if table.isEditing {
            if indexPath.row == categories.count - 1 {
                return .none
            } else {
                return .delete
            }
        }
        
        return .none
    }
    
    // editボタンを押したときの処理
    @IBAction func setTableViewEditing() {
        table.isEditing = !table.isEditing
    }
    
    //並び替えが終わったタイミングで呼ばれるメソッド
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //sourceIndexPath にデータの元の位置、destinationIndexPath に移動先の位置
        //CellValueを取得
        if let targetTitle: String = categories[sourceIndexPath.row] {
            //元の位置のデータを配列から削除
            categories.remove(at:sourceIndexPath.row)
            //移動先の位置にデータを配列に挿入
            categories.insert(targetTitle, at: destinationIndexPath.row)
        }
        // 並び替えた後の配列をfirebaseに保存する
        ref.child(uid!).child("categories").setValue(categories)
        table.reloadData()
    }
    
    // スワイプしたセルを削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            // 選択したcategoryを取得
            let categoryName = categories[indexPath.row]
            print(categoryName)
            
            // goodsとrecordsのcategoryChild内にcategoryNameが含まれているものを絞り込む
            self.ref.child(self.uid!).child("goods").queryOrdered(byChild: "category").queryEqual(toValue: categoryName).observeSingleEvent(of: .value, with: { (snapshot) in
                let goods = snapshot.value as? [String: [String: Any]] ?? [:]
                
                self.ref.child(self.uid!).child("records").queryOrdered(byChild: "category").queryEqual(toValue: categoryName).observeSingleEvent(of: .value, with: { (snapshot) in
                    let records = snapshot.value as? [String: [String: Any]] ?? [:]
                    
                    // categoryName入りのchildがなければ削除する
                    if goods.count == 0 && records.count == 0 {
                        self.categories.remove(at: indexPath.row)
                        print(self.categories[indexPath.row])
                        
                        // 削除した後の配列をfirebaseに保存する
                        self.ref.child(self.uid!).child("categories").setValue(self.categories)
                        tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
                    } else {
                        
                        // goodsかrecordsかにcategoryが含まれていることを知らせるアラート
                        let alert: UIAlertController = UIAlertController(title: "Stop!", message: "RECORDSまたはGOODSで使用されているCATEGORYは削除できません", preferredStyle: .alert)
                        alert.addAction(
                            UIAlertAction(
                                title: "cancel",
                                style: .cancel,
                                handler: nil
                            )
                        )
                        self.present(alert, animated: true, completion: nil)
                         
                    }
                })
            })
        }
    }

    // セルが選択されたら何も起きない
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
