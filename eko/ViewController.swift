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


class ViewController: UIViewController {
    var player : AVAudioPlayer!
    var downloadService = DownloadService()
    var timer : NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("Started")

        downloadService.fetch()
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("fetch"), userInfo: nil, repeats: true)

        self.play()        
        
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
        // Dispose of any resources that can be recreated.
    }


}

