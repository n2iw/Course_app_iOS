//
//  CourseList.swift
//  Course App
//
//  Created by Ming Ying on 10/10/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import Foundation

class CourseList {
    var courses: [Course] = Array()
    private let server: APIClient
    private let path: String
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    init(url: String, path: String) {
        server = APIClient(baseURL: url)
        self.path = path
        if let savedCourse = defaults.arrayForKey("Courses") {
            print("Load Saved course")
            for c in savedCourse {
                if c is [String: AnyObject] {
                    let course = Course(id: c["id"] as! Int, name: c["name"] as! String)
                    courses.append(course)
                }
            }
        }
        fetch() {
        }
    }
    
    func getCourses(callback: ( () -> Void)) {
        if courses.count == 0 {
            fetch(callback)
        } else {
            callback()
        }
    }
    
    private func fetch(callback: (() -> Void)?) {
        server.get(path) {success, data in
            if success {
                if let courses = data as? [[String:AnyObject]] {
                    print("Downloaded \(courses.count) courses")
                    self.courses = Array()
                    for element in courses {
                        self.courses.append(Course(id: element["id"] as! Int,
                            name: element["name"] as! String))
                    }
                    self.defaults.setObject(courses, forKey: "Courses")
                    self.defaults.synchronize()
                    callback?()
                }
            }
        }
    }
}