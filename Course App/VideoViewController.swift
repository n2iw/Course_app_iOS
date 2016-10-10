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

class VideoViewController: UIViewController {
    
    var lecture: Lecture!
    @IBOutlet weak var downloadVideoButton: UIButton!
    @IBOutlet weak var playVideoButton: UIButton!
    @IBOutlet weak var deleteVideoButton: UIButton!
    
    private var firstAppear = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = lecture.name
        setButtonStates()
    }
    
    private func setButtonStates() {
        playVideoButton.enabled = lecture.videoExists()
        deleteVideoButton.enabled = lecture.videoExists()
        downloadVideoButton.enabled = !lecture.videoExists()
    }
    
    @IBAction func downloadVideo(sender: UIButton) {
        lecture.downloadVideo() {
            dispatch_async(dispatch_get_main_queue()) {
                self.setButtonStates()
            }
        }
    }
    
    @IBAction func playVideo(sender: UIButton) {
        if firstAppear {
            do {
                try playVideo()
                firstAppear = false
            } catch AppError.InvalidResource(let name, let type) {
                debugPrint("Could not find resource \(name).\(type)")
            } catch {
                debugPrint("Generic error")
            }
        }
    }
    
    private func playVideo() throws {
        guard let path = NSBundle.mainBundle().pathForResource("Video", ofType:"mp4") else {
            throw AppError.InvalidResource("Video", "mp4")
        }
        let player = AVPlayer(URL: NSURL(fileURLWithPath: path))
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
    
}

enum AppError : ErrorType {
    case InvalidResource(String, String)
}