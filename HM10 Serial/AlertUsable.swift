//
//  AlertUsable.swift
//  Serial
//
//  Created by 강수진 on 2019/11/11.
//  Copyright © 2019 Balancing Rock. All rights reserved.
//

import UIKit

protocol AlertUsable: UIPresentable {
    func simpleAlert(title: String, message: String, okHandler: ((UIAlertAction) -> Void)?)
}

extension AlertUsable {
    func simpleAlert(title: String, message: String, okHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okTitle = "확인"
        let okAction = UIAlertAction(title: okTitle, style: .default, handler: okHandler)
        alert.addAction(okAction)
        self.viewController.present(alert, animated: true)
    }
    func simpleActionSheet(title: String?,
                           message: String?,
                           okTitle: String,
                           actions: [[String: ((UIAlertAction) -> Void)?]],
                           okHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for (action) in actions {
            for (key, value) in action {
                alert.addAction(UIAlertAction(title: key, style: .default, handler: value))
            }
        }
        let cancleAction = UIAlertAction(title: okTitle, style: .cancel)
        alert.addAction(cancleAction)
        self.viewController.present(alert, animated: true)
    }
}
