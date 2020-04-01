//
//  Response+Codable.swift
//  WhoTapFast
//
//  Created by lei wang on 2020/3/22.
//  Copyright © 2020 wanglei. All rights reserved.
//

import Foundation
import Moya

extension Moya.Response {

    func map<T: Decodable>(_ type: T.Type, keyPath: String? = nil) throws -> T {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(type, from: mapJSONData(keyPath: keyPath))
        } catch {
            print("[DEBUG JSON Mapping]: [Model: \(T.self)] \(error)...")
            throw MoyaError.jsonMapping(self)
        }
    }
}

extension Moya.Response {
    func mapJSON() throws -> Any {
        do {
            return try JSONSerialization.jsonObject(with: self.data, options: .allowFragments)
        } catch {
            throw MoyaError.jsonMapping(self)
        }
    }

    private func mapJSONData(keyPath: String?) throws -> Data {
        guard let keyPath = keyPath else {
            return data
        }
        do {
            let json = try mapJSON() as AnyObject
            guard let filterJSON = json.value(forKeyPath: keyPath),
                let filterData = try? JSONSerialization.data(withJSONObject: filterJSON, options: .prettyPrinted) else {
                return data
            }
            return filterData
        } catch {
            throw MoyaError.jsonMapping(self)
        }
    }
}

extension Moya.Response {
    func filterSuccessfulResponse() throws -> Moya.Response {
        if let apiError = try? self.map(APIErrorResponse.self), apiError.isFailed {
            throw AppError.api(response: apiError)
        }

        return self
    }
}
