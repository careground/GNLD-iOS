//
//  UserData.swift
//  Serial
//
//  Created by 강수진 on 2019/10/16.
//  Copyright © 2019 Balancing Rock. All rights reserved.
//

import Foundation

enum UserDataKey: String {
    case authorization = "authorization"
    case lastSendDataTime = "lastSendDataTime"
    case fcmToken = "fcmToken"
}

struct UserData {
    static func setUserDefault(value: Any, key: UserDataKey) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    static func getUserDefault<T>(key: UserDataKey, type: T.Type) -> T? {
        return UserDefaults.standard.value(forKey: key.rawValue) as? T
    }
    static var isUserLogin: Bool {
        if UserData.getUserDefault(key: .authorization, type: String.self) == nil {
            return false
        } else {
            return true
        }
    }
    static var isOver30mSendData: Bool {
        guard let lastSendDataTime = UserData.getUserDefault(key: .lastSendDataTime, type: Date.self) else {
            //초기 상태
            return true
        }
        //현재가 마지막으로 보낸시간 보다 크면 다시 보내야함
        //todo 5초 -> 60*30으로 바꿔야
        if Date() > lastSendDataTime.addingTimeInterval(5) {
           return true
        } else {
            return false
        }
    }
    static func removeUserDefault(key: UserDataKey) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
}
