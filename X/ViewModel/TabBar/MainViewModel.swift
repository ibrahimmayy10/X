//
//  MainViewModel.swift
//  X
//
//  Created by İbrahim Ay on 18.05.2024.
//

import Foundation
import Firebase

class MainViewModel: ObservableObject {
    
    var firestore = Firestore.firestore()
    var currentUserID = Auth.auth().currentUser?.uid
    
    @Published var tweets = [TweetModel]()
    @Published var profileImageUrl = String()
    
    init() {
        self.getDataFollowingTweet()
        self.getDataUserProfileImage()
    }
    
    func isRT(tweetID: String, completion: @escaping (Bool) -> Void) {
        guard let currentUserID = currentUserID else {
            completion(false)
            return
        }
        
        firestore.collection("Tweets").document(tweetID).getDocument { document, error in
            if let document = document, document.exists {
                let rtList = document.data()?["RT"] as? [String] ?? []
                completion(rtList.contains(currentUserID))
            } else {
                completion(false)
            }
        }
    }
    
    func reTweet(tweetID: String) {
        guard let currentUserID = currentUserID else { return }
        
        firestore.collection("Tweets").document(tweetID).getDocument { document, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                var rtList = document?.data()?["RT"] as? [String] ?? []
                
                if !rtList.contains(currentUserID) {
                    rtList.append(currentUserID)
                } else {
                    rtList.removeAll { $0 == currentUserID }
                }
                
                self.firestore.collection("Tweets").document(tweetID).updateData(["RT": rtList]) { error in
                    if error != nil {
                        print(error?.localizedDescription ?? "")
                    } else {
                        print("rt işlemi başarılı")
                    }
                }
            }
        }
    }
    
    func isTweetLiked(tweetID: String, completion: @escaping (Bool) -> Void) {
        guard let currentUserID = currentUserID else {
            completion(false)
            return
        }
            
        firestore.collection("Tweets").document(tweetID).getDocument { document, error in
            if let document = document, document.exists {
                let likeList = document.data()?["likes"] as? [String] ?? []
                completion(likeList.contains(currentUserID))
            } else {
                completion(false)
            }
        }
    }
    
    func likeTweet(tweetID: String) {
        guard let currentUserID = currentUserID else { return }
        
        firestore.collection("Tweets").document(tweetID).getDocument { document, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                var likeList = document?.data()?["likes"] as? [String] ?? []
                
                if !likeList.contains(currentUserID) {
                    likeList.append(currentUserID)
                    
                    self.sendNotification(to: document?.data()?["userID"] as? String ?? "")
                } else {
                    likeList.removeAll { $0 == currentUserID }
                }
                
                self.firestore.collection("Tweets").document(tweetID).updateData(["likes": likeList]) { error in
                    if error != nil {
                        print(error?.localizedDescription ?? "")
                    } else {
                        print("beğeni işlemi başarılı")
                    }
                }
            }
        }
    }
    
    func sendNotification(to recipientID: String) {
        guard let currentUserID = currentUserID else { return }
        
        let notificationData = ["recipientID": recipientID, "senderID": currentUserID, "time": FieldValue.serverTimestamp()] as [String: Any]
        
        firestore.collection("Users").document(recipientID).collection("Likes").addDocument(data: notificationData) { error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                print("bildirim gönderildi")
            }
        }
    }
    
    func getDataUserProfileImage() {
        firestore.collection("Users").whereField("userID", isEqualTo: currentUserID ?? "").addSnapshotListener { snapshot, error in
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
    
    func getDataFollowingTweet() {
        guard let currentUserID = currentUserID else {
            print("UserID boş geliyor")
            return
        }
        
        let userRef = firestore.collection("Users").document(currentUserID)
        
        userRef.getDocument { document, error in
            if error != nil {
                print("Hata oluştu: \(error?.localizedDescription ?? "")")
                return
            }
            
            if let following = document?.data()?["following"] as? [String] {
                self.firestore.collection("Tweets").whereField("userID", in: following).getDocuments { snapshot, error in
                    if error != nil {
                        print("Hata var: \(error?.localizedDescription ?? "")")
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        return
                    }
                    
                    let group = DispatchGroup()
                    var tweetsModel = [TweetModel]()
                    
                    for document in documents {
                        group.enter()
                        let data = document.data()
                        let userID = data["userID"] as? String ?? ""
                        
                        self.firestore.collection("Users").document(userID).getDocument { document, error in
                            if let userData = document?.data() {
                                if let tweet = TweetModel.createFrom(data, userData: userData) {
                                    tweetsModel.append(tweet)
                                }
                            }
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) {
                        self.tweets = tweetsModel
                    }
                }
            } else {
                print("takip edilen kullanıcı yok")
            }
        }
    }
}
