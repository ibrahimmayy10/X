//
//  UserModel.swift
//  X
//
//  Created by İbrahim Ay on 19.05.2024.
//

import Foundation
import Firebase

struct UserModel: Identifiable, Codable {
    var id: String { userID }
    let userID: String
    let name: String
    let username: String
    let imageUrl: String
    let profileImageUrl: String
    let bio: String
    let birthday: Timestamp
    
    static func createFrom( _ data: [String: Any]) -> UserModel? {
        let userID = data["userID"] as? String
        let username = data["username"] as? String
        let name = data["name"] as? String
        let imageUrl = data["imageUrl"] as? String
        let profileImageUrl = data["profileImageUrl"] as? String
        let bio = data["bio"] as? String
        let birthday = data["birthday"] as? Timestamp
        
        return UserModel(userID: userID ?? "", name: name ?? "", username: username ?? "", imageUrl: imageUrl ?? "", profileImageUrl: profileImageUrl ?? "", bio: bio ?? "", birthday: birthday ?? Timestamp())
    }
}
