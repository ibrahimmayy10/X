//
//  LoginViewModel.swift
//  X
//
//  Created by İbrahim Ay on 17.05.2024.
//

import Foundation
import Firebase

class LoginViewModel: ObservableObject {
    @Published var username = String()
    @Published var email = String()
    @Published var password = String()
    @Published var errorMessage = String()
    @Published var isLoading = false
    
    var isFormValid: Bool {
        !username.isEmpty && !email.isEmpty && !password.isEmpty
    }
    
    func login(completion: @escaping (Bool) -> Void) {
        isLoading = true
        guard validate() else {
            completion(false)
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { dataResult, error in
            self.isLoading = false
            
            if error != nil {
                print(error?.localizedDescription ?? "")
                completion(false)
            } else {
                let firestore = Firestore.firestore()
                
                firestore.collection("Users").whereField("userID", isEqualTo: Auth.auth().currentUser?.uid ?? "").addSnapshotListener { snapshot, error in
                    if error != nil {
                        print(error?.localizedDescription ?? "")
                        completion(false)
                    } else if let documents = snapshot?.documents, !documents.isEmpty {
                        for document in documents {
                            guard let username = document.get("username") as? String else {
                                completion(false)
                                return
                            }
                            
                            if self.username == username {
                                print("Giriş işlemi başarılı")
                                completion(true)
                            } else {
                                self.errorMessage = "Girilen kullanıcı adı bulunamadı"
                                completion(false)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func validate() -> Bool {
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty, !email.trimmingCharacters(in: .whitespaces).isEmpty, !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Lütfen tüm alanları doldurun"
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Lütfen geçerli bir e-posta adresi girin"
            return false
        }
        
        guard password.count >= 8 else {
            errorMessage = "Şifreniz en az 8 karakter içermelidir"
            return false
        }
        
        return true
    }
}
