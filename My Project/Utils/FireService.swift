//
//  FireService.swift
//  My Project
//
//  Created by Sophie Louise Boanas-Levitt on 13/07/2018.
//  Copyright © 2018 Marc Boanas. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class FireService {
    private init() {}
    static let shared = FireService()
    
    func configure() {
        FirebaseApp.configure()
    }
    
    private func reference(to collectionReference: FireCollectionReference) -> CollectionReference {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        return db.collection(collectionReference.rawValue)
    }
    
    func isFollowing(_ userId: String, completion: @escaping (_ following: Bool?) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        reference(to: .users).document(currentUserId).collection("following").whereField("userId", isEqualTo: userId).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if (snapshot.documents.count > 0) {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func followUser(_ followUserId: String, completion: @escaping (_ success: Bool?) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let userCollectionReference = reference(to: .users)
        let followingData = ["userId": followUserId]
        let followerData = ["userId": currentUserId]
        userCollectionReference.document(currentUserId).collection("following").addDocument(data: followingData) { (error) in
            if let error = error {
                print("Error following user: ", error)
                return
            }
            userCollectionReference.document(followUserId).collection("followers").addDocument(data: followerData, completion: { (error) in
                if let error = error {
                    print("Error adding user to followers: ", error)
                    userCollectionReference.document(currentUserId).collection("following").whereField("userId", isEqualTo: followUserId).getDocuments(completion: { (snapshot, error) in
                        if let error = error {
                            print("Error removing following user: ", error)
                            return
                        }
                        guard let snapshot = snapshot else { return }
                        for document in snapshot.documents {
                            document.reference.delete()
                        }
                    })
                }
                return completion(true)
            })
        }
    }
    
    func unfollowUser(_ unfollowUserId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let userCollectionReference = reference(to: .users)
        userCollectionReference.document(currentUserId).collection("following").whereField("userId", isEqualTo: unfollowUserId).getDocuments { (snapshot, error) in
            if let error = error {
                print("There was an error unfollowing the user: ", error)
                return
            }
            guard let snapshot = snapshot else { return }
            for document in snapshot.documents {
                document.reference.delete()
            }
            userCollectionReference.document(unfollowUserId).collection("followers").whereField("userId", isEqualTo: currentUserId).getDocuments(completion: { (snapshot, error) in
                if let error = error {
                    print("Error removing current user from user's follower list: ", error)
                    return
                }
                guard let snapshot = snapshot else { return }
                for document in snapshot.documents {
                    document.reference.delete()
                }
            })
        }
    }
    
    func createComment(postId: String, comment: Comment, completion: @escaping (_ success: Bool?) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        var userComment = comment
        userComment.userId = currentUserId
        do {
            let json = try userComment.toJson(excluding: ["id"])
            let postsCollection = reference(to: .posts).document(postId).collection("comments")
            postsCollection.addDocument(data: json) { (error) in
                if let error = error {
                    print("Unable to create comment in firebase: ", error)
                    return
                }
                print("Successfully created the comment in firebase")
                return completion(true)
            }
        } catch {
            print(error)
        }
    }
    
    func create<T: Encodable>(for encodableObject: T, in collectionReference: FireCollectionReference, id documentId: String? = nil) {
        
        do {
            let json = try encodableObject.toJson(excluding: ["id"])
            let collectionRef = reference(to: collectionReference)
            if let documentId = documentId {
                let documentRef = collectionRef.document(documentId)
                documentRef.setData(json)
            } else {
                collectionRef.addDocument(data: json)
            }
        } catch {
            print(error)
        }
    }
    
    func createUser(withEmail email: String, username: String, password: String, photo profileImageData: Data, completion: @escaping (_ success: Bool?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (authData, error) in
            
            if let error = error {
                print("Failed to create user: ", error)
                return
            }
            
            print("Successfully created user: ", authData?.user.uid ?? "")
            
            // Save user profile image (Firebase Storage)
            
            let filename = NSUUID().uuidString
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let profileImageRef = storageRef.child("profile_images").child(filename)

            profileImageRef.putData(profileImageData, metadata: nil, completion: { (metadata, err) in
                
                if let err = err {
                    print("Failed to upload profile image: ", err)
                    return
                }
                
                profileImageRef.downloadURL(completion: { (url, err) in
                    
                    if let err = err {
                        print("There was an error getting the image download url from Firebase: ", err)
                        return
                    }
                    
                    guard let profileImageURL = url?.absoluteString else {
                        return
                    }
                    
                    guard let user_uid = authData?.user.uid else {
                        return
                    }
                    
                    let fcmToken: String? = Messaging.messaging().fcmToken
                    
                    let user_profile = User(email: email, username: username, profileImageURL: profileImageURL, fcmToken: fcmToken)
                    
                    self.create(for: user_profile, in: .users, id: user_uid)
                    
                    return completion(true)
                })
            })
        }
    }
    
    func getCurrentUser(completion: @escaping (User) -> Void) {
        guard let user_uid = Auth.auth().currentUser?.uid else { return }
        reference(to: .users).document(user_uid).addSnapshotListener { (user, error) in
            if let error = error {
                print("There was an error getting the current user from firebase firestore: ", error)
                return
            }
            
            guard let user = user else { return }
            
            do {
                let userObject = try user.decode(as: User.self)
                completion(userObject)
            } catch {
                print(error)
            }
        }
    }
    
    
    
    func paginatedUserPosts(for userID: String?, lastDocument: Any?, limit: Int, completion: @escaping ([Post]?, Any?) -> Void) {
        guard let uid = userID ?? Auth.auth().currentUser?.uid else { return }
        let ref = reference(to: .posts)
        var query = ref.whereField("userID", isEqualTo: uid)
        if let lastDocument = lastDocument as? DocumentSnapshot {
            query = query.start(afterDocument: lastDocument)
        }
        query = query.limit(to: limit)
        query.getDocuments { (posts, error) in
            if let error = error {
                print("There was an error getting user's posts from Firebase: ", error)
                return
            }
            guard let posts = posts else { return }
            
            do {
                var objects = [Post]()
                var lastPost: DocumentSnapshot?
                
                for (index, post) in posts.documents.enumerated() {
                    let object = try post.decode(as: Post.self)
                    objects.insert(object, at: 0)
                    if index == (posts.count - 1) {
                        lastPost = post
                    }
                }
                
                completion(objects, lastPost)
            } catch {
                print(error)
            }
        }
    }
    
    func usersCollection<T: Decodable>(of collectionReference: FireCollectionReference, for userID: String?, returning objectType: T.Type, completion: @escaping ([T]?) -> Void) {
        guard let userID = userID ?? Auth.auth().currentUser?.uid else { return }
        reference(to: collectionReference).whereField("userID", isEqualTo: userID).getDocuments { (querySnapshot, error) in
            
            guard let snapshot = querySnapshot else { return }
            
            do {
                var objects = [T]()
                for document in snapshot.documents {
                    let object = try document.decode(as: objectType.self)
                    objects.insert(object, at: 0)
                }
                
                completion(objects)
            } catch {
                print(error)
            }
        }
    }
    
    func readOncePostComments(postId: String, completion: @escaping ([Comment]) -> Void) {
        let commentsRef = reference(to: .posts).document(postId).collection("comments")
        commentsRef.order(by: "creationDate", descending: true).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            do {
                var comments = [Comment]()
                for document in snapshot.documents {
                    let object = try document.decode(as: Comment.self)
                    comments.append(object)
                }
                completion(comments)
            } catch {
                print(error)
            }
        }
    }
    
    func readOnceCollection<T: Decodable>(from collectionReference: FireCollectionReference, returning objectType: T.Type, completion: @escaping ([T]) -> Void) {
        
        reference(to: collectionReference).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            do {
                var objects = [T]()
                for document in snapshot.documents {
                    let object = try document.decode(as: objectType.self)
                    objects.append(object)
                }
                completion(objects)
            } catch {
                print(error)
            }
        }
    }
    
    func readCollection<T: Decodable>(from collectionReference: FireCollectionReference, returning objectType: T.Type, completion: @escaping ([T]) -> Void) {
        
        reference(to: collectionReference).addSnapshotListener { (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            do {
                var objects = [T]()
                for document in snapshot.documents {
                    let object = try document.decode(as: objectType.self)
                    objects.append(object)
                }
                
                completion(objects)
            } catch {
                print(error)
            }
        }
    }
    
    func readOnceDocument<T: Decodable>(from collectionReference: FireCollectionReference, id documentId: String, returning objectType: T.Type, completion: @escaping (T) -> Void) {
        
        reference(to: collectionReference).document(documentId).getDocument { (document, error) in
            
            guard let document = document else { return }
            
            do {
                let object = try document.decode(as: objectType.self)
                completion(object)
            } catch {
                print(error)
            }
        }
    }
    
    func readDocument<T: Decodable>(from collectionReference: FireCollectionReference, id documentId: String, returning objectType: T.Type, completion: @escaping (T) -> Void) {
        
        reference(to: collectionReference).document(documentId).addSnapshotListener { (document, error) in
            
            guard let document = document else { return }
            
            do {
                let object = try document.decode(as: objectType.self)
                completion(object)
            } catch {
                print(error)
            }
        }
    }
    
    func update<T: Encodable & Identifiable>(for encodableObject: T, in collectionReference: FireCollectionReference) {
        
        do {
            let json = try encodableObject.toJson(excluding: ["id"])
            guard let id = encodableObject.id else { throw ErrorType.codingError }
            reference(to: collectionReference).document(id).setData(json, merge: true)
        } catch {
            print(error)
        }
    }
    
    func delete<T: Identifiable>(_ identifiableObject: T, in collectionReference: FireCollectionReference) {
        
        do {
            guard let id = identifiableObject.id else { throw ErrorType.codingError }
            reference(to: collectionReference).document(id).delete()
        } catch {
            print(error)
        }
    }
}
