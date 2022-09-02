//
//  AnalogJoyStick.swift
//  HelloGame
//
//  Created by 김준경 on 2022/05/07.
//

import SpriteKit

// For Delivery Data to ViewController
struct AnalogJoystickData : CustomStringConvertible{
    var velocity = CGPoint.zero
    var angle = CGFloat(0)
    
    mutating func reset(){
        velocity = CGPoint.zero
        angle = CGFloat(0)
    }
    
    var description: String{
        return "AnalogStickData velocity : \(velocity), angle : \(angle)"
    }
}

class AnalogJoystickComponent : SKSpriteNode{
    private var kvoContext = UInt8(1)
    
    var borderWidth = CGFloat(0){
        didSet {
            redrawTexture()
        }
    }
    var borderColor = UIColor.black{
        didSet{
            redrawTexture()
        }
    }
    
    var image : UIImage?{
        didSet{
            redrawTexture()
        }
    }
    
    var diameter: CGFloat{
        get{
            return max(size.width, size.height)
        }
        set(newSize){
            size = CGSize(width: newSize, height: newSize)
        }
    }
    
    var radius : CGFloat{
        get{
            return diameter / 2
        }
        set(newRadius){
            diameter = newRadius * 2
        }
    }
    
    init(diameter : CGFloat, color : UIColor? = nil, image : UIImage? = nil) {
        super.init(texture: nil, color: color ?? UIColor.black, size: CGSize(width: diameter, height: diameter))
        
        addObserver(self, forKeyPath: "color",options: NSKeyValueObservingOptions.old, context: &kvoContext)
        self.diameter = diameter
        self.image = image
        redrawTexture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserver(self, forKeyPath: "color")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        redrawTexture()
    }
    
    func redrawTexture(){
        guard diameter > 0 else{
            print("Diameter should be more than 0 ")
            texture = nil
            return
        }
        
        if let img = self.image{
            self.texture = SKTexture(image: img)
        }
    }
}


class AnalogJoystickSubstrate : AnalogJoystickComponent
{
    
}

class AnalogJoystickStick : AnalogJoystickComponent
{
    
}

class AnalogJoystick : SKNode{
    var trackingHandler : ((AnalogJoystickData)->())?
    var beginHandler : (()-> Void)?
    var stopHandler : (()-> Void)?
    
    var substrate : AnalogJoystickSubstrate!
    var stick : AnalogJoystickStick!
 
    private var isTracking = false
    private(set) var data = AnalogJoystickData()
    
    var disabled : Bool{
        get{
            return !isUserInteractionEnabled
        }
        set(isDisabled){
            isUserInteractionEnabled = !isDisabled
            
            if isDisabled{
                resetStick()
            }
        }
    }
    
    var diameter : CGFloat{
        get{
            return substrate.diameter
        }
        set(newDiameter){
            stick.diameter += newDiameter - diameter
            substrate.diameter = newDiameter
        }
    }
    
    var radius: CGFloat {
        get {
            return diameter * 0.5
        }
        
        set(newRadius) {
            diameter = newRadius * 2
        }
    }
    
    init(substrate : AnalogJoystickSubstrate, stick : AnalogJoystickStick){
        super.init()
        
        self.substrate = substrate
        self.substrate.zPosition = 0
        addChild(substrate)
        
        self.stick = stick
        self.stick.zPosition = 1
        addChild(stick)
        
        disabled = false
        
        let velocityLoop = CADisplayLink(target: self, selector: #selector(listen))
        velocityLoop.add(to: .current, forMode: .common)
    }
    
    @objc func listen(){
        if isTracking{
            trackingHandler?(data)
        }
    }
    
    convenience init(diameters : (substrate : CGFloat, stick : CGFloat?),
                     colors : (substrate : UIColor?, stick : UIColor?)? = nil,
                     images : (substrate : UIImage?, stick : UIImage?)? = nil) {
        let stickDiameter = diameters.stick ?? diameters.substrate * 0.6
        let jColors = colors ?? (substrate : nil, stick : nil)
        let jImages = images ?? (substrate : nil, stick : nil)
        
        let substate = AnalogJoystickSubstrate(diameter: diameters.substrate, color: jColors.substrate
                                               , image: jImages.substrate)
        let stick = AnalogJoystickStick(diameter: stickDiameter, color: jColors.stick, image: jImages.stick)
        
        self.init(substrate: substate, stick: stick)
    }
    
    convenience init(diameter : CGFloat,
                     colors: (substrate: UIColor?, stick: UIColor?)? = nil,
                     images: (substrate: UIImage?, stick: UIImage?)? = nil) {
        self.init(diameters: (substrate : diameter, stick : nil), colors: colors, images: images)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetStick(){
        self.isTracking = false
        let moveToBack = SKAction.move(to: CGPoint.zero, duration: TimeInterval(0.1))
        self.stick.run(moveToBack)
        data.reset()
        stopHandler?()
    }
}

extension AnalogJoystick{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchFirst = touches.first, stick == atPoint(touchFirst.location(in: self)){
            isTracking = true
            beginHandler?()
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let location = touch.location(in: self)
            
            guard isTracking else{
                return
            }
            
            let maxDistantion = self.substrate.radius
            
            let stickNextPosition = location.length() <= maxDistantion ?
            CGPoint(x: location.x, y: location.y) :
            location.normalized() * maxDistantion
            
            stick.position = stickNextPosition
            
            data = AnalogJoystickData(velocity: stickNextPosition, angle:
                                        -atan2(location.x, location.y))
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetStick()
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetStick()
    }
}
