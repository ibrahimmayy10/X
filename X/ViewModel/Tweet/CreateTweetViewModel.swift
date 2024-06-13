//
//  CreateTweetViewModel.swift
//  X
//
//  Created by İbrahim Ay on 18.05.2024.
//

import Foundation
import Firebase

class CreateTweetViewModel: ObservableObject {
    
    @Published var tweet = String()
    @Published var isLoading = false
    @Published var profileImageUrl = String()
    
    var isFormValid: Bool {
        !tweet.isEmpty
    }
    
    func shareVideoTweet(videoUrl: URL, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }
        let currentUserID = user.uid
        
        let firestore = Firestore.firestore()
        
        let tweetRef = firestore.collection("Tweets").document()
        
        let videoData = try? Data(contentsOf: videoUrl)
        let storageRef = Storage.storage().reference().child("videos/\(UUID().uuidString).mp4")
        
        storageRef.putData(videoData!, metadata: nil) { (metadata, error) in
            self.isLoading = false
            if let error = error {
                print("Error uploading video: \(error.localizedDescription)")
                completion(false)
            } else {
                storageRef.downloadURL { (url, error) in
                    if let videoUrl = url?.absoluteString {
                        let tweetData = ["userID": currentUserID, "tweet": self.tweet, "tweetID": tweetRef.documentID, "time": FieldValue.serverTimestamp(), "videoUrl": videoUrl] as [String: Any]
                        
                        firestore.collection("Tweets").document(tweetRef.documentID).setData(tweetData) { error in
                            if error != nil {
                                print(error?.localizedDescription ?? "")
                                completion(false)
                            } else {
                                print("resim paylaşıldı")
                                completion(true)
                            }
                        }
                    } else {
                        completion(false)
                    }
                }
            }
        }
    }
    
    func shareImageTweet(image: UIImage, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }
        let currentUserID = user.uid
        
        let firestore = Firestore.firestore()
        let tweetRef = firestore.collection("Tweets").document()
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        let imageName = UUID().uuidString
        let imageReference = Storage.storage().reference().child("tweetImages/\(imageName).jpg")
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        imageReference.putData(imageData, metadata: metaData) { metadata, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
                completion(false)
            } else {
                imageReference.downloadURL { (url, error) in
                    if error != nil {
                        print(error?.localizedDescription ?? "")
                        completion(false)
                    } else {
                        let imageUrl = url?.absoluteString
                        
                        let tweetData = ["userID": currentUserID, "tweet": self.tweet, "tweetID": tweetRef.documentID, "time": FieldValue.serverTimestamp(), "tweetImageUrl": imageUrl ?? ""] as [String: Any]
                        
                        firestore.collection("Tweets").document(tweetRef.documentID).setData(tweetData) { error in
                            if error != nil {
                                print(error?.localizedDescription ?? "")
                                completion(false)
                            } else {
                                print("video paylaşıldı")
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func shareTweet(completion: @escaping (Bool) -> Void) {
        isLoading = true
        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }
        
        let currentUserID = user.uid
        
        let firestore = Firestore.firestore()
        let tweetRef = firestore.collection("Tweets").document()
        
        let firestoreTweet = ["userID": currentUserID, "tweet": tweet, "tweetID": tweetRef.documentID, "time": FieldValue.serverTimestamp()] as [String: Any]
        
        firestore.collection("Tweets").document(tweetRef.documentID).setData(firestoreTweet) { error in
            
            self.isLoading = false
            
            if error != nil {
                print(error?.localizedDescription ?? "")
                completion(false)
            } else {
                print("Tweet paylaşıldı")
                completion(true)
            }
        }
    }
    
    func getDataUserProfileImage() {
        guard let user = Auth.auth().currentUser else { return }
        let currentUserID = user.uid
        
        let firestore = Firestore.firestore()
        
        firestore.collection("Users").document(currentUserID).getDocument { document, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let document = document {
                guard let profileImageUrl = document.get("profileImageUrl") as? String else { return }
                
                self.profileImageUrl = profileImageUrl
            }
        }
    }
}
