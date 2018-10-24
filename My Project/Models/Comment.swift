//
//  Comment.swift
//  My Project
//
//  Created by Sophie Louise Boanas-Levitt on 03/08/2018.
//  Copyright © 2018 Marc Boanas. All rights reserved.
//

import Foundation

struct Comment: Codable, Identifiable {
    
    var id: String? = nil
    let text: String
    var userId: String? = nil
    let creationDate: TimeInterval?
    var user: User? = nil
    
    init(text: String, creationDate: TimeInterval?) {
        self.text = text
        self.creationDate = creationDate
    }
}
