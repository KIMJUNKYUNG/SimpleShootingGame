//
//  ShootButton.swift
//  HelloGame
//
//  Created by 김준경 on 2022/05/14.
//

import SpriteKit

class ShootButtonButton : SKSpriteNode{
    init(diameter : CGFloat, color : UIColor? = nil, image : UIImage? = nil) {
        super.init(texture: nil, color: color ?? UIColor.black, size: CGSize(width: diameter, height: diameter))
        
        if let img = image{
            self.texture = SKTexture(image: img)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ShootButton : SKNode{
    var shootButton : ShootButtonButton!
    var toggleHandler : (()->Void)?
    
    init(diameter : CGFloat, color : UIColor? = nil, image : UIImage? = nil){
        super.init()
        
        self.isUserInteractionEnabled = true
        
        self.shootButton = ShootButtonButton(diameter: diameter, color: color, image: image)
        self.shootButton.zPosition = 0
        addChild(shootButton)
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

