//
//  MessageViewModel.swift
//  X
//
//  Created by İbrahim Ay on 5.06.2024.
//

import Foundation
import Firebase

class MessageViewModel: ObservableObject {
    @Published var messageText = String()
    @Published var messages = [MessageModel]()
    @Published var count = 0
    @Published var messagedUsers = [UserModel]()
    @Published var lastMessages = [String: MessageModel]()
    
    let firestore = Firestore.firestore()
    let currentUserID = Auth.auth().currentUser?.uid
    
    func loadLastMessage(with userID: String) {
        guard let currentUserID = currentUserID else { return }
        
        let chatRoomID = generateChatRoomID(currentUserID: currentUserID, recipientUserID: userID)
        
        firestore.collection("Messages").document(chatRoomID).collection("Message").order(by: "time", descending: true).limit(to: 1).getDocuments { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let document = snapshot?.documents.first {
                let data = document.data()
                let message = MessageModel(documentId: document.documentID, data: data)
                DispatchQueue.main.async {
                    self.lastMessages[userID] = message
                }
            }
        }
    }
    
    func generateChatRoomID(currentUserID: String, recipientUserID: String) -> String {
        let sortedIDs = [currentUserID, recipientUserID].sorted()
        return sortedIDs.joined(separator: "_")
    }
    
    func sendMessage(recipientUserID: String, message: String) {
        guard let currentUserID = currentUserID else { return }
        
        let chatRoomID = generateChatRoomID(currentUserID: currentUserID, recipientUserID: recipientUserID)
        
        let messageData = ["chatRoomID": chatRoomID, "senderID": currentUserID, "recipientUserID": recipientUserID, "message": messageText, "time": FieldValue.serverTimestamp()] as [String: Any]
        
        firestore.collection("Messages").document(chatRoomID).collection("Message").addDocument(data: messageData) { error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                print("mesaj gönderildi")
                self.loadMessage(recipientUserID: recipientUserID)
                self.count += 1
                self.addMessagedUser(recipientUserID: recipientUserID)
            }
        }
    }
    
    func sendImage(recipientUserID: String, image: UIImage, completion: @escaping (Bool) -> Void) {
        guard let currentUserID = currentUserID else {
            completion(false)
            return
        }
        
        let chatRoomID = generateChatRoomID(currentUserID: currentUserID, recipientUserID: recipientUserID)
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(false)
            return
        }
        
        let imageName = UUID().uuidString
        let imageReference = Storage.storage().reference().child("sentImage/\(imageName).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageReference.putData(imageData, metadata: metadata) { metadata, error in
            if error != nil {
                completion(false)
                print(error?.localizedDescription ?? "")
            } else {
                imageReference.downloadURL { url, error in
                    if error != nil {
                        completion(false)
                        print(error?.localizedDescription ?? "")
                    } else {
                        let imageUrl = url?.absoluteString
                        
                        let messageData = ["chatRoomID": chatRoomID, "senderID": currentUserID, "recipientUserID": recipientUserID, "imageUrl": imageUrl ?? "", "time": FieldValue.serverTimestamp()] as [String: Any]
                        
                        self.firestore.collection("Messages").document(chatRoomID).collection("Message").addDocument(data: messageData) { error in
                            if error != nil {
                                completion(false)
                                print(error?.localizedDescription ?? "")
                            } else {
                                self.loadMessage(recipientUserID: recipientUserID)
                                self.count += 1
                                print("resim gönderme başarılı")
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func loadMessage(recipientUserID: String) {
        guard let currentUserID = currentUserID else { return }
        
        let chatRoomID = generateChatRoomID(currentUserID: currentUserID, recipientUserID: recipientUserID)
        
        firestore.collection("Messages").document(chatRoomID).collection("Message").order(by: "time").addSnapshotListener { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            
            snapshot?.documentChanges.forEach({ change in
                if change.type == .added {
                    let data = change.document.data()
                    let message = MessageModel(documentId: change.document.documentID, data: data)
                    if !self.messages.contains(where: { $0.id == message.id }) {
                        self.messages.append(message)
                    }
                }
            })
            DispatchQueue.main.async {
                self.count += 1
            }
        }
    }
    
    func addMessagedUser(recipientUserID: String) {
        guard let currentUserID = currentUserID else { return }
        
        let currentUserRef = firestore.collection("Users").document(currentUserID)
        let recipientUserRef = firestore.collection("Users").document(recipientUserID)
        
        currentUserRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else { return }
            if let currentUser = UserModel.createFrom(data) {
                recipientUserRef.updateData([
                    "messagedUsers": FieldValue.arrayUnion([currentUser.userID])
                ])
            }
        }
        
        recipientUserRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else { return }
            if let recipientUser = UserModel.createFrom(data) {
                currentUserRef.updateData([
                    "messagedUsers": FieldValue.arrayUnion([recipientUser.userID])
                ])
            }
        }
    }
        
    func loadMessagedUsers() {
        guard let currentUserID = currentUserID else { return }
        
        firestore.collection("Users").document(currentUserID).addSnapshotListener { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            
            guard let data = snapshot?.data() else { return }
            
            let messagedUsers = data["messagedUsers"] as? [String] ?? []
            var userModel = [UserModel]()
            let group = DispatchGroup()
            
            for userID in messagedUsers {
                group.enter()
                
                self.firestore.collection("Users").document(userID).getDocument { document, error in
                    guard let data = document?.data() else { return }
                    if let user = UserModel.createFrom(data) {
                        userModel.append(user)
                    }
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                self.messagedUsers = userModel
            }
        }
    }
}
