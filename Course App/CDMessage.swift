//
//  CDMessage.swift
//  Course App
//
//  Created by Ming Ying on 11/7/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import Foundation
import CoreData


class CDMessage: NSManagedObject {
    
    private static let server = APIClient(baseURL: Settings.apiServer)
    private static var updatedAt: NSDate = NSDate(timeIntervalSince1970: 0)
    private static var lastUpdatedGroupId: Int?

    class func fetchMessagesForGroupId(id: Int, inContext context: NSManagedObjectContext, callback: (() -> Void)?) {
        let interval = abs(updatedAt.timeIntervalSinceNow)
        if lastUpdatedGroupId == id && interval <= Settings.UPDATE_INTERVAL { //update at most once every x seconds
            print("Downloaded messages for group: \(id) \(interval) seconds ago, skip this time")
            return
        }
        
        let path = Settings.messagePath + "?group=\(id)&limit=1000&sort=id%20DESC"
        
        server.get(path) {success, data in
            if success {
                if let messages = data as? [[String:AnyObject]] {
                    print("Downloaded \(messages.count) messages")
                    self.updatedAt = NSDate()
                    self.lastUpdatedGroupId = id
                    
                    context.performBlock() {
                        for msg in messages {
                            _ = CDMessage.messageFromApiJSON(msg, inContext:context)
                        }
                        _ = try? context.save()
                    }
                    callback?()
                }
            }
        }
    }
    
    class func messageFromApiJSON(jsonData: AnyObject, inContext context: NSManagedObjectContext) -> CDMessage? {
        guard let json = jsonData as? [String: AnyObject],
            let content = json["content"] as? String,
            let author = json["author"],
            let firstName = author["firstName"] as? String,
            let lastName = author["lastName"] as? String,
            let group = json["group"],
            let groupId = group["id"] as? Int,
            let id = json["id"] as? Int,
            let createdAt = json["createdAt"] as? String,
            let updatedAt = json["updatedAt"] as? String
        else {
                return nil
                
        }
        
        if let message = getMessageById(id, context: context) ?? NSEntityDescription.insertNewObjectForEntityForName("CDMessage", inManagedObjectContext: context) as? CDMessage {
        
            message.author = "\(firstName) \(lastName)"
            message.content = content
            message.group = groupId
            message.id = id
            
            message.createdAt = JSONDate.dateFromJSONString(createdAt)
            message.updatedAt = JSONDate.dateFromJSONString(updatedAt)
            
            return message
        }
        
        return nil
    }
    
    class func messageFromSocketJSON(jsonData: AnyObject, inContext context: NSManagedObjectContext) -> CDMessage? {
        guard let json = jsonData as? [String: AnyObject],
            let content = json["content"] as? String,
            let author = json["authorName"] as? String,
            let group = json["group"] as? Int,
            let id = json["id"] as? Int,
            let createdAt = json["createdAt"] as? String,
            let updatedAt = json["updatedAt"] as? String
        else {
                return nil
                
        }
        
        if let message = getMessageById(id, context: context) ??
            NSEntityDescription.insertNewObjectForEntityForName("CDMessage", inManagedObjectContext: context) as? CDMessage {
        
            message.author = author
            message.content = content
            message.group = group
            message.id = id
            
            message.createdAt = JSONDate.dateFromJSONString(createdAt)
            message.updatedAt = JSONDate.dateFromJSONString(updatedAt)
            
            return message
        }
        
        return nil
    }
    
    class func getMessageById(id: Int, context: NSManagedObjectContext) -> CDMessage? {
        let request = NSFetchRequest(entityName: "CDMessage")
        request.predicate = NSPredicate(format: " id = %@ ", argumentArray: [id])
        
       return (try? context.executeFetchRequest(request))?.first as? CDMessage
    }
    
    func getTimestamp() -> String {
        let dateFormatterGet = NSDateFormatter()
        dateFormatterGet.dateFormat = "MM-dd hh:mm"
        
        return dateFormatterGet.stringFromDate(self.createdAt!)
    }
}
