//
//  LectureList.swift
//  Course App
//
//  Created by Ming Ying on 10/10/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import Foundation

class LectureList {
    var lectures: [Lecture] = Array()
    private let baseUrl: String
    private let server: APIClient
    private let path: String
    private let courseID: Int
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    init(url: String, path: String, courseID: Int) {
        self.baseUrl = url
        server = APIClient(baseURL: url)
        self.path = path
        self.courseID = courseID
        if let savedLectures = defaults.arrayForKey("\(self.courseID)"){
            print("Load Saved lectures")
            for l in savedLectures {
                let lecture = Lecture(id: l["id"] as! Int,
                                      name: l["description"] as! String,
                                      transcript_url: l["transcript_url"] as! String)
                lectures.append(lecture)
            }
        }
        fetch() {
        }
    }
    
    
    func getLectures(callback: ( () -> Void)) {
        if lectures.count == 0 {
            fetch(callback)
        } else {
            callback()
        }
    }
    
    private func fetch(callback: (() -> Void)?) {
        server.get(path) {success, data in
            if success {
                if let lectures = data as? [[String:AnyObject]] {
                    print("Downloaded \(lectures.count) lectures")
                    self.lectures = Array()
                    for element in lectures {
                        let lecture = Lecture(id: element["id"] as! Int,
                            name: element["description"] as! String,
                            transcript_url: element["transcript_url"] as! String)
                        self.lectures.append(lecture)
                        if let videos = element["videos"] as? [[String: AnyObject]] {
                            for videoData in videos {
                               let video = Video(id: (videoData["id"] as! Int), lecture: (videoData["lecture"] as! Int), title: (videoData["title"] as! String), url: (videoData["url"] as! String))
                                lecture.videos.append(video)
                            }
                        }
                    }
                    self.defaults.setObject( lectures, forKey: "\(self.courseID)")
                    self.defaults.synchronize()
                    callback?()
                }
            }
        }
    }
}