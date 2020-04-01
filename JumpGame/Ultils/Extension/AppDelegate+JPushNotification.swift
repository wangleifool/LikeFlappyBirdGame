//
//  AppDelegate+JPushNotification.swift
//  WhoTapFast
//
//  Created by lei wang on 2020/3/26.
//  Copyright © 2020 wanglei. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

// 极光
extension AppDelegate:JPUSHRegisterDelegate {
    
    /// 初始化极光推送
    func initJpush(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        // 通知注册实体类
        let entity = JPUSHRegisterEntity();
        entity.types = Int(JPAuthorizationOptions.alert.rawValue) |  Int(JPAuthorizationOptions.sound.rawValue) |  Int(JPAuthorizationOptions.badge.rawValue);
        
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self);
        // 注册极光推送
        JPUSHService.setup(withOption: launchOptions, appKey: Const.jpushKey, channel:"" , apsForProduction: true);
        // 注册成功
        JPUSHService.registrationIDCompletionHandler { (resCode, registrationID) in
            if resCode == 0{
                print("registrationID获取成功：\(String(describing: registrationID))")
            }else {
                print("registrationID获取失败：\(String(describing: registrationID))")
            }
        }
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        JPUSHService.setBadge(0)
        
        guard let options = launchOptions else {
            return
        }
        
        if let _ = options[UIApplication.LaunchOptionsKey.remoteNotification] {
//            isNewMessage.value = true
        }
    }
    
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        JPUSHService.registerDeviceToken(deviceToken)
        print("deviceToken:\(deviceToken)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("did Fail To Register For Remote Notifications With Error:\(error)")
    }
    /**
     收到静默推送的回调
     
     @param application  UIApplication 实例
     @param userInfo 推送时指定的参数
     @param completionHandler 完成回调
     */
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        JPUSHService.handleRemoteNotification(userInfo)
//        isNewMessage.value = true
        print("iOS7及以上系统，收到通知:\(userInfo)")
        completionHandler(UIBackgroundFetchResult.newData)
        
        // 程序在后台
        if UIApplication.shared.applicationState != .active {
            receivePush(userInfo as? [String : Any])
        }
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        JPUSHService.showLocalNotification(atFront: notification, identifierKey: nil)
    }
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
//         isNewMessage.value = true
        let userInfo = notification.request.content.userInfo
        
        //        let request = notification.request; // 收到推送的请求
        //        let content = request.content; // 收到推送的消息内容
        //
        //        let badge = content.badge;  // 推送消息的角标
        //        let body = content.body;    // 推送消息体
        //        let sound = content.sound;  // 推送消息的声音
        //        let subtitle = content.subtitle;  // 推送消息的副标题
        //        let title = content.title;  // 推送消息的标题
        
        if (notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))!{
            print("iOS10 前台收到远程通知:\(userInfo)")
            JPUSHService.handleRemoteNotification(userInfo)
            
        }else {
            // 判断为本地通知
            print("iOS10 前台收到本地通知:\(userInfo)")
        }
        
        completionHandler(Int(UNAuthorizationOptions.alert.rawValue | UNAuthorizationOptions.sound.rawValue | UNAuthorizationOptions.badge.rawValue))// 需要执行这个方法，选择是否提醒用户，有badge、sound、alert三种类型可以选择设置
    }
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        let userInfo = response.notification.request.content.userInfo
//         isNewMessage.value = true
        if (response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))!{
            print("iOS10 收到远程通知:\(userInfo)")
            JPUSHService.handleRemoteNotification(userInfo)
            
            // 出口点通知信息
            receivePush(userInfo as? [String : Any])
        }
        completionHandler()
    }
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification?) {
        
    }
    
    // 接收到推送实现的方法
    func receivePush(_ userInfo :[String:Any]?) {
        // 角标变0
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}
