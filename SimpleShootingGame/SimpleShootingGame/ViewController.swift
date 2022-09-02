//
//  ViewController.swift
//  HelloGame
//
//  Created by 김준경 on 2022/04/10.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnExit: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnStartTouched(_ sender: UIButton) {
        let gameSceneVC = GameSceneViewController()
        self.present(gameSceneVC, animated: true)
    }
    @IBAction func btnExitTouched(_ sender: Any) {
        exit(0)
    }
    
    override var prefersStatusBarHidden: Bool {
      return true
    }
}

