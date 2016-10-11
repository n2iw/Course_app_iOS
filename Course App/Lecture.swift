//
//  Lecture.swift
//  Course App
//
//  Created by Ming Ying on 9/1/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import Foundation

class Lecture {
    let name: String
    let id: Int
    let video_url: String
    let localFileURL: NSURL
    let baseUrl: String
    var task: NSURLSessionDownloadTask?
    var resumeData: NSData? = nil
    
    init(id: Int, name: String, video_url: String, baseUrl: String) {
        self.id = id
        self.name = name
        self.video_url = video_url
        self.baseUrl = baseUrl
        let fileExtention = (NSURL(string: video_url)?.pathExtension!)!
        
        let folder = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        localFileURL = folder.URLByAppendingPathComponent("\(id).\(fileExtention)")
    }
    
    func videoFileURL() -> NSURL {
        if videoExists() {
            return NSURL()
        } else {
            return NSURL()
        }
    }
    
    func videoExists() -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(localFileURL.path!)
    }
    
    func downloadVideo(session: NSURLSession ,callback: (NSError?)->Void){
       
        let handler: (NSURL?, NSURLResponse?, NSError?) -> () = {location, response, err in
            if ((err == nil)) {
                self.resumeData = nil
                do {
                    try NSFileManager.defaultManager().moveItemAtURL(location!, toURL: self.localFileURL)
                } catch {
                    print("Move file \(location!.path!) failed")
                }
            }
            self.task = nil
            callback(err)
        }
        
        
        if task != nil {
            print("Lecture: already downloading, can't download again")
            return
        }
        
        
        //resume a download
        if let data = resumeData {
            print("Lecture: resume download")
            task = session.downloadTaskWithResumeData(data, completionHandler: handler)
            task!.resume()
        } else {
            //new download
            print("Lecture: new download")
            let url = baseUrl + video_url
            print("Downloading file \(url) to \(localFileURL.lastPathComponent!)")
            
            task = session.downloadTaskWithURL(NSURL(string: url)!, completionHandler: handler)
            task!.resume()
        }
    }
    
    
    func cancelDownload() {
        if let task = self.task {
            print("Lecture: Cancel download")
            task.cancelByProducingResumeData() {
                resumeData in
                self.resumeData = resumeData
                self.task = nil
            }
        }
    }
    
    func deleteVideo() -> Bool {
        do {
            try NSFileManager.defaultManager().removeItemAtURL(localFileURL)
            return true
        } catch {
            print("Can't delete file at: \(localFileURL.path!)")
            return false
        }
    }
}

