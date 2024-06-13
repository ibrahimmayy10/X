//
//  FollowingView.swift
//  X
//
//  Created by İbrahim Ay on 4.06.2024.
//

import SwiftUI

struct FollowingView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var name: String
    @State var userID: String
    
    @ObservedObject var viewModel = FollowViewModel()
    
    enum FollowingSection: String, CaseIterable {
        case following = "Takip edilenler"
        case follower = "Takipçiler"
    }
    
    @State private var selection: FollowingSection = .following
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(FollowingSection.allCases, id: \.self) { section in
                            VStack {
                                Text(section.rawValue)
                                    .padding(.horizontal)
                                    .fontWeight(.heavy)
                                    .foregroundColor(selection == section ? .white : .gray)
                                    .onTapGesture {
                                        selection = section
                                    }
                                        
                                if selection == section {
                                    Divider()
                                        .frame(height: 3)
                                        .background(.blue)
                                        .padding(.horizontal)
                                } else {
                                    Divider()
                                        .frame(height: 3)
                                        .background(Color.clear)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                        
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 30) {
                        if selection == .following {
                            ForEach(viewModel.followingList, id: \.id) { user in
                                UserWhoLikeRTCard(name: user.name, username: user.username, profileImageUrl: user.profileImageUrl, userID: user.userID, buttonText: "Takip ediliyor")
                            }
                        } else {
                            ForEach(viewModel.followerList, id: \.id) { user in
                                UserWhoLikeRTCard(name: user.name, username: user.username, profileImageUrl: user.profileImageUrl, userID: user.userID, buttonText: "Takip et")
                            }
                        }
                    }
                }
            }
            .onAppear {
                if userID.isEmpty {
                    viewModel.getDataFollowing()
                    viewModel.getDataFollower()
                } else {
                    viewModel.getDataNewUserFollower(userID: userID)
                    viewModel.getDataNewUserFollowing(userID: userID)
                }
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
                    Text(name)
                        .foregroundStyle(.white)
                        .font(.system(size: 18))
                        .fontWeight(.heavy)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    FollowingView(name: "ibrahim", userID: "")
}
