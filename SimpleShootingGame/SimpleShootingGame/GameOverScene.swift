import SpriteKit

class GameOverScene : SKScene{
    init(size : CGSize, won : Bool) {
        super.init(size: size)
        
        self.backgroundColor = .white
        
        let lblGameOver = SKLabelNode(fontNamed: "Chalkduster")
        lblGameOver.text = "Game Over"
        lblGameOver.fontColor = SKColor.black
        lblGameOver.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        
        self.addChild(lblGameOver)
        
        let retryButton = EasyButton(text: "Retry ?")
        retryButton.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 45)
        retryButton.toggleHandler = { [unowned self] in
            run(SKAction.sequence([
                SKAction.run { [weak self] in
                    guard let `self` = self else{return}

                    let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                    let scene = GameScene(size: self.size)

                    self.view?.presentScene(scene, transition: reveal)
                }
            ]))
        }
        self.addChild(retryButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
