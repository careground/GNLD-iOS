//
//  CareGroundAPI.swift
//  Serial
//
//  Created by 강수진 on 2019/10/15.
//  Copyright © 2019 Balancing Rock. All rights reserved.
//

import Foundation
import Moya

enum CareGroundAPI {
    case login(id: String, pwd: String, fcmToken: String)
    case getSensorData
    case sendSensorData(temperature: Double,
        humidityPercent: Double,
        CO: Int,
        pm10: Int,
        soilPercent: Int)
    case sendIamFine
}

extension CareGroundAPI: TargetType {
    var baseURL: URL {
        guard let url = URL(string: "http://13.125.105.66:3100/api") else {
            fatalError("base url could not be configured")
        }
        return url
    }
    var path: String {
        switch self {
        case .login:
            return "/signin"
        case .getSensorData, .sendSensorData:
            return "/sensor"
        case .sendIamFine:
            return "/sendok"
        }
    }
    var method: Moya.Method {
        switch self {
        case .getSensorData:
            return .get
        case .login, .sendSensorData:
            return .post
        case .sendIamFine:
            return .delete
        }
    }
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    var sampleData: Data {
        return Data()
    }
    var task: Task {
        switch self {
        case .login(let id, let pwd, let fcmToken):
            let parameters: [String: Any] = ["email": id,
                                             "password": pwd,
                                             "fcm_token" : fcmToken]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .getSensorData, .sendIamFine:
            return .requestPlain
        case .sendSensorData(let temperature,
                              let humidityPercent,
                              let CO,
                              let pm10,
                              let soilPercent):
            let parameters: [String: Any] = ["temperature": temperature,
                                             "humidity": humidityPercent,
                                             "co_gas": CO,
                                             "fine_dust": pm10,
                                             "soil_water": soilPercent
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
    var validationType: ValidationType {
        return .successAndRedirectCodes
    }
    var headers: [String: String]? {
        if let authorization = UserData.getUserDefault(key: .authorization, type: String.self) {
            return ["Content-type": "application/json",
                    "authorization": authorization]
        } else {
            return ["Content-type": "application/json"]
        }
    }
}
