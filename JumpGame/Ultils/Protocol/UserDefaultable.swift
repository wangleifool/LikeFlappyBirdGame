//
//  UserDefaultable.swift
//  JumpGame
//
//  Created by lei wang on 2020/3/25.
//  Copyright © 2020 lei wang. All rights reserved.
//

import Foundation

protocol KeyNamespaceable {}

extension KeyNamespaceable {
    private static func namespace(_ key: String) -> String {
        return "\(Self.self).\(key)"
    }

    static func namespace<T: RawRepresentable>(_ key: T) -> String where T.RawValue == String {
        return namespace(key.rawValue)
    }

    static func alreadyExist<Key: RawRepresentable>(forKey key: Key) -> Bool where Key.RawValue == String {
        let key: String = self.namespace(key)
        return UserDefaults.standard.object(forKey: key) != nil
    }
}

protocol BoolUserDefaultable: KeyNamespaceable {
    associatedtype BoolDefaultKey: RawRepresentable
}

extension BoolUserDefaultable where BoolDefaultKey.RawValue == String {
    static func set(_ bool: Bool, forKey key: BoolDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(bool, forKey: key)
        UserDefaults.standard.synchronize()
    }

    static func bool(forKey key: BoolDefaultKey) -> Bool {
        let key = namespace(key)
        return UserDefaults.standard.bool(forKey: key)
    }
}

protocol ValueUserDefaultable: KeyNamespaceable {
    associatedtype ValueDefaultKey: RawRepresentable
}

extension ValueUserDefaultable where ValueDefaultKey.RawValue == String {
    static func set(_ value: Any?, forKey key: ValueDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }

    static func value(forKey key: ValueDefaultKey) -> Any? {
        let key = namespace(key)
        return UserDefaults.standard.value(forKey: key)
    }
}

protocol URLUserDefaultable: KeyNamespaceable {
    associatedtype URLDefaultKey: RawRepresentable
}

extension URLUserDefaultable where URLDefaultKey.RawValue == String {
    static func set(_ url: URL?, forKey key: URLDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(url, forKey: key)
        UserDefaults.standard.synchronize()
    }

    static func url(forKey key: URLDefaultKey) -> URL? {
        let key = namespace(key)
        return UserDefaults.standard.url(forKey: key)
    }
}

protocol StringUserDefaultable: KeyNamespaceable {
    associatedtype StringDefaultKey: RawRepresentable
}

extension StringUserDefaultable where StringDefaultKey.RawValue == String {
    static func set(_ string: String?, forKey key: StringDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(string, forKey: key)
        UserDefaults.standard.synchronize()
    }

    static func string(forKey key: StringDefaultKey) -> String? {
        let key = namespace(key)
        return UserDefaults.standard.string(forKey: key)
    }
}

protocol IntUserDefaultable: KeyNamespaceable {
    associatedtype IntDefaultKey: RawRepresentable
}

extension IntUserDefaultable where IntDefaultKey.RawValue == String {
    static func set(_ int: Int, forKey key: IntDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(int, forKey: key)
        UserDefaults.standard.synchronize()
    }

    static func int(forKey key: IntDefaultKey) -> Int {
        let key = namespace(key)
        return UserDefaults.standard.integer(forKey: key)
    }
}
