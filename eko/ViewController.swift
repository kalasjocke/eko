//
//  ViewController.swift
//  eko
//
//  Created by Johannes Edelstam on 2014-10-04.
//  Copyright (c) 2014 E+E. All rights reserved.
//

let SR_API_URL = "http://localhost:4050";
//let SR_API_URL = "http://api.sr.se";


import UIKit
import AudioToolbox
import AVFoundation

class ParserDelegate : NSObject, NSXMLParserDelegate {
    var path : [String] = []
    var urls : [String] = []
    var url : String = ""
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: NSDictionary!) {

        path.append(elementName)
        if(path == ["sr", "episodes", "episode", "broadcast", "broadcastfiles", "broadcastfile", "url"]) {
            url = ""
        }
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!) {
        if(path == ["sr", "episodes", "episode", "broadcast", "broadcastfiles", "broadcastfile", "url"]) {
            self.url += string
        }
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        if(path == ["sr", "episodes", "episode", "broadcast", "broadcastfiles", "broadcastfile", "url"]) {
            urls.append(url)
        }
        path.removeLast()
    }
}

class ViewController: UIViewController {
    var player : AVAudioPlayer!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLog("Commencing.... Hej Sebastian")
        
        let url = NSURL(string: SR_API_URL + "/api/v2/episodes/index?programid=4540&urltemplateid=3&audioquality=hi")
        let parser = NSXMLParser(contentsOfURL: url)
        let parserDelegate = ParserDelegate()
        parser.delegate = parserDelegate
        parser.parse()
        let audioUrl = NSURL(string: parserDelegate.urls.first!)
        println(audioUrl)
  
        
        let task = NSURLSession.sharedSession().downloadTaskWithURL(audioUrl, completionHandler: { location, response, error in
            if(error != nil) {
                println(error)
            } else {
                var err : NSError?
                println("Temporary file \(location)")
                let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                let fileUrl = NSURL(fileURLWithPath: documentsPath + "/latest.m4a")
                let manager = NSFileManager.defaultManager()
                if(manager.fileExistsAtPath(fileUrl.path!)) {
                    manager.removeItemAtURL(fileUrl, error: nil)
                }
                
                NSFileManager.defaultManager().copyItemAtURL(location, toURL: fileUrl, error: &err)
                println(err)
                println("Permanent file \(fileUrl.absoluteString)")
                dispatch_async(dispatch_get_main_queue(),{
                    let data = NSData(contentsOfURL: fileUrl)

                    AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: &err)
                    println(err)
                    
                    self.player = AVAudioPlayer(data: data, error: &err)
                    println(err)
                    
                    self.player.prepareToPlay()
                    self.player.play()
                })

            }
        })
        
        task.resume()
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

