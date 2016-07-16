//
//  PlayScene.swift
//  UndaGame2
//
//  Created by Akhil Karun on 09/07/16.
//  Copyright © 2016 Akhil Karun. All rights reserved.
//

import SpriteKit

class PlayScene: SKScene, SKPhysicsContactDelegate {
    
    
    let runningBar = SKSpriteNode(imageNamed: "bar")
    let hero = SKSpriteNode(imageNamed: "hero")
    let block1 = SKSpriteNode(imageNamed: "block1")
    let block2 = SKSpriteNode(imageNamed: "block2")
    
    
    
    var origRunningBarPosistionX = CGFloat(0)
    var maxBarX = CGFloat(0)
    var groundSpeed = 5
    var heroBaseline = CGFloat(0)
    var onGround = true
    var velocityY = CGFloat(0)
    let gravity = CGFloat(0.6)
    
    var blockMaxX = CGFloat(0)
    var origBLockPositionX = CGFloat(0)
    var scoreText = SKLabelNode(fontNamed: "Chalkduster")
    var score = 0
    
    
    enum CollideType:UInt32{
        case Hero = 1
        case Block = 2
        
    }
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = UIColor(hex: 0x8809FF)
        self.physicsWorld.contactDelegate = self
        
        self.runningBar.anchorPoint = CGPointMake(0, 0.5)
        self.runningBar.position = CGPointMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame))
        
        self.origRunningBarPosistionX = self.runningBar.position.x
        self.maxBarX = self.runningBar.size.width - self.frame.size.width
        self.maxBarX *= -1
        
        self.heroBaseline = self.runningBar.position.y + (self.runningBar.size.height/2) + (self.hero.size.height/2)
        self.hero.position = CGPointMake(CGRectGetMinX(self.frame)+(self.hero.size.width)+(self.hero.size.width/4), self.heroBaseline)
        self.hero.physicsBody = SKPhysicsBody(circleOfRadius: self.hero.size.width/2)
        self.hero.physicsBody?.affectedByGravity = false
        self.hero.physicsBody?.categoryBitMask = CollideType.Hero.rawValue;
        self.hero.physicsBody?.collisionBitMask = CollideType.Block.rawValue;
        
        
        self.block1.position = CGPointMake(CGRectGetMaxX(self.frame) + self.block1.size.width, self.heroBaseline)
        self.block1.physicsBody = SKPhysicsBody(rectangleOfSize: self.block1.size)
        self.block1.physicsBody?.dynamic = false
        self.block1.physicsBody?.categoryBitMask = CollideType.Block.rawValue
        self.block1.physicsBody?.contactTestBitMask = CollideType.Hero.rawValue
        self.block1.physicsBody?.collisionBitMask = CollideType.Hero.rawValue
        
        self.block2.physicsBody = SKPhysicsBody(rectangleOfSize: self.block1.size)
        self.block2.physicsBody?.dynamic = false
        self.block2.physicsBody?.categoryBitMask = CollideType.Block.rawValue
        self.block2.physicsBody?.contactTestBitMask = CollideType.Hero.rawValue
        self.block2.physicsBody?.collisionBitMask = CollideType.Hero.rawValue
        
        
        self.block2.position = CGPointMake(CGRectGetMaxX(self.frame) + self.block2.size.width, self.heroBaseline + (self.block1.size.height/2))
        
        self.origBLockPositionX = self.block1.position.x
        
        self.block1.name = "block1"
        self.block2.name = "block2"
        
        blockStatuses["block1"] = BlockStatus(isRunning: false, timeGapForNextRun:random(), currentInterval: UInt32(0))
        blockStatuses["block2"] = BlockStatus(isRunning: false, timeGapForNextRun:random(), currentInterval: UInt32(0))
        
        self.scoreText.text = "0"
        self.scoreText.fontSize = 42
        self.scoreText.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame))
        
        self.blockMaxX = 0 - self.block1.size.width / 2
        
        self.addChild(self.runningBar)
        self.addChild(self.hero)
        self.addChild(self.block1)
        self.addChild(self.block2)
        self.addChild(self.scoreText)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        died()
        //contact.bodyA.categoryBitMask == ColliderType.Hero.rawValue
    }
    
    func died() {
        if let scene = GameScene(fileNamed: "GameScene"){
let skView = self.view! as SKView
            skView.ignoresSiblingOrder = true
            scene.size = skView.bounds.size
            scene.scaleMode = .AspectFill
            skView.presentScene(scene)
        }
    }
    
    func  random() -> UInt32 {
        let range = UInt32(50)..<UInt32(200)
        return range.startIndex + arc4random_uniform(range.endIndex - range.startIndex + 1)
    }
    
    var blockStatuses:Dictionary<String,BlockStatus> = [:]
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.onGround {
            self.velocityY = -18.0
            self.onGround = false
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.velocityY < -9.0 {
            self.velocityY = -9.0
        }
    }
    
    
    override func update(currentTime: NSTimeInterval) {
        if self.runningBar.position.x <= maxBarX{
            self.runningBar.position.x = self.origRunningBarPosistionX
        }
        
        
        self.velocityY += self.gravity
        self.hero.position.y -= velocityY
        
        if self.hero.position.y < self.heroBaseline{
            self.hero.position.y = self.heroBaseline
            velocityY = 0.0
            self.onGround = true
        }
        
        let degreeRotation = CDouble(self.groundSpeed) * M_PI/180
        
        
        
        self.hero.zRotation -= CGFloat(degreeRotation)
        //move the ground
        runningBar.position.x -= CGFloat(self.groundSpeed)
        
        blockRunner()
    }
    
    func blockRunner(){
        for(block, blockStatus) in self.blockStatuses{
            let thisBlock = self.childNodeWithName(block)
            if blockStatus.shouldRunBlock(){
                blockStatus.timeGapForNextRun = random()
                blockStatus.currentInterval = 0
                blockStatus.isRunning = true
            }
            
          
            
            if blockStatus.isRunning{
                if thisBlock!.position.x > blockMaxX {
                    thisBlock!.position.x -= CGFloat(self.groundSpeed)
                } else{
                    thisBlock?.position.x = self.origBLockPositionX
                    blockStatus.isRunning = false
                    self.score += 1
                    if((self.score % 5) == 0){
                        self.groundSpeed += 1
                    }
                    self.scoreText.text = String(self.score)
                }
            }
            else{
            blockStatus.currentInterval += 1
            }
            
        }
    }
    
}
