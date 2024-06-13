//
//  NotificationViewModel.swift
//  X
//
//  Created by İbrahim Ay on 10.06.2024.
//

import Foundation
import Firebase

class NotificationViewModel: ObservableObject {
    @Published var notifications = [NotificationModel]()
    
    let firestore = Firestore.firestore()
    let currentUserID = Auth.auth().currentUser?.uid
    
    func getDataLikeNotification() {
        guard let currentUserID = currentUserID else { return }
        
        firestore.collection("Users").document(currentUserID).collection("Likes").getDocuments { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let documents = snapshot?.documents, !documents.isEmpty {
                let group = DispatchGroup()
                var notificationModel = [NotificationModel]()
                
                for document in documents {
                    group.enter()
                    let data = document.data()
                    let userID = data["senderID"] as? String ?? ""
                    
                    self.firestore.collection("Users").document(userID).getDocument { document, error in
                        if let userData = document?.data() {
                            if let notification = NotificationModel.createFrom(data, userData: userData) {
                                notificationModel.append(notification)
                            }
                        }
                        group.leave()
                    }
                }
                group.notify(queue: .main) {
                    self.notifications = notificationModel
                }
            }
        }
    }
}
