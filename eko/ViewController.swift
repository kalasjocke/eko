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
    var volumeTimer : NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("Started")

        downloadService.fetch()
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("fetch"), userInfo: nil, repeats: true)

        self.play()        
        
        
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
            handler: {(action: UIAlertAction!) in self.proximityService.startReceiving() }
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
    }

    func fetch() {
        downloadService.fetch()
    }
    
    func play() {
        let fileUrl = downloadService.fileURL()
        dispatch_async(dispatch_get_main_queue(),{
            let data = NSData(contentsOfURL: fileUrl)
            var err : NSError?

            AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: &err)
            if(err != nil) { println(err) }

            self.player = AVAudioPlayer(data: data, error: &err)
            if(err != nil) { println(err) }
            
            self.player.prepareToPlay()
            self.player.play()
            
            if(self.volumeTimer == nil) {
                self.volumeTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector:  Selector("updateVolume"), userInfo: nil, repeats: true)
            }
        })

    }
    
    func updateVolume() {
        let vol = (Float) (1.0 + sin(NSDate().timeIntervalSince1970)) / 2.0
        NSLog(NSString(format: "%f", vol))
        player.volume = vol
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

