//
//  Rx+Coable.swift
//  WhoTapFast
//
//  Created by JackSen on 2020/3/22.
//  Copyright © 2020 JackSen. All rights reserved.
//

import Foundation
import Moya

enum AppError: Error {

    enum Network: Error {
        case notConnectedToInternet
        case unknown
        case statusCode(code: Int)
    }
    
    enum IAPError: Error {
        case unknown
        case invalidProductID
        case notPurchased
        case expired
        case notConnectedToInternet
        case cancelled
        
        case restorePurchaseFail
        case nothingCanRestore
    }

    case api(response: APIErrorResponse)
    case net(_ error: Network)
    case generic(_ error: Error)
}

extension AppError {
    static func make(error: Error) -> AppError {
        print("[Error]: \(error) [Request]: \((error as? MoyaError)?.response?.request?.debugDescription ?? "")")
        if let moyaError = error as? MoyaError {
            return AppError.parserMoyaError(moyaError)
        }
        if let appError = error as? AppError {
            return appError
        }
        return AppError.generic(error)
    }
}

extension AppError {
    var title: String? {
        switch self {
        case .api(let response):
            return String(describing: response.status)
        default:
            return ""
        }
    }

    var message: String {
        switch self {
        case .api(let response):
            return response.error ?? ""
        default:
            return "请确认网络情况再进行重试！"
        }
    }
}

extension AppError {
    static func parserMoyaError(_ error: MoyaError) -> AppError {
        switch error {
        case .imageMapping,
             .jsonMapping,
             .stringMapping,
             .objectMapping,
             .encodableMapping,
             .requestMapping,
             .parameterEncoding:
            print("other Error")
            return AppError.net(.unknown)
        case .statusCode(let response):
            return AppError.net(.statusCode(code: response.statusCode))
        case let .underlying(error as NSError, response):
            print("underlying: \(String(describing: response)) \(error)")
            switch URLError.Code(rawValue: error.code) {
            case URLError.notConnectedToInternet,
                 URLError.timedOut,
                 URLError.cannotFindHost,
                 URLError.cannotConnectToHost,
                 URLError.networkConnectionLost:
                return AppError.net(.notConnectedToInternet)
            default:
                return AppError.net(.unknown)
            }
        }
    }
}
