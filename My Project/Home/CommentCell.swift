//
//  CommentCell.swift
//  My Project
//
//  Created by Sophie Louise Boanas-Levitt on 03/08/2018.
//  Copyright © 2018 Marc Boanas. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else { return }
            textView.text = comment.text
            guard let profileImageUrl = comment.user?.profileImageURL else { return }
            profileImageView.loadImage(urlString: profileImageUrl)
            setupAttributedText()
        }
    }
    
    fileprivate func setupAttributedText() {
        guard let comment = comment else { return }
        guard let username = comment.user?.username else { return }
        
        let usernameTextAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)]
        let attributedText = NSMutableAttributedString(string: username, attributes: usernameTextAttributes)
        
        let commentTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
        attributedText.append(NSMutableAttributedString(string: ": \(comment.text)", attributes: commentTextAttributes))
        
        textView.attributedText = attributedText
    }
    
    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isScrollEnabled = false
        //label.numberOfLines = 0
        //label.backgroundColor = .lightGray
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40/2
        
        addSubview(textView)
        textView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: nil, height: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
