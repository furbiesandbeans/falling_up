//
//  GameOverScene.swift
//  fallingUp
//
//  Created by Erick Franco on 5/23/15.
//  Copyright (c) 2015 Erick Franco. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    var playerScore: Int = 0
    
    init(size: CGSize, score:Int) {
        super.init(size: size)
        
        var highScore: Int = 0
        // load existing high scores or set up an empty array
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] as! String
        let path = documentsDirectory.stringByAppendingPathComponent("HighScore.plist")
        let fileManager = NSFileManager.defaultManager()
        
        // check if file exists
        if !fileManager.fileExistsAtPath(path) {
            // create an empty file if it doesn't exist
            if let bundle = NSBundle.mainBundle().pathForResource("DefaultFile", ofType: "plist") {
                fileManager.copyItemAtPath(bundle, toPath: path, error:nil)
            }
        }
        
        if let rawData = NSData(contentsOfFile: path) {
            // do we get serialized data back from the attempted path?
            // if so, unarchive it into an AnyObject, and then convert to an array of HighScores, if possible
            var scoreData: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithData(rawData);
            highScore = scoreData as! Int;
        }
        
        playerScore = score
        backgroundColor = UIColor(red: 133/255, green: 208/255, blue: 240/255, alpha: 255/255)
        
        if playerScore > highScore {
            highScore = playerScore
            saveHighScore()
            
            let newHighLabel = SKLabelNode(fontNamed: "Chalkduster")
            
            newHighLabel.text = "NEW HIGHSCORE"
            newHighLabel.fontColor = SKColor.blackColor()
            newHighLabel.fontSize = 20
            newHighLabel.position = CGPointMake(size.width/2, size.height - 100)
            
            let growAction = SKAction.scaleBy(2, duration: 1)
            let shrinkAction = SKAction.scaleBy(0.5, duration: 1)
            
            let actionSequence = SKAction.sequence([growAction,shrinkAction])
            
            newHighLabel.runAction(SKAction.repeatActionForever(actionSequence))
            addChild(newHighLabel)
        }
        
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "Game Over!"
        label.fontSize = 40
        label.fontColor = SKColor.blackColor()
        label.position = CGPoint(x: size.width/2, y: size.height/2 + 200)
        addChild(label)

        let playerScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        playerScoreLabel.text = "Your score: " + String(playerScore)
        playerScoreLabel.fontSize = 20
        playerScoreLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 100.0)
        addChild(playerScoreLabel)
        
        let highScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        highScoreLabel.text = "High score: " + String(highScore)
        highScoreLabel.fontSize = 20
        highScoreLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 0.0)
        addChild(highScoreLabel)
        
        let promptLabel = SKLabelNode(fontNamed: "AppleSDGothicNeo-Bold")
        promptLabel.text = "Touch anywhere to play again..."
        promptLabel.fontSize = 20
        promptLabel.position = CGPointMake(size.width/2, 200)
        promptLabel.fontColor = SKColor.blackColor()
        addChild(promptLabel)
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let reveal = SKTransition.flipHorizontalWithDuration(0.5)
        let gameScene = GameScene(size: size)
        self.view?.presentScene(gameScene, transition: reveal)
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func saveHighScore() {

        let saveData = NSKeyedArchiver.archivedDataWithRootObject(playerScore);
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray;
        let documentsDirectory = paths.objectAtIndex(0) as! NSString;
        let path = documentsDirectory.stringByAppendingPathComponent("HighScore.plist");
        
        saveData.writeToFile(path, atomically: true);
        
    }
}