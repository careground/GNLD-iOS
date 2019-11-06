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
    case login(id: String, pwd: String)
    case getSensorData
    case sendSensorData(temperature: Double,
        humidityPercent: Double,
        CO: Int,
        pm10: Int,
        pm2p5: Int,
        soilPercent: Int)
}

extension CareGroundAPI: TargetType {
    var baseURL: URL {
        guard let url = URL(string: "http://localhost") else {
            fatalError("base url could not be configured")
        }
        return url
    }
    var path: String {
        switch self {
        case .login:
            return "/"
        case .getSensorData:
            return "/"
        case .sendSensorData:
            return "/"
        }
    }
    var method: Moya.Method {
        switch self {
        case .getSensorData:
            return .get
        case .login, .sendSensorData:
            return .post
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
        case .login(let id, let pwd):
            let parameters: [String: Any] = ["id": id,
                                             "pwd": pwd
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .getSensorData:
            return .requestPlain
        case .sendSensorData(let temperature,
                              let humidityPercent,
                              let CO,
                              let pm10,
                              let pm2p5,
                              let soilPercent):
            let parameters: [String: Any] = ["temperature": temperature,
                                             "humidity_per": humidityPercent,
                                             "CO": CO,
                                             "pm10": pm10,
                                             "pm2p5": pm2p5,
                                             "soil_per": soilPercent
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
    var validationType: ValidationType {
        return .successAndRedirectCodes
    }
    var headers: [String: String]? {
        //todo 로그인해서 채우기
        if let authorization = UserData.getUserDefault(key: .authorization, type: String.self) {
            return ["Content-type": "application/json",
                    "Authorization": authorization]
        } else {
            return ["Content-type": "application/json"]
        }
    }
}
