//
//  Settings.swift
//  Course App
//
//  Created by Ming Ying on 10/31/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import Foundation

public class Settings {
    //let apiServer = "http://localhost:1337"
    static let apiServer = "http://192.168.10.10:1337"
    static let socketServer = apiServer
    static let coursePath = "/course"
    static let lecturePath = "/lecture"
    
    static let FIRST_NAME = "firstName"
    static let LAST_NAME = "lastName"
    
    static private let defaults = NSUserDefaults.standardUserDefaults()
    
    private static var firstName: String?
    private static var lastName: String?
    
    static func getFirstName() -> String? {
        if firstName == nil {
            firstName = defaults.stringForKey(FIRST_NAME)
        }
        return firstName
    }
    
    static func setFirstName(name: String?) {
        if name != nil {
            firstName = name
            defaults.setObject( firstName, forKey: FIRST_NAME)
            defaults.synchronize()
        }
    }
    
    static func getLastName() -> String? {
        if lastName == nil {
            lastName = defaults.stringForKey(LAST_NAME)
            defaults.synchronize()
        }
        return lastName
    }
    
    static func setLastName(name: String?) {
        if name != nil {
            lastName = name
            defaults.setObject( firstName, forKey: LAST_NAME)
        }
    }
}
