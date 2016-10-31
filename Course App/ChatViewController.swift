//
//  ChatViewController.swift
//  Course App
//
//  Created by Ming Ying on 7/17/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import UIKit
import SocketIOClientSwift

class ChatViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    let messageAttribute = [ NSForegroundColorAttributeName: UIColor.blueColor() ]
    let authorAttribute = [NSForegroundColorAttributeName: UIColor.grayColor()]
    let TAB_BAR_HEIGHT = 49

    @IBOutlet weak var messageTableView: UITableView!
    
    @IBOutlet weak var textField: UITextField!
    private var messages: [Message] = []
    var lecture: Lecture!
    
    private var socket = SocketIOClient(socketURL: NSURL(string: Settings.socketServer)!, options: [SocketIOClientOption.ConnectParams(["__sails_io_sdk_version":"0.11.0"])])
    private var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.lecture.name

        socket.on("connect") {data, ack in
            print("socket connected")
            self.socket.emit("post", ["url": "/groups/join/\(self.lecture.id)"])
        }
        
        socket.on("message") {[weak weakSelf = self] data, ack in
            if let message = data[0] as? Dictionary<String, AnyObject> {
                print("message for group: \(message["group"]!)")
                dispatch_async(dispatch_get_main_queue()) {
                    let author = message["authorName"] as! String
//                    let author = message["author"] as! String
                    let msg = message["content"] as! String
                    weakSelf?.messages.append(Message(author: author, content: msg))
                    let index = weakSelf!.messages.count - 1
                    let indexPath = NSIndexPath(forRow: index ,  inSection: 0)
                    weakSelf?.messageTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
                    weakSelf?.messageTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
                }
            } else {
                print("Got message: wrong format!")
            }
        }
        
        textField.delegate = self
        
        socket.connect()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func send(sender: UIButton) {
        if textField.text! != "" && Settings.getFirstName() != nil && Settings.getLastName() != nil {
            socket.emit("post", [
                "url": "/messages",
                "data": [
                    "group": self.lecture.id,
//                    "author": 3,
                    "authorName": "\(Settings.getFirstName()!) \(Settings.getLastName()!)",
                    "content": textField.text!
                ]
                ])
            textField.text = ""
            textField.resignFirstResponder()
        } else {
            print("empty text or names")
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= keyboardSize.height - CGFloat(TAB_BAR_HEIGHT)
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height - CGFloat(TAB_BAR_HEIGHT)
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //UITableViewDelegate
    
    //UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Message", forIndexPath: indexPath)
        cell.textLabel?.text = messages[indexPath.row].author + ":"
        cell.detailTextLabel?.text = messages[indexPath.row].content
        
        return cell
    }
}
