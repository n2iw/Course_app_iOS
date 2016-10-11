//
//  Lecture.swift
//  Course App
//
//  Created by Ming Ying on 9/1/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import Foundation

class Lecture {
    let name: String
    let id: Int
    let video_url: String
    
    init(id: Int, name: String, video_url: String) {
        self.id = id
        self.name = name
        self.video_url = video_url
    }
}

