//
//  Message.swift
//  Course App
//
//  Created by Ming Ying on 11/7/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import Foundation

class Message {
    var author: String?
    var content: String?
    
    init(author: String, content: String) {
        self.author = author
        self.content = content
    }
}
