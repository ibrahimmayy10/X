//
//  UserCard.swift
//  X
//
//  Created by İbrahim Ay on 20.05.2024.
//

import SwiftUI
import Firebase

struct UserCard: View {
    
    @State var user: UserModel
    
    var body: some View {
        HStack {
            if !user.profileImageUrl.isEmpty {
                AsyncImage(url: URL(string: user.profileImageUrl)) { phase in
                    switch phase {
                    case .empty:
                            ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(25)
                            .scaledToFill()
                    case .failure(_):
                        Image(systemName: "person")
                            .font(.system(size: 35))
                            .frame(width: 50, height: 50)
                            .cornerRadius(25)
                            .overlay(Circle().stroke(.white, lineWidth: 1))
                            .foregroundStyle(.white)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "person")
                    .font(.system(size: 35))
                    .frame(width: 50, height: 50)
                    .cornerRadius(25)
                    .overlay(Circle().stroke(.white, lineWidth: 1))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading) {
                Text(user.name)
                    .foregroundStyle(.white)
                
                Text("@\(user.username)")
                    .foregroundStyle(.gray)
            }
            
            Spacer()
        }
        .padding(.leading)
    }
}

#Preview {
    UserCard(user: UserModel(userID: "", name: "İbrahim Ay", username: "ibrahimmayy10", imageUrl: "https://firebasestorage.googleapis.com:443/v0/b/twitter-39e1b.appspot.com/o/images%2F36245035-B767-406C-875E-4B9EC3BC21B3.jpg?alt=media&token=45c7af5f-8344-4aa7-a85a-8b79f7cdab7a", profileImageUrl: "https://firebasestorage.googleapis.com:443/v0/b/twitter-39e1b.appspot.com/o/profileImages%2FF90221DB-F095-4D08-9881-67B09C1AF593.jpg?alt=media&token=0056b66b-d4d1-497b-ae78-41484834f0cb", bio: "", birthday: Timestamp()))
}
