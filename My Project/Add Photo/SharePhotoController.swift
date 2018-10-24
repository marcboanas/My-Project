//
//  SharePhotoController.swift
//  My Project
//
//  Created by Sophie Louise Boanas-Levitt on 20/07/2018.
//  Copyright © 2018 Marc Boanas. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class SharePhotoController: UIViewController {
    
    var selectedImage: UIImage? {
        didSet {
            self.imageView.image = selectedImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        
        setupImageAndTextViews()
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        return textView
    }()
    
    fileprivate func setupImageAndTextViews() {
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        let containerView = UIView()
        containerView.backgroundColor = .white
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 100)
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 84, height: nil)
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
    }
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "updateFeed")
    
    @objc func handleShare() {
        guard let image = selectedImage else { return }
        guard let caption = textView.text, caption.count > 0 else { return }
        guard let uploadData = UIImageJPEGRepresentation(image, 0.5) else { return }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("post_images").child(filename)
        storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("There was an error storage the post image to Firebase: ", error)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                return
            }
            
            storageRef.downloadURL(completion: { (url, error) in
                if let error = error {
                    print("There was an error getting the download URL for the post image: ", error)
                    return
                }
                
                guard let imageUrl = url?.absoluteString else { return }
                guard let userId = Auth.auth().currentUser?.uid else { return }
                
                guard let _ = Auth.auth().currentUser?.uid else { return }
                let post = Post(id: nil, caption: caption, imageUrl: imageUrl, imageWidth: image.size.width, imageHeight: image.size.height, userID: userId, user: nil, created_at: nil)
                FireService.shared.create(for: post, in: .posts)
                self.dismiss(animated: true, completion: nil)
                
                NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
            })
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
