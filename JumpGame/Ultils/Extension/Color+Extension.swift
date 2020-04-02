//
//  Color+Extension.swift
//  JumpGame
//
//  Created by JackSen on 2020/3/28.
//  Copyright © 2020 JackSen. All rights reserved.
//

import Foundation
import SpriteKit

extension SKColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let components = (
            r: CGFloat((hex >> 16) & 0xff) / 255,
            g: CGFloat((hex >> 08) & 0xff) / 255,
            b: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.r,
                  green: components.g,
                  blue: components.b,
                  alpha: alpha)
    }

    convenience init?(hex: String, alpha: CGFloat = 1.0) {
        var hexString = ""
        if hex.lowercased().hasPrefix("0x") {
            hexString = hex.replacingOccurrences(of: "0x", with: "")
        } else if hex.lowercased().hasPrefix("#") {
            hexString = hex.replacingOccurrences(of: "#", with: "")
        } else {
            hexString = hex
        }

        if hexString.count == 3 {
            hexString = hexString.reduce("", { $0 + String(repeating: $1, count: 2) })
        }

        guard let hexValue = Int(hexString, radix: 16) else { return nil }

        var alpha = alpha
        alpha = max(alpha, 0.0)
        alpha = min(alpha, 1.0)

        let red = CGFloat((hexValue >> 16) & 0xff) / 255.0
        let green = CGFloat((hexValue >> 08) & 0xff) / 255.0
        let blue = CGFloat((hexValue >> 00) & 0xff) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
