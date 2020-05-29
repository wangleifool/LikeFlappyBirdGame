//
//  InterAppPaymentService.swift
//  JumpGame
//
//  Created by lei wang on 2020/5/29.
//  Copyright © 2020 lei wang. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyStoreKit
import RxSwift

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
    func retrieveProductsInfo(_ product: [AppStoreProducts]) -> Single<Set<SKProduct>> {
        return Single<Set<SKProduct>>.create { (single) -> Disposable in
            let productsIds = product.map { $0.productID }
            SwiftyStoreKit.retrieveProductsInfo(Set(productsIds)) { (result) in
                if let _ = result.retrievedProducts.first {
                    single(.success(result.retrievedProducts))
                }
                else if let _ = result.invalidProductIDs.first {
                    single(.error(AppError.IAPError.invalidProductID))
                }
                else {
                    single(.error(result.error!))
                    print("Error: \(String(describing: result.error))")
                }
            }
            
            return Disposables.create()
        }
    }
    
    /// 购买并且验证收据
    func purchaseAndConfirm(product: AppStoreProducts) -> Single<Void> {
        return purchaseProduct(product)
            .flatMap { self.verifyReceipt(product: product) }
    }
    
    /// 只是购买商品
    func purchaseProduct(_ product: AppStoreProducts) -> Single<Void> {
        return Single<Void>.create { (single) -> Disposable in
            
            SwiftyStoreKit.purchaseProduct(product.productID, atomically: true) { result in
                switch result {
                case .success(let purchase):
                    // Deliver content from server, then:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    single(.success(()))
                    
                case .error(let error):
                    switch error.code {
                    case .paymentCancelled:
                        single(.error(AppError.IAPError.cancelled))
                    case .paymentInvalid:
                        single(.error(AppError.IAPError.invalidProductID))
                    case .cloudServiceNetworkConnectionFailed:
                        single(.error(AppError.IAPError.notConnectedToInternet))
                    default:
                        single(.error(AppError.IAPError.unknown))
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    private func checkVerifyResult(product: AppStoreProducts, result: (VerifySubscriptionResult?,VerifyPurchaseResult?)) -> Single<Void> {
        switch product.type {
        case .autoRenewSubscription, .nonAutoRenewSubscription:
            if let subscribeResult = result.0 {
                switch subscribeResult {
                case .purchased(_, let items):
                    guard let _ = items.first(where: { $0.productId == product.productID }) else {
                        return Single.error(AppError.IAPError.invalidProductID)
                    }
                case .expired:
                    return Single.error(AppError.IAPError.expired)
                case .notPurchased:
                    return Single.error(AppError.IAPError.notPurchased)
                }
            } else {
                return Single.error(AppError.IAPError.unknown)
            }
            
        case .consumable, .nonconsumable:
            if let purchaseResult = result.1 {
                switch purchaseResult {
                case .notPurchased:
                    return Single.error(AppError.IAPError.notPurchased)
                case .purchased(let item):
                    guard item.productId == product.productID else {
                        return Single.error(AppError.IAPError.invalidProductID)
                    }
                }
            } else {
                return Single.error(AppError.IAPError.unknown)
            }
        }
        return Single.just(())
    }
    
    /// 验证收据, 指定要验证的产品，如果成功 得到成功事件，如果失败得到错误事件
    public func verifyReceipt(product: AppStoreProducts) -> Single<Void> {
        return verifyReceipt(product: product)
            .flatMap { self.checkVerifyResult(product: product, result: $0) }
    }
    
    /// 验证收据, 指定要验证的产品，返回验证临时结果
    private func verifyReceipt(product: AppStoreProducts) -> Single<(VerifySubscriptionResult?,VerifyPurchaseResult?)> {
        return Single<(VerifySubscriptionResult?,VerifyPurchaseResult?)>.create { (single) -> Disposable in
            
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
                        let subscribeResult = SwiftyStoreKit.verifySubscription(ofType: type,
                                                                               productId: product.productID,
                                                                               inReceipt: receipt)
                        single(.success((subscribeResult, nil)))
                    } else {
                        let purchaseResult = SwiftyStoreKit.verifyPurchase(productId: product.productID, inReceipt: receipt)
                        single(.success((nil, purchaseResult)))
                    }
                case .error(let error):
                    single(.error(error))
                }
            }
            
            return Disposables.create()
        }
    }
}

extension InterAppPaymentService {
    func dealSKError(_ error: SKError) {
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
