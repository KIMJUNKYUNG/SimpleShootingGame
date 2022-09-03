//
//  GameSceneViewController.swift
//  HelloGame
//
//  Created by 김준경 on 2022/04/17.
//

import UIKit
import SpriteKit

class GameSceneViewController: ViewController {
        
    lazy var skView: SKView = {
        let view = SKView()
        view.isMultipleTouchEnabled = true
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skView.frame = CGRect(x: 0, y: 0, width: ScreenSize.width, height: ScreenSize.height)

        let scene = GameScene(size : CGSize(width: ScreenSize.width, height: ScreenSize.height))
        scene.scaleMode = .resizeFill
        
        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        
        view.addSubview(skView)
    }
}
