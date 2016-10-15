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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    func animateTextField(up: Bool)
    {
        let movementDistance:CGFloat = -250
        let movementDuration: Double = 0.3
        
        var movement:CGFloat = 0
        if up {
            movement = movementDistance
        } else {
            movement = -movementDistance
        }
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        UIView.commitAnimations()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text! != "" {
            socket.emit("post", [
                "url": "/messages",
                "data": [
                    "group": self.lecture.id,
                    "author": 3,
                    "content": textField.text!
                ]
            ])
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        self.animateTextField(true)
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        self.animateTextField(false)
        textField.text = ""
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
