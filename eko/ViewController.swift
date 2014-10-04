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
    var downloadService : DownloadService!
    var audioService : AudioService!

    var timer : NSTimer!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.downloadService = DownloadService()
        self.audioService = AudioService(downloadService: downloadService)
    }
    
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

        if(proximity == 0 || proximity < -90) {
            self.pause()
        }
        
        if(proximity < 0 && proximity > -55) {
            self.play()
        }
        
        let level = (Float(proximity) - -65.0) / -15.0 as Float
        audioService.setVolume(0.2 + 0.8 * max(min(level, 1.0), 0.0) as Float)
    }

    func fetch() {
        downloadService.fetch()
    }
    
    func play() {
        audioService.play()
    }
    
    func pause() {
        audioService.pause()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

