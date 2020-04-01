//
//  BaseViewController.swift
//  WhoTapFast
//
//  Created by Shi Li on 2020/3/19.
//  Copyright © 2020 wanglei. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class BaseViewController: UIViewController {

    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    deinit {
        print("[DEBUG]: \(String(describing: self.classForCoder)) deinit")
    }

}

extension BaseViewController {
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeLeft
    }
}
