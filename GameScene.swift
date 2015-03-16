//
//  Game Scene.swift
//  Adventure
//
//  Created by Martin Mumford on 3/5/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}

struct Player
{
    var sprite:CCSprite
    var position:CGPoint
}

class GameScene : CCScene, NetKitDelegate
{
    var netKit:NetKit
    
    var playerPosition:CGPoint
    var playerVelocity:CGPoint
    var interactionAngle:Double
    var interactionPoint:CGPoint
    var positionUpdated:Bool
    var pressing:Bool
    
    var updateCounter:Int
    
    var playerSprite:CCSprite
    
    // Maps the Peer ID string to their sprite
    var otherPlayers = [String:CCSprite]()
    
    let info:DeviceInfo = DeviceInfo.init()
    
    init(displayName:String)
    {
        println("init checkpoint A")
        
        self.netKit = NetKit(displayName:displayName)
        
        self.playerPosition = CGPoint(x:0.0, y:0.0)
        self.playerVelocity = CGPoint(x:0.0, y:0.0)
        self.positionUpdated = false
        self.pressing = false
        self.playerSprite = CCSprite(imageNamed:"UI_Circle.png")
        playerSprite.position = playerPosition
        playerSprite.resizeNode(10.0, y:10.0)
        self.interactionAngle = 0.0
        self.interactionPoint = CGPointMake(CGFloat(0.0), CGFloat(0.0))
        self.updateCounter = 0
        
        super.init()
        
        let random_x_pos_offset = Double(randRange(-10, upper:10))
        let random_y_pos_offset = Double(randRange(-10, upper:10))
        
        let random_x_vel = Double(randRange(-3, upper:3))
        let random_y_vel = Double(randRange(-3, upper:3))
        
        self.playerPosition = CGPoint(x:50.0 + random_x_pos_offset, y:50.0 + random_y_pos_offset)
        self.playerVelocity = CGPoint(x:random_x_vel, y:random_y_vel)
        
        self.addChild(playerSprite)
        
        self.userInteractionEnabled = true
    }
    
    override func onEnter()
    {
        println("onEnter")
        // call this FIRST
        super.onEnter()
        
        netKit.setDelegate(self)
        netKit.startTransceiving(serviceType:"BYOA")
    }
    
    override func onEnterTransitionDidFinish() {
        
        // call this FIRST
        super.onEnterTransitionDidFinish()
    }
    
    override func onExitTransitionDidStart()
    {
        // call this LAST
        super.onExit()
    }
    
    override func onExit()
    {
        // call this LAST
        super.onExit()
    }
    
    override func update(delta: CCTime) {
        
        // Update counter
        
        updateCounter++
        if (updateCounter % 60 == 0)
        {
            updateCounter = 0
        }
        
        // Update velocity
        if (pressing)
        {
            let booster = CGFloat(0.5)
            let unitVector = unitVectorForAngle(angleToPoint(interactionPoint))
            playerVelocity = CGPointMake(CGFloat(playerVelocity.x+(unitVector.x*booster)), CGFloat(playerVelocity.y+(unitVector.y*booster)))
        }
        
        // Apply velocity
        if (fabs(playerVelocity.x) > 0.01 && fabs(playerVelocity.y) > 0.01)
        {
            let resistance = CGFloat(0.98)
            playerVelocity = CGPoint(x:playerVelocity.x*resistance, y:playerVelocity.y*resistance)  // resistence
            playerPosition = CGPoint(x:playerPosition.x + playerVelocity.x, y:playerPosition.y + playerVelocity.y)
            
            positionUpdated = true
        }
        
        // Check bounds
        if (playerPosition.x < 0)
        {
            playerPosition = CGPoint(x:CGFloat(0.0), y:playerPosition.y)
            playerVelocity = CGPoint(x:playerVelocity.x*CGFloat(-1.0), y:playerVelocity.y)
        }
        else if (playerPosition.x > info.view.width)
        {
            playerPosition = CGPoint(x:info.view.width, y:playerPosition.y)
            playerVelocity = CGPoint(x:playerVelocity.x*CGFloat(-1.0), y:playerVelocity.y)
        }
        
        if (playerPosition.y < 0)
        {
            playerPosition = CGPoint(x:playerPosition.x, y:CGFloat(0.0))
            playerVelocity = CGPoint(x:playerVelocity.x, y:playerVelocity.y*CGFloat(-1.0))
        }
        else if (playerPosition.y > info.view.height)
        {
            playerPosition = CGPoint(x:playerPosition.x, y:info.view.height)
            playerVelocity = CGPoint(x:playerVelocity.x, y:playerVelocity.y*CGFloat(-1.0))
        }
        
        // Update the view to reflect the world
        playerSprite.position = playerPosition
        
        // Broadcast any changes to the network
        if (positionUpdated)
        {
            netKit.sendToAllPeers("CHPOS|\(playerPosition.x),\(playerPosition.y)")
            positionUpdated = false
        }
    }
    
