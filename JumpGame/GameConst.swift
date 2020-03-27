//
//  GameConst.swift
//  JumpGame
//
//  Created by lei wang on 2020/3/23.
//  Copyright © 2020 lei wang. All rights reserved.
//

import Foundation
import CoreGraphics

enum Game {
    struct NodeName {
        private init() {}
        
        static let land = "land"
        static let sky = "sky"
        static let pipeUp = "PipeDown"
        static let pipeDown = "PipeUp"
        static let birdState1 = "bat-1"
        
        static let scoreboard = "scoreboard"
    }
    
    struct NodeSize {
        private init() {}
        
        static let pipeWidth: CGFloat = 60
        static let floorRatio: CGFloat = 1242 / 363
        static let skyRatio: CGFloat = 1242 / 877
        static let pipeRatio: CGFloat = 299 / 848
    }
    
    struct Key {
        private init() {}
        
        static let createPipeAction = "createPipe"
        static let pipeName = "pipe"
    }
    
    struct Category {
        private init() {}
        
        static let bird: UInt32 = 0x1 << 0
        static let pipe: UInt32 = 0x1 << 1
        static let floor: UInt32 = 0x1 << 2
    }
    
    struct ZPosition {
        private init() {}

        static let sky: CGFloat = -2
        static let pipe: CGFloat = -1
        static let character: CGFloat = -1
        static let score: CGFloat = 1
        static let result: CGFloat = 2
        static let resultText: CGFloat = 3
    }
    
    struct FontName {
        private init() {}
        
        static let score = "MarkerFelt-Wide"
    }
    
    struct Sound {
        private init() {}
        
        static let bgName = "bg"
        static let bgFormat = "mp3"
        
        static let score = "score.mp3"
        static let gameOver = "gameOver.mp3"
    }
}
