//
//  MessageModel.swift
//  X
//
//  Created by İbrahim Ay on 6.06.2024.
//

import Foundation

struct MessageModel: Identifiable {
    var id: String { documentId }
    
    let documentId: String
    let senderID, recipientID, message, imageUrl: String
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.senderID = data["senderID"] as? String ?? ""
        self.recipientID = data["recipientID"] as? String ?? ""
        self.message = data["message"] as? String ?? ""
        self.imageUrl = data["imageUrl"] as? String ?? ""
    }
}
