//
//  AppDelegate.swift
//  Goods2
//
//  Created by 工藤彩名 on 2019/05/11.
//  Copyright © 2019 Kudo Ayana. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseUI

import AuthenticationServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var selectedText: String?
    var commentText: String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        // Override point for customization after application launch.
        // ナビゲーションバーの戻るボタンの画像を変更、textにスペース入れて空白にする
        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "left-allow")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "left-allow")
        
        // tabbar消す
        if Auth.auth().currentUser != nil {
            // ログイン中
            let storyboard: UIStoryboard =  UIStoryboard(name: "Main", bundle: nil)
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "tab")
        } else {
            // ログインしてない
        }
        
//        // twitter認証 "apiキー","apiシークレット"
//        TWTRTwitter.sharedInstance().start(withConsumerKey: "flUEWydRtnAW5voQrAP51eGE2", consumerSecret: "1woejLRaJQhCsC2tKDtCLCEhmf3vQ5maAujpzuZERo5Hqoh2DH")

        return true
    }
    
    // facebook&Google&電話番号認証時に呼ばれる関数
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        // GoogleもしくはFacebook認証の場合、trueを返す
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // 電話番号認証の場合、trueを返す
        if Auth.auth().canHandle(url) {
            return true
        }
        return false
    }
    
//    // Twitter認証
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//
//        return true
//    }
    


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

