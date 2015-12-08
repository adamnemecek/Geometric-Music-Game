//
//  GameVC.swift
//  Geo
//
//  Created by Rodrigo Leite on 22/10/15.
//  Copyright © 2015 Rodrigo Leite. All rights reserved.
//

import UIKit
import SceneKit
import AVFoundation

class GameVC: UIViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate, AVAudioPlayerDelegate {

    // MARK: CONSTANTS
    let GAME_SCENE = "art.scnassets/game.scn"
    let ASTEROID_SCENE = "art.scnassets/asteroid.scn"
    let BOX_FIELD  = "BoxField"
    let PLAYER = "Player"
    let ENEMY_NAME = "Enemy"
    let CAMERA = "Camera"
    let ENEMY_GAME = "EnemyGame"
    
    // MARK:
    var pathMusic: NSURL?
    var pathMusicName: String?
    
    // MARK: OBJECTS
    var scene   : SCNScene!
    var scnView : SCNView!
    var field   : SCNNode!
    var enemies : [SCNNode]!
    var beatDetector  : BeatDetector!
    var player : SCNNode!
    var camera : SCNNode!
    var asteroid: SCNNode!
    
    var audiokit: AudioKit!
    
    
    // MARK: INITIALIZERS
    func buildScene(){
        self.scene = SCNScene(named: GAME_SCENE)
        self.scnView = self.view as! SCNView
        self.scnView.scene = self.scene
        self.scnView.backgroundColor = UIColor.blackColor()
        self.scnView.delegate = self
        self.scene.physicsWorld.contactDelegate = self
        
        // Retrieve Elements of the scene
        self.field = self.scene!.rootNode.childNodeWithName(BOX_FIELD, recursively: false)
        self.field.physicsBody = SCNPhysicsBody.staticBody()
        self.field.physicsBody?.categoryBitMask = CollisionCategory.FIELD.rawValue
        
        self.enemies = self.scene!.rootNode.childNodesPassingTest({ (node, pointer) -> Bool in node.name == self.ENEMY_NAME })
            .map({ (node) -> SCNNode in
                    node.hidden = true
                    return node })
        
//        self.player = self.scene!.rootNode.childNodeWithName("PLAYER", recursively: true)
        
        self.player = self.scene!.rootNode.childNodeWithName(PLAYER, recursively: false)
//        let playerMaterial = SCNMaterial()
//        let materialPath = NSBundle.mainBundle().pathForResource("art.scnassets/arc170-txt-version-4-d", ofType: "tga")
//        let image = UIImage(contentsOfFile: materialPath!)
//        playerMaterial.diffuse.contents = image
//        self.player.geometry?.materials = [playerMaterial]
        
        
        self.player.physicsBody = SCNPhysicsBody.staticBody()
        self.player.physicsBody?.categoryBitMask = CollisionCategory.PLAYER.rawValue
        self.player.physicsBody?.contactTestBitMask = CollisionCategory.ENEMIE.rawValue
        
        // Animation player
        let animationUp = SCNAction.moveByX(0.0, y: 0.1, z: 0.0, duration: 5)
        let animationDown = SCNAction.moveByX(0.0, y: -0.1, z: 0.0, duration: 5)
        let mix = SCNAction.sequence([animationUp, animationDown])
        self.player.runAction(SCNAction.repeatActionForever(mix))
        
        self.camera = self.scene!.rootNode.childNodeWithName(CAMERA, recursively: false)
        self.camera.physicsBody?.categoryBitMask = CollisionCategory.CAM.rawValue
        
        // Load Asteroid
        let asteroidScene = SCNScene(named: ASTEROID_SCENE)
        self.asteroid = asteroidScene?.rootNode.childNodeWithName("Asteroid", recursively: false)
        
        // Debug variables
        //scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        scnView.debugOptions = .ShowBoundingBoxes
        
        // Run the scene
        self.scnView.playing = true
    }
    
