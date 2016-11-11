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
import QuickLook

class VideoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, QLPreviewControllerDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var lecture: Lecture! {
        didSet {
            let urlString = Settings.apiServer  + lecture.transcript_url.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            guard
                let url = NSURL(string: urlString),
                let fileExtention = url.pathExtension,
                let fileName = url.lastPathComponent
                else {
                    print("Transcript url wrong: \(lecture.transcript_url)")
                    return
            }
            
            lecture.fileName = fileName
            let folder = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            lecture.localFileURL = folder.URLByAppendingPathComponent("lecture_\(lecture.id).\(fileExtention)")
            
            lecture.remoteURL = NSURL(string: urlString)
            
            for video in lecture.videos {
                let urlString = Settings.apiServer  + video.url.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                guard
                    let url = NSURL(string: urlString),
                    let fileExtention = url.pathExtension
                    else {
                        print("Video url wrong: \(video.url)")
                        return
                }
                
                let folder = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                video.localFileURL = folder.URLByAppendingPathComponent("video_\(video.id).\(fileExtention)")
                
                video.remoteURL = NSURL(string: urlString)
            }
        }
    }
//    private var downloader: Downloader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = lecture.name
    }
    
    // Table row selected
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("session: \(indexPath.section) row: \(indexPath.row) touched")
        if indexPath.section == 0 {
            selectPDF(tableView, indexPath: indexPath)
        } else if indexPath.section == 1 {
            selectVideo(tableView, indexPath: indexPath)
        }
    }
    
    private func selectPDF(tableView: UITableView ,indexPath: NSIndexPath) {
        if fileExists(lecture.localFileURL) {
            let preview = QLPreviewController()
            preview.dataSource = self
            if let nvc = self.navigationController {
                nvc.pushViewController(preview, animated: true)
            } else {
                self.presentViewController(preview, animated: true, completion: nil)
            }
        } else {
            guard let rUrl = lecture.remoteURL,
                let lUrl = lecture.localFileURL
                else {
                  return
            }
            let downloader = Downloader(remoteURL: rUrl, localURL: lUrl) { progress in
                self.lecture.progress = progress
                dispatch_async(dispatch_get_main_queue(), {
//                    self.tableView.reloadData()
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                })
            }
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? VideoTableViewCell {
                cell.progressBar.progress = 0.0
                cell.progressBar.hidden = false
            }
            
            downloader.start()
        }
    }
    
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(controller: QLPreviewController,
                           previewItemAtIndex index: Int) -> QLPreviewItem {
        if let url = lecture.localFileURL{
            return url
        } else {
            return NSURL()
        }
    }
    
    private func fileExists(localFileURL: NSURL?) -> Bool {
        guard let url = localFileURL
        else {
            return false
        }
        return NSFileManager.defaultManager().fileExistsAtPath(url.path!)
    }
    
    private func selectVideo(tableView: UITableView, indexPath: NSIndexPath) {
        let video = lecture.videos[indexPath.row]
        guard
            let file = video.localFileURL
            else {
                return
        }
        
        if fileExists(file) {
            _ = try? playVideo(file)
        } else {
            guard let rUrl = video.remoteURL,
                let lUrl = video.localFileURL
                else {
                    return
            }
            let downloader = Downloader(remoteURL: rUrl, localURL: lUrl) { progress in
                video.progress = progress
                dispatch_async(dispatch_get_main_queue(), { 
//                    self.tableView.reloadData()
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                })
            }
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? VideoTableViewCell {
                cell.progressBar.progress = 0.0
                cell.progressBar.hidden = false
            }
            downloader.start()
        }
 
    }
    
    private func playVideo(url: NSURL) throws {
        let player = AVPlayer(URL: url)
        let playerController = AVPlayerViewController()
        playerController.player = player
        self.presentViewController(playerController, animated: true) {
            player.play()
        }
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
    
    //UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.lecture.videos.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoCell", forIndexPath: indexPath)
        if let videoCell = cell as? VideoTableViewCell {
            var progress: Float = 0.0
            if indexPath.section == 0 {
                videoCell.titleLabel?.text = lecture.fileName
                progress = lecture.progress
            } else {
                videoCell.titleLabel?.text = self.lecture.videos[indexPath.row].title
                progress = lecture.videos[indexPath.row].progress
            }
            videoCell.progressBar.setProgress(progress, animated: false)
            if progress == 0 {
                videoCell.progressBar.hidden = true
            } else {
                videoCell.progressBar.hidden = false
            }
            return videoCell
        }
        return cell
    }
    
    //UITableViewDelegate
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 56
    }
}

enum AppError : ErrorType {
    case InvalidResource(String, String)
}