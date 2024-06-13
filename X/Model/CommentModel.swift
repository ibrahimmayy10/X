//
//  CommentModel.swift
//  X
//
//  Created by İbrahim Ay on 28.05.2024.
//

import Foundation
import Firebase

struct CommentModel: Identifiable {
    var id: String { commentID }
    let commentID: String
    let time: Timestamp
    let comment: String
    let tweetID: String
    let userID: String
    let name: String
    let username: String
    let profileImageUrl: String
    
    static func createFrom(_ data: [String: Any], userData: [String: Any]) -> CommentModel? {
        let commentID = data["commentID"] as? String
        let time = data["time"] as? Timestamp
        let comment = data["comment"] as? String
        let tweetID = data["tweetID"] as? String
        let userID = data["userID"] as? String
        let name = userData["name"] as? String
        let username = userData["username"] as? String
        let profileImageUrl = userData["profileImageUrl"] as? String
        
        return CommentModel(commentID: commentID ?? "", time: time ?? Timestamp(), comment: comment ?? "", tweetID: tweetID ?? "", userID: userID ?? "", name: name ?? "", username: username ?? "", profileImageUrl: profileImageUrl ?? "")
    }
}
