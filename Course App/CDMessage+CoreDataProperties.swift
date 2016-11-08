//
//  CDMessage+CoreDataProperties.swift
//  Course App
//
//  Created by Ming Ying on 11/8/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CDMessage {

    @NSManaged var author: String?
    @NSManaged var content: String?
    @NSManaged var createdAt: NSDate?
    @NSManaged var id: NSNumber?
    @NSManaged var authorName: String?
    @NSManaged var updatedAt: NSDate?
    @NSManaged var group: NSNumber?

}
