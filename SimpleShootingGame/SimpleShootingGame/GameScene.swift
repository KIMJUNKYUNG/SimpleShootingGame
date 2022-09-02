//
//  GameScene.swift
//  HelloGame
//
//  Created by 김준경 on 2022/04/10.
//

import SpriteKit
import GameController
//
//import GameplayKit
//import Combine
//import ControlGameKit

struct PhysicsCategory{
    static let none : UInt32 = 0
    static let all : UInt32 = UInt32.max
    static let monster : UInt32 = 0b1 // bit가 32개, 1
    static let projectile : UInt32 = 0b10 // 2
}

class GameScene : SKScene
{
    let velocityMultiplier: CGFloat = 0.15
    
    let player = SKSpriteNode(imageNamed: "player")
    var isLeft = false
    
    var monstersDestroyed = 0
    var monsterVelocity = 136.17
//    var mosterHp = Dictionary<SKSpriteNode, Int>()
    var monsters : [SKSpriteNode] = []
    var waveLevel = 1
    
    var shootSpeed = 0.75
    var shootTimer : Timer?
    
    let killScore = SKLabelNode(fontNamed: "Chalkduster")
    let highScore = SKLabelNode(fontNamed: "Chalkduster")
    
    let lblNotify = SKLabelNode(fontNamed: "Chalkduster")
    
