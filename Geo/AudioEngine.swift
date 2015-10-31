//
//  AudioAnalizer.swift
//  Geo
//
//  Created by Rodrigo Leite on 10/30/15.
//  Copyright © 2015 Rodrigo Leite. All rights reserved.
//

import UIKit
import AVFoundation
import Accelerate

class AudioEngine {
    
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    var songPlayerNote: AVAudioPlayerNode!
    var songBuffer: AVAudioPCMBuffer!
    
    init(name: String, ext: String) {
        let path = NSBundle.mainBundle().pathForResource(name, ofType: ext)
        let url = NSURL(fileURLWithPath: path!)
        self.audioEngine = AVAudioEngine()
        self.songPlayerNote = AVAudioPlayerNode()
        self.audioEngine.attachNode(self.songPlayerNote)
        self.audioFile = try! AVAudioFile(forReading: url)
        
        self.songBuffer = AVAudioPCMBuffer(PCMFormat: self.audioFile.processingFormat, frameCapacity: UInt32(self.audioFile.length))
        try! self.audioFile.readIntoBuffer(self.songBuffer)
        self.audioEngine.connect(self.songPlayerNote, to: self.audioEngine.mainMixerNode, format: self.songBuffer.format)

            self.songPlayerNote.scheduleBuffer(self.songBuffer, atTime: nil, options: AVAudioPlayerNodeBufferOptions.InterruptsAtLoop, completionHandler: nil)
//       self.songPlayerNote.scheduleFile(self.audioFile, atTime: nil, completionHandler: nil)
        
        try! self.audioEngine.start()
        self.songPlayerNote.play()
        
        
//        do{
//            self.attachNodes()
//
//            // Allocate Song File
//            self.audioFile = try AVAudioFile(forReading: url)
//            self.songBuffer = AVAudioPCMBuffer(PCMFormat: self.audioFile!.processingFormat, frameCapacity: UInt32(self.audioFile!.length))
//            
//            // Notification
//            NSNotificationCenter.defaultCenter().addObserverForName(AVAudioEngineConfigurationChangeNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { (notification) -> Void in
//                print("Received a \(AVAudioEngineConfigurationChangeNotification) notification!")
//                print("Receive the connection and try again")
//                self.makeEngineConnection()
//                self.starEngine()
//            })
//            
//            // AUDIO SESSION 
//            
//            self.makeEngineConnection()
//            self.starEngine()
//            
//        }catch  {
//            print("Error Load Song file")
//        }
    }
   
    // Create And attachNodes
    func attachNodes(){
        // Allocate AudioEngine
        self.audioEngine = AVAudioEngine()
        
        // Allocate PlayerNodes
        self.songPlayerNote = AVAudioPlayerNode()
        
        // AttachNodes to Engine
        self.audioEngine.attachNode(self.songPlayerNote!)
    }
    
    func makeEngineConnection(){
        let mainMixer = self.audioEngine.mainMixerNode
//        let output = self.audioEngine?.outputNode
        self.audioEngine.connect(self.songPlayerNote, to: mainMixer, format: self.songBuffer.format)
    }
    
    func starEngine(){
        if !self.audioEngine.running{
            do{
                try self.audioEngine.start()
            }catch {
                print("Error to initialize engine")
            }
        }
    }
    
    
    func playSong(){
        if !self.songPlayerNote.playing{
            self.starEngine()
            self.songPlayerNote.scheduleBuffer(self.songBuffer, atTime: nil, options: AVAudioPlayerNodeBufferOptions.Loops, completionHandler: nil)
            self.songPlayerNote.play()
        }else{
            self.songPlayerNote.stop()
        }
    }
    

}
