//
//  GameScene.swift
//  JumpGame
//
//  Created by JackSen on 2020/3/23.
//  Copyright © 2020 JackSen. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVKit

enum GameState {
    case ready
    case running
    case over
}

class GameScene: SKScene {
    
    // 每个地板显示整个屏幕，实际上每次加载两个屏幕的地面，当第一个地面完全移出屏幕，再将其加载到第二个的右边，循环下去
    var floor1: SKSpriteNode!
    var floor2: SKSpriteNode!
    
    var skyNode1: SKSpriteNode!
    var skyNode2: SKSpriteNode!
    
    var bird: SKSpriteNode!
    var gameState: GameState = .ready
    
    let scoreAudioAction = SKAction.playSoundFileNamed(Game.Sound.score, waitForCompletion: false)
    let gameOverAudioAction = SKAction.playSoundFileNamed(Game.Sound.gameOver, waitForCompletion: false)
    lazy var gameBgPlayer: AVAudioPlayer? = {
        let player = createAudioPlayer(name: Game.Sound.bgName, type: Game.Sound.bgFormat)
        player?.numberOfLoops = -1
        return player
    }()
    
    lazy var titleLabelNode: SKLabelNode = {
        let titleLbl = SKLabelNode(fontNamed: Game.FontName.title)
        titleLbl.text = "Tap Run Bat"
        titleLbl.fontColor = .darkText
        titleLbl.fontSize = 40
        titleLbl.position = CGPoint(x: frame.midX, y: 7 * self.size.height / 10)
        titleLbl.zPosition = Game.ZPosition.score
        return titleLbl
    }()

    lazy var scoreLabelNode: SKLabelNode = {
        let scoreLbl = SKLabelNode(fontNamed: Game.FontName.score)
        scoreLbl.position = CGPoint(x: frame.midX, y: 4 * self.size.height / 5)
        scoreLbl.zPosition = Game.ZPosition.score
        return scoreLbl
    }()
    
    var score = 0 {
        didSet {
            run(scoreAudioAction)
            scoreLabelNode.text = String(score)
            scoreLabelNode.run(SKAction.sequence([
                SKAction.scale(to: 1.5, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1),
            ]))
        }
    }
    
    lazy var resultNode: ResultBoard = {
        let size = CGSize(width: self.size.width - 64,
                          height: (self.size.width  - 64) / Game.NodeSize.resultBoard)
        let resultNode = ResultBoard(score: score, size: size)
        resultNode.zPosition = Game.ZPosition.result
        resultNode.position = CGPoint(x: self.frame.midX, y: self.frame.height * 3 / 5)
        return resultNode
    }()
    
    // MARK: - initial the game
    override func didMove(to view: SKView) {
        
        self.gameBgPlayer?.play()
        
        configPhysicalWorld()
        configFloor()
        configSky()
        configBird()
        
        resetGame()
    }
    
    func configPhysicalWorld() {
        self.backgroundColor = SKColor(hex: 0x65cb99)
        
        //给场景添加一个物理体，这个物理体就是一条沿着场景四周的边，限制了游戏范围，其他物理体就不会跑出这个场景
        physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
    }
    
    func configSky() {
        let texture = SKTexture(imageNamed: Game.NodeName.sky)
        let size = CGSize(width: self.size.width, height: self.size.width / Game.NodeSize.skyRatio)
        skyNode1 = SKSpriteNode(texture: texture, size: size)
        skyNode1.anchorPoint = .zero
        skyNode1.position = CGPoint(x: 0, y: floor1.size.height)
        skyNode1.zPosition = Game.ZPosition.sky
        addChild(skyNode1)
        
        skyNode2 = SKSpriteNode(texture: texture, size: size)
        skyNode2.anchorPoint = .zero
        skyNode2.position = CGPoint(x: skyNode1.size.width, y: floor1.size.height)
        skyNode2.zPosition = Game.ZPosition.sky
        addChild(skyNode2)
    }
    
