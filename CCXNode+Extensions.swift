//
//  CCNode+Extensions.swift
//  Adventure
//
//  Created by Martin Mumford on 3/6/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

extension CCSprite {
    func resizeNode(x:Double, y:Double)
    {
        self.scaleX = Float(x/Double(self.contentSize.width))
        self.scaleY = Float(y/Double(self.contentSize.height))
    }
}