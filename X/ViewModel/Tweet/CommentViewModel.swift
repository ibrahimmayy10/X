//
//  CommentViewModel.swift
//  X
//
//  Created by İbrahim Ay on 26.05.2024.
//

import Foundation
import Firebase

class CommentViewModel: ObservableObject {
    
    @Published var tweet = String()
    @Published var profileImageUrl = String()
    @Published var isLoading = false
    
    let firestore = Firestore.firestore()
    let currentUserID = Auth.auth().currentUser?.uid
    
    var isFormValid: Bool {
        !tweet.isEmpty
    }
    
    func shareComment(tweetID: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        guard let currentUserID = currentUserID else {
            completion(false)
            return 
        }
        
        let commentRef = firestore.collection("Tweets").document(tweetID).collection("Comments").document()
        
        let firestoreComment = ["userID": currentUserID, "commentID": commentRef.documentID, "comment": tweet, "tweetID": tweetID, "time": FieldValue.serverTimestamp()] as [String: Any]
        
        commentRef.setData(firestoreComment) { error in
            if error != nil {
                print(error?.localizedDescription ?? "")
                completion(false)
            } else {
                print("yorum atma başarılı")
                completion(true)
            }
        }
    }
    
    func getDataCurrentUserProfileImage() {
        guard let currentUserID = currentUserID else { return }
        
        firestore.collection("Users").document(currentUserID).getDocument { document, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let document = document, document.exists {
                guard let profileImageUrl = document.get("profileImageUrl") as? String else { return }
                self.profileImageUrl = profileImageUrl
            }
        }
    }
}
