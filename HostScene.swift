import Foundation

class HostScene: CCNode, UITextFieldDelegate
{
    var info:DeviceInfo
    var interfaceUnit:Double
    
    var uiNode:CCNode
    
    // Random Interface Stuff
    var nameField:UITextField
    var textInputHeight:Double
    var chatButton:CCXSimpleButton
    
    override init()
    {
        info = DeviceInfo()
        
        nameField = UITextField()
        
        interfaceUnit = Double(info.view.height/10)
        if (info.category == .kDevice_iPadRetina)
        {
            interfaceUnit = Double(info.view.height/15)
        }
        
        textInputHeight = 0.7
        
        uiNode = CCNode()
        
        chatButton = CCXSimpleButton(title:"Start Chat", fontSize:CGFloat(20.0))
        chatButton.enableBackground()
        chatButton.position = info.center
        uiNode.addChild(chatButton)
        
        // For now, we initialize this as a random display name. Eventually, the user will enter a name.
        let randomNumberString:String = String(Int(arc4random_uniform(100)))
        let displayName:String = "Derp" + randomNumberString
        
        super.init()
        
        userInteractionEnabled = true
    }
    
    override func onEnter()
    {
        // call this FIRST
        super.onEnter()
        
        // Remove obnoxious SpriteBuilder pregenerated scene content
        self.removeAllChildren()
        
        self.addChild(uiNode)
    }
    
    override func onEnterTransitionDidFinish() {
        
        // call this FIRST
        super.onEnterTransitionDidFinish()
        
        addCenteredTextInputWithPlaceHolder("Screen Name", yPercent:(1-textInputHeight), textField:nameField)
    }
    
    override func onExitTransitionDidStart()
    {
        // call this LAST
        super.onExit()
    }
    
    override func onExit()
    {
        nameField.removeFromSuperview()
        
        // call this LAST
        super.onExit()
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Text Field Input
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return false
    }
    
    func getName() -> String
    {
        var name:String = UIDevice.currentDevice().name
        var fieldTextL:String = nameField.text
        
        if let fieldText:String = nameField.text
        {
            name = nameField.text
        }
        
        return name
    }
    
    //////////////////////////////
    // Interactivity
    //////////////////////////////
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        
    }
    
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        
    }
    
    override func touchCancelled(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        let uiTouchLocation:CGPoint = touch.locationInView(touch.view)
        let ccTouchLocation:CGPoint = convertUILocToCC(uiTouchLocation)
        
        let buttonRect:CGRect = CGRectMake(chatButton.touchBounds.origin.x + chatButton.position.x, chatButton.touchBounds.origin.y + chatButton.position.y, chatButton.touchBounds.size.width, chatButton.touchBounds.size.height)
        
        if (chatButton.enabled && CGRectContainsPoint(buttonRect, ccTouchLocation))
        {
            let displayName:String = getName()
            CCDirector.sharedDirector().replaceScene(GameScene(displayName:displayName), withTransition:CCTransition(fadeWithDuration:0.5))
        }
    }
    
    func convertUILocToCC(uiTouchLocation:CGPoint) -> CGPoint
    {
        return CGPointMake(uiTouchLocation.x, info.view.height - uiTouchLocation.y)
    }
    
    //////////////////////////////
    // Interface
    //////////////////////////////
    
    func addCenteredTextInputWithPlaceHolder(placeholder:String, yPercent:Double, textField:UITextField)
    {
        let textInputBoxWidth = interfaceUnit*12
        let textInputBoxHeight = interfaceUnit
        let label_box_buffer = interfaceUnit
        let textBracketWidth = textInputBoxHeight*0.625
        let approximateTotalBoxWidth = textInputBoxWidth + label_box_buffer + textBracketWidth
        let approximateSideWidth = Double((Double(info.view.width) - Double(approximateTotalBoxWidth))/2)
        
        textField.frame = CGRectMake(CGFloat(approximateSideWidth + label_box_buffer), CGFloat(info.view.height*CGFloat(yPercent)), CGFloat(textInputBoxWidth), CGFloat(textInputBoxHeight))
        textField.returnKeyType = UIReturnKeyType.Done
        textField.delegate = self
        textField.textAlignment = NSTextAlignment.Center
        textField.textColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
        textField.font = UIFont(name:"Myriad", size:17.0)
        textField.attributedPlaceholder = NSAttributedString(string:placeholder, attributes:[NSForegroundColorAttributeName:UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.5)])
        
        CCDirector.sharedDirector().view.addSubview(textField)
        
        var inputBoundingBox = boundingBoxForAppleUIRect(textField.frame)
        inputBoundingBox.opacity = 0.0
        uiNode.addChild(inputBoundingBox)
    }
    
    func boundingBoxForAppleUIRect(rect:CGRect) -> CCNode
    {
        var boundingBox:CCNode = CCNode()
        
        let cocosRect:CGRect = cocosRectForAppleUIRect(rect)
        
        let midElementWidth:Double = Double(cocosRect.size.width)
        let boundingBoxHeight:Double = Double(cocosRect.size.height)
        let sideElementWidth:Double = Double(boundingBoxHeight*0.625)
        
        var boundBox_Left:CCSprite = CCSprite(imageNamed:"BoundBox_Side.png")
        boundBox_Left.resizeNode(sideElementWidth, y:boundingBoxHeight)
        boundBox_Left.position = CGPointMake(CGFloat(-1*sideElementWidth/2), CGFloat(-1*boundingBoxHeight/2))
        boundingBox.addChild(boundBox_Left)
        
        var boundBox_Right:CCSprite = CCSprite(imageNamed:"BoundBox_Side.png")
        boundBox_Right.resizeNode(-1*sideElementWidth, y:boundingBoxHeight)
        boundBox_Right.position = CGPointMake(CGFloat(midElementWidth+sideElementWidth/2), CGFloat(-1*boundingBoxHeight/2))
        boundingBox.addChild(boundBox_Right)
        
        var boundBox_Mid:CCSprite = CCSprite(imageNamed:"BoundBox_Mid.png")
        boundBox_Mid.resizeNode(midElementWidth, y:boundingBoxHeight)
        boundBox_Mid.position = CGPointMake(CGFloat(midElementWidth/2), CGFloat(-1*boundingBoxHeight/2))
        boundingBox.addChild(boundBox_Mid)
        
        boundingBox.position = CGPointMake(cocosRect.origin.x, cocosRect.origin.y)
        
        return boundingBox
    }
    
    func cocosRectForAppleUIRect(rect:CGRect) -> CGRect
    {
        return CGRectMake(rect.origin.x, info.view.height - rect.origin.y, rect.size.width, rect.size.height)
    }
    
}