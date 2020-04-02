//
//  URL+Additions.swift
//  WhoTapFast
//
//  Created by JackSen on 2020/3/22.
//  Copyright © 2020 JackSen. All rights reserved.
//

import Foundation

extension URL {
    func addSchemeIfNeeded(_ newScheme: String = "https") -> URL {
        let urlString = self.absoluteString
        if let oldScheme = self.scheme {
            guard oldScheme != newScheme else { return self }

            let filterRange = urlString.range(of: oldScheme)
            let newURLString = urlString.replacingOccurrences(of: oldScheme,
                                                              with: newScheme,
                                                              options: [],
                                                              range: filterRange)
            return URL(string: newURLString) ?? self
        }
        let newURLString = String(format: "%@://%@", newScheme, urlString)
        return URL(string: newURLString) ?? self
    }
}
