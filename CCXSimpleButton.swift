//
//  CCXSimpleButton.swift
//  Adventure
//
//  Created by Martin Mumford on 3/6/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class CCXSimpleButton : CCNode
{
    var label:CCLabelTTF
    var visualBounds:CGRect
    var touchBounds:CGRect
    var background:CCSprite?
    
    var text:String
    var enabled:Bool
    
    init(title:String, fontSize:CGFloat)
    {
        self.enabled = true
        self.text = title
        
        self.label = CCLabelTTF(string:title, fontName:"Myriad", fontSize:fontSize)
        label.position = CGPointMake(0, 0)
        
        let touchBuffer:Double = 15
        
        self.visualBounds = CGRectMake(0, 0, label.contentSize.width, label.contentSize.height)
        self.touchBounds = CGRectMake(CGFloat(-touchBuffer/2), CGFloat(-touchBuffer/2), CGFloat(label.contentSize.width + CGFloat(touchBuffer)), CGFloat(label.contentSize.height + CGFloat(touchBuffer)))
        
        super.init()
        
        self.addChild(label)
    }
    
    func enableBackground()
    {
        var background = CCSprite(imageNamed:"UI_Square.png")
        background?.resizeNode(Double(touchBounds.size.width), y: Double(touchBounds.size.height))
        background?.opacity = 0.25
        background?.position = CGPointMake(0, 0)
        self.addChild(background, z:0, name:"background")
    }
    
    func disableBackground()
    {
        self.removeChildByName("background")
    }
}