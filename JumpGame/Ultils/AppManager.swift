//
//  AppManager.swift
//  WhoTapFast
//
//  Created by JackSen on 2020/3/22.
//  Copyright © 2020 JackSen. All rights reserved.
//

import Foundation
import UIKit

final class AppManager {
    init() {}
}

extension AppManager {
    func showAppInStore() {
        let targetUrl = "itms-apps://itunes.apple.com/app/id\(Const.appID)"
        if let url = URL(string: targetUrl),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
