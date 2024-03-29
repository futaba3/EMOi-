//
//  LoginViewController.swift
//  Goods
//
//  Created by 工藤彩名 on 2019/07/13.
//  Copyright © 2019 Kudo Ayana. All rights reserved.
//

import UIKit
import AuthenticationServices
import CryptoKit
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseEmailAuthUI
import FirebaseOAuthUI

class LoginViewController: UIViewController, FUIAuthDelegate {
    
    @IBOutlet var AuthButton: UIButton!
    
    var authUI: FUIAuth { get { return FUIAuth.defaultAuthUI()!}}
    
    let actionCodeSettings = ActionCodeSettings()

    override func viewDidLoad() {
        super.viewDidLoad()
        // 認証に使用するプロバイダの選択
        let googleAuthProvider = FUIGoogleAuth(authUI: authUI)
        let providers: [FUIAuthProvider] = [
            googleAuthProvider,
            FUIEmailAuth(),
            FUIOAuth.appleAuthProvider()
        ]
        
        self.authUI.delegate = self
        self.authUI.providers = providers
        AuthButton.addTarget(self,action: #selector(self.AuthButtonTapped(sender:)),for: .touchUpInside)
        
        // Do any additional setup after loading the view.
    }
    
    // ステータスバーの文字色白くする
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    
    @objc func AuthButtonTapped(sender : AnyObject) {
        // FirebaseUIのViewの取得
        let authViewController = self.authUI.authViewController()
        // FirebaseUIのViewの表示
        self.present(authViewController, animated: true, completion: nil)
    }
    
    //　認証画面から離れたときに呼ばれる（キャンセルボタン押下含む）
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?){
        // 認証に成功した場合
        if error == nil {
            self.performSegue(withIdentifier: "toTopView", sender: self)
        }
    }
    
    

}
