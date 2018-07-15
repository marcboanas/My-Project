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
    
    func createUser(withEmail email: String, username: String, password: String, photo profileImageData: Data) {
        
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
                    
                    guard let profileImageURL = url?.absoluteString else { return }
                    guard let user_uid = authData?.user.uid else { return }
                    
                    let user_profile = User(email: email, username: username, profileImageURL: profileImageURL)
                    
                    self.create(for: user_profile, in: .users, id: user_uid)
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