    func buildRecognizers(){
        
        let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: "swipe:")
        swipeGestureRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeGestureRight)
        
        let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: "swipe:")
        swipeGestureLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeGestureLeft)
        
        let swipeGestureUp = UISwipeGestureRecognizer(target: self, action: "swipe:")
        swipeGestureUp.direction = UISwipeGestureRecognizerDirection.Up
        self.view.addGestureRecognizer(swipeGestureUp)
        
        let swipeGestureDown = UISwipeGestureRecognizer(target: self, action: "swipe:")
        swipeGestureDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeGestureDown)
        
    }
    
    func buildSound(){
        
        self.audiokit = AudioKit()
        if self.pathMusicName != nil{
            self.audiokit.loadSound(self.pathMusicName!, path: self.pathMusic, unitEffect: nil, unitTimeEffect: self.audiokit.pinchEffect)
            self.audiokit.playSong(self.pathMusicName!)
        }else{
            self.audiokit.loadSound("dropkick", ext: "mp3", unitEffect: nil, unitTimeEffect: self.audiokit.pinchEffect)
            self.audiokit.playSong("dropkick")
        }
    }
    
    func genEnemies(timer : NSTimer){
        let position = Int(arc4random_uniform(4)) // random position
        let enemiePosition = self.enemies[position]
        let asteroid = self.asteroid.clone()
        asteroid.scale = SCNVector3(x:0.03, y:0.03, z:0.03)
        asteroid.position = enemiePosition.position
        asteroid.position.z = -20
        asteroid.name = ENEMY_GAME
        asteroid.hidden = false
        asteroid.physicsBody = SCNPhysicsBody.kinematicBody()
        asteroid.physicsBody?.categoryBitMask = CollisionCategory.ENEMIE.rawValue
        self.field.addChildNode(asteroid)
    }
    
    // MARK: VC LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.translucent = true
        
        // Load the scene
        self.buildScene()
        self.buildRecognizers()
        self.buildSound()
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "genEnemies:", userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        self.audiokit.clearEngine()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    

    // MARK: SCENEKIT RENDER DELEGATE
    internal func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval){
        
        // Move Geometris
        _ = self.field.childNodes.filter { (node) -> Bool in
                    node.name == ENEMY_GAME
                }.map { (node) -> SCNNode in
                    if node.position.z > 35{
                            node.removeFromParentNode()
                    }
                    node.position.z += self.audiokit.dbPower;
                    return node
                }
    }
    
    // MARK: AVAUDIO DELEGATE
    internal func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool){
        
        
    }
    
    // MARK: Gesture Recognizer
    func swipe(gesture: UISwipeGestureRecognizer){
        
        switch gesture.direction {
            case  UISwipeGestureRecognizerDirection.Up:
                    print("Up")
           
            case  UISwipeGestureRecognizerDirection.Down:
                    print("Down")
            
            case UISwipeGestureRecognizerDirection.Left:
                let action = SCNAction.rotateByAngle(CGFloat(90 * M_PI / 180), aroundAxis: SCNVector3(0.0,0.0,1.0), duration: 0.2)
                self.field.runAction(action)
                
                let actionleft = SCNAction.rotateByAngle(CGFloat(45 * M_PI / 180), aroundAxis: SCNVector3(0.0,0.0,0.5), duration: 0.3)
                let actionleftBack = SCNAction.rotateByAngle(CGFloat(-45 * M_PI / 180), aroundAxis: SCNVector3(0.0,0.0,0.5), duration: 0.3)
                self.player.runAction(SCNAction.sequence([actionleft, actionleftBack]))
            
            case UISwipeGestureRecognizerDirection.Right:
                let action = SCNAction.rotateByAngle(CGFloat(-45 * M_PI / 180), aroundAxis: SCNVector3(0.0,0.0,1.0), duration: 0.2)
                self.field.runAction(action)
            
                let actionRight = SCNAction.rotateByAngle(CGFloat(-45 * M_PI / 180), aroundAxis: SCNVector3(0.0,0.0,0.5), duration: 0.3)
                let actionRightBack = SCNAction.rotateByAngle(CGFloat(45 * M_PI / 180), aroundAxis: SCNVector3(0.0,0.0,0.5), duration: 0.3)
                self.player.runAction(SCNAction.sequence([actionRight, actionRightBack]))

            default:
                print("nothing")
        }
    }
    
    internal func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact){
            //TODO: UPDATE SCORE
        
            print("Begin contact: - \(contact.nodeA.name) : \(contact.nodeB.name)")
            contact.nodeB.removeFromParentNode()
        
    }
    
//    internal func physicsWorld(world: SCNPhysicsWorld, didEndContact contact: SCNPhysicsContact){
//                print("End contant")
//    }

    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
