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
    
    private var purchaseBtn: UIButton?
    private var restoreBtn: UIButton?
    private var checkSubscription: UIButton?
    
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
//        testRetieveInfo()
        
        addTestInAppPurchaseUI()
        
    }
    
    func addTestInAppPurchaseUI() {
        let testBtn = UIButton(frame: CGRect(x: 150, y: 100, width: 100, height: 80))
        testBtn.setTitle("Purchase", for: .normal)
        testBtn.setTitleColor(.systemBlue, for: .normal)
        view.addSubview(testBtn)
        self.purchaseBtn = testBtn
        testBtn.rx.tap
            .asDriver()
            .debounce(0.2)
            .drive(onNext: { [weak self] _ in
                self?.testPurchase()
            })
            .disposed(by: disposeBag)
        
        let checkBtn = UIButton(frame: CGRect(x: 150, y: 150, width: 150, height: 80))
        checkBtn.setTitle("Check Subscription", for: .normal)
        checkBtn.setTitleColor(.systemBlue, for: .normal)
        view.addSubview(checkBtn)
        self.checkSubscription = checkBtn
        checkBtn.rx.tap
            .asDriver()
            .debounce(0.2)
            .drive(onNext: { [weak self] _ in
                self?.testVerify()
            })
            .disposed(by: disposeBag)
        
        let restoreBtn = UIButton(frame: CGRect(x: 150, y: 200, width: 150, height: 80))
        restoreBtn.setTitle("restore purchase", for: .normal)
        restoreBtn.setTitleColor(.systemBlue, for: .normal)
        view.addSubview(restoreBtn)
        self.restoreBtn = restoreBtn
        restoreBtn.rx.tap
            .asDriver()
            .debounce(0.2)
            .drive(onNext: { [weak self] _ in
                self?.testRestorePurchase()
            })
            .disposed(by: disposeBag)
    }
    
    func testRetieveInfo() {
        InterAppPaymentService.shared.retrieveProductsInfo([AppStoreProducts.tenLifesPerMonth])
            .subscribe(onSuccess: { (productSet) in
                let product = productSet.first
                print("got product is: \(product?.localizedTitle)")
            }, onError: { error in
                print("got error: \(error.localizedDescription)")
            })
        .disposed(by: disposeBag)
    }
    
    func testVerify() {
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
                    let alert = Alert()
                    alert.show(title: "verify Error",
                        message: iapError.localizedDescription,
                        preferredStyle: .alert,
                        actions: [DefaultAlertAction.ok(nil)],
                        textFieldConfigurationHandlers: [],
                        completion: nil)
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
                    default:
                        break
                    }
                    
                    let alert = Alert()
                    alert.show(title: "Purchase Error",
                        message: iapError.localizedDescription,
                        preferredStyle: .alert,
                        actions: [DefaultAlertAction.ok(nil)],
                        textFieldConfigurationHandlers: [],
                        completion: nil)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func testRestorePurchase() {
        InterAppPaymentService.shared.restorePurchase()
            .subscribe(onSuccess: { (_) in
                let alert = Alert()
                alert.show(title: "",
                           message: "Restore Successful",
                           preferredStyle: .alert,
                           actions: [DefaultAlertAction.ok(nil)],
                           textFieldConfigurationHandlers: [],
                           completion: nil)
            }, onError: { error in
                let alert = Alert()
                alert.show(title: "Restore Error",
                           message: error.localizedDescription,
                           preferredStyle: .alert,
                           actions: [DefaultAlertAction.ok(nil)],
                           textFieldConfigurationHandlers: [],
                           completion: nil)
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
