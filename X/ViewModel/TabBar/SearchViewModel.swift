//
//  SearchViewModel.swift
//  X
//
//  Created by İbrahim Ay on 19.05.2024.
//

import Foundation
import Firebase

class SearchViewModel: ObservableObject {
    @Published var searchText = "" {
        didSet {
            searchInFirestore()
        }
    }
    
    @Published var searchResult = [UserModel]()
    
    func searchInFirestore() {
        guard !searchText.isEmpty else {
            searchResult = []
            return
        }
        
        let firestore = Firestore.firestore()
        
        firestore.collection("Users")
            .whereField("name", isGreaterThanOrEqualTo: searchText)
            .whereField("name", isLessThanOrEqualTo: searchText + "\u{f8ff}")
            .getDocuments { snapshot, error in
                
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self.searchResult = snapshot?.documents.compactMap { document in
                guard let name = document.data()["name"] as? String,
                      let userID = document.data()["userID"] as? String,
                      let username = document.data()["username"] as? String else {
                    return UserModel(userID: "", name: "", username: "", imageUrl: "", profileImageUrl: "", bio: "", birthday: Timestamp())
                }
                
                let imageUrl = document.data()["imageUrl"] as? String
                let profileImageUrl = document.data()["profileImageUrl"] as? String
                let bio = document.data()["bio"] as? String
                let birthday = document.data()["birthday"] as? Timestamp
                
                return UserModel(userID: userID, name: name, username: username, imageUrl: imageUrl ?? "", profileImageUrl: profileImageUrl ?? "", bio: bio ?? "", birthday: birthday ?? Timestamp())
                
            } ?? [] as! [UserModel]
        }
    }
}
