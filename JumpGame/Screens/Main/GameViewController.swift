//
//  GameViewController.swift
//  JumpGame
//
//  Created by JackSen on 2020/3/23.
//  Copyright © 2020 JackSen. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import RxSwift

class GameViewController: UIViewController {

    var disposeBag = DisposeBag()
    
    static func instance() -> GameViewController {
        return GameViewController.initFromStoryboard(name: "Main")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let view = self.view as! SKView? {
//
//            let scene = GameScene(size: view.bounds.size)
//
//            // Set the scale mode to scale to fit the window
//            scene.scaleMode = .aspectFil
//
//            // Present the scene
//            view.presentScene(scene)
//
//            view.ignoresSiblingOrder = true
//
//            #if DEBUG
////            view.showsFPS = true
////            view.showsNodeCount = true
////            view.showsPhysics = true
//            #endif
//        }
        view.backgroundColor = .red
        testIAP()
    }
    
    func testIAP() {
//        InterAppPaymentService.shared.retrieveProductsInfo()
        
//        InterAppPaymentService.shared.verifyReceipt(product: .tenLifesPerMonth)
//        
//        InterAppPaymentService.shared.purchaseProduct(.tenLifesPerMonth)
//        
//        InterAppPaymentService.shared.verifyReceipt(product: .tenLifesPerMonth)
        
        InterAppPaymentService.shared.verifyReceipt(product: .tenLifesPerMonth)
            .subscribe(onSuccess: { _ in
                print("当前在订阅期间")
            }, onError: { error in
                if let iapError = error as? AppError.IAPError {
                    switch iapError {
                    case .expired:
                        print("订阅时间到期了")
                    case .invalidProductID:
                        print("产品ID无效")
                    case .notPurchased:
                        print("还未购买该产品")
                    case .unknown:
                        print("未知错误")
                    default:
                        break
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    func testPurchase() {
        InterAppPaymentService.shared.purchaseAndConfirm(product: .tenLifesPerMonth)
            .subscribe(onSuccess: { _ in
                print("购买成功")
            }, onError: { error in
                if let iapError = error as? AppError.IAPError {
                    switch iapError {
                    case .expired:
                        print("订阅时间到期了")
                    case .invalidProductID:
                        print("产品ID无效")
                    case .notPurchased:
                        print("还未购买该产品")
                    case .unknown:
                        print("未知错误")
                    case .notConnectedToInternet:
                        // 一般这种情况需要特殊处理
                        print("未连接网络")
                    case .cancelled:
                        print("购买被取消")
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
