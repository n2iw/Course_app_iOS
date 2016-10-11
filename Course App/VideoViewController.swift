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
    var downloading: Bool = false
    
    @IBOutlet weak var downloadVideoButton: UIButton!
    @IBOutlet weak var playVideoButton: UIButton!
    @IBOutlet weak var deleteVideoButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = lecture.name
        updateButtonStates()
        progressBar.hidden = true
        downloading = false
    }
    
    private func updateButtonStates() {
        playVideoButton.enabled = lecture.videoExists()
        deleteVideoButton.enabled = lecture.videoExists()
        downloadVideoButton.enabled = !lecture.videoExists()
    }
    
    @IBAction func downloadVideo(sender: UIButton) {
        if !downloading {
            downloading = true
            downloadVideoButton.setTitle("Cancel Download", forState: .Normal)
            progressBar.hidden = false
            progressBar.setProgress(0.0, animated: false)
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                                   delegate: self,
                                   delegateQueue: NSOperationQueue.mainQueue())
            lecture.downloadVideo(session) { err in
                dispatch_async(dispatch_get_main_queue()) {
                    self.downloading = false
                    self.downloadVideoButton.setTitle("Download Video", forState: .Normal)
                    self.updateButtonStates()
                }
                if err != nil {
                    print("Download failed for \(self.lecture.name)")
                }
            }
        } else {
            downloading = false;
            downloadVideoButton.setTitle("Download Video", forState: .Normal)
            lecture.cancelDownload()
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        print("Delegate Finish downloading")
    }
    
    func URLSession(session: NSURLSession,
                    downloadTask: NSURLSessionDownloadTask,
                    bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    tototalBytesExpectedToWrite: Int64) {
        self.progressBar.setProgress(Float(totalBytesWritten)/Float(tototalBytesExpectedToWrite), animated: true)
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
        let player = AVPlayer(URL: lecture.localFileURL)
        let playerController = AVPlayerViewController()
        playerController.player = player
        self.presentViewController(playerController, animated: true) {
            player.play()
        }
    }
    
    @IBAction func deleteVideo(sender: UIButton) {
        let result = lecture.deleteVideo()
        print("delete success? \(result)")
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