//
//  CDVideo.swift
//  Course App
//
//  Created by Ming Ying on 11/7/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import Foundation
import CoreData


class CDVideo: NSManagedObject {
    private static let server = APIClient(baseURL: Settings.apiServer)
    private static var updatedAt: NSDate = NSDate(timeIntervalSince1970: 0)
    
    class func deleteVideosForLecture(lecture: CDLecture ,inContext context: NSManagedObjectContext) {
        let request = NSFetchRequest(entityName: "CDVideo")
        request.predicate = NSPredicate(format: "lecture = %@", argumentArray: [lecture])
        
        if let videos = (try? context.executeFetchRequest(request)) as? [CDVideo] {
            for video in videos {
                context.deleteObject(video)
            }
        }
    }
    
    private class func truncate(inContext context: NSManagedObjectContext) {
        let request = NSFetchRequest(entityName: "CDVideo")
        
        if let videos = (try? context.executeFetchRequest(request)) as? [CDVideo] {
            for video in videos {
                context.deleteObject(video)
            }
        }
    }
    
    class func upsertFromApiJSON(json: [String: AnyObject], inContext context: NSManagedObjectContext, tryUpdate: Bool) -> CDVideo?{
        
        guard
            let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let createdAt = json["createdAt"] as? String,
            let updatedAt = json["updatedAt"] as? String,
            let url = json["url"] as? String
            
            else {
                return nil
        }
        
        var vid: CDVideo? = nil
        if tryUpdate {
            vid = getVideoById(id, inContext: context) ??
                NSEntityDescription.insertNewObjectForEntityForName("CDVideo", inManagedObjectContext: context) as? CDVideo
        } else {
            vid = NSEntityDescription.insertNewObjectForEntityForName("CDVideo", inManagedObjectContext: context) as? CDVideo
        }
        
        guard let video = vid
            else {
                return nil
        }
        
        video.id = id
        video.title = title
        video.url = url
        video.createdAt = JSONDate.dateFromJSONString(createdAt)
        video.updatedAt = JSONDate.dateFromJSONString(updatedAt)
        if let lecture = json["lecture"] as? [String: AnyObject] {
            video.lecture = CDLecture.getLectureByApiJSON(lecture, inContext: context)
        }
        
        video.remoteUrl = Settings.apiServer  + url.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        guard
            let remoteUrl = NSURL(string: video.remoteUrl!),
            let fileExtention = remoteUrl.pathExtension
            else {
                print("Video url wrong: \(video.url)")
                return nil
        }
        
        let folder = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        video.localFileUrl = folder.URLByAppendingPathComponent("video_\(video.id!).\(fileExtention)").absoluteString
        
        return video
    }
    
    class func getVideoById(id: Int, inContext context: NSManagedObjectContext?) -> CDVideo? {
        let request = NSFetchRequest(entityName: "CDVideo")
        request.predicate = NSPredicate(format: " id = %@ ", argumentArray: [id])
        
        return (try? context?.executeFetchRequest(request))??.first as? CDVideo
    }
}
