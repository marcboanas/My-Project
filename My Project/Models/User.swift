//
//  User.swift
//  My Project
//
//  Created by Sophie Louise Boanas-Levitt on 13/07/2018.
//  Copyright © 2018 Marc Boanas. All rights reserved.
//

import Foundation

protocol Identifiable {
    var id: String? { get set }
}

struct User: Codable, Identifiable {
    
    var id: String? = nil
    var email: String
    var username: String
    var profileImageURL: String
    
    init(email: String, username: String, profileImageURL: String) {
        self.email = email
        self.username = username
        self.profileImageURL = profileImageURL
    }
}
