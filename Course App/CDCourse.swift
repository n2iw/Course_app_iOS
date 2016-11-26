//
//  CDCourse.swift
//  Course App
//
//  Created by Ming Ying on 11/7/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import Foundation
import CoreData


class CDCourse: NSManagedObject {
    
    private static let server = APIClient(baseURL: Settings.apiServer)
    private static var updatedAt: NSDate = NSDate(timeIntervalSince1970: 0)

    class func fetchCourses(context: NSManagedObjectContext) {
        let interval = abs(updatedAt.timeIntervalSinceNow)
        if interval <= Settings.UPDATE_INTERVAL { //update at most once every x seconds
            print("Downloaded courses \(interval) seconds ago, skip this time")
            return
        }
        
        server.get(Settings.coursePath) {success, data in
            if success {
                guard let courses = data as? [[String:AnyObject]]
                    else {
                        return
                }
                
                print("Downloaded \(courses.count) courses")
                self.updatedAt = NSDate()
                
                context.performBlock() {
                    self.truncate(context)
                    
                    for element in courses {
                        upsertFromApiJSON(element, context: context, tryUpdate: false)
                    }
                    _ = try? context.save()
                }
            }
        }
    }
    
    private class func truncate(context: NSManagedObjectContext) {
        let request = NSFetchRequest(entityName: "CDCourse")
        
        if let courses = (try? context.executeFetchRequest(request)) as? [CDCourse] {
            for course in courses {
                context.deleteObject(course)
            }
            
        }
    }
    
    class func upsertFromApiJSON(json: [String: AnyObject], context: NSManagedObjectContext, tryUpdate: Bool) {
        
        guard
            let id = json["id"] as? Int,
            let name = json["name"] as? String,
            let createdAt = json["createdAt"] as? String,
            let updatedAt = json["updatedAt"] as? String
            else {
                return
        }
        
        var cs: CDCourse? = nil
        if tryUpdate {
            cs = getCourseById(id, inContext: context) ??
                NSEntityDescription.insertNewObjectForEntityForName("CDCourse", inManagedObjectContext: context) as? CDCourse
        } else {
            cs = NSEntityDescription.insertNewObjectForEntityForName("CDCourse", inManagedObjectContext: context) as? CDCourse
        }
        
        guard
            let course = cs
            else {
                return
        }
        
        course.id = id
        course.name = name
        course.createdAt = JSONDate.dateFromJSONString(createdAt)
        course.updatedAt = JSONDate.dateFromJSONString(updatedAt)
        
        if let lectures = json["lectures"] as? [[String: AnyObject]] {
            for lec in lectures {
                if let cdLecture = CDLecture.upsertFromApiJSON(lec, inContext: context, tryUpdate: true) {
                    cdLecture.course = course
                }
            }
        }
    }
    
    class func getCourseById(id: Int, inContext context: NSManagedObjectContext?) -> CDCourse? {
        let request = NSFetchRequest(entityName: "CDCourse")
        request.predicate = NSPredicate(format: " id = %@ ", argumentArray: [id])
        
        return (try? context?.executeFetchRequest(request))??.first as? CDCourse
    }
    
    class func getCourseByApiJSON(json: [String: AnyObject], inContext context: NSManagedObjectContext) -> CDCourse? {
        guard
            let id = json["id"] as? Int
            else {
                return nil
        }
        return getCourseById(id, inContext: context)
    }
}
