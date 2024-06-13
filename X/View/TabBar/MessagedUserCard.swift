//
//  MessagedUserCard.swift
//  X
//
//  Created by İbrahim Ay on 7.06.2024.
//

import SwiftUI
import Firebase

struct MessagedUserCard: View {
    
    @State var user: UserModel
    
    @ObservedObject var messageViewModel = MessageViewModel()
    
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
                HStack {
                    Text(user.name)
                        .foregroundStyle(.white)
                    
                    Text("@\(user.username)")
                        .foregroundStyle(.gray)
                }
            
                let lastMessages = messageViewModel.lastMessages[user.userID]
                if Auth.auth().currentUser?.uid == lastMessages?.senderID {
                    Text("Sen: \(lastMessages?.message ?? "")")
                        .foregroundStyle(.gray)
                        .lineLimit(1)
                        .truncationMode(.tail)
                } else {
                    Text(lastMessages?.message ?? "")
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            
            Spacer()
        }
        .padding(.leading)
        .onAppear {
            messageViewModel.loadLastMessage(with: user.userID)
        }
    }
}

#Preview {
    MessagedUserCard(user: UserModel(userID: "", name: "İbrahim Ay", username: "ibrahimmayy10", imageUrl: "", profileImageUrl: "", bio: "", birthday: Timestamp()))
}
