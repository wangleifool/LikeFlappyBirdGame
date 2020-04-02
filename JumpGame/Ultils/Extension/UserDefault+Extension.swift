//
//  UserDefault+Extension.swift
//  JumpGame
//
//  Created by JackSen on 2020/3/25.
//  Copyright © 2020 JackSen. All rights reserved.
//

import Foundation

extension UserDefaults {
    struct App: IntUserDefaultable {
        private init() {}
        
        enum IntDefaultKey: String {
            case bestscore
        }
    }
}
