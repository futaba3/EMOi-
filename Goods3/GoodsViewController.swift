//
//  GoodsViewController.swift
//  Goods
//
//  Created by 工藤彩名 on 2019/05/11.
//  Copyright © 2019 Kudo Ayana. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class GoodsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var collectionView: UICollectionView!
    
//    let searchController = UISearchController(searchResultsController: nil)
    
    var goods: [Good] = []
    var categories: [String] = []
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    
    // userのidはuid
    let uid = Auth.auth().currentUser?.uid
    
    // くるくるに必要なやつ
    var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
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
////        // tableViewのヘッダーにsearchController.searchBarをセット
//        collectionView.collectionHeaderView = searchController.searchBar
//        automaticallyAdjustsScrollViewInsets = false
//        definesPresentationContext = true
//
        
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
            self.collectionView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
        
        // firebaseからデータを読み込む(createdでソート)
        ref.child(uid!).child("goods").queryOrdered(byChild: "created").observeSingleEvent(of: .value, with: { (snapshot) in
            // 一旦配列を初期化
            self.goods.removeAll()
            
            // 順番通りになっているsnapshot内の数だけ読み込みをループ
            for child in snapshot.children {
                
                // DataSnapshotにキャスト(型変換)したvaluesを取り出してAny型からString型にキャストするのを安全に行うguard
                guard let values = child as? DataSnapshot, let value = values.value as? [String: Any] else {
                    return
                }
                
                // valueをgoodインスタンスにしてgoods配列に保存
                let good = Good(key: value["key"] as? String ?? "", title: value["title"] as? String ?? "", date: value["date"] as? String ?? "", category: value["category"] as? String ?? "", place: value["place"] as? String ?? "", image: value["image"] as? String ?? "")
                self.goods.append(good)
            }
            
            // goodsがなければCollectionViewを非表示にして初期画面を出す
            if self.goods.count == 0 {
                print("goodsないです")
                self.collectionView.isHidden = true
            } else {
                self.collectionView.isHidden = false
            }
            
            // アニメーション終了
            self.activityIndicatorView.stopAnimating()
            self.collectionView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        
    }
    
    // セルが表示されるときに呼ばれる処理（1個のセルを描画する毎に呼び出される）
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let good = goods.filter { $0.category == self.categories[indexPath.section] } [indexPath.row]
        let cell:CustomCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! CustomCell
        cell.title.text = good.title
        cell.date.text = good.date
        // imageがない時はデフォルト画像、ある時は読み込む
        if good.image == "" {
            let image = UIImage(named: "trading_goods.png")
            cell.goodsimg.image = image
        } else {
            let reference = storageRef.child(uid!).child(good.image)
            cell.goodsimg.sd_setImage(with: reference)
        }
        return cell
    }
    
    // sectionの数
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.categories.count
    }
    
    // 表示するセルの数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return goods.filter { $0.category == self.categories[section] }.count
    }
    
    // セルのサイズを設定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 画面の幅-(スペース*2)/3
        return CGSize(width: (self.view.frame.width - 10) / 3, height: self.view.frame.width / 2)
    }
    
    // sectionの名前を設定
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader", for: indexPath) as? SectionHeader else {
            fatalError("Could not find proper header")
        }
        if kind == UICollectionView.elementKindSectionHeader {
            header.sectionLabel.text = self.categories[indexPath.section]
            return header
        }
        
        return UICollectionReusableView()
    }
    
    // category内に何もなければヘッダーを非表示
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let good = goods.filter { $0.category == self.categories[section] }
        if good.count == 0 {
            return CGSize(width: self.view.bounds.width, height: 0)
        } else {
            return CGSize(width: self.view.bounds.width, height: 30)
        }
    }
    
    // 初期画面に表示する追加画面への遷移ボタン
    @IBAction func toAdd() {
        
    }
    
    // 編集画面への画面遷移
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let good = goods.filter { $0.category == self.categories[indexPath.section] } [indexPath.row]
        self.performSegue(withIdentifier: "toEditGoods", sender: good)
        
    }
    
    // senderにgoodを入れたことで使える画面遷移の時に配列を渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? EditGoodsViewController {
            viewController.good = sender as? Good
        }
    }
    
//    func reload(query: String!) {
//        // アニメーション開始
//        activityIndicatorView.startAnimating()
//        print(query)
//
//        // 配列内でqueryを含むものをfilterでOR検索
//        // localizedCaseInsensitiveContainsは大文字小文字の区別をせずに検索
//        let filterGoods = goods.filter { $0.title.localizedCaseInsensitiveContains(query) || $0.date.localizedCaseInsensitiveContains(query) || $0.category.localizedCaseInsensitiveContains(query) || $0.place.localizedCaseInsensitiveContains(query) }
//        print(filterGoods)
//        print("検索しました")
//        // 一旦配列を初期化
//        self.goods.removeAll()
//        // filter後の配列を入れる
//        self.goods.append(contentsOf: filterGoods)
//
//        // アニメーション終了
//        self.activityIndicatorView.stopAnimating()
//        self.collectionView.reloadData()
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

