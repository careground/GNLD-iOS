//
//  SerialViewController.swift
//  HM10 Serial
//
//  Created by Alex on 10-08-15.
//  Copyright (c) 2015 Balancing Rock. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuartzCore
import SwiftyJSON

/// The option to add a \n or \r or \r\n to the end of the send message
enum MessageOption: Int {
    case noLineEnding,
         newline,
         carriageReturn,
         carriageReturnAndNewline
}

/// The option to add a \n to the end of the received message (to make it more readable)
enum ReceivedMessageOption: Int {
    case none,
         newline
}

final class SerialViewController: UIViewController, UITextFieldDelegate, BluetoothSerialDelegate {

//MARK: IBOutlets
    @IBOutlet weak var noConnectView: UIView!
    //@IBOutlet weak var mainTextView: UITextView!
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var waterImageView: UIImageView!
    @IBOutlet weak var dustImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var gasImageView: UIImageView!
    
    @IBOutlet weak var waterLabel: UILabel!
    @IBOutlet weak var dustLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var gasLabel: UILabel!
    
    private var msgToJson = ""
    private var sensorData: ArduSensor?


//MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // init serial
        serial = BluetoothSerial(delegate: self)
    
        reloadView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SerialViewController.reloadView), name: NSNotification.Name(rawValue: "reloadStartViewController"), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func reloadView() {
        // in case we're the visible view again
        serial.delegate = self
        
        if serial.isReady {
            noConnectView.isHidden = true
            barButton.title = "연결 해제"
            barButton.tintColor = UIColor.red
            barButton.isEnabled = true
        } else if serial.centralManager.state == .poweredOn {
            noConnectView.isHidden = false
            barButton.title = "연결"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = true
        } else {
            noConnectView.isHidden = false
            barButton.title = "연결"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = false
        }
    }

    

//MARK: BluetoothSerialDelegate
 
    func serialDidReceiveString(_ message: String) {
        if message.first == "{" {
            msgToJson = ""
        }
        msgToJson += message
        if message.last == "}" {
            let data = msgToJson.data(using: .utf8)!
            do {
                let sensorData = try JSONDecoder().decode(ArduSensor.self, from: data)
                //센서 메시지 받아서 서버로 통신
                self.sensorData = sensorData
                sendSensorData(isNeedToSend: UserData.isOver30mSendData, sensorData: sensorData)
            } catch {
                print("Decoding Err")
            }
        }
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        reloadView()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "연결 해제"
        hud?.hide(true, afterDelay: 1.0)
    }
    
    func serialDidChangeState() {
        reloadView()
        if serial.centralManager.state != .poweredOn {
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud?.mode = MBProgressHUDMode.text
            hud?.labelText = "블루투스 종료"
            hud?.hide(true, afterDelay: 1.0)
        }
    }
    
    
//MARK: IBActions
    @IBAction func barButtonPressed(_ sender: AnyObject) {
        if serial.connectedPeripheral == nil {
            performSegue(withIdentifier: "ShowScanner", sender: self)
        } else {
            serial.disconnect()
            reloadView()
        }
    }
    
    @IBAction func rightBarButtonPressed(_ sender: AnyObject) {
        //30분이랑 상관없이 보내기까지 된 후에 업데이트.
        guard let sensorData = self.sensorData else {
            //MARK: 야매
            //미세먼지 bad -> good
            //dustLabel.text = "미세먼지가 양호해요:)"
            //dustLabel.textColor = #colorLiteral(red: 0.3586158454, green: 0.6558669806, blue: 0.8545332551, alpha: 1)
            
            //gas bad -> good
            //gasLabel.text = "일산화탄소 농도가 적정해요:)"
            //gasLabel.textColor = #colorLiteral(red: 0.3586158454, green: 0.6558669806, blue: 0.8545332551, alpha: 1)
            
            waterLabel.text = "수분이 적정해요 :)"
            waterLabel.textColor = #colorLiteral(red: 0.3660923839, green: 0.6661527753, blue: 0.8566637635, alpha: 1)
            return
        }
        sendSensorData(isNeedToSend: true, sensorData: sensorData)
        
    }
}

