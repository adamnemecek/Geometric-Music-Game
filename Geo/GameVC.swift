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
    let BOX_FIELD  = "BoxField"
    let PLAYER = "Player"
    let ENEMY_NAME = "Enemy"
    let CAMERA = "Camera"
    let ENEMY_GAME = "EnemyGame"
    
    // MARK: OBJECTS
    var scene   : SCNScene!
    var scnView : SCNView!
    var field   : SCNNode!
    var enemies : [SCNNode]!
    var beatDetector  : BeatDetector!
    var player : SCNNode!
    var camera : SCNNode!
    
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
        
        self.player = self.scene!.rootNode.childNodeWithName(PLAYER, recursively: false)
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
        
        
        // Debug variables
        //scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        
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
//        self.beatDetector = BeatDetector()
//        self.beatDetector.loadMusic("firestone", type: "mp3")
//        self.beatDetector.audioPlayer.delegate = self
//        self.beatDetector.playMusic()
        
        self.audiokit = AudioKit()
        self.audiokit.loadSound("dropkick", ext: "mp3", unitEffect: nil, unitTimeEffect: self.audiokit.pinchEffect)
        self.audiokit.playSong("dropkick")
        
    }
    
    func buildShaders(){
//        let resource = NSBundle.mainBundle().URLForResource("Outline", withExtension: "shader")!
//        let outline =  try! String(contentsOfURL: resource, encoding: NSUTF8StringEncoding)
//        let resourceTwist = NSBundle.mainBundle().URLForResource("Twisted", withExtension: "shader")!
//        let twisted =  try! String(contentsOfURL: resourceTwist, encoding: NSUTF8StringEncoding)
//        
//        
//        //[SCNShaderModifierEntryPointGeometry:twisted]
//        let shaders =   [SCNShaderModifierEntryPointFragment:outline]
//        
//        let material = SCNMaterial()
//        material.shaderModifiers = shaders
//        self.player.geometry?.materials = [material]
        
        
        
        
//        let program = SCNProgram()
//        let material = SCNMaterial()
//        
//        // Read the vertex shader file and set its content as our vertex shader
//        let vertexShaderPath = NSBundle.mainBundle().pathForResource("Basic", ofType:"vsh")!
//        let vertexShaderAsAString = try!  String(contentsOfFile: vertexShaderPath, encoding: NSUTF8StringEncoding)
//        program.vertexShader = vertexShaderAsAString
//        
//        // Read the fragment shader file and set its content as our fragment shader
//        let fragmentShaderPath = NSBundle.mainBundle().pathForResource("Basic", ofType:"fsh")!
//        let fragmentShaderAsAString = try! String(contentsOfFile: fragmentShaderPath, encoding: NSUTF8StringEncoding)
//        program.fragmentShader = fragmentShaderAsAString
//        
//        // Give a meaning to variables used in the shaders
//        program.setSemantic(SCNGeometrySourceSemanticVertex, forSymbol: "a_position", options: nil)
//        program.setSemantic(SCNModelViewProjectionTransform, forSymbol: "u_viewProjectionTransformMatrix", options: nil)
//        
//        material.program = program
//        self.field.geometry?.materials.append(material)
        
        
    }
    
    
    func genEnemies(timer : NSTimer){
        let position = Int(arc4random_uniform(4)) // random position
        let enemie = self.enemies[position].clone()
        enemie.position.z = -20
        enemie.name = ENEMY_GAME
        enemie.hidden = false
        enemie.physicsBody = SCNPhysicsBody.kinematicBody()
        enemie.physicsBody?.categoryBitMask = CollisionCategory.ENEMIE.rawValue
        enemie.geometry?.firstMaterial?.diffuse.contents = UIColor.RandomColor()
        self.field.addChildNode(enemie)
    }
    
    // MARK: VC LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the scene
        self.buildScene()
        //self.buildShaders()
        self.buildRecognizers()
        self.buildSound()
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "genEnemies:", userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        self.audioEngine.playSong()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    

    // MARK: SCENEKIT RENDER DELEGATE
    internal func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval){
        
        //let bpmPower = self.beatDetector.powerBpmValue()
        
        // Move Geometris
        _ = self.field.childNodes.filter { (node) -> Bool in
                    node.name == ENEMY_GAME
                }.map { (node) -> SCNNode in
                    if node.position.z > 35{
                            node.removeFromParentNode()
                    }
//                    let action = SCNAction.moveBy(SCNVector3(0.0, 0.0, 1.0), duration: NSTimeInterval(bpmPower))
//                    node.runAction(action)
                    node.position.z += 0.1;
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
