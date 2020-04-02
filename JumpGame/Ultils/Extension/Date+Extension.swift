//
//  Date+Extension.swift
//  WhoTapFast
//
//  Created by JackSen on 2020/3/22.
//  Copyright © 2020 JackSen. All rights reserved.
//

import Foundation

extension Date {
    enum DateFormaType: String {
        case yyyyMd = "yyyy/M/d"
        case yyyyMMdd = "yyyy/MM/dd"
        case md = "M/d"
        case mmdd = "MM/dd"
        case mdHHmm = "M/d HH:mm"
        case yyyyMM = "yyyyMM"
        case yyd = "yy.M"
        case yyyyMMddHHmm = "yyyy/MM/dd HH:mm"
        case yyyyMMddHHmmWithUnit = "yyyy年MM月dd日 HH:mm"
        case yyyyMMddTHHmmss = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        case hhmm = "HH:mm"
        case hmm = "H:mm"
        case yyyyM = "yyyy/M"
    }

    private func makeDateFormatter() -> DateFormatter {
        return DateFormatter.gregorianFormatter
    }

    func string(format: String,
                dateFormatter: DateFormatter = .gregorianFormatter) -> String? {
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

    func string(for formatType: DateFormaType,
                dateFormatter: DateFormatter = .gregorianFormatter) -> String? {
        return self.string(format: formatType.rawValue, dateFormatter: dateFormatter)
    }
}

extension DateFormatter {
    static let gregorianFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        if let identifier = Locale.preferredLanguages.first {
            formatter.locale = Locale(identifier: identifier)
        }
        return formatter
    }()

    static let jpFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()

    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }()
}