    func configFloor() {
        let floorTexture = SKTexture(imageNamed: Game.NodeName.land)
//        floor1 = SKSpriteNode(imageNamed: Game.NodeName.land)
        let size = CGSize(width: self.size.width, height: self.size.width / Game.NodeSize.floorRatio)
        floor1 = SKSpriteNode(texture: floorTexture, size: size)
        floor1.anchorPoint = CGPoint(x: 0, y: 0)
        floor1.position = .zero
        floor1.zPosition = Game.ZPosition.sky
        floor1.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: floor1.size.width, height: floor1.size.height))
        floor1.physicsBody?.categoryBitMask = Game.Category.floor
        addChild(floor1)

//        floor2 = SKSpriteNode(imageNamed: Game.NodeName.land)
        floor2 = SKSpriteNode(texture: floorTexture, size: size)
        floor2.anchorPoint = CGPoint(x: 0, y: 0)
        floor2.position = CGPoint(x: floor1.size.width, y: 0)
        floor2.zPosition = Game.ZPosition.sky
        floor2.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: floor2.size.width, height: floor2.size.height))
        floor2.physicsBody?.categoryBitMask = Game.Category.floor
        addChild(floor2)
    }
    
    func configBird() {
        bird = SKSpriteNode(imageNamed: Game.NodeName.birdState1)
        bird.setScale(0.5)
        bird.zPosition = Game.ZPosition.character
        bird.physicsBody = SKPhysicsBody(texture: bird.texture!, size: bird.size)
        bird.physicsBody?.allowsRotation = false
        bird.physicsBody?.categoryBitMask = Game.Category.bird
        bird.physicsBody?.contactTestBitMask = Game.Category.floor | Game.Category.pipe
        addChild(bird)
    }
    
    func showTitleBoard() {
        addChild(titleLabelNode)
        titleLabelNode.run(SKAction.sequence([
            SKAction.scale(to: 1.25, duration: 0.2),
            SKAction.scale(to: 0.85, duration: 0.2),
            SKAction.scale(to: 1, duration: 0.2)
        ]))
    }
    
    func hideTitleBoard() {
        titleLabelNode.run(SKAction.scale(to: 0.01, duration: 0.2)) { [weak self] in
            self?.titleLabelNode.removeFromParent()
        }
    }
    
    func showResultBoard() {
        resultNode.score = score
        addChild(resultNode)

        resultNode.run(SKAction.sequence([
            SKAction.scale(to: 1, duration: 0.1),
            SKAction.scale(to: 1.25, duration: 0.1),
        ])) { [weak self] in
            self?.isUserInteractionEnabled = true
        }
    }
    
    func hideResultBoard() {
        resultNode.removeFromParent()
    }
    
    // MARK: - about bird
    // 开始飞
    func birdStartFly() {

        let altas = SKTextureAtlas(named: "bird")
        let textureArray = [1, 2, 3, 4, 5, 1]
            .map { "bat-\($0)" }
            .map { altas.textureNamed($0) }
        
        let flyAction = SKAction.animate(with: textureArray,timePerFrame: 0.1)

        bird.run(SKAction.repeatForever(flyAction), withKey: "fly")

    }

    //停止飞
    func birdStopFly() {
        bird.removeAction(forKey: "fly")
    }
    
    // MARK: - about pipe
    func startCreateRandomPipesAction() {

        //创建一个等待的action,等待时间的平均值为3.5秒，变化范围为1秒
        let waitAct = SKAction.wait(forDuration: 3.5, withRange: 1.0)
            //创建一个产生随机水管的action，这个action实际上就是调用一下我们上面新添加的那个createRandomPipes()方法
        let generatePipeAct = SKAction.run {
            self.createRandomPipes()
        }

        //让场景开始重复循环执行"等待" -> "创建" -> "等待" -> "创建"。。。。。

        //并且给这个循环的动作设置了一个叫做"createPipe"的key来标识它
        run(SKAction.repeatForever(SKAction.sequence([waitAct, generatePipeAct])), withKey: Game.Key.createPipeAction)

    }
    
    func stopCreateRandomPipesAction() {
        self.removeAction(forKey: Game.Key.createPipeAction)
    }

    // 宽度可能不会变，但是高度是随机的
    func addPipes(topSize: CGSize, bottomSize: CGSize) {

        //创建上水管
        let topTexture = SKTexture(imageNamed: Game.NodeName.pipeUp)
        topTexture.filteringMode = .nearest
        
        //利用上水管图片创建一个上水管纹理对象
        let topPipe = SKSpriteNode(texture: topTexture, size: topSize)
        
        //利用上水管纹理对象和传入的上水管大小参数创建一个上水管对象
        topPipe.name = Game.Key.pipeName

        //设置上水管的垂直位置为顶部贴着屏幕顶部，水平位置在屏幕右侧之外
        topPipe.position = CGPoint(x: self.size.width + topPipe.size.width * 0.5,
                                   y: self.size.height - topPipe.size.height * 0.5)
        topPipe.zPosition = Game.ZPosition.pipe

        topPipe.physicsBody = SKPhysicsBody(texture: topTexture, size: topSize)
        topPipe.physicsBody?.isDynamic = false
        topPipe.physicsBody?.categoryBitMask = Game.Category.pipe
        
        //创建下水管，每一句方法都与上面创建上水管的相同意义
        let bottomTexture = SKTexture(imageNamed: Game.NodeName.pipeDown)

        let bottomPipe = SKSpriteNode(texture: bottomTexture, size: bottomSize)

        bottomPipe.name = Game.Key.pipeName
        
        //设置下水管的垂直位置为底部贴着地面的顶部，水平位置在屏幕右侧之外
        bottomPipe.position = CGPoint(x: self.size.width + bottomPipe.size.width * 0.5,
                                      y: self.floor1.size.height + bottomPipe.size.height * 0.5)
        bottomPipe.zPosition = Game.ZPosition.pipe
        bottomPipe.physicsBody = SKPhysicsBody(texture: bottomTexture, size: bottomSize)
        bottomPipe.physicsBody?.isDynamic = false
        bottomPipe.physicsBody?.categoryBitMask = Game.Category.pipe


        //将上下水管添加到场景里
        addChild(topPipe)
        addChild(bottomPipe)
    }
    
    func createRandomPipes() {
        //先计算地板顶部到屏幕顶部的总可用高度
        let height = self.size.height - self.floor1.size.height
        //计算上下管道中间的空档的随机高度，最小为空档高度为2.5倍的小鸟的高度，最大高度为3.5倍的小鸟高度
        let pipeGap = CGFloat(arc4random_uniform(UInt32(bird.size.height))) + bird.size.height * 0.8

        //随机计算顶部pipe的随机高度，这个高度肯定要小于(总的可用高度减去空档的高度)
        var topPipeHeight = CGFloat(arc4random_uniform(UInt32(height - pipeGap)))
        topPipeHeight = topPipeHeight >= 80 ? topPipeHeight : topPipeHeight + 80

        //总可用高度减去空档gap高度减去顶部水管topPipe高度剩下就为底部的bottomPipe高度
        var bottomPipeHeight = height - pipeGap - topPipeHeight
        if bottomPipeHeight < 80 {
            bottomPipeHeight = bottomPipeHeight + 80
            topPipeHeight = height - pipeGap - bottomPipeHeight
        }

        //调用添加水管到场景方法
        addPipes(topSize: CGSize(width: Game.NodeSize.pipeWidth, height: topPipeHeight),
                 bottomSize: CGSize(width: Game.NodeSize.pipeWidth, height: bottomPipeHeight))

    }
    
    func removeAllPipesNode() {
        //循环检查场景的子节点，同时这个子节点的名字要为pipe
        for pipe in self.children where pipe.name == Game.Key.pipeName {
            //将水管这个节点从场景里移除掉
            pipe.removeFromParent()
        }
    }
    
    // MARK: - game logic
    func resetGame() {
        gameState = .ready
        
        showTitleBoard()
        hideResultBoard()
        
        removeAllPipesNode()
        bird.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        bird.physicsBody?.isDynamic = false
        birdStartFly()
    }
    
    func startGame() {
        gameState = .running
        hideTitleBoard()
        score = 0
        addChild(scoreLabelNode)
        bird.physicsBody?.isDynamic = true
        startCreateRandomPipesAction()
    }
    
    func gameOver() {
        gameState = .over
        
        isUserInteractionEnabled = false
        
        scoreLabelNode.removeFromParent()
        run(gameOverAudioAction)
        birdStopFly()
        stopCreateRandomPipesAction()
        
        showResultBoard()
//        resultNode.score = score
//        addChild(resultNode)
//        let finished = SKAction.run {
//            self.isUserInteractionEnabled = true
//        }
//        resultNode.run(SKAction.sequence([
//            SKAction.scale(to: 1, duration: 0.1),
//            SKAction.scale(to: 1.25, duration: 0.1),
//            SKAction.wait(forDuration: 1),
//            finished
//        ]))
    }
    
    func moveScene() {

        //make floor move
        floor1.position = CGPoint(x: floor1.position.x - 1, y: floor1.position.y)
        floor2.position = CGPoint(x: floor2.position.x - 1, y: floor2.position.y)
        skyNode1.position = CGPoint(x: skyNode1.position.x - 1, y: skyNode1.position.y)
        skyNode2.position = CGPoint(x: skyNode2.position.x - 1, y: skyNode2.position.y)

        //check floor position
        if floor1.position.x < -floor1.size.width {
            floor1.position = CGPoint(x: floor2.position.x + floor2.size.width, y: floor1.position.y)
        }

        if floor2.position.x < -floor2.size.width {
            floor2.position = CGPoint(x: floor1.position.x + floor1.size.width, y: floor2.position.y)
        }
        
        // check sky position
        if skyNode1.position.x < -skyNode1.size.width {
            skyNode1.position = CGPoint(x: skyNode2.position.x + skyNode2.size.width, y: skyNode1.position.y)
        }

        if skyNode2.position.x < -skyNode2.size.width {
            skyNode2.position = CGPoint(x: skyNode1.position.x + skyNode1.size.width, y: skyNode2.position.y)
        }
        
        //循环检查场景的子节点，同时这个子节点的名字要为pipe
        var judgeGetScore = false
        for pipeNode in self.children where pipeNode.name == Game.Key.pipeName {
            //因为我们要用到水管的size，但是SKNode没有size属性，所以我们要把它转成SKSpriteNode
            if let pipeSprite = pipeNode as? SKSpriteNode {
                //将水管左移1
                pipeSprite.position = CGPoint(x: pipeSprite.position.x - 1, y: pipeSprite.position.y)

                //检查水管是否完全超出屏幕左侧了，如果是则将它从场景里移除掉
                if pipeSprite.position.x < -pipeSprite.size.width * 0.5 {
                    pipeSprite.removeFromParent()
                }

                let birdPostionX = bird.position.x
                let positionGetScoreX = pipeSprite.position.x + Game.NodeSize.pipeWidth * 0.5
//                print("potion bird: \(birdPostionX), postion get score: \(positionGetScoreX)")
                if !judgeGetScore, Int(birdPostionX) == Int(positionGetScoreX) {
                    judgeGetScore = true
                    score += 1
                }
            }
        }

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameState {
        case .ready:
            startGame()
        case .running:
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10))
        case .over:
            resetGame()
        }
    }
    
    // 页面每一帧会刷新一次
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if gameState == .running {
            moveScene()
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        if gameState != .running { return }

        var bodyA : SKPhysicsBody
        var bodyB : SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            bodyA = contact.bodyA
            bodyB = contact.bodyB
        } else {
            bodyA = contact.bodyB
            bodyB = contact.bodyA
        }
        
        if ((bodyA.categoryBitMask == Game.Category.bird) && (bodyB.categoryBitMask == Game.Category.floor)) ||
            ((bodyA.categoryBitMask == Game.Category.bird) && (bodyB.categoryBitMask == Game.Category.pipe)) {
            gameOver()
        }
    }
}

// MARK: - tools
func createAudioPlayer(name : String, type: String) -> AVAudioPlayer? {
    guard let path = Bundle.main.path(forResource: name,
                                      ofType: type) else {
                                        return nil
    }
    let assetUrl = URL(fileURLWithPath: path)
    let player = try? AVAudioPlayer(contentsOf: assetUrl, fileTypeHint: type)
    player?.prepareToPlay()
    player?.volume = 0.9
    return player
}
