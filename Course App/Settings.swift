//
//  Settings.swift
//  Course App
//
//  Created by Ming Ying on 10/31/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import Foundation

public class Settings {
//    static let apiServer = "http://104.236.56.153:1337" //Ocean2
//    static let apiServer = "http://192.168.10.10:1337" //local vagrant
    static let apiServer = "http://localhost:1337" //localhost
//    static let apiServer = "https://shaban.rit.albany.edu" //production
//    static let apiServer = "https://shaban-test.rit.albany.edu" //testing
//    static let apiServer = "https://shaban-stage.rit.albany.edu" //staging
    
    static let socketServer = apiServer
    static let coursePath = "/course"
    static let lecturePath = "/lecture"
    static let messagePath = "/messages"
    static let userPath = "/users"
    
    static let USER_NAME = "userName"
    static let USER_ID = "phone"
    static let SETTINGS_TAB_INDEX = 1 //tab index of settings tab
    static let COURSES_TAB_INDEX = 0 //tab index of courses tab
    static let UPDATE_INTERVAL: Double = 30 // Minimal seconds interval for updating courses
    
    static private let defaults = NSUserDefaults.standardUserDefaults()
    
    private static var phone: String?
    private static var userName: String?
    private static var server = APIClient(baseURL: apiServer)
    
    
    static func getPhone() -> String? {
        if phone == nil {
            phone = defaults.stringForKey(USER_ID)
        }
        return phone
    }
    
    static func setPhone(phone: String, succeed: (String) -> Void, fail: () -> Void) {
        self.phone = phone
        defaults.setObject( phone, forKey: USER_ID)
        self.userName = nil
        defaults.setObject( self.userName, forKey: USER_NAME)
        defaults.synchronize()
        
        let path = userPath + "?\(USER_ID)=\(phone)"
        server.get(path) {success, data in
            if success {
                guard let users = data as? [[String: AnyObject]]
                    where users.count > 0
                    else {
                        fail()
                        return
                    }
                let user = users[0]
                guard let firstName = user["firstName"],
                    let lastName = user["lastName"]
                    else {
                        fail()
                        return
                    }
                
                self.userName = "\(firstName) \(lastName)"
                defaults.setObject( self.userName, forKey: USER_NAME)
                defaults.synchronize()
                succeed(self.userName!)
            } else {
                fail()
            }
        }
    }
    
    static func getUserName() -> String? {
        if userName == nil {
            userName = defaults.stringForKey(USER_NAME)
        }
        return userName
    }
}
