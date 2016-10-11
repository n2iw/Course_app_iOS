//
//  VideoViewController.swift
//  Course App
//
//  Created by Ming Ying on 8/31/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoViewController: UIViewController, NSURLSessionDownloadDelegate {
    
    var lecture: Lecture!
    var localFileURL: NSURL!
    var downloading: Bool = false
    var session: NSURLSession?
    var task: NSURLSessionDownloadTask?
    var resumeData: NSData?
    
    @IBOutlet weak var downloadVideoButton: UIButton!
    @IBOutlet weak var playVideoButton: UIButton!
    @IBOutlet weak var deleteVideoButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = lecture.name
        progressBar.hidden = true
        downloading = false
        
        let fileExtention = (NSURL(string: lecture.video_url)?.pathExtension!)!
        let folder = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        localFileURL = folder.URLByAppendingPathComponent("\(lecture.id).\(fileExtention)")
        
        session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                               delegate: self,
                               delegateQueue: NSOperationQueue.mainQueue())
        updateButtonStates()
    }
    
    private func updateButtonStates() {
        playVideoButton.enabled = videoExists()
        deleteVideoButton.enabled = videoExists()
        downloadVideoButton.enabled = !videoExists()
    }
    
    private func videoExists() -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(localFileURL.path!)
    }
    
    @IBAction func downloadVideo(sender: UIButton) {
        if task == nil {
            downloadVideoButton.setTitle("Cancel Download", forState: .Normal)
            progressBar.hidden = false
            downloadVideo()
        } else {
            downloadVideoButton.setTitle("Download Video", forState: .Normal)
            cancelDownload()
        }
    }
    
    private func downloadVideo(){
        if task != nil {
            print("Lecture: already downloading, can't download again")
            return
        }
        
        //resume a download
        if let data = resumeData {
            print("resume download")
            task = session?.downloadTaskWithResumeData(data)
            task!.resume()
        } else {
            //new download
            print("new download")
            let url = apiServer + lecture.video_url
            print("Downloading file \(url) to \(localFileURL.lastPathComponent!)")
            
            task = session?.downloadTaskWithURL(NSURL(string: url)!)
            task!.resume()
        }
    }
    
    
    private func cancelDownload() {
        if let task = self.task {
            print("Cancel download")
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
        self.progressBar.setProgress(Float(fileOffset)/Float(expectedTotalBytes), animated: true)
    }
    
    //progress report
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.progressBar.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
    }
    
    //download finished
    func URLSession(session: NSURLSession,
                      downloadTask: NSURLSessionDownloadTask,
                                   didFinishDownloadingToURL location: NSURL) {
        do {
            try NSFileManager.defaultManager().moveItemAtURL(location, toURL: self.localFileURL)
        } catch {
            print("Move file \(location.path!) failed")
        }
        
        self.task = nil
        self.resumeData = nil
        self.downloadVideoButton.setTitle("Download Video", forState: .Normal)
        self.updateButtonStates()
        self.progressBar.hidden = true
        self.progressBar.setProgress(0.0, animated: false)
        print("download succeed")
    }
    
    //download failed
    func URLSession(session: NSURLSession,
                      task: NSURLSessionTask,
                           didCompleteWithError error: NSError?) {
        if error != nil {
            print("download failed")
            resumeData = error?.userInfo[NSURLSessionDownloadTaskResumeData] as? NSData
        }
        self.task = nil
        self.downloadVideoButton.setTitle("Download Video", forState: .Normal)
    }
    
    
    @IBAction func playVideo(sender: UIButton) {
            do {
                try playVideo()
            } catch AppError.InvalidResource(let name, let type) {
                debugPrint("Could not find resource \(name).\(type)")
            } catch {
                debugPrint("Generic error")
            }
    }
    
    private func playVideo() throws {
        let player = AVPlayer(URL: localFileURL)
        let playerController = AVPlayerViewController()
        playerController.player = player
        self.presentViewController(playerController, animated: true) {
            player.play()
        }
    }
    
    @IBAction func deleteVideo(sender: UIButton) {
        do {
            try NSFileManager.defaultManager().removeItemAtURL(localFileURL)
        } catch {
            print("Can't delete file at: \(localFileURL.path!)")
        }
        updateButtonStates()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let chatVC = segue.destinationViewController as? ChatViewController {
            chatVC.lecture = self.lecture
        }
    }
    
}

enum AppError : ErrorType {
    case InvalidResource(String, String)
}