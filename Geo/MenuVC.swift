//
//  MenuVC.swift
//  Geo
//
//  Created by Rodrigo Leite on 11/5/15.
//  Copyright © 2015 Rodrigo Leite. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class MenuVC: UIViewController, MPMediaPickerControllerDelegate  {

    // MARK: ATTRIBUTES
    
    @IBOutlet weak var selectSong: UIButton!
    
    var mediaPicker: MPMediaPickerController!
    var songPath: NSURL?
    var songName: String?
    
    // MARK: VC LIFE CYCLE
    override func viewDidLoad() {
        self.navigationController?.navigationBarHidden = true
        self.mediaPicker = MPMediaPickerController(mediaTypes: .Music)
        self.mediaPicker.delegate = self
        self.mediaPicker.allowsPickingMultipleItems = false
        self.mediaPicker.showsCloudItems = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    // MARK: IBACTION
    @IBAction func selectSong(sender: UIButton) {
        self.presentViewController(self.mediaPicker, animated: true, completion: nil)
    }
    
    
    @IBAction func playGame(sender: UIButton){
        self.performSegueWithIdentifier("goToGame", sender: nil)
    }
    
    
    // MARK: PICKER MEDIA
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection){
        let item = mediaItemCollection.items.first
        self.selectSong.setTitle(item?.title, forState: UIControlState.Normal)
        self.songPath = item?.valueForProperty(MPMediaItemPropertyAssetURL) as? NSURL
        self.songName = item?.title
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: NAVIGATION
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToGame"{
            let game = segue.destinationViewController as! GameVC
            game.pathMusicName = self.songName
            game.pathMusic = self.songPath
        }
    }
    
    
}
