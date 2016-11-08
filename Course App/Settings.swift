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
    static let apiServer = "http://192.168.10.10:1337" //local vagrant
//    static let apiServer = "https://shaban.rit.albany.edu" //local vagrant
//    static let apiServer = "https://shaban.rit.albany.edu/test" //local vagrant
    
    static let socketServer = apiServer
    static let coursePath = "/course"
    static let lecturePath = "/lecture"
    
    static let FIRST_NAME = "firstName"
    static let LAST_NAME = "lastName"
    static let PHONE = "phone"
    
    static private let defaults = NSUserDefaults.standardUserDefaults()
    
    private static var phone: String?
    
    static func getPhone() -> String? {
        if phone == nil {
            phone = defaults.stringForKey(PHONE)
        }
        return phone
    }
    
    static func setPhone(phone: String?) {
        if phone != nil {
            self.phone = phone
            defaults.setObject( phone, forKey: PHONE)
            defaults.synchronize()
        }
    }
}
