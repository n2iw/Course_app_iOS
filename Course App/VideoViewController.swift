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
    
    var lecture: Lecture!
    private var localTranscriptFileURL: NSURL?
    private var transcriptFileName: String?
    private var transcriptURL: NSURL?
    private var downloader: Downloader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = lecture.name
        
        let urlString = Settings.apiServer  + lecture.transcript_url.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        guard
            let url = NSURL(string: urlString),
            let fileExtention = url.pathExtension,
            let fileName = url.lastPathComponent
        else {
            print("Transcript url wrong: \(lecture.transcript_url)")
            return
        }
        
        transcriptFileName = fileName
        let folder = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        localTranscriptFileURL = folder.URLByAppendingPathComponent("\(lecture.id).\(fileExtention)")
        
        transcriptURL = NSURL(string: urlString)
    }
    
    
    // Table row selected
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("session: \(indexPath.section) row: \(indexPath.row) touched")
        if (indexPath.section == 0) {
            viewPDF(tableView, indexPath: indexPath)
        }
    }
    
    private func viewPDF(tableView: UITableView ,indexPath: NSIndexPath) {
        if fileExists(localTranscriptFileURL) {
            let preview = QLPreviewController()
            preview.dataSource = self
            if let nvc = self.navigationController {
                nvc.pushViewController(preview, animated: true)
            } else {
                self.presentViewController(preview, animated: true, completion: nil)
            }
        } else {
            guard let rUrl = transcriptURL,
                let lUrl = localTranscriptFileURL
                else {
                  return
            }
            let cell = tableView.dequeueReusableCellWithIdentifier("VideoCell", forIndexPath: indexPath)
            if let videoCell = cell as? VideoTableViewCell {
                downloader = Downloader(remoteURL: rUrl, localURL: lUrl, indicator: videoCell.progressBar)
                downloader?.start()
            }
        }
    }
    
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(controller: QLPreviewController,
                           previewItemAtIndex index: Int) -> QLPreviewItem {
        if let url = localTranscriptFileURL{
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
    
//    func playVideo(sender: UIButton) {
//            do {
//                try playVideo()
//            } catch AppError.InvalidResource(let name, let type) {
//                debugPrint("Could not find resource \(name).\(type)")
//            } catch {
//                debugPrint("Generic error")
//            }
//    }
//    
//    private func playVideo() throws {
//        let player = AVPlayer(URL: localFileURL)
//        let playerController = AVPlayerViewController()
//        playerController.player = player
//        self.presentViewController(playerController, animated: true) {
//            player.play()
//        }
//    }
    
//    func deleteVideo(sender: UIButton) {
//        do {
//            try NSFileManager.defaultManager().removeItemAtURL(localFileURL)
//        } catch {
//            print("Can't delete file at: \(localFileURL.path!)")
//        }
//    }
    
    
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
    
//    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
//        return ["Transcript", "Videos"]
//    }
    
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
            if indexPath.section == 0 {
                videoCell.titleLabel?.text = transcriptFileName
            } else {
                videoCell.titleLabel?.text = self.lecture.videos[indexPath.row].title
            }
            return videoCell
        }
        return cell
    }
    
    //UITableViewDelegate
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
}

enum AppError : ErrorType {
    case InvalidResource(String, String)
}