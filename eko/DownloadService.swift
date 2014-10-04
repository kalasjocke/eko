//
//  DownloadService.swift
//  eko
//
//  Created by Johannes Edelstam on 2014-10-04.
//  Copyright (c) 2014 E+E. All rights reserved.
//

import Foundation

//let SR_API_URL = "http://localhost:4050";
let SR_API_URL = "http://api.sr.se";


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


class DownloadService : NSObject {
    var fetching = false
    
    func fileURL() -> NSURL {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let fileUrl = NSURL(fileURLWithPath: documentsPath + "/latest.m4a")
        return fileUrl;
    }
    
    func fileExists(fileUrl : NSURL) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(fileUrl.path!)
    }
    
    func fetch() {
        if(self.fetching) { return }
        self.fetching = true
        let url = NSURL(string: SR_API_URL + "/api/v2/episodes/index?programid=4540&urltemplateid=3&audioquality=hi")
        var parser = NSXMLParser(contentsOfURL: url)
        var parserDelegate = ParserDelegate()
        parser.delegate = parserDelegate
        parser.parse()
        let audioUrl = NSURL(string: parserDelegate.urls.first!)
        
        println("Fetching \(audioUrl)")
        let task = NSURLSession.sharedSession().downloadTaskWithURL(audioUrl, completionHandler: { location, response, error in
            if(error != nil) {
                println(error)
                return
            }
            
            var err : NSError?
            let fileUrl = self.fileURL()
            if(self.fileExists(fileUrl)) {
                NSFileManager.defaultManager().removeItemAtURL(fileUrl, error: &err)
                if(err != nil) { println(err) }
            }
            
            NSFileManager.defaultManager().copyItemAtURL(location, toURL: fileUrl, error: &err)
            if(err != nil) { println(err) }
            
            
            self.fetching = false
        })
        
        task.resume()

    }
}
