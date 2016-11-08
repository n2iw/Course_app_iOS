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
        
        if let message = NSEntityDescription.insertNewObjectForEntityForName("CDMessage", inManagedObjectContext: context!) as? CDMessage {
        
            message.author = author
            message.content = content
            message.group = group
            message.id = id
            
            message.createdAt = JSONDate.dateFromJSONString(createdAt)
            message.updatedAt = JSONDate.dateFromJSONString(updatedAt)
            
            _ = try? context!.save()
            
            return message
        }
        
        return nil
    }

}
