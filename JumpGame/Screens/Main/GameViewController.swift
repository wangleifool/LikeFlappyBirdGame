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

class GameViewController: UIViewController {

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
        InterAppPaymentService.shared.purchaseProduct(.tenLifesPerMonth)
//        
//        InterAppPaymentService.shared.verifyReceipt(product: .tenLifesPerMonth)
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
