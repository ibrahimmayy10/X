//
//  EditProfileViewModel.swift
//  X
//
//  Created by İbrahim Ay on 23.05.2024.
//

import Foundation
import Firebase

class EditProfileViewModel: ObservableObject {
    @Published var name = String()
    @Published var username = String()
    @Published var bio = String()
    @Published var birthday = Date()
    @Published var getBirthday: Timestamp?
    @Published var imageUrl = String()
    @Published var profileImageUrl = String()
    
    let firestore = Firestore.firestore()
    let currentUserID = Auth.auth().currentUser?.uid
    
    func updateUserInfo(completion: @escaping (Bool) -> Void) {
        let userData = ["name": name, "username": username, "birthday": Timestamp(date: birthday), "bio": bio] as [String: Any]
        firestore.collection("Users").document(currentUserID ?? "").updateData(userData) { error in
            if error != nil {
                print(error?.localizedDescription ?? "")
                completion(false)
            } else {
                print("güncelleme işlemi başarılı")
                completion(true)
            }
        }
    }
    
    func getDataUserBio() {
        firestore.collection("Users")
            .whereField("userID", isEqualTo: currentUserID ?? "")
            .addSnapshotListener { snapshot, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else if let documents = snapshot?.documents {
                    for document in documents {
                        guard let bio = document.get("bio") as? String else { return }
                        
                        self.bio = bio
                    }
                }
            }
    }
    
    func getDataUserBirthday() {
        firestore.collection("Users")
            .whereField("userID", isEqualTo: currentUserID ?? "")
            .addSnapshotListener { snapshot, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else if let documents = snapshot?.documents {
                    for document in documents {
                        if let birthday = document.get("birthday") as? Timestamp {
                            self.getBirthday = birthday
                        } else {
                            self.getBirthday = nil
                        }
                    }
                }
            }
    }
    
    func getDataUserInfo() {
        firestore.collection("Users")
            .whereField("userID", isEqualTo: currentUserID ?? "")
            .addSnapshotListener { snapshot, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else if let documents = snapshot?.documents, !documents.isEmpty {
                    for document in documents {
                        guard let name = document.get("name") as? String,
                              let username = document.get("username") as? String else { return }
                        
                        self.name = name
                        self.username = username
                    }
                }
            }
    }
    
    func getDataUserImage() {
        firestore.collection("Users")
            .whereField("userID", isEqualTo: currentUserID ?? "")
            .addSnapshotListener { snapshot, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else if let documents = snapshot?.documents, !documents.isEmpty {
                    for document in documents {
                        guard let imageUrl = document.get("imageUrl") as? String else { return }
                        
                        self.imageUrl = imageUrl
                    }
                }
            }
    }
    
    func getDataUserProfileImage() {
        firestore.collection("Users")
            .whereField("userID", isEqualTo: currentUserID ?? "")
            .addSnapshotListener { snapshot, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else if let documents = snapshot?.documents, !documents.isEmpty {
                    for document in documents {
                        guard let profileImageUrl = document.get("profileImageUrl") as? String else { return }
                        
                        self.profileImageUrl = profileImageUrl
                    }
                }
            }
    }
    
    func addImage(image: UIImage, completion: @escaping (Bool) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        let imageName = UUID().uuidString
        let imageReference = Storage.storage().reference().child("images/\(imageName).jpg")
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        imageReference.putData(imageData, metadata: metaData) { metadata, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
                completion(false)
            } else {
                imageReference.downloadURL { (url, error) in
                    if let error = error {
                        print("Resim URL'sini alma hatası: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        let imageUrl = url?.absoluteString
                        
                        let userData = ["imageUrl": imageUrl ?? ""] as [String: Any]
                        
                        self.firestore.collection("Users").document(self.currentUserID ?? "").updateData(userData) { error in
                            if error != nil {
                                print("Kapak fotoğrafı eklenemedi: \(error?.localizedDescription ?? "")")
                                completion(false)
                            } else {
                                print("Kapak fotoğrafı başarıyla eklendi")
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func addProfileImage(image: UIImage, completion: @escaping (Bool) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        let imageName = UUID().uuidString
        let imageReference = Storage.storage().reference().child("profileImages/\(imageName).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageReference.putData(imageData, metadata: metadata) { metadata, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
                completion(false)
            } else {
                imageReference.downloadURL { (url, error) in
                    if error != nil {
                        print(error?.localizedDescription ?? "")
                        completion(false)
                    } else {
                        let imageUrl = url?.absoluteString
                        
                        let userData = ["profileImageUrl": imageUrl ?? ""] as [String: Any]
                        
                        self.firestore.collection("Users").document(self.currentUserID ?? "").updateData(userData) { error in
                            if error != nil {
                                print(error?.localizedDescription ?? "")
                                completion(false)
                            } else {
                                print("Profil fotoğrafı başarıyla eklendi")
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
}
