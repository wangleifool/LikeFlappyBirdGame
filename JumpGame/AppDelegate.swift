//
//  AppDelegate.swift
//  JumpGame
//
//  Created by JackSen on 2020/3/23.
//  Copyright © 2020 JackSen. All rights reserved.
//

import UIKit
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appManager = AppManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        initJpush(launchOptions)
        
        /// 在启动时添加应用程序的观察者可确保在应用程序的所有启动过程中都会持续，从而允许您的应用程序接收所有支付队列通知。如果此时有任何待处理的事务，将触发block，以便可以更新应用程序状态和UI。如果没有待处理的事务，则不会调用。
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    break // do nothing
                }
            }
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = LaunchViewController.instance()
        window?.makeKeyAndVisible()
        
        return true
    }

}

