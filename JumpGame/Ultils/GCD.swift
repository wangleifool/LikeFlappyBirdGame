//
//  GCD.swift
//  WhoTapFast
//
//  Created by Shi Li on 2020/3/19.
//  Copyright © 2020 wanglei. All rights reserved.
//

import Foundation

final class GCD {
    private init() {}

    @inline(__always)
    class func async(_ block: @escaping () -> Void) {
        DispatchQueue.main.async(execute: block)
    }

    @inline(__always)
    class func after(_ milliseconds: Int, block: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(milliseconds), execute: block)
    }

    @inline(__always)
    class func after(sec seconds: Int, block: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(seconds), execute: block)
    }

    @inline(__always)
    class func main(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }
}
