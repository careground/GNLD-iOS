//
//  UIViewController+Extension.swift
//  Serial
//
//  Created by 강수진 on 2019/11/11.
//  Copyright © 2019 Balancing Rock. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = title
        hud?.hide(true, afterDelay: 1.0)
    }
}
