//
//  ChatViewController.swift
//  Course App
//
//  Created by Ming Ying on 7/17/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import UIKit
import SocketIOClientSwift
import CoreData

class ChatViewController: CDTableViewInViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    let TAB_BAR_HEIGHT = 49
    
    private let context = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext)!
    
    @IBOutlet weak var messageTableView: UITableView! {
        didSet {
            self.tableView = messageTableView
        }
    }
    
    @IBOutlet weak var textField: UITextField!
    
    var lecture: CDLecture! {
        didSet {
            guard let lecture = self.lecture
                else {
                    return
            }
            
            self.navigationItem.title = lecture.name

            let request = NSFetchRequest(entityName: "CDMessage")
            request.sortDescriptors = [NSSortDescriptor(
                key: "id",
                ascending: true,
                selector: nil
                )]
            request.predicate = NSPredicate(format: "group == %@", lecture.id!)
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            CDMessage.fetchMessagesForGroupId(self.lecture.id as! Int, inContext: self.context, callback: nil)
        }
    }
    
    private var socket = SocketIOClient(socketURL: NSURL(string: Settings.socketServer)!, options: [SocketIOClientOption.ConnectParams(["__sails_io_sdk_version":"0.11.0"])])
    
    // MARK: ViewController Lift cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Chatting: \(self.lecture.name!)"

        socket.on("connect") {data, ack in
            print("socket connected")
            let url = "/groups/join/\(self.lecture.id!)"
            self.socket.emit("post", ["url": url])
        }
        
        socket.on("message") { data, ack in
            self.context.performBlock() {
                for msg in data {
                    _ = CDMessage.messageFromSocketJSON(msg, inContext: self.context)
                }
                _ = try? self.context.save()
            }
        }
        
        textField.delegate = self
        
        socket.connect()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        guard let sections = fetchedResultsController?.sections,
            let row = sections.first?.numberOfObjects
            where row > 0
            else {
                return
        }
        
        let indexPath = NSIndexPath(forRow: row - 1, inSection: 0)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
    }
    
    // MARK: UITextFieldDelegate
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
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
    
    // MARK: Actions
    @IBAction func send(sender: UIButton) {
        guard let text = textField.text where text != "",
            let phone = Settings.getPhone() where phone != "",
            let userName = Settings.getUserName() where userName != ""
            else {
                let alert = UIAlertController(title: "Couldn't send message", message: "Please enter your registered phone number in \"Settings\" tab!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                self.tabBarController?.selectedIndex = Settings.SETTINGS_TAB_INDEX
                return
        }
        
        socket.emit("post", [
            "url": "/messages",
            "data": [
                "group": self.lecture.id as! Int,
                "author": phone,
                "content": text
            ]
            ])
        textField.text = ""
        textField.resignFirstResponder()
    }
    
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Message", forIndexPath: indexPath)
        if let message = fetchedResultsController?.objectAtIndexPath(indexPath) as? CDMessage {
            cell.textLabel?.text = message.author! + ":    (\(message.getTimestamp()))"
            cell.detailTextLabel?.text = message.content
        }
        
        return cell
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    override func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
        
        guard let sections = fetchedResultsController?.sections,
            let row = sections.first?.numberOfObjects
            where row > 0
            else {
                return
        }
        
        let indexPath = NSIndexPath(forRow: row - 1, inSection: 0)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
    }
}
