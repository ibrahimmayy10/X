//
//  UserProfileViewModel.swift
//  X
//
//  Created by İbrahim Ay on 19.05.2024.
//

import Foundation
import Firebase

class UserProfileViewModel: ObservableObject {
    @Published var name = String()
    @Published var username = String()
    @Published var followerCount = Int()
    @Published var followingCount = Int()
    @Published var imageUrl = String()
    @Published var profileImageUrl = String()
    @Published var birthday: Timestamp?
    @Published var bio = String()
    @Published var currentUserTweets = [CurrentUserTweetModel]()
    @Published var reTweets = [TweetModel]()
    @Published var likedTweets = [TweetModel]()
    @Published var comments = [CommentModel]()
    
    let firestore = Firestore.firestore()
    
    let currentUserID = Auth.auth().currentUser?.uid
    
    func signOut(completion: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
        } catch {
            print("çıkış yapılamadı")
            completion(false)
        }
    }
    
    func getDataLikedTweets() {
        guard let currentUserID = currentUserID else { return }
        
        firestore.collection("Tweets").whereField("likes", arrayContains: currentUserID).getDocuments { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let documents = snapshot?.documents, !documents.isEmpty {
                
                var tweetModel = [TweetModel]()
                let group = DispatchGroup()
                
                for document in documents {
                    group.enter()
                    let data = document.data()
                    let userID = data["userID"] as? String ?? ""
                    
                    self.firestore.collection("Users").document(userID).getDocument { document, error in
                        if let userData = document?.data() {
                            if let tweet = TweetModel.createFrom(data, userData: userData) {
                                tweetModel.append(tweet)
                            }
                        }
                        group.leave()
                    }
                }
                group.notify(queue: .main) {
                    self.likedTweets = tweetModel
                }
            }
        }
    }
    
    func getDataRT() {
        guard let currentUserID = currentUserID else { return }
        
        firestore.collection("Tweets").whereField("RT", arrayContains: currentUserID).getDocuments { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let documents = snapshot?.documents, !documents.isEmpty {
                
                var tweetModel = [TweetModel]()
                let group = DispatchGroup()
                
                for document in documents {
                    group.enter()
                    let data = document.data()
                    let userID = data["userID"] as? String ?? ""
                    
                    self.firestore.collection("Users").document(userID).getDocument { document, error in
                        if let userData = document?.data() {
                            if let tweet = TweetModel.createFrom(data, userData: userData) {
                                tweetModel.append(tweet)
                            }
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    self.reTweets = tweetModel
                }
            }
        }
    }
    
    func getDataUserBio() {
        firestore.collection("Users")
            .whereField("userID", isEqualTo: currentUserID ?? "")
            .addSnapshotListener { snapshot, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else if let documents = snapshot?.documents {
                    for document in documents {
                        guard let bio = document.get("bio") as? String else { return }
                        
                        self.bio = bio
                    }
                }
            }
    }
    
    func getDataUserBirthday() {
        firestore.collection("Users")
            .whereField("userID", isEqualTo: currentUserID ?? "")
            .addSnapshotListener { snapshot, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else if let documents = snapshot?.documents {
                    for document in documents {
                        if let birthday = document.get("birthday") as? Timestamp {
                            self.birthday = birthday
                        } else {
                            self.birthday = nil
                        }
                    }
                }
            }
    }
    
    func getDataUsername() {
        firestore.collection("Users")
            .whereField("userID", isEqualTo: currentUserID ?? "")
            .addSnapshotListener { snapshot, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else if let documents = snapshot?.documents, !documents.isEmpty {
                    for document in documents {
                        guard let name = document.get("name") as? String,
                              let username = document.get("username") as? String else { return }
                        
                        self.name = name
                        self.username = username
                    }
                }
            }
    }
    
    func getDataUserImage() {
        firestore.collection("Users")
            .whereField("userID", isEqualTo: currentUserID ?? "")
            .addSnapshotListener { snapshot, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else if let documents = snapshot?.documents, !documents.isEmpty {
                    for document in documents {
                        guard let imageUrl = document.get("imageUrl") as? String else { return }
                        
                        self.imageUrl = imageUrl
                    }
                }
            }
    }
    
    func getDataUserProfileImage() {
        firestore.collection("Users")
            .whereField("userID", isEqualTo: currentUserID ?? "")
            .addSnapshotListener { snapshot, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else if let documents = snapshot?.documents, !documents.isEmpty {
                    for document in documents {
                        guard let profileImageUrl = document.get("profileImageUrl") as? String else { return }
                        
                        self.profileImageUrl = profileImageUrl
                    }
                }
            }
    }
    
    func getDataTweet() {
        guard let currentUserID = currentUserID else { return }
        
        firestore.collection("Tweets").whereField("userID", isEqualTo: currentUserID).getDocuments { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            
            guard let documents = snapshot?.documents else {
                return
            }
            
            var currentUserTweetModel = [CurrentUserTweetModel]()
            
            for document in documents {
                let data = document.data()
                
                if let tweet = CurrentUserTweetModel.createFrom(data) {
                    currentUserTweetModel.append(tweet)
                }
            }
            
            self.currentUserTweets = currentUserTweetModel
        }
    }
    
    func getDataFollowerCount() {
        firestore.collection("Users").document(currentUserID ?? "").getDocument { document, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let document = document, document.exists {
                let follower = document.data()?["follower"] as? [String] ?? []
                let followerCount = follower.count
                self.followerCount = followerCount
            }
        }
    }
    
    func getDataFollowingCount() {
        firestore.collection("Users").document(currentUserID ?? "").getDocument { document, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let document = document, document.exists {
                let following = document.data()?["following"] as? [String] ?? []
                let followingCount = following.count
                self.followingCount = followingCount
            }
        }
    }
}
