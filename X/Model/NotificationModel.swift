//
//  NotificationModel.swift
//  X
//
//  Created by İbrahim Ay on 10.06.2024.
//

import Foundation
import Firebase

struct NotificationModel: Identifiable {
    var id: String { senderID }
    let senderID: String
    let recipientID: String
    let time: Timestamp
    let name: String
    let profileImageUrl: String
    
    static func createFrom(_ data: [String: Any], userData: [String: Any]) -> NotificationModel? {
        let senderID = data["senderID"] as? String
        let recipientID = data["recipientID"] as? String
        let time = data["time"] as? Timestamp
        let name = userData["name"] as? String
        let profileImageUrl = userData["profileImageUrl"] as? String
                
        return NotificationModel(senderID: senderID ?? "", recipientID: recipientID ?? "", time: time ?? Timestamp(), name: name ?? "", profileImageUrl: profileImageUrl ?? "")
    }
}
