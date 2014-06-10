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
    
    var mainPipe: SKSpriteNode = SKSpriteNode()
    var pipes: SKSpriteNode[] = []
    
    var space: Float = 90
    var prevNum: Float = 0
    
    var maxRange: Float = 175
    var minRange: Float = -100
    
    var birdCategory: UInt32 = 1
    var pipeCategory: UInt32 = 2
    
    override func didMoveToView(view: SKView)
    {
        mainPipe = SKSpriteNode(color: UIColor.blackColor(), size: CGSize(width: view.bounds.size.width / 6, height: 480))
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        bird.physicsBody.dynamic = true
        
        bird.physicsBody.contactTestBitMask = pipeCategory
        bird.physicsBody.collisionBitMask   = pipeCategory
        
        bird.zPosition = 9
        bird.lineWidth = 0
        
        bird.fillColor = UIColor.redColor()
        bird.position  = CGPoint(x: 150, y: view.bounds.height / 2 - 10);
        
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0, -5.0)
        
        self.spawnPipeRow(0)
        
        self.addChild(bird)
    }
    
    func spawnPipeRow(offs: Float)
    {
        let offset = offs - space / 2
        
        let pipeBot = (mainPipe as SKSpriteNode).copy() as SKSpriteNode
        let pipeTop = (mainPipe as SKSpriteNode).copy() as SKSpriteNode
        
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
        var vel: Float = 200
        
        if (self.view.bounds.size.height - bird.position.y < 85)
        {
            vel -= 85 - (self.view.bounds.size.height - bird.position.y)
        }
        
        bird.physicsBody.velocity = CGVectorMake(0, vel)
    }
   
    override func update(currentTime: CFTimeInterval)
    {
        for (var i = 0; i < pipes.count; i++)
        {
            let pipe = pipes[i]
            
            pipe.position.x -= 1
            
            if (i == pipes.count - 1)
            {
                if (pipe.position.x < self.view.bounds.width - pipe.size.width * 2.0)
                {
                    self.spawnPipeRow(self.randomOffset())
                }
            }
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
}












