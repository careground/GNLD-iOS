//
//  ArduSensor.swift
//  Serial
//
//  Created by 강수진 on 2019/10/15.
//  Copyright © 2019 Balancing Rock. All rights reserved.
//

import Foundation
struct ArduSensor: Codable {
    //선 연결 안되면 null 들어기 때문에 optional 처리
    let temperature: Double?
    let humidityPercent: Double?
    let CO: Int?
    let pm10: Int?
    let pm2p5: Int?
    let soilPercent: Int?

    
    enum CodingKeys: String, CodingKey {
        case temperature, CO, pm10, pm2p5
        case humidityPercent = "humidity_percent"
        case soilPercent = "soil_percent"
    }
}
