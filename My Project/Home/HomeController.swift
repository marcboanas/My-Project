//
//  HomeController.swift
//  My Project
//
//  Created by Sophie Louise Boanas-Levitt on 21/07/2018.
//  Copyright © 2018 Marc Boanas. All rights reserved.
//

import UIKit

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomePostCellDelegate {
    
    let cellID = "cellId"
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)
        
        collectionView?.backgroundColor = .white
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellID)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        setupNavigationItems()
        fetchPosts()
    }
    
    @objc fileprivate func handleUpdateFeed() {
        handleRefresh()
    }
    
    @objc fileprivate func handleRefresh() {
        print("Refreshing...")
        fetchPosts()
    }
    
    static var cachedUsers = [String: User]()
    
    fileprivate func fetchPosts() {
        FireService.shared.readOnceCollection(from: .posts, returning: Post.self) { (posts) in
            
            self.collectionView?.refreshControl?.endRefreshing()
            
            self.posts = []
            for post in posts {
                var userPost = post
                let uid = post.userID
                
                if let cachedUser = HomeController.cachedUsers[uid] {
                    userPost.user = cachedUser
                    self.posts.append(userPost)
                    if (posts.count == self.posts.count) {
                        self.collectionView?.reloadData()
                    }
                } else {
                
                    FireService.shared.readOnceDocument(from: .users, id: uid, returning: User.self, completion: { (user) in
                        HomeController.cachedUsers[uid] = user
                        userPost.user = user
                        self.posts.append(userPost)
                        if (posts.count == self.posts.count) {
                            self.collectionView?.reloadData()
                        }
                    })
                }
            }
        }
    }
    
    fileprivate func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3"), style: .plain, target: self, action: #selector(handleCamera))
    }
    
    @objc fileprivate func handleCamera() {
        let cameraController = CameraController()
        present(cameraController, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! HomePostCell
        cell.post = posts[indexPath.item]
        cell.delegate = self
        return cell
    }
    
    func didTapComment(post: Post) {
        let layout = UICollectionViewFlowLayout()
        let commentsController = CommentsController(collectionViewLayout: layout)
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didTapLike(post: Post) {
        print("like post..")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 40 + 8 + 8 // userprofileimageview + padding
        height += view.frame.width // post's photo
        height += 50 // action button's beneath photo
        height += 60 // post's caption
        
        return CGSize(width: view.frame.width, height: height)
    }
}
