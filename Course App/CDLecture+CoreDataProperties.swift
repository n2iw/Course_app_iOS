//
//  CDLecture+CoreDataProperties.swift
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

extension CDLecture {

    @NSManaged var serial_number: NSNumber?
    @NSManaged var name: String?
    @NSManaged var transcript_url: String?
    @NSManaged var id: NSNumber?
    @NSManaged var createdAt: NSDate?
    @NSManaged var updatedAt: NSDate?
    @NSManaged var course: CDCourse?
    @NSManaged var videos: NSSet?
    @NSManaged var messages: NSSet?

}
