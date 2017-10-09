//
//  VideoViewController.swift
//  Course App
//
//  Created by Ming Ying on 10/8/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import QuickLook
import CoreData

class DemoVideoViewController: CDTableViewInViewController, UITableViewDataSource, UITableViewDelegate, QLPreviewControllerDataSource {
    private let context = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext)!
    
    @IBOutlet weak var weakTableView: UITableView! {
        didSet {
            self.tableView = weakTableView
        }
    }
    
    var pdfs: [[String:String]] = []
    var selectedPdf = -1
    
    var lecture: CDLecture! {
        didSet {
            guard let lecture = self.lecture
                else {
                    fetchedResultsController = nil
                    return
            }
            
            self.title = lecture.name
            self.navigationItem.title = "Day 2"
            
            let request = NSFetchRequest(entityName: "CDVideo")
            request.sortDescriptors = [NSSortDescriptor(
                key: "id",
                ascending: true,
                selector: nil
                )]
            request.predicate = NSPredicate(format: "lecture == %@", lecture)
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
            let folder = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let day1 = ["title": "Unit_1_Pre-reading", "rUrl": lecture.remoteUrl!, "localUrl": folder.URLByAppendingPathComponent("Unit_1_Pre-Reading.pdf").absoluteString]
            let day2 = ["title": "Unit_1_Reading", "rUrl": "https://shaban.rit.albany.edu/files/Unit_1_Reading_.pdf", "localUrl": folder.URLByAppendingPathComponent("Unit_1_Reading.pdf").absoluteString]
            self.pdfs = [day1, day2]
            for i in 0 ..< pdfs.count {
                let pdf = pdfs[i]
                if fileExists(pdf["localUrl"]!) {
                    let indexPath = NSIndexPath(forRow: i, inSection: 1)
                    progresses[indexPath] = 1.0
                }
            }
        }
        
    }
    
    private var progresses = Dictionary<NSIndexPath, Float>()
    
    // MARK: ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.lecture.name
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: Actions
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            selectPDF(tableView, indexPath: indexPath)
        } else if indexPath.section == 0 {
            selectVideo(tableView, indexPath: indexPath)
        }
    }
    
    private func selectPDF(tableView: UITableView ,indexPath: NSIndexPath) {
        if indexPath.row >= self.pdfs.count {
                return
        }
        let pdf = self.pdfs[indexPath.row]
        let localFileURL = pdf["localUrl"]!
        
        if fileExists(localFileURL) {
            let preview = QLPreviewController()
            preview.dataSource = self
            self.selectedPdf = indexPath.row
            if let nvc = self.navigationController {
                nvc.pushViewController(preview, animated: true)
            } else {
                self.presentViewController(preview, animated: true, completion: nil)
            }
        } else {
            guard let rUrl = pdf["rUrl"],
                let lUrl = pdf["localUrl"]
                else {
                  return
            }
            let downloader = Downloader(remoteURL: rUrl, localURL: lUrl) { progress in
                self.progresses[indexPath] = progress
                dispatch_async(dispatch_get_main_queue(), {
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
    
    private func selectVideo(tableView: UITableView, indexPath: NSIndexPath) {
        guard
            let video = fetchedResultsController?.objectAtIndexPath(indexPath) as? CDVideo,
            let file = video.localFileUrl
            else {
                return
        }
        
        if fileExists(file) {
            _ = try? playVideo(video)
        } else {
            guard let rUrl = video.remoteUrl,
                let lUrl = video.localFileUrl
                else {
                    return
            }
            let downloader = Downloader(remoteURL: rUrl, localURL: lUrl) { progress in
                self.progresses[indexPath] = progress
                dispatch_async(dispatch_get_main_queue(), { 
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
    
    private func playVideo(video: CDVideo) throws {
        guard let url = NSURL(string: video.localFileUrl!)
            else {
                return
        }
        let player = AVPlayer(URL: url)
        let playerController = AVPlayerViewController()
        playerController.player = player
        player.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(5, 1), queue: nil) { (currentTime) in
            let seconds = CMTimeGetSeconds(player.currentTime())
            self.context.performBlock() {
                video.currentTime = seconds
                _ = try? self.context.save()
            }
        }
        
        if let currentTime = video.currentTime as? Double {
            let cmtime = CMTime(seconds: currentTime, preferredTimescale: 1)
            player.seekToTime(cmtime)
        }
        
        self.presentViewController(playerController, animated: true) {
            player.play()
        }
    }
    
    private func fileExists(localFileURL: String) -> Bool {
        guard let url = NSURL(string: localFileURL)
            else {
                return false
        }
        return NSFileManager.defaultManager().fileExistsAtPath(url.path!)
    }
    
    // MARK: QLPreviewControllerDataSource
    
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(controller: QLPreviewController,
                           previewItemAtIndex index: Int) -> QLPreviewItem {
        guard let urlString = self.pdfs[self.selectedPdf]["localUrl"],
        let url = NSURL(string: urlString)
        else {
            return NSURL()
        }
        
        return url
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let chatVC = segue.destinationViewController as? ChatViewController {
            chatVC.lecture = self.lecture
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return super.tableView(tableView, numberOfRowsInSection: section)
        } else {
            return pdfs.count
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Transcripts"
        } else if section == 0 {
            return "Videos"
        }
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoCell", forIndexPath: indexPath)
        if let videoCell = cell as? VideoTableViewCell {
            if indexPath.section == 0 {
                if let video = self.fetchedResultsController?.objectAtIndexPath(indexPath) as? CDVideo {
                    videoCell.titleLabel?.text = video.title
                    if let localFileUrl = video.localFileUrl {
                        if fileExists(localFileUrl) {
                            progresses[indexPath] = 1.0
                        }
                    }
                }
            } else {
                if indexPath.row < pdfs.count {
                    videoCell.titleLabel?.text = pdfs[indexPath.row]["title"]
                }
            }
            
            let progress = progresses[indexPath] ?? 0
            videoCell.progressBar.setProgress(progress, animated: false)
            
            videoCell.progressBar.hidden = (progress == 0)
            
            return videoCell
        } else {
            return cell
        }
    }
    
    //MARK: UITableViewDelegate
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 56
    }
}