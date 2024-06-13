//
//  UserWhoRTView.swift
//  X
//
//  Created by İbrahim Ay on 4.06.2024.
//

import SwiftUI

struct UserWhoRTView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var tweetID: String

    @ObservedObject var userWhoRTViewModel = UserWhoLikeRTViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 30) {
                        ForEach(userWhoRTViewModel.users, id: \.id) { user in
                            UserWhoLikeRTCard(name: user.name, username: user.username, profileImageUrl: user.profileImageUrl, userID: user.userID, buttonText: "Takip et")
                        }
                    }
                }
            }
            .onAppear {
                userWhoRTViewModel.getDataUsersWhoRT(tweetID: tweetID)
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
                    Text("Yeniden gönderen:")
                        .foregroundStyle(.white)
                        .fontWeight(.heavy)
                        .font(.system(size: 18))
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    UserWhoRTView(tweetID: "")
}
