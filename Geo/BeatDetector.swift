//
//  BeatDetector.swift
//  Touch Music
//
//  Created by Rodrigo Leite on 10/20/15.
//  Copyright © 2015 Kobe. All rights reserved.
//

import UIKit
import AVFoundation

class BeatDetector: NSObject {

    let mMinDecibels : Float!
    let mDecibelResolution: Float!
    let	mScaleFactor: Float!
    let mTable: NSMutableArray!
    var audioPlayer: AVAudioPlayer!
    
    init(inMinDecibels: Float = -80.0, inTableSize: Int = 800, inRoot: Float = 3){
        self.mMinDecibels = inMinDecibels
        self.mDecibelResolution = (self.mMinDecibels / Float(inTableSize - 1))
        self.mScaleFactor = 1.0 / self.mDecibelResolution
        self.mTable = NSMutableArray(capacity: inTableSize)
        
        if inMinDecibels >= 0{
            print("BeatDetector inMinDecibels must be negative")
            return;
        }
        
        let minAmp = BeatDetector.DbToAmp(Double(inMinDecibels))
        let ampRange = 1.0 - minAmp
        let invAmpRange = 1.0 / ampRange
        let rroot = 1.0 / inRoot
        for i in 0..<inTableSize{
            let decibels = Float(i) * mDecibelResolution
            let amp = BeatDetector.DbToAmp(Double(decibels))
            let adjAmp = (amp - minAmp) * invAmpRange
            self.mTable.addObject( pow(Double(adjAmp),Double(rroot)) )
        }
        
    }
    
    func loadMusic(name: String, type: String){
        let audioPath = NSBundle.mainBundle().pathForResource(name, ofType: type)
        let url = NSURL(fileURLWithPath: audioPath!)
        self.audioPlayer = try! AVAudioPlayer(contentsOfURL: url)
        self.audioPlayer.meteringEnabled = true
    }

    func playMusic(){
        self.audioPlayer.play()
    }
    
    func stopMusic(){
        self.audioPlayer.stop()
    }
    
    func powerBpmValue() -> Float{
        var power: Float = 0.0
        var level: Float = 0.0
        
        if self.audioPlayer.playing{
            self.audioPlayer.updateMeters()
            for i in 0..<self.audioPlayer.numberOfChannels{
                power += self.audioPlayer.averagePowerForChannel(i)
            }
            power /= Float(self.audioPlayer.numberOfChannels)
            level = self.valueAt(power)
        }
        return level
    }
    
    func valueAt(inDecibel: Float) -> Float{
        if inDecibel < self.mMinDecibels{
            return 0.0
        }else if inDecibel >= 0.0{
            return 1.0
        }else{
            let index = Int(inDecibel * mScaleFactor)
            return self.mTable.objectAtIndex(index) as! Float
        }
    }

    class func  DbToAmp(inDb: Double) -> Double{
        return pow(10.0, 0.05 * inDb);
    }

}