//
//  CustomImageView.swift
//  My Project
//
//  Created by Sophie Louise Boanas-Levitt on 21/07/2018.
//  Copyright © 2018 Marc Boanas. All rights reserved.
//

import UIKit

var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var lastURLUsedToLoadImage: String?
    
    func loadImage(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        self.image = nil
        
        lastURLUsedToLoadImage = urlString
        
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("There was an error downloading the post image from url: ", error)
                return
            }
            
            if url.absoluteString != self.lastURLUsedToLoadImage {
                return
            }

            guard let data = data else { return }
            let image = UIImage(data: data)
            
            imageCache[url.absoluteString] = image
            
            DispatchQueue.main.async {
                self.image = image
            }
            }.resume()
    }
}
