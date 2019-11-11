//
//  UIPresentable.swift
//  Serial
//
//  Created by 강수진 on 2019/11/11.
//  Copyright © 2019 Balancing Rock. All rights reserved.
//

import UIKit

protocol UIPresentable: class {
    var viewController: UIViewController { get }
}

extension UIPresentable where Self: UIViewController {
    var viewController: UIViewController {
        return self
    }
}
