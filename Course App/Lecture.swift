//
//  Lecture.swift
//  Course App
//
//  Created by Ming Ying on 9/1/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import Foundation

class Lecture {
    var name: String!
    var id: Int!
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

class LectureList {
    var lectures: [Lecture] = Array()
    private let server: APIClient
    private let path: String
    private let courseID: Int
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    init(url: String, path: String, courseID: Int) {
        server = APIClient(baseURL: url)
        self.path = path
        self.courseID = courseID
        if let savedLectures = defaults.arrayForKey("\(self.courseID)"){
            print("Load Saved lectures")
            for l in savedLectures {
                let lecture = Lecture(id: l["id"] as! Int, name: l["description"] as! String)
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
                        self.lectures.append(Lecture(id: element["id"] as! Int,
                            name: element["description"] as! String))
                    }
                    self.defaults.setObject( lectures, forKey: "\(self.courseID)")
                    self.defaults.synchronize()
                    callback?()
                }
            }
        }
    }
}