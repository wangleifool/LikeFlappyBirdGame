//
//  GameScene.swift
//  JumpGame
//
//  Created by lei wang on 2020/3/23.
//  Copyright © 2020 lei wang. All rights reserved.
//

import SpriteKit
import GameplayKit

enum GameState {
    case ready
    case running
    case over
}

class GameScene: SKScene {
    
    // 每个地板显示整个屏幕，实际上每次加载两个屏幕的地面，当第一个地面完全移出屏幕，再将其加载到第二个的右边，循环下去
    var floor1: SKSpriteNode!
    var floor2: SKSpriteNode!
    
    var bird: SKSpriteNode!
    var gameState: GameState = .ready
    
    // MARK: - initial the game
    override func didMove(to view: SKView) {
        
        configPhysicalWorld()
        configFloor()
        configBird()
        
        resetGame()
    }
    
    func configPhysicalWorld() {
        self.backgroundColor = SKColor(red: 80.0/255.0,
        green: 192.0/255.0,
        blue: 203.0/255.0,
        alpha: 1.0)
        
        //给场景添加一个物理体，这个物理体就是一条沿着场景四周的边，限制了游戏范围，其他物理体就不会跑出这个场景
        physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
    }
    
    func configFloor() {
        floor1 = SKSpriteNode(imageNamed: Game.NodeName.land)
        floor1.anchorPoint = CGPoint(x: 0, y: 0)
        floor1.position = CGPoint(x: 0, y: 0)
        floor1.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: floor1.size.width, height: floor1.size.height))
        floor1.physicsBody?.categoryBitMask = Game.Category.floor
        addChild(floor1)

        floor2 = SKSpriteNode(imageNamed: Game.NodeName.land)
        floor2.anchorPoint = CGPoint(x: 0, y: 0)
        floor2.position = CGPoint(x: floor1.size.width, y: 0)
        floor2.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: floor2.size.width, height: floor2.size.height))
        floor2.physicsBody?.categoryBitMask = Game.Category.floor
        addChild(floor2)
    }
    
    func configBird() {
        bird = SKSpriteNode(imageNamed: Game.NodeName.birdState1)
        bird.physicsBody = SKPhysicsBody(texture: bird.texture!, size: bird.size)
        bird.physicsBody?.allowsRotation = false
        bird.physicsBody?.categoryBitMask = Game.Category.bird
        bird.physicsBody?.contactTestBitMask = Game.Category.floor | Game.Category.pipe
        addChild(bird)
    }
    
    // MARK: - about bird
    // 开始飞
    func birdStartFly() {

        let flyAction = SKAction.animate(with: [SKTexture(imageNamed: Game.NodeName.birdState1),
                                                SKTexture(imageNamed: Game.NodeName.birdState2),
                                                SKTexture(imageNamed: Game.NodeName.birdState1)],timePerFrame: 0.15)

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
        
        //利用上水管图片创建一个上水管纹理对象
        let topPipe = SKSpriteNode(texture: topTexture, size: topSize)
        
        //利用上水管纹理对象和传入的上水管大小参数创建一个上水管对象
        topPipe.name = Game.Key.pipeName

        //设置上水管的垂直位置为顶部贴着屏幕顶部，水平位置在屏幕右侧之外
        topPipe.position = CGPoint(x: self.size.width + topPipe.size.width * 0.5,
                                   y: self.size.height - topPipe.size.height * 0.5)

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
        let pipeGap = CGFloat(arc4random_uniform(UInt32(bird.size.height))) + bird.size.height * 2.5

        //随机计算顶部pipe的随机高度，这个高度肯定要小于(总的可用高度减去空档的高度)
        let topPipeHeight = CGFloat(arc4random_uniform(UInt32(height - pipeGap)))

        //总可用高度减去空档gap高度减去顶部水管topPipe高度剩下就为底部的bottomPipe高度
        let bottomPipeHeight = height - pipeGap - topPipeHeight

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
        
        removeAllPipesNode()
        bird.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        bird.physicsBody?.isDynamic = false
        birdStartFly()
    }
    
    func startGame() {
        gameState = .running
        bird.physicsBody?.isDynamic = true
        startCreateRandomPipesAction()
    }
    
    func gameOver() {
        gameState = .over
        
        birdStopFly()
        stopCreateRandomPipesAction()
    }
    
    func moveScene() {

        //make floor move
        floor1.position = CGPoint(x: floor1.position.x - 1, y: floor1.position.y)
        floor2.position = CGPoint(x: floor2.position.x - 1, y: floor2.position.y)

        //check floor position
        if floor1.position.x < -floor1.size.width {
            floor1.position = CGPoint(x: floor2.position.x + floor2.size.width, y: floor1.position.y)
        }

        if floor2.position.x < -floor2.size.width {
            floor2.position = CGPoint(x: floor1.position.x + floor1.size.width, y: floor2.position.y)
        }
        
        //循环检查场景的子节点，同时这个子节点的名字要为pipe
        for pipeNode in self.children where pipeNode.name == Game.Key.pipeName {
            
            //因为我们要用到水管的size，但是SKNode没有size属性，所以我们要把它转成SKSpriteNode
            if let pipeSprite = pipeNode as? SKSpriteNode {
                //将水管左移1
                pipeSprite.position = CGPoint(x: pipeSprite.position.x - 1, y: pipeSprite.position.y)

                //检查水管是否完全超出屏幕左侧了，如果是则将它从场景里移除掉
                if pipeSprite.position.x < -pipeSprite.size.width * 0.5 {
                    pipeSprite.removeFromParent()
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
        
        if (bodyA.categoryBitMask == Game.Category.bird && bodyB.categoryBitMask == Game.Category.floor) ||
            (bodyA.categoryBitMask == Game.Category.bird && bodyB.categoryBitMask == Game.Category.pipe) {
            gameOver()
        }
    }
}
