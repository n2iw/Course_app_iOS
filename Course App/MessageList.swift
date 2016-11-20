//
//  MessageList.swift
//  Shaban
//
//  Created by Ming Ying on 11/19/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import Foundation
import CoreData

class MessageList {
    
    var messages = [CDMessage]()
    private var groupId:Int
    private var context: NSManagedObjectContext
    private let server: APIClient
    private let path: String
    
    init(id: Int, url: String, path: String, context: NSManagedObjectContext) {
        self.groupId = id
        self.context = context
        server = APIClient(baseURL: url)
        self.path = path + "?group=\(groupId)"
    }
    
    func loadMessages() {
        //load Messages from database
        let request = NSFetchRequest(entityName: "CDMessage")
        request.sortDescriptors = [NSSortDescriptor(
            key: "id",
            ascending: true,
            selector: nil
            )]
        let predicate = NSPredicate(format: " group = %@ ", argumentArray: [groupId])
        request.predicate = predicate
       
        context.performBlock() {
            let messages = try? self.context.executeFetchRequest(request)
            self.messages = messages as! [CDMessage]
        }
    }

    func fetchMessages(callback: (() -> Void)?) {
        server.get(path) {success, data in
            if success {
                if let messages = data as? [[String:AnyObject]] {
                    print("Downloaded \(messages.count) messages")
                    self.context.performBlock(){
                        for msg in messages {
                            _ = CDMessage.objectFromApiJSON(msg, inContext: self.context)
                        }
                        self.loadMessages()
                        callback?()
                    }
                }
            }
        }
    }
}
