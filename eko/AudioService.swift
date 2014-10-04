//
//  AudioService.swift
//  eko
//
//  Created by Johannes Edelstam on 2014-10-04.
//  Copyright (c) 2014 E+E. All rights reserved.
//

import Foundation
import AudioToolbox
import AVFoundation


class AudioService : NSObject, AVAudioPlayerDelegate {
    var player : AVAudioPlayer!
    var isPlayingVinjett = false
    var isPlaying = false;
    var isPaused = false;
    var downloadService : DownloadService
    
    init(downloadService : DownloadService) {
        self.downloadService = downloadService
    }

    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        println("finished")
        if(isPlayingVinjett) {
            self.play(next: true)
        } else {
            isPlaying = false
        }
    }
    
    
    func play(next : Bool = false) {
        
        if(!next && (isPlaying || isPlayingVinjett)) { return }
        
        if(!isPaused) {
            let fileUrl = downloadService.fileURL()
            if(!downloadService.fileExists(fileUrl)) { return }

            var err : NSError?

            AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: &err)
            if(err != nil) { println(err) }

            var data : NSData!
            
            if(!isPlayingVinjett) {
                let vinjettPath = NSBundle.mainBundle().pathForResource("vinjett", ofType: "m4a")
                data = NSData(contentsOfURL: NSURL(fileURLWithPath: vinjettPath!))
                self.isPlayingVinjett = true
            } else {
                data = NSData(contentsOfURL: fileUrl)
                self.isPlayingVinjett = false
                self.isPlaying = true
            }
            
            
            self.player = AVAudioPlayer(data: data, error: &err)
            if(err != nil) { println(err) }
            self.player.delegate = self
            
            self.player.prepareToPlay()
        }
        
        self.player.play()
        self.isPaused = false
    }
    
    func pause() {
        if(isPaused) { return }
        
        if(self.player != nil) {
            println("Pause")
            self.player.pause()
            self.isPaused = true
            self.isPlaying = false
        }
    }
    
    func setVolume(vol  : Float) {
        if(self.player != nil) {
            player.volume = vol;
            println("Volume \(player.volume)")
        }

    }

}