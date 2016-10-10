//
//  Lecture.swift
//  Course App
//
//  Created by Ming Ying on 9/1/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import Foundation

class Lecture {
    var name: String!
    var id: Int!
    var video_url: String!
    init(id: Int, name: String, video_url: String) {
        self.id = id
        self.name = name
        self.video_url = video_url
    }
    
    func videoFileURL() -> NSURL {
        if videoExists() {
            return NSURL()
        } else {
            return NSURL()
        }
    }
    
    func videoExists() -> Bool {
        return false
    }
    
    func downloadVideo(callback: ()->Void) {
        print("Downloading file \(video_url)")
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.downloadTaskWithURL(NSURL(string: video_url)!) {
            location, response, err in
            if ((err == nil)) {
                print(response)
                print(location)
            }
            
        }
        task.resume()
        
        let folder = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        
        callback()
    }
}

