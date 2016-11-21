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
    
    class func fetchMessages(groupId: Int, context: NSManagedObjectContext?) -> [CDMessage] {
        let request = NSFetchRequest(entityName: "CDMessage")
        request.sortDescriptors = [NSSortDescriptor(
            key: "id",
            ascending: true,
            selector: nil
            )]
        let predicate = NSPredicate(format: " group = %@ ", argumentArray: [groupId])
        request.predicate = predicate
        
        let messages = try? context?.executeFetchRequest(request)
        
        return messages as! [CDMessage]
    }

    class func objectFromApiJSON(jsonData: AnyObject, inContext context: NSManagedObjectContext?) -> CDMessage? {
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
            where context != nil
        else {
                return nil
                
        }
        
        if let message = getMessageById(id, context: context) {
            message.author = firstName + lastName
            message.content = content
            message.group = groupId
            message.id = id
            
            message.createdAt = JSONDate.dateFromJSONString(createdAt)
            message.updatedAt = JSONDate.dateFromJSONString(updatedAt)
            
            context?.performBlock() {
                _ = try? context!.save()
            }
            
            return message
        } else if let message = NSEntityDescription.insertNewObjectForEntityForName("CDMessage", inManagedObjectContext: context!) as? CDMessage {
        
            message.author = firstName + lastName
            message.content = content
            message.group = groupId
            message.id = id
            
            message.createdAt = JSONDate.dateFromJSONString(createdAt)
            message.updatedAt = JSONDate.dateFromJSONString(updatedAt)
            
            context?.performBlock() {
                _ = try? context!.save()
            }
            
            return message
        }
        
        return nil
    }
    class func objectFromSocketJSON(jsonData: AnyObject, inContext context: NSManagedObjectContext?) -> CDMessage? {
        guard let json = jsonData as? [String: AnyObject],
            let content = json["content"] as? String,
            let author = json["authorName"] as? String,
            let group = json["group"] as? Int,
            let id = json["id"] as? Int,
            let createdAt = json["createdAt"] as? String,
            let updatedAt = json["updatedAt"] as? String
            where context != nil
        else {
                return nil
                
        }
        
        if let message = getMessageById(id, context: context) {
            message.author = author
            message.content = content
            message.group = group
            message.id = id
            
            message.createdAt = JSONDate.dateFromJSONString(createdAt)
            message.updatedAt = JSONDate.dateFromJSONString(updatedAt)
            
            context?.performBlock() {
                _ = try? context!.save()
            }
            
            return message
        } else if let message = NSEntityDescription.insertNewObjectForEntityForName("CDMessage", inManagedObjectContext: context!) as? CDMessage {
        
            message.author = author
            message.content = content
            message.group = group
            message.id = id
            
            message.createdAt = JSONDate.dateFromJSONString(createdAt)
            message.updatedAt = JSONDate.dateFromJSONString(updatedAt)
            
            context?.performBlock() {
                _ = try? context!.save()
            }
            
            return message
        }
        
        return nil
    }
    
    class func getMessageById(id: Int, context: NSManagedObjectContext?) -> CDMessage? {
        let request = NSFetchRequest(entityName: "CDMessage")
        request.predicate = NSPredicate(format: " id = %@ ", argumentArray: [id])
        
        var result : [AnyObject]?? = nil
        
        context?.performBlockAndWait() {
            result = try? context?.executeFetchRequest(request)
        }
        
        guard let messages = result as? [CDMessage]
        where messages.count > 0
        else {
            return nil
        }
        return messages[0]
    }
}
