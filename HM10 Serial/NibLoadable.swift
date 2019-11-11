//
//  NibLoadable.swift
//  Serial
//
//  Created by 강수진 on 2019/11/11.
//  Copyright © 2019 Balancing Rock. All rights reserved.
//

import Foundation

protocol NibLoadable: class {
    static var nibId: String { get }
}

extension NibLoadable {
    static var nibId: String {
        return String(describing: self)
    }
    var nidId: String {
        return String(describing: type(of: self))
    }
}
