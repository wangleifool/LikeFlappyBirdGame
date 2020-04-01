//
//  StoryboardInitializable.swift
//  WhoTapFast
//
//  Created by Shi Li on 2020/3/14.
//  Copyright © 2020 wanglei. All rights reserved.
//

import UIKit

public protocol StoryboardInitializable {
    static var storyboardIdenfiter: String { get }
}

extension StoryboardInitializable where Self: UIViewController {

    static func initFromStoryboard(name: String = Self.storyboardIdenfiter) -> Self {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: storyboardIdenfiter) as? Self
        guard let viewController = viewCtrl else {
            fatalError("Couldn't find storyboard file for `\(storyboardIdenfiter)`")
        }
        return viewController
    }

}

extension UIViewController: StoryboardInitializable {
    public static var storyboardIdenfiter: String {
        return String(describing: self)
    }
}
