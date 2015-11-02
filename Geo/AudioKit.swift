//
//  AudioKit.swift
//  Geo
//
//  Created by Rodrigo Leite on 10/31/15.
//  Copyright © 2015 Rodrigo Leite. All rights reserved.
//

import UIKit
import AVFoundation
import Accelerate

/// Manager the sound
class AudioKit: NSObject {

    let engine: AVAudioEngine
    var pinchEffect: AVAudioUnitTimePitch = AVAudioUnitTimePitch()
    var content: [String:AudioComponent]
    
    override init() {
        self.engine = AVAudioEngine()
        self.content = [String:AudioComponent]()
        self.engine.attachNode(self.pinchEffect)
        let mixer = self.engine.mainMixerNode
        
        mixer.installTapOnBus(0, bufferSize: 2048, format: mixer.outputFormatForBus(0)) { (buffer, time) -> Void in
               print( AudioKit.fft(buffer) )
        }
        
        
        super.init()
        NSNotificationCenter.defaultCenter().addObserverForName(AVAudioEngineConfigurationChangeNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { (notification) -> Void in
            print("Received a \(AVAudioEngineConfigurationChangeNotification) notification!")
            print("Receive the connection and try again")
            self.connectionsToEngine()
            self.startEngine()
        })
    }
    
    func attachUnitTime(){
        self.engine.attachNode(self.pinchEffect)
    }
   
    /// Start Engine
    func startEngine(){
        if !self.engine.running{
            do{
                self.engine.prepare()
                try self.engine.start()
             }catch{
                print("Error To Start Engine")
            }
        }
    }
    
    func connectionsToEngine(){
        for (_, value) in self.content{
           value.connectToEngine(self.engine)
        }
    }
    
    
    /// Create PlayerNote - Send here and mixer
    func loadSound(name: String, ext: String, unitEffect: AVAudioUnitEffect?, unitTimeEffect: AVAudioUnitTimeEffect?){
        let path = NSBundle.mainBundle().pathForResource(name, ofType: ext)
        let url = NSURL(fileURLWithPath: path!)
        do{
            let audioFile = try AVAudioFile(forReading: url)
            let audioComponent : AudioComponent
            
            if unitEffect != nil{
                audioComponent = AudioComponent(audioFile: audioFile, unitEffect: unitEffect)
            }else if unitTimeEffect != nil{
                audioComponent = AudioComponent(audioFile: audioFile, timeEffect:unitTimeEffect)
            }else{
                audioComponent = AudioComponent(audioFile: audioFile, unitEffect: nil)
            }
            
            self.content[name] = audioComponent
            self.engine.attachNode(audioComponent.audioPlayerNode)
            audioComponent.connectToEngine(engine)
            self.startEngine()
        }catch{
            print("Error to load song")
        }
    }
    
    // Play Audio
    func playSong(name:String){
        let audioContent = self.content.filter { $0.0 == name}
        if !audioContent.isEmpty{
            let audioComponent = audioContent.first!.1
            if !audioComponent.audioPlayerNode.playing{
                let buffer = audioComponent.audioBuffer
                audioComponent.audioPlayerNode.scheduleBuffer(buffer, atTime: nil, options: AVAudioPlayerNodeBufferOptions.InterruptsAtLoop, completionHandler: nil)
                audioComponent.audioPlayerNode.play()
            }else{
                audioComponent.audioPlayerNode.stop()
            }
        }
    }
    
    func changePitchValue(value: Float) {
        self.pinchEffect.pitch = value
    }
    
  /// Perform FFT
  class func fft(buffer: AVAudioPCMBuffer) -> [Float] {
        
