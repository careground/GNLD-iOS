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
        NetworkManager.sharedInstance.sendIamFine { [weak self] (res) in
            guard let `self` = self else {
                return
            }
            switch res {
            case .success(_):
                self.dismiss(animated: true, completion: nil)
            case .failure(let type):
                switch type {
                case .networkConnectFail, .networkError:
                    self.showAlert(title: "네트워크 에러")
                case .decodeError:
                    self.showAlert(title: "디코딩 에러")
                }
            }
        }
    }
}
