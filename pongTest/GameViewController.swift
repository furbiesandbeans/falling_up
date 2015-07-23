//
//  GameViewController.swift
//  pongTest
//
//  Created by Erick Franco on 5/22/15.
//  Copyright (c) 2015 Erick Franco. All rights reserved.
//
import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        scene.backgroundColor = UIColor.blueColor()
        scene.scaleMode = .ResizeFill
        
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
