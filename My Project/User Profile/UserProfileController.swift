//
//  UserProfileController.swift
//  My Project
//
//  Created by Sophie Louise Boanas-Levitt on 14/07/2018.
//  Copyright © 2018 Marc Boanas. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate {
    
    var user: User?
    
    let cellID: String = "cellID"
    
    let homePostCellID: String = "homePostCellID"
    
    var isGridView: Bool = true
    
    func didChangeToListView() {
        isGridView = false
        collectionView?.reloadData()
    }
    
    func didChangeToGridView() {
        isGridView = true
        collectionView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        
        if user == nil {
            FireService.shared.getCurrentUser { (current_user) in
                self.user = current_user
                self.navigationItem.title = current_user.username
                self.collectionView?.reloadData()
            }
        } else {
            navigationItem.title = self.user?.username ?? ""
            collectionView?.reloadData()
        }
        
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
        
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellID)
        
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellID)
        
        setupLogoutButton()
        
        fetchPaginatedPosts()
    }
    
    var posts = [Post]()
    var isFinishedPaging = false
    var lastDocument: DocumentSnapshot?
    
    fileprivate func fetchPaginatedPosts() {
        FireService.shared.paginatedUserPosts(for: user?.id, lastDocument: lastDocument, limit: 3) { (posts, lastDocument) in
            guard let posts = posts else { return }
            guard let lastDocument = lastDocument as? DocumentSnapshot else { return }
            self.lastDocument = lastDocument
            
            if posts.count < 3 {
                self.isFinishedPaging = true
                print("Finished paging")
            }
            
            for post in posts {
                var userPost = post
                userPost.user = self.user
                self.posts.append(userPost)
            }
            self.collectionView?.reloadData()
        }
    }
    
//    fileprivate func fetchPosts() {
//        FireService.shared.usersCollection(of: .posts, for: user?.id, returning: Post.self) { (posts) in
//            if let posts = posts {
//                self.posts = []
//                for post in posts {
//                    var userPost = post
//                    userPost.user = self.user
//                    self.posts.append(userPost)
//                }
//                self.collectionView?.reloadData()
//            } else {
//                print("Error obtaining user's posts")
//            }
//        }
//    }
    
    fileprivate func setupLogoutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogout))
    }
    
    @objc func handleLogout() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            print("Logging out...")
            do {
                try Auth.auth().signOut()
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
            } catch {
                print(error)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == posts.count - 1 && !isFinishedPaging {
            print("Paginating for posts")
            fetchPaginatedPosts()
        }
        
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! UserProfilePhotoCell
            cell.post = posts[indexPath.item]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellID, for: indexPath) as! HomePostCell
            cell.post = posts[indexPath.item]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isGridView {
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        } else {
            var height: CGFloat = 40 + 8 + 8 // userprofileimageview + padding
            height += view.frame.width // post's photo
            height += 50 // action button's beneath photo
            height += 60 // post's caption
            return CGSize(width: view.frame.width, height: height)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind   , withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        
        header.user = self.user
        
        header.delegate = self
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 200)
    }
}
