//
//  UserDefault+Extension.swift
//  JumpGame
//
//  Created by lei wang on 2020/3/25.
//  Copyright © 2020 lei wang. All rights reserved.
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
