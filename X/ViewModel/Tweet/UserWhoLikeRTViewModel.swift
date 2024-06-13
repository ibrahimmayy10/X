//
//  UserWhoLikeViewModel.swift
//  X
//
//  Created by İbrahim Ay on 31.05.2024.
//

import Foundation
import Firebase

class UserWhoLikeRTViewModel: ObservableObject {
    @Published var users = [UserModel]()
    
    let firestore = Firestore.firestore()
    
    func getDataUsersWhoRT(tweetID: String) {
        firestore.collection("Tweets").document(tweetID).getDocument { document, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let document = document, document.exists {
                let rtList = document.data()?["RT"] as? [String] ?? []
                
                var users = [UserModel]()
                let group = DispatchGroup()
                
                for userID in rtList {
                    self.firestore.collection("Users").whereField("userID", isEqualTo: userID).getDocuments { snapshot, error in
                        if let documents = snapshot?.documents {
                            for document in documents {
                                group.enter()
                                
                                let data = document.data()
                                
                                if let user = UserModel.createFrom(data) {
                                    users.append(user)
                                }
                                group.leave()
                            }
                            group.notify(queue: .main) {
                                self.users = users
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getDataUsersWhoLike(tweetID: String) {
        firestore.collection("Tweets").document(tweetID).getDocument { document, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let document = document, document.exists {
                let likeList = document.data()?["likes"] as? [String] ?? []
                
                var users = [UserModel]()
                let group = DispatchGroup()
                
                for userID in likeList {
                    self.firestore.collection("Users").whereField("userID", isEqualTo: userID).getDocuments { snapshot, error in
                        if let documents = snapshot?.documents {
                            for document in documents {
                                group.enter()
                                let data = document.data()
                                
                                if let user = UserModel.createFrom(data) {
                                    users.append(user)
                                }
                                group.leave()
                            }
                            group.notify(queue: .main) {
                                self.users = users
                            }
                        }
                    }
                }
            }
        }
    }
}
