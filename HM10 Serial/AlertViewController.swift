//
//  AlertViewController.swift
//  Serial
//
//  Created by 강수진 on 2019/10/29.
//  Copyright © 2019 Balancing Rock. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func okAction(_ sender: Any) {
        sendIamFine()
    }
    
    func sendIamFine() {
        self.pleaseWait()
        NetworkManager.sharedInstance.sendIamFine { [weak self] (res) in
            guard let `self` = self else {
                return
            }
            self.clearAllNotice()
            switch res {
            case .success(_):
                self.dismiss(animated: true, completion: nil)
            case .failure(let type):
                switch type {
                case .networkConnectFail:
                    self.showAlert(title: "네트워크 연결상태 확인")
                case .networkError(let errMessage):
                    self.showAlert(title: errMessage)
                case .decodeError:
                    self.showAlert(title: "디코딩 에러")
                }
            }
        }
    }
}
