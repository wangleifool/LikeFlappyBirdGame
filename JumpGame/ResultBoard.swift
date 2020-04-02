//
//  ResultBoard.swift
//  JumpGame
//
//  Created by JackSen on 2020/3/25.
//  Copyright © 2020 JackSen. All rights reserved.
//

import SpriteKit

class ResultBoard: SKSpriteNode {
    
    lazy var currentScore: SKLabelNode = {
        let label = SKLabelNode(fontNamed: Game.FontName.score)
        label.zPosition = Game.ZPosition.resultText
        label.fontSize = 16
        label.fontColor = SKColor.darkText
        return label
    }()
    
    lazy var bestScore: SKLabelNode = {
        let label = SKLabelNode(fontNamed: Game.FontName.score)
        label.zPosition = Game.ZPosition.resultText
        label.fontSize = 16
        label.fontColor = SKColor.darkText
        label.text = String(ResultBoard.bestScore())
        return label
    }()
    
    lazy var medal: SKLabelNode = {
        let label = SKLabelNode(fontNamed: Game.FontName.score)
        label.zPosition = Game.ZPosition.resultText
        label.fontSize = 30
        label.fontColor = SKColor.orange
        return label
    }()

    var score: Int = 0 {
        didSet {
            currentScore.text = "\(score)"
            bestScore.text = "\(ResultBoard.bestScore())"
            medal.text = score < 3 ? "C" : (score < 10 ? "B" : (score < 15 ? "A" : "S"))
            ResultBoard.setBestScoreIfPossible(score)
        }
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(score: Int, size: CGSize) {
        let scoreTexture = SKTexture(imageNamed: Game.NodeName.scoreboard)
        scoreTexture.filteringMode = .nearest
        self.init(texture: scoreTexture, color: UIColor.clear, size: size)
        addChild(currentScore)
        addChild(bestScore)
        addChild(medal)
        self.score = score
        
        if UIDevice.isIPhoneX {
            currentScore.position = CGPoint(x: frame.midX + 63, y: frame.midY - 46)
            bestScore.position = CGPoint(x: frame.midX + 63, y: frame.midY - 100)
            medal.position = CGPoint(x: frame.midX - 62, y: frame.midY - 92)
        } else if UIDevice.isIPhoneSE {
            currentScore.position = CGPoint(x: frame.midX + 50, y: frame.midY - 40)
            bestScore.position = CGPoint(x: frame.midX + 50, y: frame.midY - 82)
            medal.position = CGPoint(x: frame.midX - 46, y: frame.midY - 74)
        } else if UIDevice.isIPhone8 {
            currentScore.position = CGPoint(x: frame.midX + 55, y: frame.midY - 46)
            bestScore.position = CGPoint(x: frame.midX + 55, y: frame.midY - 96)
            medal.position = CGPoint(x: frame.midX - 56, y: frame.midY - 84)
        } else {
            currentScore.position = CGPoint(x: frame.midX + 63, y: frame.midY - 46)
            bestScore.position = CGPoint(x: frame.midX + 63, y: frame.midY - 100)
            medal.position = CGPoint(x: frame.midX - 62, y: frame.midY - 92)
        }
    }
}

private extension ResultBoard {
    class func bestScore() -> Int {
        return UserDefaults.App.int(forKey: .bestscore)
    }

    class func setBestScoreIfPossible(_ score: Int) {
        let best = UserDefaults.App.int(forKey: .bestscore)
        if score > best {
            UserDefaults.App.set(score, forKey: .bestscore)
        }
    }
}

