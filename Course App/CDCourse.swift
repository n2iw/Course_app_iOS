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
        if updatedAt.timeIntervalSinceNow >= -5 { //update at most once every 5 seconds
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
                
                for element in courses {
                    upsertFromApiJSON(element, context: context)
                }
            }
        }
    }
    
    class func upsertFromApiJSON(json: [String: AnyObject], context: NSManagedObjectContext) {
        
        guard
            let id = json["id"] as? Int,
            let name = json["name"] as? String,
            let createdAt = json["createdAt"] as? String,
            let updatedAt = json["updatedAt"] as? String
            else {
                return
        }
        
        
        var cs = getCourseById(id, context: context)
        if cs == nil {
            cs = NSEntityDescription.insertNewObjectForEntityForName("CDCourse", inManagedObjectContext: context) as? CDCourse
        }
        
        guard let course = cs
            else {
                return
        }
        
        course.id = id
        course.name = name
        course.createdAt = JSONDate.dateFromJSONString(createdAt)
        course.updatedAt = JSONDate.dateFromJSONString(updatedAt)
        
        if let lectures = json["lectures"] as? [[String: AnyObject]] {
            for lec in lectures {
                if let cdLecture = CDLecture.upsertFromApiJSON(lec, context: context) {
                    cdLecture.course = course
                }
            }
        }
    }
    
    class func getCourseById(id: Int, context: NSManagedObjectContext?) -> CDCourse? {
        let request = NSFetchRequest(entityName: "CDCourse")
        request.predicate = NSPredicate(format: " id = %@ ", argumentArray: [id])
        
        return (try? context?.executeFetchRequest(request))??.first as? CDCourse
    }

}
