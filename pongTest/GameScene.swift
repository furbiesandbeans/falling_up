//
//  GameScene.swift
//  pongTest
//
//  Created by Erick Franco on 5/22/15.
//  Copyright (c) 2015 Erick Franco. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Ball   : UInt32 = 0b1       // 1
    static let Screen : UInt32 = 0b10      // 2
    static let Brick  : UInt32 = 0b100     // 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var ball: SKSpriteNode!
    var screen: SKSpriteNode!
    var player: SKSpriteNode!
    var wallSpeed: CGFloat = 20
    var xVelocity: CGFloat = 200
    var yVelocity: CGFloat = 200
    var brickWallFrequency: CFTimeInterval = 0.8 // How often to create the wall
    var lastTime: CFTimeInterval = 0.0
    var score: Int = 0
    var startTime: CFTimeInterval = 0.0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        self.backgroundColor = UIColor(red: 133, green: 208, blue: 240, alpha: 255)
        
        for var i: Int = 0; i < 2 ; i++ {
            let bg = SKSpriteNode(imageNamed: "Background")
            bg.name = "Bg"
            bg.anchorPoint = CGPointZero
            bg.position = CGPointMake(-200, CGFloat(i) * bg.size.height)
            self.addChild(bg)
        }
        
        screen = SKSpriteNode()
        screen.position = CGPoint(x: 0, y: 0)
        screen.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(origin: CGPoint(x:0,y:0), size: self.size))
        screen.physicsBody?.categoryBitMask = PhysicsCategory.Screen
        screen.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        screen.physicsBody?.collisionBitMask = PhysicsCategory.All
        
        ball = SKSpriteNode(imageNamed: "Ball")
        ball.position = CGPoint(x: self.size.width / 2, y: 50.0)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2.0)
        ball.physicsBody?.dynamic = true
        ball.physicsBody?.categoryBitMask = PhysicsCategory.Ball
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.Screen | PhysicsCategory.Brick
        ball.physicsBody?.collisionBitMask = PhysicsCategory.All
        
        let spinningAction = SKAction.rotateByAngle(CGFloat(M_PI), duration: 2)
        ball.runAction(SKAction.repeatActionForever(spinningAction))
    
        let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: "
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = UIColor.blackColor()
        scoreLabel.position = CGPoint(x: size.width/2 - 100, y: size.height - 50.0)
        
        let scoreNumberLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreNumberLabel.name = "Score"
        scoreNumberLabel.text = String(score)
        scoreNumberLabel.fontSize = 20
        scoreNumberLabel.fontColor = UIColor.blackColor()
        scoreNumberLabel.position = CGPoint(x: size.width/2, y: size.height - 50.0)
        
        self.addChild(ball)
        self.addChild(screen)
        self.addChild(scoreLabel)
        self.addChild(scoreNumberLabel)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in (touches as! Set<UITouch>){
            let location = touch.locationInNode(self)
            
            let action = SKAction.moveToX(location.x, duration: 0)
            
            ball.runAction(action)
            
        }
    }
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if startTime == 0.0 { startTime = currentTime }
        if lastTime == 0.0 { lastTime = currentTime }
        
        // Work around for background process
        if currentTime - lastTime > 1 {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, score: score)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        
        ball.physicsBody?.velocity = CGVector(dx:0.0,dy:yVelocity)
        if lastTime + brickWallFrequency < currentTime {
            createBrickWall()
            lastTime = currentTime
        }
        
        if brickWallFrequency > 0.20 {
            brickWallFrequency = brickWallFrequency - 0.0005
        }
        else if (currentTime - startTime) > 30 && brickWallFrequency > 0.05{
            brickWallFrequency = brickWallFrequency - 0.0005
        }
        
        score = Int((currentTime - startTime) * 130)
        
        let scoreLabel = childNodeWithName("Score") as? SKLabelNode
        scoreLabel?.text = String(score)
        
        self.enumerateChildNodesWithName("Bg", usingBlock: {node, stop in
            if let bg = node as? SKSpriteNode {
                bg.position = CGPointMake(bg.position.x, bg.position.y - 6)
                
                if bg.position.y <= -bg.size.height{
                    bg.position = CGPointMake(bg.position.x, bg.position.y + bg.size.height * 2)
                }
            }
            })
        /*
        self.enumerateChildNodesWithName("Wall", usingBlock: {node, stop in
            if let wall: SKSpriteNode = node as? SKSpriteNode {
                // wall.position = CGPointMake(wall.position.x, wall.position.y-self.wallSpeed)
                wall.runAction(SKAction.moveByX(0, y: -self.wallSpeed, duration: 0))
            }
        })
        */
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Ball != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Screen != 0)) {
                ballDidCollideWithWall(contact.contactNormal.dy)
        }


    }
    
    func ballDidCollideWithWall( dy: CGFloat){
        if dy > 0.0 {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, score: score)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }

    
    func createBrickWall(){
       
        let gapSize : CGFloat = ball.size.width+10
        let gapLocation: CGFloat = CGFloat(random() % Int(self.size.width - gapSize))
        let wallTexture = SKTexture(imageNamed: "wallTexture")
        let downAction: SKAction = SKAction.moveByX(0, y: -self.size.height, duration: 1.5)
        
        let leftWall = SKSpriteNode(texture: wallTexture , size: CGSizeMake(gapLocation, 25.0))
        leftWall.name = "Wall"
        leftWall.anchorPoint = CGPointMake(0, 0)
        leftWall.position = CGPointMake(0,self.size.height+20)
        leftWall.physicsBody = SKPhysicsBody(rectangleOfSize: leftWall.size, center: CGPointMake(leftWall.size.width/2, leftWall.size.height/2))
        leftWall.physicsBody?.categoryBitMask = PhysicsCategory.Brick
        leftWall.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        leftWall.physicsBody?.collisionBitMask = PhysicsCategory.None
        leftWall.runAction(SKAction.sequence([downAction,SKAction.removeFromParent()]))
        self.addChild(leftWall)
        
        let rightWall = SKSpriteNode(texture: wallTexture, size: CGSizeMake(self.size.width - gapLocation - gapSize, 25.0))
        rightWall.name = "Wall"
        rightWall.anchorPoint = CGPointMake(0, 0)
        rightWall.position = CGPointMake(gapLocation+gapSize,self.size.height+20)
        rightWall.physicsBody = SKPhysicsBody(rectangleOfSize: rightWall.size, center: CGPointMake(rightWall.size.width/2, rightWall.size.height/2))
        rightWall.physicsBody?.categoryBitMask = PhysicsCategory.Brick
        rightWall.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        rightWall.physicsBody?.collisionBitMask = PhysicsCategory.None
        rightWall.runAction(SKAction.sequence([downAction,SKAction.removeFromParent()]))
        self.addChild(rightWall)
    
    }
}
