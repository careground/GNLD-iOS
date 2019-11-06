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
                    let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                    hud?.mode = MBProgressHUDMode.text
                    hud?.labelText = "네트워크 에러"
                    hud?.hide(true, afterDelay: 1.0)
                case .decodeError:
                    let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                    hud?.mode = MBProgressHUDMode.text
                    hud?.labelText = "디코딩 에러"
                    hud?.hide(true, afterDelay: 1.0)
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
