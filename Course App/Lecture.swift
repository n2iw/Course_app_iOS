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
    let transcript_url: String
    var videos: [Video] = []
    
    init(id: Int, name: String, transcript_url: String) {
        self.id = id
        self.name = name
        self.transcript_url = transcript_url
    }
}

