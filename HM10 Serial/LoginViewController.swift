//
//  LoginViewController.swift
//  Serial
//
//  Created by 강수진 on 2019/11/06.
//  Copyright © 2019 Balancing Rock. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var idTxtField: UITextField!
    @IBOutlet weak var pwdTxtField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLogin()
    }
    @IBAction func loginAction(_ sender: Any) {
        login(id: idTxtField.text ?? "", pwd: pwdTxtField.text ?? "")
    }
    func checkLogin() {
        if UserData.isUserLogin {
            //유저 정보 있는 상태면 메인 뷰로
            toMainView()
        }
    }
    func toMainView() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let startNavigationView = storyBoard.instantiateViewController(withIdentifier: "StartNavigationView") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = startNavigationView
    }
}

//MARK: 통신
extension LoginViewController {
    func login(id: String, pwd: String) {
        NetworkManager.sharedInstance.login(id: id, pwd: pwd) { [weak self] (res) in
            guard let `self` = self else {
                return
            }
            switch res {
            case .success(let data):
                UserData.setUserDefault(value: data, key: .authorization)
                self.toMainView()
            case .failure(let type):
                //todo 여기에 잘못된 사용자 정보입니다 추가?
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
}
