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
        let interval = abs(updatedAt.timeIntervalSinceNow)
        if interval <= Settings.UPDATE_INTERVAL { //update at most once every x seconds
            print("Downloaded lectures \(interval) seconds ago, skip this time")
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
                context.performBlock() {
                    self.truncate(inContext: context)
                    
                    for element in lcts {
                        upsertFromApiJSON(element, inContext: context, tryUpdate: false)
                    }
                    _ = try? context.save()
                }
            }
        }
    
    }
    
    private class func truncate(inContext context: NSManagedObjectContext) {
        let request = NSFetchRequest(entityName: "CDLecture")
        
        if let lectures = (try? context.executeFetchRequest(request)) as? [CDLecture] {
            for lecture in lectures {
                context.deleteObject(lecture)
            }
        }
    }
    

    class func upsertFromApiJSON(json: [String: AnyObject], inContext context: NSManagedObjectContext, tryUpdate: Bool) -> CDLecture?{
        
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
        
        
        var lec: CDLecture? = nil
        if tryUpdate {
            lec = getLectureById(id, inContext: context) ??
                    NSEntityDescription.insertNewObjectForEntityForName("CDLecture", inManagedObjectContext: context) as? CDLecture
        } else {
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
        
        let urlString = Settings.apiServer  + transcript_url
        lecture.remoteUrl = urlString
        
        guard let url = NSURL(string: urlString)
            else {
                print("\(urlString) is not URL")
                return nil
        }
        
        let fileExtention = url.pathExtension
//        let fileName = url.lastPathComponent
        
//        lecture.fileName = fileName
        lecture.fileName = name
        let folder = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        lecture.localFileUrl = folder.URLByAppendingPathComponent("lecture_\(lecture.id!).\(fileExtention!)").absoluteString
        
        if let course = json["course"] as? [String: AnyObject] {
            lecture.course = CDCourse.getCourseByApiJSON(course, inContext: context)
        }
        
        if let videos = json["videos"] as? [[String: AnyObject]] {
//            CDVideo.deleteVideosForLecture(lecture, inContext: context)
            for video in videos {
                if let cdVideo = CDVideo.upsertFromApiJSON(video, inContext: context, tryUpdate: true) {
                    cdVideo.lecture = lecture
                }
            }
        }

        return lecture
    }
    
    class func getLectureById(id: Int, inContext context: NSManagedObjectContext?) -> CDLecture? {
        let request = NSFetchRequest(entityName: "CDLecture")
        request.predicate = NSPredicate(format: " id = %@ ", argumentArray: [id])
        
       return (try? context?.executeFetchRequest(request))??.first as? CDLecture
    }
    
    class func getLectureByApiJSON(json: [String: AnyObject], inContext context: NSManagedObjectContext) -> CDLecture? {
        guard
            let id = json["id"] as? Int
            else {
                return nil
        }
        return getLectureById(id, inContext: context)
    }
}
