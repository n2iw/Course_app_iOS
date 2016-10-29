//
//  ChatViewController.swift
//  Course App
//
//  Created by Ming Ying on 7/17/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import UIKit
import SocketIOClientSwift

class ChatViewController: UIViewController, UITextFieldDelegate {
    let messageAttribute = [ NSForegroundColorAttributeName: UIColor.blueColor() ]
    let authorAttribute = [NSForegroundColorAttributeName: UIColor.grayColor()]
    let TAB_BAR_HEIGHT = 49

    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textField: UITextField!
    var lecture: Lecture!
    
    private var socket = SocketIOClient(socketURL: NSURL(string: socketServer)!, options: [SocketIOClientOption.ConnectParams(["__sails_io_sdk_version":"0.11.0"])])
//    private var socket = SocketIOClient(socketURL: NSURL(string: "http://localhost:1337")!, options: [SocketIOClientOption.ConnectParams(["__sails_io_sdk_version":"0.11.0"])])
    private var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.lecture.name

        socket.on("connect") {data, ack in
            print("socket connected")
            self.socket.emit("post", ["url": "/groups/join/\(self.lecture.id)"])
        }
        
        socket.on("message") {data, ack in
            if let message = data[0] as? Dictionary<String, AnyObject> {
                print("message for group: \(message["group"]!)")
                dispatch_async(dispatch_get_main_queue()) {
                    // create attributed string
                    let author = message["author"] as! String + ":\n"
                    let msg = message["content"] as! String + "\n\n"
                    let myAttrString = NSMutableAttributedString(attributedString: self.textView.attributedText)
                    myAttrString.appendAttributedString(NSAttributedString(string: author, attributes: self.authorAttribute))
                    myAttrString.appendAttributedString(NSAttributedString(string: msg, attributes: self.messageAttribute))
                    
                    self.textView.attributedText = myAttrString
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func send(sender: UIButton) {
        if textField.text! != "" {
            socket.emit("post", [
                "url": "/messages",
                "data": [
                    "group": self.lecture.id,
                    "author": 3,
                    "content": textField.text!
                ]
                ])
            textField.text = ""
            textField.resignFirstResponder()
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
}
