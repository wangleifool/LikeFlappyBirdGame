//
//  GameViewController.swift
//  JumpGame
//
//  Created by lei wang on 2020/3/23.
//  Copyright © 2020 lei wang. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            
            let scene = GameScene(size: view.bounds.size)
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
                           
            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            #if DEBUG
            view.showsFPS = true
            view.showsNodeCount = true
            #endif
        }
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
