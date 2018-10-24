//
//  UserProfilePhotoCell.swift
//  My Project
//
//  Created by Sophie Louise Boanas-Levitt on 21/07/2018.
//  Copyright © 2018 Marc Boanas. All rights reserved.
//

import UIKit

class UserProfilePhotoCell: UICollectionViewCell {
    
    var post: Post? {
        didSet {
            setCellPhotoImageView()
        }
    }
    
    fileprivate func setCellPhotoImageView() {
        guard let post = post else { return }
        photoImageView.loadImage(urlString: post.imageUrl)
    }
    
    let photoImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