    //////////////////////////////
    // Interactivity
    //////////////////////////////
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        pressing = true
        interactionPoint = touch.locationInWorld()
    }
    
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        interactionPoint = touch.locationInWorld()
    }
    
    override func touchCancelled(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        pressing = false
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        pressing = false
    }
    
    func convertUILocToCC(uiTouchLocation:CGPoint) -> CGPoint
    {
        return CGPointMake(uiTouchLocation.x, info.view.height - uiTouchLocation.y)
    }
    
    /////////////////////////
    // NetKit Delegate
    /////////////////////////
    
    func peerDiscovered(peerIDString: String)
    {
        println("PEER DISCOVERED: \(peerIDString)")
    }
    
    func peerRequestFrom(peerIDString: String)
    {
        println("PEER REQUEST FROM: \(peerIDString)")
    }
    
    func peerConnected(peerIDString:String)
    {
        println("PEER CONNECTED: \(peerIDString)")
        // Add their peerID and make a sprite for them
        var newSprite = CCSprite(imageNamed:"UI_Circle.png")
        var newSpritePosition = CGPointMake(CGFloat(10.0), CGFloat(10.0))
        newSprite.position = newSpritePosition
        newSprite.resizeNode(10.0, y:10.0)
        self.addChild(newSprite)
        otherPlayers[peerIDString] = newSprite
    }
    
    func peerConnecting(peerIDString:String)
    {
        println("PEER CONNECTING: \(peerIDString)")
    }
    
    func peerDisconnected(peerIDString:String)
    {
        println("PEER DISCONNECTED: \(peerIDString)")
        if let disconnectedPlayerSprite = otherPlayers[peerIDString]
        {
            self.removeChild(disconnectedPlayerSprite)
            otherPlayers.removeValueForKey(peerIDString)
        }
    }
    
    func receivedDataFromPeer(peerIDString: String, dataString: String) {
        
        let messageComponents = dataString.componentsSeparatedByString("|")
        let messageHeader = messageComponents[0]
        let messageBody = messageComponents[1]
        
        if (messageHeader == "CHPOS")
        {
            let positionComponents = messageBody.componentsSeparatedByString(",")
            let pos_x = CGFloat(positionComponents[0].floatValue)
            let pos_y = CGFloat(positionComponents[1].floatValue)
            
            if let otherPlayerSprite = otherPlayers[peerIDString]
            {
                otherPlayerSprite.position = CGPointMake(pos_x, pos_y)
            }
        }
    }
    
    /////////////////////////
    // Utilities
    /////////////////////////
    
    func randRange (lower:Int , upper:Int) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
    func degreesInRadians(angle:Double) -> Double
    {
        return angle / 180.0 * M_PI
    }
    
    func angleToPoint(point:CGPoint) -> Double
    {
        let delta_x = Double(point.x - playerPosition.x)
        let delta_y = Double(point.y - playerPosition.y)
        
        var angle = Double(atan2(delta_y, delta_x) * 180.0 / M_PI)
        
        if (delta_y < 0)
        {
            angle += 360
        }
        
        return angle
    }
    
    func unitVectorForAngle(angle:Double) -> CGPoint
    {
        return CGPointMake(CGFloat(cosf(Float(degreesInRadians(angle)))), CGFloat(sinf(Float(degreesInRadians(angle)))))
    }
}
