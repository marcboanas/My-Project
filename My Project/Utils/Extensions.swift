//
//  Extensions.swift
//  My Project
//
//  Created by Sophie Louise Boanas-Levitt on 13/07/2018.
//  Copyright © 2018 Marc Boanas. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

enum ErrorType: Error {
    case codingError
}

extension Encodable {
    func toJson(excluding keys: [String] = [String]()) throws -> [String: Any] {
        
        let objectData = try JSONEncoder().encode(self)
        let jsonObject = try JSONSerialization.jsonObject(with: objectData, options: [])
        
        guard var json = jsonObject as? [String: Any] else { throw ErrorType.codingError }
        
        for key in keys {
            json[key] = nil
        }
        
        return json
    }
}

extension DocumentSnapshot {
    func decode<T: Decodable>(as objectType: T.Type, includingId: Bool = true) throws -> T {
        var documentJSON = self.data()
        if includingId {
            documentJSON!["id"] = documentID
        }
        let documentData = try JSONSerialization.data(withJSONObject: documentJSON!, options: [])
        let decoderObject = try JSONDecoder().decode(objectType, from: documentData)
        return decoderObject
    }
}
