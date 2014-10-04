//
//  ViewController.swift
//  eko
//
//  Created by Johannes Edelstam on 2014-10-04.
//  Copyright (c) 2014 E+E. All rights reserved.
//



import UIKit
import AudioToolbox
import AVFoundation

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    var proximityService : ProximityService!
    var player : AVAudioPlayer!
    var downloadService = DownloadService()
    var timer : NSTimer!
    var isPlaying = false;
    var isPaused = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let action : Selector = "handleTap:"
        let tapRecognizer = UITapGestureRecognizer(target: self, action: action)
        tapRecognizer.numberOfTapsRequired = 1
        
        self.view.addGestureRecognizer(tapRecognizer)
    
        self.proximityService = ProximityService(delegate: self)
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        var alertController = UIAlertController(
            title: "Mode?",
            message: nil,
            preferredStyle: .Alert
        )
        alertController.addAction(UIAlertAction(
            title: "Radio",
            style: .Default,
            handler: {(action: UIAlertAction!) in
                self.downloadService.fetch()
                
                self.timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("fetch"), userInfo: nil, repeats: true)
                
                self.proximityService.startReceiving()
            }
        ))
        alertController.addAction(UIAlertAction(
            title: "Person",
            style: .Default,
            handler: {(action: UIAlertAction!) in self.proximityService.startTransmitting() }
        ))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func didUpdateProximity(proximity : Int) {
        NSLog(proximity.description)

        if((proximity == 0 || proximity < -90) && isPlaying) {
            self.pause()
        }
        
        if((proximity < 0 && proximity > -55) && !isPlaying) {
            self.play()
        }
        
        if(self.player != nil) {
            let level = (Float(proximity) - -65.0) / -15.0 as Float
            player.volume = 0.2 + 0.8 * max(min(level, 1.0), 0.0) as Float
            println("Volume \(player.volume)")
        }
        
    }

    func fetch() {
        downloadService.fetch()
    }
    
    func play() {

        if(!isPaused) {
            self.player.play()
        
            let fileUrl = downloadService.fileURL()
            if(!downloadService.fileExists(fileUrl)) { return }
            
            let data = NSData(contentsOfURL: fileUrl)
            var err : NSError?
            
            AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: &err)
            if(err != nil) { println(err) }
            
            self.player = AVAudioPlayer(data: data, error: &err)
            if(err != nil) { println(err) }
            
            self.player.prepareToPlay()
        }
        
        self.player.play()
        self.isPlaying = true
        self.isPaused = false
    }
    
    func pause() {
        if(self.player != nil) {
            println("Pause")
            self.player.pause()
            self.isPaused = true
            self.isPlaying = false
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

