//
//  LevelUpScene.swift
//  HelloGame
//
//  Created by 김준경 on 2022/06/28.
//

import SpriteKit

class LevelUpScene : SKScene{
    var helloHandler : (()->())?
    
    init(beforeScene : SKScene, size : CGSize, won : Bool) {
        super.init(size: size)
        
        self.backgroundColor = .white
        
        let lblGameOver = SKLabelNode(fontNamed: "Chalkduster")
        lblGameOver.text = "message"
        lblGameOver.fontColor = SKColor.black
        lblGameOver.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        
        self.addChild(lblGameOver)
        
        let retryButton = EasyButton(text: "Retry ?")
        retryButton.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 45)
        retryButton.toggleHandler = {
            [unowned self]  in
            helloHandler?()
            self.view?.presentScene(beforeScene)
        }
        self.addChild(retryButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
