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
    private func updateView(with data: SensorDataModel) {
        if data.soilWater {
            waterLabel.textColor = #colorLiteral(red: 0.3586158454, green: 0.6558669806, blue: 0.8545332551, alpha: 1)
            waterLabel.text = "수분이 양호해요:)"
        } else {
            waterLabel.textColor = #colorLiteral(red: 0.9667089581, green: 0.3216629326, blue: 0.3425347209, alpha: 1)
            waterLabel.text = "수분이 부족해요!"
        }
        if data.fineDust {
            dustLabel.textColor = #colorLiteral(red: 0.3586158454, green: 0.6558669806, blue: 0.8545332551, alpha: 1)
            dustLabel.text = "미세먼지가 양호해요:)"
        } else {
            dustLabel.textColor = #colorLiteral(red: 0.9667089581, green: 0.3216629326, blue: 0.3425347209, alpha: 1)
            dustLabel.text = "미세먼지가 나빠요!"
        }
        if data.temperature {
            tempLabel.textColor = #colorLiteral(red: 0.3586158454, green: 0.6558669806, blue: 0.8545332551, alpha: 1)
            tempLabel.text = "온도가 양호해요:)"
        } else {
            tempLabel.textColor = #colorLiteral(red: 0.9667089581, green: 0.3216629326, blue: 0.3425347209, alpha: 1)
            tempLabel.text = "온도를 조절해주세요!"
        }
        if data.coGas {
            gasLabel.textColor = #colorLiteral(red: 0.3586158454, green: 0.6558669806, blue: 0.8545332551, alpha: 1)
            gasLabel.text = "일산화탄소 농도가 양호해요:)"
        } else {
            gasLabel.textColor = #colorLiteral(red: 0.9667089581, green: 0.3216629326, blue: 0.3425347209, alpha: 1)
            gasLabel.text = "일산화탄소 농도가 나빠요!"
        }
    }
    
    //MARK: LifeCycle
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
            //블루투스 연결되어있는 상태
            noConnectView.isHidden = true
            barButton.title = "연결 해제"
            barButton.tintColor = UIColor.red
            barButton.isEnabled = true
        } else if serial.centralManager.state == .poweredOn {
            //블루투스 켜져있고 연결 대기중인 상태
            self.clearAllNotice()
            noConnectView.isHidden = false
            barButton.title = "연결"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = true
        } else {
            //블루투스 꺼져있는 상태
            self.clearAllNotice()
            noConnectView.isHidden = false
            barButton.title = "연결"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = false
        }
    }
    
    //MARK: IBActions
    //블루투스 연결
    @IBAction func barButtonPressed(_ sender: AnyObject) {
        if serial.connectedPeripheral == nil {
            performSegue(withIdentifier: "ShowScanner", sender: self)
        } else {
            serial.disconnect()
            reloadView()
        }
    }
    
    //새로고침
    @IBAction func rightBarButtonPressed(_ sender: AnyObject) {
        //30분이랑 상관없이 보내기까지 된 후에 업데이트.
        guard let sensorData = self.sensorData else {
            return
        }
        sendSensorData(isNeedToSend: true, sensorData: sensorData)
    }
}

//MARK: BluetoothSerialDelegate
extension SerialViewController {
    func serialDidReceiveString(_ message: String) {
        if message.first == "{" {
            msgToJson = ""
        }
        msgToJson += message
        print(message)
        if message.contains("}"){
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
        self.showAlert(title: "연결 해제")
    }
    
    func serialDidChangeState() {
        reloadView()
        if serial.centralManager.state != .poweredOn {
            self.showAlert(title: "블루투스 종료")
        }
    }
}

//MARK: 통신
extension SerialViewController {
    func sendSensorData(isNeedToSend: Bool, sensorData: ArduSensor) {
        if !isNeedToSend {
            return
        }
        self.pleaseWait()
        NetworkManager.sharedInstance.sendSensorData(temperature: sensorData.temperature, humidityPercent: sensorData.humidityPercent, CO: sensorData.CO, pm10: sensorData.pm10, soilPercent: sensorData.soilPercent) { [weak self] (res) in
            guard let `self` = self else {
                return
            }
            self.clearAllNotice()
            switch res {
            case .success(_):
                //마지막으로 서버에 데이터 보낸 시간을 현재 시간으로 초기화
                UserData.setUserDefault(value: Date(), key: .lastSendDataTime)
                //데이터 보낸후 (1.30분 지났거나, 2.새로고침 한 경우) 에 update view 하기위해 getData 호출
                self.getSensorDataFromNetwork()
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
    
    func getSensorDataFromNetwork() {
        self.pleaseWait()
        NetworkManager.sharedInstance.getSensorData { [weak self] (res) in
            guard let `self` = self else {
                return
            }
            self.clearAllNotice()
            switch res {
            case .success(let data):
                self.updateView(with: data)
                break
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
