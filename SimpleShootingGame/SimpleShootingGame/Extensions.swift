//
//  Utility.swift
//  HelloGame
//
//  Created by 김준경 on 2022/04/27.
//

import SpriteKit

let reveal = SKTransition.flipHorizontal(withDuration: 0.5)

class EasyButtonButton : SKSpriteNode{
    init(text : String, backgroundWidth : CGFloat, backgroundHeight : CGFloat, backgroundColor : UIColor? = nil, fontColor : SKColor? = SKColor.black, image : UIImage? = nil) {
        
        super.init(texture: nil, color: backgroundColor ?? UIColor.red, size: CGSize(width: backgroundWidth, height: backgroundHeight))
        
        let lblButton = SKLabelNode(fontNamed: "Chalkduster")
        lblButton.text = text
        if let fontColor = fontColor {
            lblButton.fontColor = fontColor
        }
        
        self.addChild(lblButton)
        
        if let img = image{
            self.texture = SKTexture(image: img)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EasyButton : SKNode{
    var easyButton : EasyButtonButton!
    var toggleHandler : (()->Void)?
    
    init(text : String, backgroundWidth : CGFloat = 0, backgroundHeight : CGFloat = 0, backgroundColor : UIColor? = nil, fontColor : SKColor? = SKColor.black, image : UIImage? = nil){
        super.init()
        
        self.isUserInteractionEnabled = true
        
        self.easyButton = EasyButtonButton(text: text, backgroundWidth: backgroundWidth, backgroundHeight: backgroundHeight
                                           , backgroundColor: backgroundColor,fontColor: fontColor, image: image)
        self.easyButton.zPosition = 0
        addChild(easyButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        //
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("Begin")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        toggleHandler?()
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        toggleHandler?()
    }
}

struct ScreenSize{
    static let width = UIScreen.main.bounds.width
    static let height = UIScreen.main.bounds.height
}

func +(left : CGPoint, right : CGPoint) -> CGPoint{
    return CGPoint(x : left.x + right.x, y : left.y + right.y)
}

func -(left : CGPoint, right : CGPoint) -> CGPoint{
    return CGPoint(x : left.x - right.x, y : left.y - right.y)
}

func *(left : CGPoint, scalar : CGFloat) -> CGPoint{
    return CGPoint(x: left.x * scalar, y : left.y * scalar)
}

func /(left : CGPoint, scalar : CGFloat) -> CGPoint{
    return CGPoint(x : left.x / scalar, y : left.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
func sqrt(a : CGFloat) -> CGFloat{
    return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint{
    
    // get magnitude
    func length() -> CGFloat{
        return sqrt(x*x + y*y)
    }
    
    // 1짜리 Vector로 만들기
    func normalized() -> CGPoint{
        return self / length()
    }
}

func random() -> CGFloat{
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

func random(min : CGFloat, max : CGFloat) -> CGFloat{
    return random() * (max - min) + min
}
