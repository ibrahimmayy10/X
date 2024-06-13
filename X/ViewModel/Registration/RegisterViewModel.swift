//
//  RegisterViewModel.swift
//  X
//
//  Created by İbrahim Ay on 15.05.2024.
//

import Foundation
import Firebase

class RegisterViewModel: ObservableObject {
    
    @Published var name = String()
    @Published var username = String()
    @Published var email = String()
    @Published var password = String()
    @Published var errorMessage = String()
    @Published var isLoading = false
    
    private var auth: Auth
    
    init(auth: Auth = Auth.auth()) {
        self.auth = auth
    }
        
    var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty && !username.isEmpty
    }
        
    func register(completion: @escaping (Bool) -> Void) {
        isLoading = true
        guard validate() else {
            isLoading = false
            completion(false)
            return
        }
        
        auth.createUser(withEmail: email, password: password) { dataResult, error in
            self.isLoading = false
            
            if let error = error {
                print("kayıt yaparken hata oluştu: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
                completion(false)
            } else {
                guard let dataResult = dataResult else {
                    self.errorMessage = "Kullanıcı oluşturulamadı"
                    completion(false)
                    return
                }
                
                let currentUserID = dataResult.user.uid
                let firestore = Firestore.firestore()
                
                let firestoreUser = ["userID": currentUserID, "name": self.name, "username": self.username] as [String: Any]
                
                firestore.collection("Users").document(currentUserID).setData(firestoreUser, merge: true) { error in
                    if let error = error {
                        print(error.localizedDescription)
                        self.errorMessage = error.localizedDescription
                        completion(false)
                    } else {
                        print("Kayıt işlemi başarılı")
                        completion(true)
                    }
                }
            }
        }
    }
    
    func validate() -> Bool {
        errorMessage = ""
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty, !username.trimmingCharacters(in: .whitespaces).isEmpty, !email.trimmingCharacters(in: .whitespaces).isEmpty, !password.trimmingCharacters(in: .whitespaces).isEmpty else {
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
