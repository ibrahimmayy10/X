//
//  TweetDetailsViewModel.swift
//  X
//
//  Created by İbrahim Ay on 28.05.2024.
//

import Foundation
import Firebase

class TweetDetailsViewModel: ObservableObject {
    @Published var comments = [CommentModel]()
    
    let firestore = Firestore.firestore()
    let currentUserID = Auth.auth().currentUser?.uid
    
    func getDataTweetDetails(tweetID: String) {
        firestore.collection("Tweets").document(tweetID).collection("Comments").getDocuments { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            let group = DispatchGroup()
            var commentModel = [CommentModel]()
            
            for document in documents {
                group.enter()
                let data = document.data()
                let userID = data["userID"] as? String ?? ""
                
                self.firestore.collection("Users").document(userID).getDocument { document, error in
                    if let userData = document?.data() {
                        if let comment = CommentModel.createFrom(data, userData: userData) {
                            commentModel.append(comment)
                        }
                    }
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                DispatchQueue.main.async {
                    self.comments = commentModel
                }
            }
        }
    }
    
    func isTweetLiked(tweetID: String, commentID: String, completion: @escaping (Bool) -> Void) {
        guard let currentUserID = currentUserID else {
            completion(false)
            return
        }
        
        firestore.collection("Tweets").document(tweetID).collection("Comments").document(commentID).getDocument { document, error in
            if let document = document, document.exists {
                let likeList = document.data()?["likes"] as? [String] ?? []
                completion(likeList.contains(currentUserID))
            } else {
                completion(false)
            }
        }
    }
    
    func likeComment(commentID: String, tweetID: String) {
        guard let currentUserID = currentUserID else { return }
        
        firestore.collection("Tweets").document(tweetID).collection("Comments").document(commentID).getDocument { document, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                var likeList = document?.data()?["likes"] as? [String] ?? []
                
                if !likeList.contains(currentUserID) {
                    likeList.append(currentUserID)
                } else {
                    likeList.removeAll { $0 == currentUserID }
                }
                
                self.firestore.collection("Tweets").document(tweetID).collection("Comments").document(commentID).updateData(["likes": likeList]) { error in
                    if error != nil {
                        print(error?.localizedDescription ?? "")
                    } else {
                        print("yorum beğenme işlemi başarılı")
                    }
                }
            }
        }
    }
}