//MARK: 통신
extension SerialViewController {
    func sendSensorData(isNeedToSend: Bool, sensorData: ArduSensor) {
        if !isNeedToSend {
            return
        }
        //todo 서버에 보낼 시간까지 추가
        guard let temperature = sensorData.temperature,
            let humidityPercent = sensorData.humidityPercent,
            let CO = sensorData.CO,
            let pm10 = sensorData.pm10,
            let pm2p5 = sensorData.pm2p5,
            let soilPercent = sensorData.soilPercent else {
                return
        }
        NetworkManager.sharedInstance.sendSensorData(temperature: temperature, humidityPercent: humidityPercent, CO: CO, pm10: pm10, pm2p5: pm2p5, soilPercent: soilPercent) { [weak self] (res) in
            guard let `self` = self else {
                return
            }
            switch res {
            case .success(let data):
                //마지막으로 서버에 데이터 보낸 시간을 현재 시간으로 초기화
                UserData.setUserDefault(value: Date(), key: .lastSendDataTime)
                //데이터 보낸후 (30분 지났거나 새로고침 한 경우) 에 update view 하기위해 getData 호출
                self.getSensorDataFromNetwork()
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

    func getSensorDataFromNetwork() {
        print("emfdjdh")
        NetworkManager.sharedInstance.getSensorData { [weak self] (res) in
            guard let `self` = self else {
                return
            }
            switch res {
            case .success(let data):
                //todo 뷰 업데이트
                //서버 데이터 값만 if문에 넣어주면 됨!
                
//                if 수분 데이터 정상일 때 {
//                    waterImageView.image = UIImage(named: "water")
//                    waterLabel.textColor = #colorLiteral(red: 0.3586158454, green: 0.6558669806, blue: 0.8545332551, alpha: 1)
//                    waterLabel.text = "수분이 양호해요:)"
//                } else {
//                    waterImageView.image = UIImage(named: "water_none")
//                    waterLabel.textColor = #colorLiteral(red: 0.9667089581, green: 0.3216629326, blue: 0.3425347209, alpha: 1)
//                    waterLabel.text = "수분이 부족해요!"
//                }
//
//                if 먼지 데이터 정상일 때 {
//                    dustImageView.image = UIImage(named: "dust_none")
//                    dustLabel.textColor = #colorLiteral(red: 0.3586158454, green: 0.6558669806, blue: 0.8545332551, alpha: 1)
//                    dustLabel.text = "미세먼지가 양호해요:)"
//                } else {
//                    dustImageView.image = UIImage(named: "dust")
//                    dustLabel.textColor = #colorLiteral(red: 0.9667089581, green: 0.3216629326, blue: 0.3425347209, alpha: 1)
//                    dustLabel.text = "미세먼지가 나빠요!"
//                }
//
//                if 온도 데이터 정상일 때 {
//                    tempImageView.image = UIImage(named: "thermometer_none")
//                    tempLabel.textColor = #colorLiteral(red: 0.3586158454, green: 0.6558669806, blue: 0.8545332551, alpha: 1)
//                    tempLabel.text = "온도가 양호해요:)"
//                } else {
//                    tempImageView.image = UIImage(named: "thermometer")
//                    tempLabel.textColor = #colorLiteral(red: 0.9667089581, green: 0.3216629326, blue: 0.3425347209, alpha: 1)
//                    tempLabel.text = "온도가 낮아요!"
//                }
//
//                if 가스 데이터 정상일 때 {
//                    gasImageView.image = UIImage(named: "gas_none")
//                    gasLabel.textColor = #colorLiteral(red: 0.3586158454, green: 0.6558669806, blue: 0.8545332551, alpha: 1)
//                    gasLabel.text = "CO가 양호해요:)"
//                } else {
//                    gasImageView.image = UIImage(named: "gas")
//                    gasLabel.textColor = #colorLiteral(red: 0.9667089581, green: 0.3216629326, blue: 0.3425347209, alpha: 1)
//                    gasLabel.text = "CO가 나빠요!"
//                }
                
                break
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
}
