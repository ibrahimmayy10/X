//
//  UserWhoLikeView.swift
//  X
//
//  Created by İbrahim Ay on 31.05.2024.
//

import SwiftUI

struct UserWhoLikeView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var tweetID: String
    
    @ObservedObject var userWhoLikeViewModel = UserWhoLikeRTViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 30) {
                        ForEach(userWhoLikeViewModel.users, id: \.id) { user in
                            UserWhoLikeRTCard(name: user.name, username: user.username, profileImageUrl: user.profileImageUrl, userID: user.userID, buttonText: "Takip et")
                        }
                    }
                }
            }
            .onAppear {
                userWhoLikeViewModel.getDataUsersWhoLike(tweetID: tweetID)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "arrow.backward")
                            .foregroundStyle(.white)
                    })
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Beğenenler:")
                        .font(.system(size: 18))
                        .fontWeight(.heavy)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    UserWhoLikeView(tweetID: "")
}
