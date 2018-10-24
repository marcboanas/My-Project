//
//  Post.swift
//  My Project
//
//  Created by Sophie Louise Boanas-Levitt on 20/07/2018.
//  Copyright © 2018 Marc Boanas. All rights reserved.
//

import Foundation
import Firebase

struct Post: Codable, Identifiable {
    var id: String?
    let caption: String
    let imageUrl: String
    let imageWidth: CGFloat
    let imageHeight: CGFloat
    let userID: String
    var user: User? = nil
    let created_at: String?
    
    init(id: String?, caption: String, imageUrl: String, imageWidth: CGFloat, imageHeight: CGFloat, userID: String, user: User?, created_at: String?) {
        self.id = id
        self.caption = caption
        self.imageUrl = imageUrl
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.userID = userID
        self.user = user
        self.created_at = created_at
    }
}

extension Post {
    enum PostKeys: String, CodingKey {
        case id
        case caption
        case imageUrl
        case imageWidth
        case imageHeight
        case userID
        case created_at
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PostKeys.self)
        let id: String = try container.decode(String.self, forKey: .id)
        let caption: String = try container.decode(String.self, forKey: .caption)
        let imageUrl: String = try container.decode(String.self, forKey: .imageUrl)
        let imageWidth: Float = try container.decode(Float.self, forKey: .imageWidth)
        let imageHeight: Float = try container.decode(Float.self, forKey: .imageHeight)
        let userID: String = try container.decode(String.self, forKey: .userID)
        let created_at: String? = try container.decodeIfPresent(String.self, forKey: .created_at)
        self.init(id: id, caption: caption, imageUrl: imageUrl, imageWidth: CGFloat(imageWidth), imageHeight: CGFloat(imageHeight), userID: userID, user: nil, created_at: created_at)
    }
}
