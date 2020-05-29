//
//  InterAppPaymentService.swift
//  JumpGame
//
//  Created by lei wang on 2020/5/29.
//  Copyright © 2020 lei wang. All rights reserved.
//

import Foundation
import SwiftyStoreKit

enum AppStoreProductType {
    /// 消耗型项目
    /// 只可使用一次的产品，使用之后即失效，必须再次购买。
    /// 示例：钓鱼 App 中的鱼食。
    case consumable
    
    /// 非消耗型项目
    /// 只需购买一次，不会过期或随着使用而减少的产品。
    /// 示例：游戏 App 的赛道。
    case nonconsumable
    
    /// 自动续期订阅
    /// 允许用户在固定时间段内购买动态内容的产品。除非用户选择取消，否则此类订阅会自动续期。
    /// 示例：每月订阅提供流媒体服务的 App。
    case autoRenewSubscription
    
    /// 非续期订阅
    /// 允许用户购买有时限性服务的产品。此 App 内购买项目的内容可以是静态的。此类订阅不会自动续期。
    /// 示例：为期一年的已归档文章目录订阅。
    case nonAutoRenewSubscription
    
    var sharedSecret: String? {
        switch self {
        case .autoRenewSubscription:
            return ""
        default:
            return nil
        }
    }
}

enum AppStoreProducts: CaseIterable {
    case tenLifesPerMonth
    
    var productID: String {
        switch self {
        case .tenLifesPerMonth:
            return "com.leiwang.taprunfast.tenLifes"
        }
    }
    
    var type: AppStoreProductType {
        switch self {
        case .tenLifesPerMonth:
            return .nonAutoRenewSubscription
        }
    }
    
    var validDuration: TimeInterval {
        switch self {
        case .tenLifesPerMonth:
            return 3600 * 24 * 30
        }
    }
}

struct InterAppPaymentService {
    static var shared = InterAppPaymentService()
    private init() {}
    
    /// 获取在售产品信息
    func retrieveProductsInfo() {
        let productsIds = AppStoreProducts.allCases.map { $0.productID }
        SwiftyStoreKit.retrieveProductsInfo(Set(productsIds)) { (result) in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(String(describing: result.error))")
            }
        }
    }
    
    /// 购买商品
    func purchaseProduct(_ product: AppStoreProducts) {
        SwiftyStoreKit.purchaseProduct(product.productID, atomically: true) { result in
        
            switch result {
            case .success(let purchase):
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                
                let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "your-shared-secret")
                SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
                    
                    if case .success(let receipt) = result {
                        let purchaseResult = SwiftyStoreKit.verifySubscription(
                            ofType: .autoRenewable,
                            productId: product.productID,
                            inReceipt: receipt)
                        
                        switch purchaseResult {
                        case .purchased(let expiryDate, let receiptItems):
                            print("Product is valid until \(expiryDate)")
                        case .expired(let expiryDate, let receiptItems):
                            print("Product is expired since \(expiryDate)")
                        case .notPurchased:
                            print("This product has never been purchased")
                        }

                    } else {
                        // receipt verification error
                    }
                }
            case .error(let error):
                switch error.code {
                case .unknown:
                    print("Unknown error. Please contact support")
                case .clientInvalid:
                    print("Not allowed to make the payment")
                case .paymentCancelled:
                    break
                case .paymentInvalid:
                    print("The purchase identifier was invalid")
                case .paymentNotAllowed:
                    print("The device is not allowed to make the payment")
                case .storeProductNotAvailable:
                    print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied:
                    print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed:
                    print("Could not connect to the network")
                case .cloudServiceRevoked:
                    print("User has revoked permission to use this cloud service")
                case .privacyAcknowledgementRequired:
                    print("privacyAcknowledgementRequired")
                case .unauthorizedRequestData:
                    print("unauthorizedRequestData")
                case .invalidOfferIdentifier:
                    print("invalidOfferIdentifier")
                case .invalidSignature:
                    print("invalidSignature")
                case .missingOfferParams:
                    print("missingOfferParams")
                case .invalidOfferPrice:
                    print("invalidOfferPrice")
                @unknown default:
                    break
            }
            }
        }
    }
    
    func verifyReceipt(product: AppStoreProducts) {
        var service: AppleReceiptValidator.VerifyReceiptURLType = .production
        #if DEBUG
        service = .sandbox
        #endif
        let appleValidator = AppleReceiptValidator(service: service, sharedSecret: product.type.sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { (result) in
            switch result {
            case .success(let receipt):
                if product.type == .autoRenewSubscription || product.type == .nonAutoRenewSubscription {
                    let type: SubscriptionType = product.type == .autoRenewSubscription ? .autoRenewable : .nonRenewing(validDuration: product.validDuration)
                    let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: type,
                                                                           productId: product.productID,
                                                                           inReceipt: receipt)
                    switch purchaseResult {
                    case .purchased(let expiryDate, let receiptItems):
                        print("Product is valid until \(expiryDate)")
                    case .expired(let expiryDate, let receiptItems):
                        print("Product is expired since \(expiryDate)")
                    case .notPurchased:
                        print("This product has never been purchased")
                    }
                } else {
                    let purchaseResult = SwiftyStoreKit.verifyPurchase(productId: product.productID, inReceipt: receipt)
                        
                    switch purchaseResult {
                    case .purchased(let receiptItem):
                        print("\(product.productID) is purchased: \(receiptItem)")
                    case .notPurchased:
                        print("The user has never purchased \(product.productID)")
                    }
                    print("Verify receipt success: \(receipt)")
                }
            case .error(let error):
                print("Verify receipt fail: \(error)")
            }
        }
    }
}
