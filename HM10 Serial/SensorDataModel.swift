//
//  SensorDataModel.swift
//  Serial
//
//  Created by 강수진 on 2019/11/12.
//  Copyright © 2019 Balancing Rock. All rights reserved.
//

import Foundation
struct SensorDataModel: Codable {
    let soilWater, temperature, fineDust, coGas: Bool

    enum CodingKeys: String, CodingKey {
        case soilWater = "soil_water"
        case temperature
        case fineDust = "fine_dust"
        case coGas = "co_gas"
    }
}
