//
//  LikeListModel.swift
//  X
//
//  Created by İbrahim Ay on 3.06.2024.
//

import Foundation

struct LikeListModel: Identifiable {
    var id: String { userID }
    let userID: String
    let name: String
    let username: String
    let imageUrl: String
    let profileImageUrl: String
    
    static func createFrom( _ data: [String: Any]) -> LikeListModel? {
        let userID = data["userID"] as? String
        let username = data["username"] as? String
        let name = data["name"] as? String
        let imageUrl = data["imageUrl"] as? String
        let profileImageUrl = data["profileImageUrl"] as? String
        
        return LikeListModel(userID: userID ?? "", name: name ?? "", username: username ?? "", imageUrl: imageUrl ?? "", profileImageUrl: profileImageUrl ?? "")
    }
}
