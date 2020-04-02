//
//  Rx+Coable.swift
//  WhoTapFast
//
//  Created by JackSen on 2020/3/22.
//  Copyright © 2020 JackSen. All rights reserved.
//

import Foundation
import Moya

extension PrimitiveSequence where Trait == SingleTrait, Element == Moya.Response {
    func map<T: Decodable>(_ type: T.Type, keyPath: String? = nil) -> Single<T> {
        return flatMap({ response -> Single<T> in
            return Single<T>.just(try response.map(type, keyPath: keyPath))
        })
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element == Moya.Response {
    func filterSuccessfulResponse() -> Single<Moya.Response> {
        return flatMap {
            return Single<Moya.Response>.just(try $0.filterSuccessfulResponse())
        }
    }
}

extension ObservableType where E == Response {
    func map<T: Decodable>(_ type: T.Type, keyPath: String? = nil) -> Observable<T> {
        return flatMap({ response -> Observable<T> in
            return Observable<T>.just(try response.map(type, keyPath: keyPath))
        })
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element == Moya.Response {
    func flatMapAppError() -> Single<Element> {
        return catchError({ error -> PrimitiveSequence<Trait, Element> in
            throw AppError.make(error: error)
        })
    }
}
