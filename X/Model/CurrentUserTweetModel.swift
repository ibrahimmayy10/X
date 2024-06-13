//
//  CurrentUserTweetModel.swift
//  X
//
//  Created by İbrahim Ay on 25.05.2024.
//

import Foundation
import Firebase

struct CurrentUserTweetModel: Identifiable {
    var id: String { tweetID }
    let tweetID: String
    let tweet: String
    let time: Timestamp
    let likes: [String]
    let rt: [String]
    let tweetImageUrl: String
    let videoUrl: String
    
    static func createFrom(_ data: [String: Any]) -> CurrentUserTweetModel? {
        let tweetID = data["tweetID"] as? String
        let tweet = data["tweet"] as? String
        let time = data["time"] as? Timestamp
        let likes = data["likes"] as? [String]
        let rt = data["RT"] as? [String]
        let tweetImageUrl = data["tweetImageUrl"] as? String
        let videoUrl = data["videoUrl"] as? String
                
        return CurrentUserTweetModel(tweetID: tweetID ?? "", tweet: tweet ?? "", time: time ?? Timestamp(), likes: likes ?? [], rt: rt ?? [], tweetImageUrl: tweetImageUrl ?? "", videoUrl: videoUrl ?? "")
    }
}
