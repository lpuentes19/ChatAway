//
//  UIColor+Extension.swift
//  ChatAway
//
//  Created by Luis Puentes on 10/30/17.
//  Copyright © 2017 LuisPuentes. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
