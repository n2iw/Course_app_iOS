//
//  Downloader.swift
//  Shaban
//
//  Created by Ming Ying on 11/10/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import Foundation

class Downloader: NSObject, NSURLSessionDownloadDelegate  {
    private var progressCB: ((Float) -> Void)?
    private var remoteURL: NSURL
    private var localURL: NSURL
    
    private var session: NSURLSession?
    private var task: NSURLSessionDownloadTask?
    private var resumeData: NSData?
    
    init(remoteURL: NSURL, localURL: NSURL, progressCB: ((Float) -> Void )?) {
        self.remoteURL = remoteURL
        self.localURL = localURL
        self.progressCB = progressCB
    }
    
    func start() {
        
        if task != nil {
            print("Downloader: already downloading, can't download again")
            return
        }
        
        //resume a download
        if let data = resumeData {
            print("resume download for \(remoteURL)")
            task = session?.downloadTaskWithResumeData(data)
            task!.resume()
        } else {
            //new download
            if session == nil {
                session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                                       delegate: self,
                                       delegateQueue: NSOperationQueue.mainQueue())
            }
            print("new download")
            print("Downloading file \(remoteURL) to \(localURL.lastPathComponent!)")
            
            task = session?.downloadTaskWithURL(remoteURL)
            task!.resume()
        }
    }
    
    
    private func cancelDownload() {
        if let task = self.task {
            print("Cancel download for \(remoteURL)")
            task.cancelByProducingResumeData() {
                resumeData in
                self.resumeData = resumeData
                self.task = nil
            }
        }
    }
    
    //download resume
    func URLSession(session: NSURLSession,
                    downloadTask: NSURLSessionDownloadTask,
                    didResumeAtOffset fileOffset: Int64,
                                      expectedTotalBytes: Int64) {
        self.progressCB?(Float(fileOffset)/Float(expectedTotalBytes))
    }
    
    //progress report
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.progressCB?(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite))
    }
    
    //download finished
    @objc func URLSession(session: NSURLSession,
                      downloadTask: NSURLSessionDownloadTask,
                                   didFinishDownloadingToURL location: NSURL) {
        do {
            try NSFileManager.defaultManager().moveItemAtURL(location, toURL: self.localURL)
        } catch {
            print("Move file \(location.path!) failed")
        }
        
        self.task = nil
        self.resumeData = nil
    }
    
    //download failed
    func URLSession(session: NSURLSession,
                      task: NSURLSessionTask,
                           didCompleteWithError error: NSError?) {
        if error != nil {
            print("download \(remoteURL) failed")
            resumeData = error?.userInfo[NSURLSessionDownloadTaskResumeData] as? NSData
           _ = try? NSFileManager.defaultManager().removeItemAtURL(self.localURL)
        } else {
            print("download \(remoteURL) succeed")
        }
        self.task = nil
    }
    
}