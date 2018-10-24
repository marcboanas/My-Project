//
//  CommentsController.swift
//  My Project
//
//  Created by Sophie Louise Boanas-Levitt on 31/07/2018.
//  Copyright © 2018 Marc Boanas. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class CommentsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var post: Post?
    
    var comments = [Comment]()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        
        collectionView?.backgroundColor = .white
        tabBarController?.tabBar.isHidden = true
        navigationItem.title = "Comments"
        collectionView?.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        
        fetchComments()
    }
    
    fileprivate func fetchComments() {
        guard let postId = post?.id else { return }
        FireService.shared.readOncePostComments(postId: postId) { (comments) in
            
            self.comments = []
            
            print("Fetching users")
            
            for comment in comments {
                var userComment = comment
                guard let uid = userComment.userId else { return }
                if let cachedUser = HomeController.cachedUsers[uid] {
                    userComment.user = cachedUser
                    self.comments.append(userComment)
                    if (self.comments.count == comments.count) {
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    }
                } else {
                
                    FireService.shared.readOnceDocument(from: .users, id: uid, returning: User.self, completion: { (user) in
                        HomeController.cachedUsers[uid] = user
                        userComment.user = user
                        self.comments.append(userComment)
                        if (self.comments.count == comments.count) {
                            DispatchQueue.main.async {
                                self.collectionView?.reloadData()
                            }
                        }
                    })
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        cell.comment = comments[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40 + 8 + 8, estimatedSize.height)
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    let commentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter comment"
        return textField
    }()
    
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        containerView.backgroundColor = .white
        
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        submitButton.addTarget(self, action: #selector(handleSubmitComment), for: .touchUpInside)
        containerView.addSubview(submitButton)
        submitButton.anchor(top: containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: nil)
        
        containerView.addSubview(self.commentTextField)
        self.commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: submitButton.leftAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: nil, height: nil)
        
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        
        containerView.addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 1)
        
        return containerView
    }()
    
    @objc fileprivate func handleSubmitComment() {
        guard let post = post else { return }
        guard let id = post.id else { return }
        guard let commentText = commentTextField.text, commentText.count > 0 else { return }
        let creationDate = Date().timeIntervalSince1970
        let comment = Comment(text: commentText, creationDate: creationDate)
        let postId = id
        commentTextField.resignFirstResponder()
        commentTextField.text = ""
        FireService.shared.createComment(postId: postId, comment: comment) { (success) in
            guard let success = success else { return }
            print("The comment was successfully created: ", success)
            self.fetchComments()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}
