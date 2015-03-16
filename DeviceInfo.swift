//
//  DeviceInfo.swift
//  Adventure
//
//  Created by Martin Mumford on 3/5/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

enum deviceCategory
{
    case kDevice_iPhone,
    kDevice_iPhoneRetina,
    kDevice_iPhone5,
    kDevice_iPhone6,
    kDevice_iPhone6plus,
    kDevice_iPad,
    kDevice_iPadRetina,
    kDevice_unknown
}

class DeviceInfo
{
    var view:CGSize
    var center:CGPoint
    var category:deviceCategory?
    
    init()
    {
        let viewSize:CGSize = CCDirector.sharedDirector().viewSize()
        self.view = CGSizeMake(viewSize.width, viewSize.height)
        self.center = CGPointMake(viewSize.width/2, viewSize.height/2)
        self.category = currentDeviceClass()
    }
    
    func windowRectMatchesDimensions(width:Double, height:Double) -> Bool
    {
        let matchesLandscape:Bool = (Double(view.height) == width && Double(view.width) == height)
        let matchesPortrait:Bool = (Double(view.height) == height && Double(view.width) == width)
        
        return (matchesLandscape || matchesPortrait)
    }
    
    func currentDeviceClass() -> deviceCategory
    {
        let greaterPixelDimension:CGFloat = CGFloat(fmaxf(Float(UIScreen.mainScreen().bounds.size.height), Float(UIScreen.mainScreen().bounds.size.width)))
        
        switch greaterPixelDimension
        {
        case 480:
            return ((UIScreen.mainScreen().scale > 1.0) ? .kDevice_iPhoneRetina : .kDevice_iPhone)
        case 568:
            return .kDevice_iPhone5
        case 667:
            return .kDevice_iPhone6
        case 736:
            return .kDevice_iPhone6plus
        case 1024:
            return ((UIScreen.mainScreen().scale > 1.0) ? .kDevice_iPadRetina : .kDevice_iPad)
        default:
            return .kDevice_unknown
        }
    }
}