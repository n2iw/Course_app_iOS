//
//  CDLecture.swift
//  Course App
//
//  Created by Ming Ying on 11/7/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import Foundation
import CoreData


class CDLecture: NSManagedObject {

    private static let server = APIClient(baseURL: Settings.apiServer)
    private static var updatedAt: NSDate = NSDate(timeIntervalSince1970: 0)
    
    class func fetchLectures(course: CDCourse, context: NSManagedObjectContext) {
        if updatedAt.timeIntervalSinceNow >= -5 { //update at most once every 5 seconds
            return
        }
        
        server.get(Settings.lecturePath) {success, data in
            if success {
                guard let lcts = data as? [[String:AnyObject]]
                    else {
                        return
                }
                
                print("Downloaded \(lcts.count) lectures")
                self.updatedAt = NSDate()
                
                for element in lcts {
                    upsertFromApiJSON(element, context: context)
                    //        if let lectures = json["lectures"] as? [[String: AnyObject]] {
                    //            for lec in lectures {
                    //                CDLecture.upsertFromApiJSON(lec, context: context)
                    //            }
                    //        }
                }
            }
        }
    
    }
    class func upsertFromApiJSON(json: [String: AnyObject], context: NSManagedObjectContext) -> CDLecture?{
        
        guard
            let id = json["id"] as? Int,
            let name = json["description"] as? String,
            let serial_number = json["serial_number"] as? Int,
            let transcript_url = json["transcript_url"] as? String,
            let createdAt = json["createdAt"] as? String,
            let updatedAt = json["updatedAt"] as? String
            else {
                return nil
        }
        
        
        var lec = getLectureById(id, context: context)
        if lec == nil {
            lec = NSEntityDescription.insertNewObjectForEntityForName("CDLecture", inManagedObjectContext: context) as? CDLecture
        }
        
        guard let lecture = lec
            else {
                return nil
        }
        
        lecture.id = id
        lecture.name = name
        lecture.serial_number = serial_number
        lecture.transcript_url = transcript_url
        lecture.createdAt = JSONDate.dateFromJSONString(createdAt)
        lecture.updatedAt = JSONDate.dateFromJSONString(updatedAt)

        return lecture
    }
    
    class func getLectureById(id: Int, context: NSManagedObjectContext?) -> CDLecture? {
        let request = NSFetchRequest(entityName: "CDLecture")
        request.predicate = NSPredicate(format: " id = %@ ", argumentArray: [id])
        
        
       return (try? context?.executeFetchRequest(request))??.first as? CDLecture
    }


}
