//
//  UIViewController+NavigationBar.swift
//  Goods3
//
//  Created by Ayana Kudo on 2023/09/15.
//  Copyright © 2023 Kudo Ayana. All rights reserved.
//

import UIKit

extension UIViewController: UINavigationBarDelegate {
    // NavigationControllerではなくModal遷移しているAddRecord/AddGoodVCのstatusBarの背景色がBarと同じになるようにするため、Barを一番上まで広げる
    public func position(for bar: UIBarPositioning) -> UIBarPosition {
            return .topAttached
    }
}
