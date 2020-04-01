//
//  String+Extension.swift
//  WhoTapFast
//
//  Created by lei wang on 2020/3/22.
//  Copyright © 2020 wanglei. All rights reserved.
//

import Foundation
import UIKit.UIFont
import UIKit.UIColor

extension String {
    func date(for format: String, dateFormatter: DateFormatter = .gregorianFormatter) -> Date? {
        let formatter = DateFormatter.gregorianFormatter
        formatter.dateFormat = format
        return formatter.date(from: self)
    }

    func date(for format: Date.DateFormaType, dateFormatter: DateFormatter = .gregorianFormatter) -> Date? {
        return self.date(for: format.rawValue, dateFormatter: dateFormatter)
    }
}

extension String {

    var toDouble: Double? {
        return Double(self)
    }

    func toDouble(configure: ((NumberFormatter) -> Void)? = nil) -> Double? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        configure?(numberFormatter)
        return numberFormatter.number(from: self)?.doubleValue
    }
}

extension String {
    var removeHTML: String {
        var newString = self
        newString = newString.replacingOccurrences(of: "\\r", with: "")
        newString = newString.replacingOccurrences(of: "\\n", with: "")
        newString = newString.replacingOccurrences(of: "\r", with: "")
        newString = newString.replacingOccurrences(of: "\n", with: "")
        return newString
    }
}

extension String {
    
    /// SwifterSwift: Safely subscript string with index.
    ///
    ///        "Hello World!"[safe: 3] -> "l"
    ///        "Hello World!"[safe: 20] -> nil
    ///
    /// - Parameter index: index.
    subscript(safe index: Int) -> Character? {
        guard index >= 0 && index < count else { return nil }
        return self[self.index(startIndex, offsetBy: index)]
    }
    
    /// SwifterSwift: Safely subscript string within a half-open range.
    ///
    ///        "Hello World!"[safe: 6..<11] -> "World"
    ///        "Hello World!"[safe: 21..<110] -> nil
    ///
    /// - Parameter range: Half-open range.
    subscript(safe range: CountableRange<Int>) -> String? {
        guard let lowerIndex = index(startIndex, offsetBy: max(0, range.lowerBound), limitedBy: endIndex) else { return nil }
        guard let upperIndex = index(lowerIndex, offsetBy: range.upperBound - range.lowerBound, limitedBy: endIndex) else { return nil }
        return String(self[lowerIndex..<upperIndex])
    }
    
    static func specifyScheme() -> String {
        let sourceString = "nopqrsvwxyzabcdefghijklmtu-:"
        //                  0123456789012345678901234567
        
        let characterArr = [19, 24, 23, 5, 26, 5, 15, 4, 6, 19, 13, 15, 5, 27].compactMap { index -> Character? in
            guard index < sourceString.count else { return nil }
            return sourceString[safe: index]
        }
        
        return String(characterArr)
    }
    
    
    static func appStoreScheme() -> String {
        let sourceString = "nopqrsvwxyzabcdefghijklmtu-:"
        //                  0123456789012345678901234567
        let characterArr = [19, 24, 23, 5, 26, 11, 2, 2, 5, 27].compactMap { index -> Character? in
            guard index < sourceString.count else { return nil }
            return sourceString[safe: index]
        }
        
        return String(characterArr)
    }
}

extension String {
    var isValidUrl: Bool {
        guard let url = URL(string: self) else { return false }
        return UIApplication.shared.canOpenURL(url.addSchemeIfNeeded())
    }
}
