//
//  RecordViewController.swift
//  Goods
//
//  Created by 工藤彩名 on 2019/06/23.
//  Copyright © 2019 Kudo Ayana. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseStorageUI
import FirebaseDatabase

class RecordViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var table: UITableView!
    
//    , UISearchResultsUpdating
//    let searchController = UISearchController(searchResultsController: nil)

    var records: [Record] = []
    var categories: [String] = []
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    
    // userのidはuid
    let uid = Auth.auth().currentUser?.uid
    
    // くるくるに必要なやつ
    var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        
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
        
    
//        // searchBarフォーカス時に背景色を暗くするか？
//        searchController.obscuresBackgroundDuringPresentation = false
//        // searchBarのスタイル
//        searchController.searchBar.searchBarStyle = UISearchBar.Style.prominent
//        // searchbarのサイズを調整
//        searchController.searchBar.sizeToFit()
//        // 何も入力されていなくてもReturnキーを押せるようにする
//        searchController.searchBar.enablesReturnKeyAutomatically = false
//        searchController.searchBar.placeholder = "Search"
//        // UISearchResultsUpdating関連のやつ
//        searchController.searchResultsUpdater = self
//        // tableViewのヘッダーにsearchController.searchBarをセット
//        table.tableHeaderView = searchController.searchBar
        
        
    }
    
    
    // 開いた時に毎回読み込む
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        load()
        // tabbarを表示
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func load() {
        // アニメーション開始
        activityIndicatorView.startAnimating()
        // firebaseからデータを読み込む
        ref.child(uid!).child("categories").observeSingleEvent(of: .value, with: { (snapshot) in
            self.categories.removeAll()
            // valueの中身が空の時は空の配列を入れる
            let values = snapshot.value as? [String] ?? []
            for title in values {
                self.categories.append(title)
            }
            self.table.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }

        // firebaseからデータを読み込む
        ref.child(uid!).child("records").queryOrdered(byChild: "created").observeSingleEvent(of: .value, with: { (snapshot) in
            // 一旦配列を初期化
            self.records.removeAll()
            
            // valueの数だけ読み込みをループ
            for child in snapshot.children {
                
                // DataSnapshotにキャスト(型変換)したvaluesを取り出してAny型からString型にキャストするのを安全に行うguard
                guard let values = child as? DataSnapshot, let value = values.value as? [String: Any] else {
                    return
                }
                
                // valueをrecordインスタンスにしてrecords配列に保存
                let record = Record(key: value["key"] as? String ?? "", title: value["title"] as? String ?? "", date: value["date"] as? String ?? "", category: value["category"] as? String ?? "", result: value["result"] as? String ?? "", place: value["place"] as? String ?? "", comment: value["comment"] as? String ?? "", emotion: value["emotion"] as? String ?? "", image: value["image"] as? String ?? "")
                //print(record)
                self.records.append(record)
            }
            
            // goodsがなければTableViewを非表示にして初期画面を出す
            if self.records.count == 0 {
                print("goodsないです")
                self.table.isHidden = true
            } else {
                self.table.isHidden = false
            }
            
            // アニメーション終了
            self.activityIndicatorView.stopAnimating()
            self.table.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
        
            }
    
    // cellに表示する内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:RecordTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! RecordTableViewCell
        let Record = records.filter { $0.category == self.categories[indexPath.section] } [indexPath.row]
        
        if Record.emotion == "1" {
            cell.emotion.image = UIImage(named: "1_color")
        } else  if Record.emotion == "2" {
            cell.emotion.image = UIImage(named: "2_color")
        } else if Record.emotion == "3" {
            cell.emotion.image = UIImage(named: "3_color")
        } else  if Record.emotion == "4" {
            cell.emotion.image = UIImage(named: "4_color")
        } else  if Record.emotion == "5" {
            cell.emotion.image = UIImage(named: "5_color")
        }

        
        cell.title.text = Record.title
        cell.date.text = Record.date
        cell.result.text = Record.result
        cell.place.text = Record.place
        let reference = storageRef.child(uid!).child(Record.image)
        cell.mainimg.sd_setImage(with: reference)
        
        return cell
    }
    
    // sectionの数
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.categories.count
    }
    
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.filter { $0.category == self.categories[section] }.count
    }
    
    // label
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label : UILabel = UILabel()
        label.backgroundColor = UIColor.init(red: 41/255, green: 94/255, blue: 164/255, alpha: 100/100)
        label.textColor = UIColor.white
        label.font = UIFont(name: "Kano", size: 17)
        label.text = self.categories[section] as? String
        
        return label
    }
    
    // category内に何もない時ヘッダー非表示
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let record = records.filter { $0.category == self.categories[section] }
        if record.count == 0 {
            return CGFloat(signOf: self.view.bounds.width, magnitudeOf: 0)
        } else {
            return table.sectionHeaderHeight
        }
    }
    
    // 初期画面に表示する追加画面への遷移ボタン
    @IBAction func toAdd() {
        
    }
    
    // 編集画面への画面遷移
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let record = records.filter { $0.category == self.categories[indexPath.section] } [indexPath.row]
        // 画面遷移する前に検索バーを隠す
//        self.searchController.isActive = false
        self.performSegue(withIdentifier: "toEditRecords", sender: record)
    }
    
    // senderにrecordを入れたことで使える画面遷移の時に値を渡すやつ
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? EditRecordViewController {
            viewController.record = sender as? Record
            
        }
    }
    
//    func reload(query: String!) {
//        // アニメーション開始
//        activityIndicatorView.startAnimating()
//        print(query)
//        
//        // 配列内でqueryを含むものをfilterでOR検索
//        // localizedCaseInsensitiveContainsは大文字小文字の区別をせずに検索
//        let filterRecords = records.filter { $0.title.localizedCaseInsensitiveContains(query) || $0.date.localizedCaseInsensitiveContains(query) || $0.category.localizedCaseInsensitiveContains(query) || $0.result.localizedCaseInsensitiveContains(query) || $0.place.localizedCaseInsensitiveContains(query) || $0.comment.localizedCaseInsensitiveContains(query) }
//        print(filterRecords)
//        print("検索しました")
//        // 一旦配列を初期化
//        self.records.removeAll()
//        // filter後の配列を入れる
//        self.records.append(contentsOf: filterRecords)
//        
//        // アニメーション終了
//        self.activityIndicatorView.stopAnimating()
//        self.table.reloadData()
//    }
//    
//    // SearchBarの検索ボタンを押した時
//    func updateSearchResults(for searchController: UISearchController) {
//        // tabbarを非表示
//        self.tabBarController?.tabBar.isHidden = true
//        guard let searchText = searchController.searchBar.text else { return }
//        // !=でノットイコール
//        if searchText != "" {
//            self.reload(query: searchText)
////            print(searchText)
//        } else {
//            // 空欄なら全部表示する
//            load()
//        }
//        
//        if !searchController.isActive {
//            // tabbarを表示
//            self.tabBarController?.tabBar.isHidden = false
//            print("Cancelled")
//        }
//    }
    
    
}
