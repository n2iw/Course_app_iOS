//
//  Message+CoreDataProperties.swift
//  Course App
//
//  Created by Ming Ying on 11/7/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Message {

    @NSManaged var author: String?
    @NSManaged var content: String?
    @NSManaged var createdAt: NSDate?
    @NSManaged var group: NSNumber?
    @NSManaged var id: NSNumber?

}
