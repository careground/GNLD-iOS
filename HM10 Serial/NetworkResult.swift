//
//  NetworkResult.swift
//  Serial
//
//  Created by 강수진 on 2019/10/15.
//  Copyright © 2019 Balancing Rock. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case decodeError
    case networkConnectFail
    case networkError
}
