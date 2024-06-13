//
//  UserWhoLikeCard.swift
//  X
//
//  Created by İbrahim Ay on 31.05.2024.
//

import SwiftUI

struct UserWhoLikeRTCard: View {
    
    @State var name: String
    @State var username: String
    @State var profileImageUrl: String
    @State var userID: String
    @State var buttonText: String
    
    @ObservedObject var viewModel = NewUserProfileViewModel()
    
    var body: some View {
        HStack {
            if !profileImageUrl.isEmpty {
                AsyncImage(url: URL(string: profileImageUrl)) { phase in
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
                Text(name)
                    .bold()
                    .foregroundStyle(.white)
                
                Text("@\(username)")
                    .foregroundStyle(.gray)
                    .font(.system(size: 15))
                
                Text("Banü Software Engineer")
                    .foregroundStyle(.white)
                    .font(.system(size: 14))
            }
            
            Button(action: {
                viewModel.followUser(newUserID: userID)
            }, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(.gray, lineWidth: 1)
                        .frame(width: 140, height: 35)
                    
                    Text(buttonText)
                        .foregroundStyle(.white)
                        .bold()
                }
            })
        }
    }
}

#Preview {
    UserWhoLikeRTCard(name: "İbrahim Ay", username: "ibrahimmayy10", profileImageUrl: "", userID: "", buttonText: "Takip et")
}
