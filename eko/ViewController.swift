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
    let proximityService = ProximityService()
    var player : AVAudioPlayer!
    var downloadService = DownloadService()
    var timer : NSTimer!
    
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
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        var alertController = UIAlertController(
            title: "Start radio mode?",
            message: nil,
            preferredStyle: .Alert
        )
        alertController.addAction(UIAlertAction(
            title: "No",
            style: .Default,
            handler: {(action: UIAlertAction!) in NSLog(":((")}
        ))
        alertController.addAction(UIAlertAction(
            title: "Yes",
            style: .Default,
            handler: {(action: UIAlertAction!) in
                NSLog("YES!!")
                self.proximityService.startAdvertising()
            }
        ))
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func fetch() {
        NSLog("Fetching...")
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
        })

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

