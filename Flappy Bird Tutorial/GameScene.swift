//
//  GameScene.swift
//  Flappy Bird Tutorial
//
//  Created by Connor Christie on 6/9/14.
//  Copyright (c) 2014 Connor Christie. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var bird: SKShapeNode = SKShapeNode(circleOfRadius: 15)
    var overlay: SKSpriteNode = SKSpriteNode()
    
    var scoreLabel: SKLabelNode = SKLabelNode(fontNamed: "System-Bold")
    
    var ground1: SKSpriteNode = SKSpriteNode()
    var ground2: SKSpriteNode = SKSpriteNode()
    
    var background1: SKSpriteNode = SKSpriteNode()
    var background2: SKSpriteNode = SKSpriteNode()
    
    var mainPipe: Pipe = Pipe()
    var pipes: Pipe[] = []
    
    var space: Float = 90
    var prevNum: Float = 0
    
    var maxRange: Float = 175
    var minRange: Float = -100
    
    var birdCategory: UInt32 = 1
    var pipeCategory: UInt32 = 2
    
    var score: Int = 0
    
    var movingSpeed: Float = 3.3
    
    var isMoving: Bool       = false
    var isGroundMoving: Bool = true
    
    override func didMoveToView(view: SKView)
    {
        mainPipe = Pipe(color: UIColor.blackColor(), size: CGSize(width: view.bounds.size.width / 6, height: 480))
        
        overlay = SKSpriteNode(color: UIColor.grayColor(), size: self.view.bounds.size)
        
        overlay.alpha = 0.7
        overlay.zPosition = 11
        
        overlay.position.x += overlay.size.width / 2
        overlay.position.y += overlay.size.height / 2
        
        background1 = SKSpriteNode(imageNamed: "Background")
        background2 = SKSpriteNode(imageNamed: "Background")
        
        background1.position.x = view.bounds.size.width * 0.5
        background2.position.x = view.bounds.size.width * 1.5
        
        background1.position.y = view.bounds.size.height * 0.5
        background2.position.y = view.bounds.size.height * 0.5
        
        background1.texture.filteringMode = SKTextureFilteringMode.Nearest
        background2.texture.filteringMode = SKTextureFilteringMode.Nearest
        
        ground1 = SKSpriteNode(imageNamed: "Ground")
        ground2 = SKSpriteNode(imageNamed: "Ground")
        
        ground1.size.width = view.bounds.size.width + 2
        ground2.size.width = view.bounds.size.width + 2
        
        ground1.position.x = view.bounds.size.width * 0.5
        ground2.position.x = view.bounds.size.width * 1.5
        
        ground1.position.y = ground1.size.height * 0.4
        ground2.position.y = ground2.size.height * 0.4
        
        ground1.physicsBody = SKPhysicsBody(rectangleOfSize: ground1.size)
        ground2.physicsBody = SKPhysicsBody(rectangleOfSize: ground2.size)
        
        ground1.physicsBody.dynamic = false
        ground2.physicsBody.dynamic = false
        
        ground1.zPosition = 10
        ground2.zPosition = 10
        
        ground1.texture.filteringMode = SKTextureFilteringMode.Nearest
        ground2.texture.filteringMode = SKTextureFilteringMode.Nearest
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        bird.physicsBody.dynamic = false
        
        bird.physicsBody.contactTestBitMask = pipeCategory
        bird.physicsBody.collisionBitMask   = pipeCategory
        
        bird.zPosition = 9
        bird.lineWidth = 0
        
        bird.fillColor = UIColor.redColor()
        bird.position  = CGPoint(x: 150, y: view.bounds.height / 2 - 10)
        
        scoreLabel.position.x = 13
        scoreLabel.position.y = view.bounds.height - 50
        
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        
        scoreLabel.hidden = true
        
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0, -5.0)
        
        self.addChild(background1)
        self.addChild(background2)
        
        self.addChild(ground1)
        self.addChild(ground2)
        
        self.addChild(bird)
        self.addChild(scoreLabel)
    }
    
    func spawnPipeRow(offs: Float)
    {
        let offset = offs - space / 2
        
        let pipeBot = mainPipe.copy() as Pipe
        let pipeTop = mainPipe.copy() as Pipe
        
        pipeBot.texture = SKTexture(imageNamed: "BotPipe")
        pipeTop.texture = SKTexture(imageNamed: "TopPipe")
        
        pipeBot.texture.filteringMode = SKTextureFilteringMode.Nearest
        pipeTop.texture.filteringMode = SKTextureFilteringMode.Nearest
        
        pipeBot.isBottom = true
        
        let xx = self.view.bounds.size.width
        
        self.setPositionRelativeBot(pipeBot, x: xx, y: offset)
        self.setPositionRelativeTop(pipeTop, x: xx, y: offset + space)
        
        pipeBot.physicsBody = SKPhysicsBody(rectangleOfSize: pipeBot.size)
        pipeTop.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTop.size)
        
        pipeBot.physicsBody.dynamic = false
        pipeTop.physicsBody.dynamic = false
        
        pipeBot.physicsBody.contactTestBitMask = birdCategory
        pipeTop.physicsBody.contactTestBitMask = birdCategory
        
        pipeBot.physicsBody.collisionBitMask = birdCategory
        pipeTop.physicsBody.collisionBitMask = birdCategory
        
        pipes.append(pipeBot)
        pipes.append(pipeTop)
        
        self.addChild(pipeBot)
        self.addChild(pipeTop)
    }
    
    func setPositionRelativeBot(node: SKSpriteNode, x: Float, y: Float)
    {
        let xx = (Float(node.size.width) / 2) + x
        let yy = Float(self.view.bounds.size.height) / 2 - (Float(node.size.height) / 2) + y
        
        node.position.x = CGFloat(xx)
        node.position.y = CGFloat(yy)
    }
    
    func setPositionRelativeTop(node: SKSpriteNode, x: Float, y: Float)
    {
        let xx = (Float(node.size.width) / 2) + x
        let yy = Float(self.view.bounds.size.height) / 2 + (Float(node.size.height) / 2) + y
        
        node.position.x = CGFloat(xx)
        node.position.y = CGFloat(yy)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        if (!bird.physicsBody.dynamic)
        {
            //First touch
            
            self.spawnPipeRow(0)
            
            bird.physicsBody.dynamic = true
            
            bird.physicsBody.velocity = CGVectorMake(0, 175)
            
            scoreLabel.hidden = false
            
            isMoving = true
        } else if (isMoving)
        {
            var vel: Float = 200
            
            if (self.view.bounds.size.height - bird.position.y < 85)
            {
                vel -= 85 - (self.view.bounds.size.height - bird.position.y)
            }
            
            bird.physicsBody.velocity = CGVectorMake(0, vel)
        } else
        {
            overlay.removeFromParent()
            
            for pi in pipes
            {
                pi.removeFromParent()
            }
            
            pipes.removeAll(keepCapacity: false)
            
            score = 0
            
            bird.physicsBody.dynamic = false
            bird.position = CGPoint(x: 150, y: view.bounds.size.height / 2 - 10)
            
            scoreLabel.hidden = true
            
            isGroundMoving = true
        }
    }
   
    override func update(currentTime: CFTimeInterval)
    {
        if (isGroundMoving)
        {
            ground1.position.x -= movingSpeed
            ground2.position.x -= movingSpeed
            
            if (ground1.position.x <= -self.view.bounds.size.width / 2)
            {
                ground1.position.x = self.view.bounds.size.width * 1.5 - 2
            }
            
            if (ground2.position.x <= -self.view.bounds.size.width / 2)
            {
                ground2.position.x = self.view.bounds.size.width * 1.5 - 2
            }
            
            background1.position.x -= movingSpeed / 3
            background2.position.x -= movingSpeed / 3
            
            if (background1.position.x <= -self.view.bounds.size.width / 2)
            {
                background1.position.x = self.view.bounds.size.width * 1.5 - 2
            }
            
            if (background2.position.x <= -self.view.bounds.size.width / 2)
            {
                background2.position.x = self.view.bounds.size.width * 1.5 - 2
            }
            
            if (isMoving)
            {
                for (var i = 0; i < pipes.count; i++)
                {
                    let pipe = pipes[i]
                    
                    if (pipe.position.x + (pipe.size.width / 2) < 0)
                    {
                        pipe.removeFromParent()
                        
                        continue
                    }
                    
                    if (pipe.position.x + (pipe.size.width / 2) < self.view.bounds.size.width / 2 && pipe.isBottom && !pipe.pointAdded)
                    {
                        score++
                        
                        pipe.pointAdded = true
                    }
                    
                    pipe.position.x -= movingSpeed
                    
                    if (i == pipes.count - 1)
                    {
                        if (pipe.position.x < self.view.bounds.width - pipe.size.width * 2.0)
                        {
                            self.spawnPipeRow(self.randomOffset())
                        }
                    }
                }
                
                scoreLabel.text = "Score: \(score)"
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact!)
    {
        if (isMoving)
        {
            isMoving = false
            isGroundMoving = false
            
            bird.physicsBody.velocity = CGVectorMake(0, 0)
            
            for pi in pipes
            {
                pi.physicsBody = nil
            }
            
            self.addChild(overlay)
        } else
        {
            bird.physicsBody.velocity = CGVectorMake(0, 0)
        }
    }
    
    func randomOffset() -> Float
    {
        let max = maxRange - prevNum
        let min = minRange - prevNum
        
        var rNum:  Float = Float(arc4random() % 61) + 40 //40 - 100
        var rNum1: Float = Float(arc4random() % 31) + 1
        
        if (rNum1 % 2 == 0)
        {
            var tempNum = prevNum + rNum
            
            if (tempNum > maxRange)
            {
                tempNum = maxRange - rNum
            }
            
            rNum = tempNum
        } else
        {
            var tempNum = prevNum - rNum
            
            if (tempNum < minRange)
            {
                tempNum = minRange + rNum
            }
            
            rNum = tempNum
        }
        
        prevNum = rNum
        
        return rNum
    }
    
    class Pipe: SKSpriteNode
    {
        var isBottom: Bool = false
        
        var pointAdded: Bool = false
    }
}














