//
//  CustomPhotoSelectorCell.swift
//  My Project
//
//  Created by Sophie Louise Boanas-Levitt on 19/07/2018.
//  Copyright © 2018 Marc Boanas. All rights reserved.
//

import UIKit

class CustomPhotoSelectorCell: UICollectionViewCell {
    
    let photoImageView: UIImageView = {
        let image_view = UIImageView()
        image_view.backgroundColor = .lightGray
        image_view.contentMode = .scaleAspectFill
        image_view.clipsToBounds = true
        return image_view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