    lazy var analogJoystick : AnalogJoystick = {
        let js = AnalogJoystick(diameter: 100, colors: nil,
                                images: (substrate : #imageLiteral(resourceName: "jSubstrate"), stick : #imageLiteral(resourceName: "jStick")))
        
        js.position = CGPoint(x: js.radius + 45,
                              y: js.radius + 45)
        
        js.zPosition = 2
        return js
    }()
    
    lazy var shootButton : ShootButton = {
        let sbtn = ShootButton(diameter: 60, color: nil, image: #imageLiteral(resourceName: "jStick"))
        
        sbtn.position = CGPoint(x: UIScreen.main.bounds.width - 95, y: 95)
        return sbtn
    }()
    
    override init(size : CGSize) {
        super.init(size: size)
        self.initDB()
        self.initEnv()
        self.initLabel()
        self.initPlayer()
        self.initJoystick()
        
        self.startWave(level : waveLevel)
        //self.initAudio()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("D E I N I T !")
    }
}

extension GameScene{
    override func didMove(to view: SKView) {
        self.runWorld()
    }
}

extension GameScene{
    func initJoystick()
    {
        addChild(analogJoystick)
        analogJoystick.trackingHandler = { [unowned self] data in
            
        var actualPosX = self.player.position.x + data.velocity.x * self.velocityMultiplier
        var actualPosY = self.player.position.y + data.velocity.y * self.velocityMultiplier
        
        if actualPosX > ScreenSize.width
        {
            actualPosX = ScreenSize.width
        }
        else if actualPosX < 0
        {
            actualPosX = 0
        }
        
        if actualPosY > ScreenSize.height
        {
            actualPosY = ScreenSize.height
        }
        else if actualPosY < 0
        {
            actualPosY = 0
        }
        
        
        self.player.position = CGPoint(x : actualPosX, y : actualPosY)
            
//            var playerRotation = data.angle
//            if playerRotation > 0{
//                if let img = UIImage(named: "playerLeft"){
//                    self.player.texture = SKTexture(image: img)
//                }
//                playerRotation -= (0.5 * Double.pi)
//                isLeft = true
//            }
//            else{
//                if let img = UIImage(named: "player"){
//                    self.player.texture = SKTexture(image: img)
//                }
//                playerRotation += (0.5 * Double.pi)
//                isLeft = false
//            }
////            print(data.angle)
//            self.player.zRotation = playerRotation
        }
    }
    func initEnv()
    {
//        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.levelUpMonster), userInfo: nil, repeats: true)
        
        self.backgroundColor = SKColor.white
        self.view?.isMultipleTouchEnabled = true
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
    }
    func initPlayer()
    {
        player.position = CGPoint(x: ScreenSize.width / 2, y:  ScreenSize.height / 2 - 45)
        
        self.addChild(player)
    }
    
    func initDB()
    {
        createTable()
        if selectValue(1) == nil{
            insert("0")
        }
    }
    
    func initLabel()
    {
        lblNotify.text = ""
        lblNotify.fontSize = 75
        lblNotify.fontColor = SKColor.black
        lblNotify.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 + 45)
        
        killScore.text = "0"
        killScore.fontSize = 40
        killScore.fontColor = SKColor.black
        killScore.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        
        var dbHighScore = selectValue(1)
        if dbHighScore == nil
        {
            dbHighScore = "0"
        }
        
        highScore.text = "High Score : \(dbHighScore ?? "0")"
        highScore.fontSize = 15
        highScore.fontColor = SKColor.black
        //highScore.horizontalAlignmentMode = .right
        highScore.position = CGPoint(x: self.size.width * 0.75, y: self.size.height * 0.9)
        
        self.addChild(killScore)
        self.addChild(highScore)
        self.addChild(lblNotify)
    }
    
    func initAudio()
    {
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac")
        backgroundMusic.autoplayLooped = true
        
        self.addChild(backgroundMusic)
    }
}

// Utility
extension GameScene{
    func NotifyLabel(text : String)
    {
        lblNotify.text = text
        
        let twinkleDuration = 0.5
        let bright = CGFloat(1)
        let dim = CGFloat(0)
        
        let brighten = SKAction.fadeAlpha(to: bright, duration: 0.5 * twinkleDuration)
        brighten.timingMode = .easeIn
        
        let fade = SKAction.fadeAlpha(to: dim, duration: 0.5 * twinkleDuration)
        fade.timingMode = .easeOut
                                             
        lblNotify.alpha = dim
        lblNotify.speed = 1.2
        
        lblNotify.run(SKAction.repeat(.sequence([brighten, fade]), count: 3))
    }
}

// Stop & Resume
extension GameScene{
    func runWorld()
    {
        startAutoShoot()
        for monster in monsters
        {
            runMonster(monster: monster)
        }
    }
    func stopWorld()
    {
        shootTimer?.invalidate()
        let resetData = AnalogJoystickData()
        analogJoystick.trackingHandler?(resetData)
        for monster in monsters
        {
            monster.removeAllActions()
        }
    }
}

// DB
extension GameScene{
    func updateHighScore(){
        if let beforeHighScore = Int(selectValue(1) ?? "O"){
            if let newScore = Int(self.monstersDestroyed.description){
                if beforeHighScore < newScore{
                    updateTable("1", self.monstersDestroyed.description)
                    self.highScore.text = selectValue(1) ?? "0"
                }
            }
        }
    }
}

// Shoot
extension GameScene{
    func makeProjectile() -> SKSpriteNode
    {
        let projectile = SKSpriteNode(imageNamed: "projectile")

        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width / 2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
        projectile.physicsBody?.usesPreciseCollisionDetection = true

        projectile.position = player.position
        
        return projectile
    }
    
    @objc func shootProjectile()
    {
        let projectile = makeProjectile()
        self.addChild(projectile)
        
        let direction = CGPoint(x: cos(Double(self.player.zRotation)),
                y: sin(Double(self.player.zRotation)))
        
        let shootAmount = direction * 1000

        let destination : CGPoint = shootAmount + projectile.position

        let actionMove = SKAction.move(to: destination, duration: 1.5)
        let actionMoveDone = SKAction.removeFromParent()

        projectile.run(SKAction.sequence(
            [actionMove, actionMoveDone])
        )
    }
                       
    func startAutoShoot()
    {
        if let currentShootTimer = shootTimer{
            if currentShootTimer.isValid{
                currentShootTimer.invalidate()
            }
            shootTimer = Timer.scheduledTimer(timeInterval: self.shootSpeed, target: self, selector: #selector(self.shootProjectile), userInfo: nil, repeats: true)
        }else{
            shootTimer = Timer.scheduledTimer(timeInterval: self.shootSpeed, target: self, selector: #selector(self.shootProjectile), userInfo: nil, repeats: true)
        }
            //        addChild(shootButton)

        
//        shootButton.toggleHandler = { [unowned self] in
    
            //run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
    


            

            // Unit Vector
//            print(self.player.zRotation)
//            let direction = !isLeft ?
//            CGPoint(x: cos(Double(self.player.zRotation)),
//                    y: sin(Double(self.player.zRotation))) :
//            CGPoint(x: -cos(Double(self.player.zRotation)),
//                    y: -sin(Double(self.player.zRotation)))

            // Multiply 1000 to Unit Vetor?
            // enough to off scrren
//            let shootAmount = direction * 1000
//
//            let destination : CGPoint = shootAmount + projectile.position
//
//            let actionMove = SKAction.move(to: destination, duration: 1.5)
//            let actionMoveDone = SKAction.removeFromParent()
//
//            projectile.run(SKAction.sequence(
//                [actionMove, actionMoveDone])
//            )
//        }
    }
}

// Monster
extension GameScene{
    func runMonster(monster : SKSpriteNode)
    {
        let duration = (monster.position.x - self.player.size.width) / self.monsterVelocity
        let actionMove = SKAction.move(
            to: CGPoint(x: -(self.player.size.width), y: monster.position.y),
            duration: TimeInterval(duration)
        )
        
        // monster의 목적지는 -(self.player.size.width)
        // 거리 = 속도 * 시간
        // 시간 = 거리 / 속도
        // 817 / 6 = 136.17
        // velocity = 136.17
        
        let actionMoveDone = SKAction.removeFromParent()
        
        // 게임 끝나는 조건
        let loseAction = SKAction.run { [weak self] in
            guard let `self` = self else { return }
            
            self.updateHighScore()
            
            let gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene,transition: reveal)
        }
        
        monster.run(SKAction.sequence([
            actionMove, loseAction, actionMoveDone])
        )
    }
    
    func addMonster(){
        let monster = SKSpriteNode(imageNamed: "monster")
        
//        mosterHp[monster] = Int.random(in: 0...5)
        
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)
        monster.physicsBody?.isDynamic = true
        monster.physicsBody?.categoryBitMask = PhysicsCategory.monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
        monster.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        
        // 이렇게하면 monster가 짤릴일이 없음
        let actualY = random(
            min : monster.size.height/2,
            max : self.size.height - monster.size.height/2
        )
        
        //let actualY = random(min : 0.0, max : self.size.height)
        
        monster.position = CGPoint(
            x : self.size.width, //+ monster.size.width/2,
            y : actualY
        )
        
        self.addChild(monster)
        runMonster(monster: monster)
        monsters.append(monster)
    }
    
    func genMonster(genCount : Int, genDuration : Double)
    {
        let waveDoneAction = SKAction.run { [weak self] in
                guard let `self` = self else { return }
            
                self.waveLevel += 1
                self.startWave(level: self.waveLevel)
            }
        
        self.run(SKAction.sequence([SKAction.repeat(SKAction.sequence([
            SKAction.run(addMonster),
            SKAction.wait(forDuration: genDuration)]),count : genCount), waveDoneAction]))
    }
    
    func startWave(level : Int)
    {
        NotifyLabel(text: "Wave " + String(waveLevel))
        self.genMonster(genCount: level * 10, genDuration: 1.0 / Double(level))
    }
}

// Crash Check
extension GameScene : SKPhysicsContactDelegate{
    func projectileDidCollideWithMonster(projectile : SKSpriteNode, monster : SKSpriteNode)
    {
        projectile.removeFromParent()
        monster.removeFromParent()
        
        self.monstersDestroyed += 1
        if self.monstersDestroyed % 1 == 0
        {
            stopWorld()
            
            let fade = SKTransition.fade(withDuration: 0.5)
            let levelUpScene = LevelUpScene(beforeScene: self, size: self.size, won: false)
            
            levelUpScene.helloHandler = {
                [unowned self] in
                self.shootSpeed *= 0.5
            }
            self.view?.presentScene(levelUpScene, transition: fade)
        }
        self.killScore.text = self.monstersDestroyed.description
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody : SKPhysicsBody
        var secondBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
            // 0001 & 0001 => 0001, 0001
        if ((firstBody.categoryBitMask == PhysicsCategory.monster) &&
            (secondBody.categoryBitMask == PhysicsCategory.projectile )){
            
            if let monster = firstBody.node as? SKSpriteNode,
               let projectile = secondBody.node as? SKSpriteNode{
                self.projectileDidCollideWithMonster(projectile: monster, monster: projectile)
            }
        }
    }
}