//
//  Course.swift
//  Course App
//
//  Created by Ming Ying on 9/1/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import Foundation

class Course {
    var name: String!
    var id: Int!
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}