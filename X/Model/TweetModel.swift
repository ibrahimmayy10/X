//
//  TweetModel.swift
//  X
//
//  Created by İbrahim Ay on 20.05.2024.
//

import Foundation
import Firebase

struct TweetModel: Identifiable {
    var id: String { tweetID }
    let tweetID: String
    let tweet: String
    let time: Timestamp
    let likes: [String]
    let rt: [String]
    let tweetImageUrl: String
    let videoUrl: String
    let userID: String
    let name: String
    let username: String
    let profileImageUrl: String
    let imageUrl: String
    let bio: String
    let birthday: Timestamp
    
    static func createFrom(_ data: [String: Any], userData: [String: Any]) -> TweetModel? {
        let tweetID = data["tweetID"] as? String
        let tweet = data["tweet"] as? String
        let time = data["time"] as? Timestamp
        let likes = data["likes"] as? [String]
        let rt = data["RT"] as? [String]
        let tweetImageUrl = data["tweetImageUrl"] as? String
        let videoUrl = data["videoUrl"] as? String
        let userID = data["userID"] as? String
        let username = userData["username"] as? String
        let name = userData["name"] as? String
        let profileImageUrl = userData["profileImageUrl"] as? String
        let imageUrl = userData["imageUrl"] as? String
        let bio = userData["bio"] as? String
        let birthday = userData["birthday"] as? Timestamp
                
        return TweetModel(tweetID: tweetID ?? "", tweet: tweet ?? "", time: time ?? Timestamp(), likes: likes ?? [], rt: rt ?? [], tweetImageUrl: tweetImageUrl ?? "", videoUrl: videoUrl ?? "", userID: userID ?? "", name: name ?? "", username: username ?? "", profileImageUrl: profileImageUrl ?? "", imageUrl: imageUrl ?? "", bio: bio ?? "", birthday: birthday ?? Timestamp())
    }
}
