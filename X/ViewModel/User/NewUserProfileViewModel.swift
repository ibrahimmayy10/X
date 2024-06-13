//
//  NewUserProfileViewModel.swift
//  X
//
//  Created by İbrahim Ay on 20.05.2024.
//

import Foundation
import Firebase

class NewUserProfileViewModel: ObservableObject {
    @Published var tweets = [CurrentUserTweetModel]()
    @Published var followerCount = Int()
    @Published var followingCount = Int()
    @Published var reTweets = [TweetModel]()
    @Published var likedTweets = [TweetModel]()
    
    var firestore = Firestore.firestore()
    let currentUserID = Auth.auth().currentUser?.uid
    
    func getDataLikedTweets(userID: String) {
        firestore.collection("Tweets").whereField("likes", arrayContains: userID).getDocuments { snapshot, error in
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
    
    func getDataRT(userID: String) {
        firestore.collection("Tweets").whereField("RT", arrayContains: userID).getDocuments { snapshot, error in
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
    
    func getDataTweet(userID: String) {
        firestore.collection("Tweets")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    return
                }
                
                var tweetModel = [CurrentUserTweetModel]()
                
                for document in documents {
                    let data = document.data()
                    
                    if let tweet = CurrentUserTweetModel.createFrom(data) {
                        tweetModel.append(tweet)
                    }
                }
                self.tweets = tweetModel
            }
    }
    
    func isUserFollowed(newUserID: String, completion: @escaping (Bool) -> Void) {
        guard let currentUserID = currentUserID else {
            completion(false)
            return
        }
        
        firestore.collection("Users").document(currentUserID).getDocument { document, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
                completion(false)
            } else if let document = document, document.exists {
                let followingList = document.data()?["following"] as? [String] ?? []
                completion(followingList.contains(newUserID))
            }
        }
    }
    
    func followUser(newUserID: String) {
        guard let currentUserID = currentUserID else { return }
        
        let currentUserReference = firestore.collection("Users").document(currentUserID)
        let newUserReference = firestore.collection("Users").document(newUserID)
        
        newUserReference.getDocument { document, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            } else if let document = document, document.exists {
                var followerList = document.data()?["follower"] as? [String] ?? []
                let isFollowing = followerList.contains(currentUserID)
                
                if isFollowing {
                    followerList.removeAll { $0 == currentUserID }
                } else {
                    followerList.append(currentUserID)
                }
                
                newUserReference.updateData(["follower": followerList])
                
                currentUserReference.getDocument { snapshot, error in
                    if error != nil {
                        print(error?.localizedDescription ?? "")
                        return
                    }
                    
                    if let snapshot = snapshot, snapshot.exists {
                        var followingList = snapshot.data()?["following"] as? [String] ?? []
                        
                        if isFollowing {
                            followingList.removeAll { $0 == newUserID }
                        } else {
                            followingList.append(newUserID)
                        }
                        
                        currentUserReference.updateData(["following": followingList])
                    }
                }
            }
        }
    }

    
    func getDataFollowerCount(newUserID: String) {
        firestore.collection("Users").document(newUserID).getDocument { document, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let document = document, document.exists {
                let follower = document.data()?["follower"] as? [String] ?? []
                let followerCount = follower.count
                self.followerCount = followerCount
            }
        }
    }
    
    func getDataFollowingCount(newUserID: String) {
        firestore.collection("Users").document(newUserID).getDocument { document, error in
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
