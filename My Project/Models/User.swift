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

struct UserUpdate: Encodable, Identifiable {
    
    var id: String? = nil
    var email: String? = nil
    var username: String? = nil
    var profileImageURL: String? = nil
    var fcmToken: String? = nil
}

struct User: Codable, Identifiable {
    
    var id: String? = nil
    let email: String
    let username: String
    let profileImageURL: String
    var fcmToken: String?
    
    init(email: String, username: String, profileImageURL: String, fcmToken: String?) {
        self.email = email
        self.username = username
        self.profileImageURL = profileImageURL
        self.fcmToken = fcmToken
    }
}
