//
//  APIService.swift
//  WhoTapFast
//
//  Created by Shi Li on 2020/3/20.
//  Copyright © 2020 wanglei. All rights reserved.
//

import Foundation
import Moya

enum APITarget {
    case appVersion
}

extension APITarget: TargetType {
    var baseURL: URL {
        var urlString: String
        switch self {
        case .appVersion:
            urlString = "https://materCup.github.io"
        }
        
        guard let url = URL(string: urlString) else {
            fatalError()
        }
        return url
    }

    var path: String {
        switch self {
        case .appVersion:
            return "/appVersion.json"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        var parameters: [String: Any] = [:]
        
        switch self {
        case .appVersion:
            parameters["id"] = "TestJump"
        }
        
        return Task.requestParameters(parameters: parameters,
                                      encoding: URLEncoding.default)
    }

    var headers: [String: String]? {
        return nil
    }
}
