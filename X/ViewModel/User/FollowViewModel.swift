//
//  FollowViewModel.swift
//  X
//
//  Created by İbrahim Ay on 4.06.2024.
//

import Foundation
import Firebase

class FollowViewModel: ObservableObject {
    @Published var followingList = [UserModel]()
    @Published var followerList = [UserModel]()
    
    let firestore = Firestore.firestore()
    let currentUserID = Auth.auth().currentUser?.uid
    
    func getDataNewUserFollower(userID: String) {
        firestore.collection("Users").document(userID).getDocument { document, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let document = document {
                let followingList = document.data()?["follower"] as? [String] ?? []
                
                var users = [UserModel]()
                let group = DispatchGroup()
                
                for userID in followingList {
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
                                self.followerList = users
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getDataNewUserFollowing(userID: String) {
        firestore.collection("Users").document(userID).getDocument { document, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let document = document {
                let followingList = document.data()?["following"] as? [String] ?? []
                
                var users = [UserModel]()
                let group = DispatchGroup()
                
                for userID in followingList {
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
                                self.followingList = users
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getDataFollower() {
        guard let currentUserID = currentUserID else { return }
        
        firestore.collection("Users").document(currentUserID).getDocument { document, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let document = document {
                let followingList = document.data()?["follower"] as? [String] ?? []
                
                var users = [UserModel]()
                let group = DispatchGroup()
                
                for userID in followingList {
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
                                self.followerList = users
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getDataFollowing() {
        guard let currentUserID = currentUserID else { return }
        
        firestore.collection("Users").document(currentUserID).getDocument { document, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let document = document {
                let followingList = document.data()?["following"] as? [String] ?? []
                
                var users = [UserModel]()
                let group = DispatchGroup()
                
                for userID in followingList {
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
                                self.followingList = users
                            }
                        }
                    }
                }
            }
        }
    }
}
