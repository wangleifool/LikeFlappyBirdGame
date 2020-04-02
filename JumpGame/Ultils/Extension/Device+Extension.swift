//
//  Device+Extension.swift
//  JumpGame
//
//  Created by JackSen on 2020/3/29.
//  Copyright © 2020 JackSen. All rights reserved.
//

import UIKit

extension UIDevice {
    static let appShortVersion: String = {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }()

    static let appVersion: String = {
        return Bundle.main.object(forInfoDictionaryKey: String(kCFBundleVersionKey)) as? String ?? ""
    }()

    static let osVersion: String = {
        return UIDevice.current.systemVersion
    }()
}

extension UIDevice {
    static let isIPhoneX: Bool = {
        guard #available(iOS 11, *), UIDevice.current.userInterfaceIdiom == .phone else {
            return false
        }
        let nativeSize = UIScreen.main.nativeBounds.size
        let (d1, d2) = (CGFloat(1_125), CGFloat(2_436))
        // iphone xr
        let (d3, d4) = (CGFloat(828), CGFloat(1792))
        
        // iphone xs max
        let (d5, d6) = (CGFloat(1242), CGFloat(2688))
        
        return nativeSize == CGSize(width: d1, height: d2) ||
            nativeSize == CGSize(width: d2, height: d1) ||
            nativeSize == CGSize(width: d3, height: d4) ||
            nativeSize == CGSize(width: d4, height: d3) ||
            nativeSize == CGSize(width: d5, height: d6) ||
            nativeSize == CGSize(width: d6, height: d5)
    }()
    
    static let isIPhoneSE: Bool = {
        return UIScreen.main.nativeBounds.size == CGSize(width: 640, height: 1136)
    }()
    
    static let isIPhone8: Bool = {
        return UIScreen.main.nativeBounds.size == CGSize(width: 750, height: 1334)
    }()
    
    static let isIPhone8Plus: Bool = {
        return UIScreen.main.nativeBounds.size == CGSize(width: 1242, height: 2208)
    }()
}

