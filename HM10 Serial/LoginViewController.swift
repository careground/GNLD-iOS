//
//  LoginViewController.swift
//  Serial
//
//  Created by 강수진 on 2019/11/06.
//  Copyright © 2019 Balancing Rock. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, KeyboardObserving {
    
    @IBOutlet weak var idTxtField: UITextField!
    @IBOutlet weak var pwdTxtField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        //todo 지우기
        idTxtField.text = "test2@gmail.com"
        pwdTxtField.text = "1234"
        UserData.removeUserDefault(key: .authorization)
        checkLogin()
        registerForKeyboardEvents()
    }
    @IBAction func loginAction(_ sender: Any) {
        guard let id = idTxtField.text, let pwd = pwdTxtField.text else {
            return
        }
        if (isTextFieldValidate(id: id, pwd: pwd)) {
            login(id: id, pwd: pwd)
        } else {
            showAlert(title: "모든 값을 채워주세요")
        }
    }
    private func isTextFieldValidate(id: String?,
                                    pwd: String?) -> Bool {
        //textField 가 비어있는지 체크
        guard let id = id, let pwd = pwd else {
            return false
        }
        guard !id.isEmpty, !pwd.isEmpty else {
            return false
        }
        return true
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

    deinit {
        unregisterFromKeyboardEvents()
    }
}

extension LoginViewController: UITextFieldDelegate  {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

//MARK: 통신
extension LoginViewController {
    func login(id: String, pwd: String) {
        guard let fcmToken = UserData.getUserDefault(key: .fcmToken, type: String.self) else {
            return
        }
        self.pleaseWait()
        NetworkManager.sharedInstance.login(id: id, pwd: pwd, fcmToken: fcmToken) { [weak self] (res) in
            guard let `self` = self else {
                return
            }
            self.clearAllNotice()
            switch res {
            case .success(let data):
                UserData.setUserDefault(value: data, key: .authorization)
                self.toMainView()
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
