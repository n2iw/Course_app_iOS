//
//  JSONDate.swift
//  Course App
//
//  Created by Ming Ying on 11/7/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import Foundation

class JSONDate {
    class func dateFromJSONString(dateString: String) -> NSDate? {
        let formater = NSDateFormatter()
        formater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return formater.dateFromString(dateString)
    }
}