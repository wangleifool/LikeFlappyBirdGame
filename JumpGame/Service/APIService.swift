//
//  APIService.swift
//  WhoTapFast
//
//  Created by JackSen on 2020/3/20.
//  Copyright © 2020 JackSen. All rights reserved.
//

import Foundation
import Moya

struct APIService {

    private static let manager: Manager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.httpAdditionalHeaders = Manager.defaultHTTPHeaders
        let mgr = Manager.default
        mgr.startRequestsImmediately = false
        return mgr
    }()

    private static let endpoint = { (multiTarget: MultiTarget) -> Endpoint in
        let endpoint = MoyaProvider<MultiTarget>.defaultEndpointMapping(for: multiTarget)
        return endpoint
    }

//    private static let requestClosure = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
//        do {
//            var request = try endpoint.urlRequest()
//            let hash = UserDefaults.standard.value(forKey: quickHashKey) as? String ?? "b94e3ab0df9c37f95a01818c9102f433019d29090a3c3a70969f5afdcedeb128"
//            print("[HASH]: \(hash)")
//            let requestURL = request.url?.absoluteString.replacingOccurrences(of: quickHashKey, with: hash) ?? ""
//            if let newURL = URL(string: requestURL) {
//                request.url = newURL
//                done(.success(request))
//            } else {
//                done(.failure(MoyaError.requestMapping(requestURL)))
//            }
//
//        } catch {
//            done(.failure(MoyaError.underlying(error, nil)))
//        }
//    }
//
//    private let provider = MoyaProvider<MultiTarget>(endpointClosure: endpoint,
//                                                     requestClosure: requestClosure,
//                                                     manager: manager)

    private let provider = MoyaProvider<MultiTarget>(endpointClosure: endpoint,
                                                     manager: manager)

    init() {
        let urlCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        URLCache.shared = urlCache
    }

    public func request<Traget: TargetType>(target: Traget) -> PrimitiveSequence<SingleTrait, Moya.Response> {
        let multiTarget = MultiTarget(target)
        return self.provider.rx.request(multiTarget)
            .filterSuccessfulStatusCodes()
            .flatMapAppError()
    }

    public func request<Target: TargetType, Element: Decodable>(target: Target,
                                                                element: Element.Type) ->
        PrimitiveSequence<SingleTrait, Element> {
        return self.request(target: target)
            .map(Element.self)
    }
}

struct APIErrorResponse: Decodable {
    var status: Int?
    var error: String?
    var type: String?

    var isFailed: Bool {
        return (error != nil)
    }
}

extension APIService {
    func requestAppVersion() -> Single<AppVersion> {
        return request(target: APITarget.appVersion, element: AppVersion.self)
    }
}
