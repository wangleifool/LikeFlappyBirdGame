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
        static let birdState1 = "bird1"
        static let birdState2 = "bird2"
        
        static let scoreboard = "scoreboard"
    }
    
    struct NodeSize {
        private init() {}
        
        static let pipeWidth: CGFloat = 60
    }
    
    struct Key {
        private init() {}
        
        static let createPipeAction = "createPipe"
        static let pipeName = "pipe"
        static let scoreNodeName = "scoreNode"
    }
    
    struct Category {
        private init() {}
        
        static let bird: UInt32 = 0x1 << 0
        static let pipe: UInt32 = 0x1 << 1
        static let floor: UInt32 = 0x1 << 2
        /// 当玩家通过一次管道，加一次分
        static let score: UInt32 = 0x1 << 3
    }
    
    struct ZPosition {
        private init() {}

        static let sky: CGFloat = -2
        static let pipe: CGFloat = -1
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
