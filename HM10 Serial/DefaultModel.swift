//
//  DefaultModel.swift
//  Serial
//
//  Created by 강수진 on 2019/11/12.
//  Copyright © 2019 Balancing Rock. All rights reserved.
//

import Foundation
struct DefaultModel: Codable {
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case message
    }
}
