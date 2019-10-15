//
//  SampleModel.swift
//  Serial
//
//  Created by 강수진 on 2019/10/15.
//  Copyright © 2019 Balancing Rock. All rights reserved.
//

import Foundation
struct SampleModel: Codable {
    let comments: String?
    let movieID: String
    
    enum CodingKeys: String, CodingKey {
        case comments
        case movieID = "movie_id"
    }
}