    let log2n = UInt(round(log2(Double( buffer.frameLength ))))
    let bufferSizePOT = Int(1 << log2n)
    
    
    // Set up the transform
    let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))
    // create packed real input
    var realp = [Float](count: bufferSizePOT/2, repeatedValue: 0)
    var imagp = [Float](count: bufferSizePOT/2, repeatedValue: 0)
    var output = DSPSplitComplex(realp: &realp, imagp: &imagp)
    
    vDSP_ctoz(UnsafePointer<DSPComplex>(buffer.floatChannelData.memory), 2, &output, 1, UInt(bufferSizePOT / 2))
    
    // Do the fast Fourier forward transform, packed input to packed output
    vDSP_fft_zrip(fftSetup, &output, 1, log2n, Int32(FFT_FORWARD))
    
    // you can calculate magnitude squared here, with care
    // as the first result is wrong! read up on packed formats
    var fft = [Float](count:Int(bufferSizePOT / 2), repeatedValue:0.0)
    let bufferOver2: vDSP_Length = vDSP_Length(bufferSizePOT / 2)
    vDSP_zvmags(&output, 1, &fft, 1, bufferOver2)

   fft.removeFirst(fft.count / 2)
    var db = [Float](count: fft.count, repeatedValue: 0.0)
    var mean : Float = 1.0
    vDSP_vdbcon(fft, 1, &mean, &db, 1, vDSP_Length(fft.count), 0)
    
    
//    var sqrtFFT = [Float](count: db.count, repeatedValue: 0.0)
//    vvsqrtf(&sqrtFFT, db, [Int32(db.count)])
//    
//    
//    
//    var normalizedMagnitudes = [Float](count: db.count, repeatedValue: 0.0)
//    vDSP_vsmul(sqrtFFT, 1, [2.0 / Float(db.count)], &normalizedMagnitudes, 1, vDSP_Length(db.count))
    
   
    //    var frequency = [Float]()
    //    for (var i = 0; i < fft.count; i++){
    //        frequency.append(  Float(i * 44100 / fft.count) )
    //    }

    
    
//    fft.removeFirst(fft.count / 2)
//
    let m  = db.reduce(0.0, combine: { $0 + $1})
    
    // Release the setup
    vDSP_destroy_fftsetup(fftSetup)
    return  [m / Float(db.count/2) ] //[ m / Float(fft.count/2) ];
    
    }
    
    
}


class AudioComponent {
    
    var audioPlayerNode: AVAudioPlayerNode
    var audioUnitTimeEffect: AVAudioUnitTimeEffect?
    var audioUnitUnitEffect: AVAudioUnitEffect?
    var audioBuffer:AVAudioPCMBuffer
    
    
    init(audioFile: AVAudioFile, unitEffect: AVAudioUnitEffect?){
        self.audioPlayerNode = AVAudioPlayerNode()
        self.audioUnitTimeEffect = nil
        self.audioUnitUnitEffect = unitEffect
        self.audioBuffer = AVAudioPCMBuffer(PCMFormat: audioFile.processingFormat, frameCapacity: UInt32(audioFile.length))
        try! audioFile.readIntoBuffer(self.audioBuffer)
    }
    
    init(audioFile: AVAudioFile, timeEffect: AVAudioUnitTimeEffect?){
        self.audioPlayerNode = AVAudioPlayerNode()
        self.audioUnitTimeEffect = timeEffect
        self.audioUnitUnitEffect = nil
        self.audioBuffer = AVAudioPCMBuffer(PCMFormat: audioFile.processingFormat, frameCapacity: UInt32(audioFile.length))
        try! audioFile.readIntoBuffer(self.audioBuffer)
    }
    
    func connectToEngine(engine: AVAudioEngine){
        if self.audioUnitTimeEffect != nil{
            engine.connect(self.audioPlayerNode, to: self.audioUnitTimeEffect!, format: self.audioBuffer.format)
            engine.connect(self.audioUnitTimeEffect!, to: engine.mainMixerNode, format: self.audioBuffer.format)
        }else if self.audioUnitUnitEffect != nil{
            engine.connect(self.audioPlayerNode, to: self.audioUnitUnitEffect!, format: self.audioBuffer.format)
            engine.connect(self.audioUnitTimeEffect!, to: engine.mainMixerNode, format: self.audioBuffer.format)
        }else {
            engine.connect(self.audioPlayerNode, to: engine.mainMixerNode, format: self.audioBuffer.format)
        }
    }
    
}



