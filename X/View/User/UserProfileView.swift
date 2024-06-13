//
//  UserProfileView.swift
//  X
//
//  Created by İbrahim Ay on 19.05.2024.
//

import SwiftUI
import Firebase

struct UserProfileView: View {
    
    @ObservedObject var userProfileViewModel = UserProfileViewModel()
    @ObservedObject var newUserViewModel = NewUserProfileViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var isPresented = false
    @State private var showMainView = false
    @State private var isRefreshing = false
    @State var userID = Auth.auth().currentUser?.uid
    
    enum Section: String, CaseIterable {
        case tweets = "Gönderi sayısı"
        case like = "Beğeni"
        case rt = "Yeniden yayınlananlar"
    }
    
    @State private var selection: Section = .tweets
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        if isRefreshing {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        
                        ZStack(alignment: .bottomLeading) {
                            if userProfileViewModel.imageUrl.isEmpty {
                                RoundedRectangle(cornerRadius: 0)
                                    .foregroundStyle(.blue)
                                    .frame(height: 130)
                            } else {
                                AsyncImage(url: URL(string: userProfileViewModel.imageUrl)) { phase in
                                    switch phase {
                                    case .empty:
                                        HStack {
                                            Spacer()
                                            
                                            ProgressView()
                                                .frame(height: 130)
                                            
                                            Spacer()
                                        }
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .frame(height: 130)
                                    case .failure(_):
                                        RoundedRectangle(cornerRadius: 0)
                                            .foregroundStyle(.blue)
                                            .frame(height: 130)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                            
                            if userProfileViewModel.profileImageUrl.isEmpty {
                                Image(systemName: "person")
                                    .font(.system(size: 35))
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(25)
                                    .overlay(Circle().stroke(.white, lineWidth: 1))
                                    .foregroundStyle(.white)
                                    .offset(x: 0, y: 25)
                                    .padding(.leading)
                            } else {
                                AsyncImage(url: URL(string: userProfileViewModel.profileImageUrl)) { phase in
                                    switch phase {
                                    case .empty:
                                            ProgressView()
                                                .offset(x: 0, y: 25)
                                                .padding(.leading)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(25)
                                            .scaledToFill()
                                            .offset(x: 0, y: 25)
                                            .padding(.leading)
                                    case .failure(_):
                                        Image(systemName: "person")
                                            .font(.system(size: 35))
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(25)
                                            .overlay(Circle().stroke(.white, lineWidth: 1))
                                            .foregroundStyle(.white)
                                            .offset(x: 0, y: 25)
                                            .padding(.leading)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                        }
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(userProfileViewModel.name)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 22))
                                    .fontWeight(.heavy)
                                
                                Text("@\(userProfileViewModel.username)")
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 16))
                            }
                            .padding(.top, 30)
                            
                            Spacer()
                            
                            Button(action: {
                                isPresented = true
                            }, label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(.gray, lineWidth: 1)
                                        .frame(width: 140, height: 35)
                                    
                                    Text("Profili düzenle")
                                        .foregroundStyle(.white)
                                        .bold()
                                }
                            })
                            .padding(.trailing)
                        }
                        
                        Text(userProfileViewModel.bio)
                            .padding(.top)
                            .foregroundStyle(.white)
                        
                        if let birthday = userProfileViewModel.birthday {
                            Text("Doğum tarihi: \(formatDate(birthday))")
                                .foregroundStyle(.gray)
                                .font(.system(size: 15))
                        }
                        
                        
                        HStack {
                            NavigationLink(destination: FollowingView(name: userProfileViewModel.name, userID: "")) {
                                Text(String(userProfileViewModel.followingCount))
                                    .font(.system(size: 13))
                                    .bold()
                                    .foregroundStyle(.white)
                                
                                Text("Takip edilen")
                                    .font(.system(size: 13))
                                    .bold()
                                    .foregroundStyle(.gray)
                            }
                            
                            NavigationLink(destination: FollowingView(name: userProfileViewModel.name, userID: "")) {
                                Text(String(userProfileViewModel.followerCount))
                                    .font(.system(size: 13))
                                    .bold()
                                    .foregroundStyle(.white)
                                
                                Text("Takipçi")
                                    .font(.system(size: 13))
                                    .bold()
                                    .foregroundStyle(.gray)
                            }
                        }
                        .padding(.top)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(Section.allCases, id: \.self) { section in
                                    VStack {
                                        Text(section.rawValue)
                                            .padding(.horizontal)
                                            .fontWeight(.heavy)
                                            .foregroundStyle(selection == section ? .white : .gray)
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
                                                .background(.clear)
                                                .padding(.horizontal)
                                        }
                                    }
                                }
                            }
                        }
                        
                        LazyVGrid(columns: [GridItem(.flexible())], spacing: 20) {
                            if selection == .tweets {
                                ForEach(Array(userProfileViewModel.currentUserTweets.enumerated()), id: \.element.id) { index, tweet in
                                    VStack {
                                        NavigationLink(destination: TweetDetailsView(profileImageUrl: userProfileViewModel.profileImageUrl, name: userProfileViewModel.name, username: userProfileViewModel.username, tweet: tweet.tweet, time: tweet.time, tweetID: tweet.tweetID, likes: tweet.likes.count, rtCount: tweet.rt.count, tweetImageUrl: tweet.tweetImageUrl, videoUrl: tweet.videoUrl)) {
                                            
                                            TweetCard(profileImageUrl: userProfileViewModel.profileImageUrl, name: userProfileViewModel.name, username: userProfileViewModel.username, userID: userID ?? "", imageUrl: userProfileViewModel.imageUrl, bio: userProfileViewModel.bio, birthday: userProfileViewModel.birthday ?? Timestamp(), tweet: tweet.tweet, time: tweet.time, tweetID: tweet.tweetID, likes: tweet.likes.count, rtCount: tweet.rt.count, tweetImageUrl: tweet.tweetImageUrl, videoUrl: tweet.videoUrl)
                                        }
                                        
                                        if index < userProfileViewModel.currentUserTweets.count - 1 {
                                            Divider()
                                                .background(.gray)
                                        }
                                    }
                                }
                            } else if selection == .rt {
                                ForEach(Array(userProfileViewModel.reTweets.enumerated()), id: \.element.id) { index, tweet in
                                    VStack {
                                        NavigationLink(destination: TweetDetailsView(profileImageUrl: tweet.profileImageUrl, name: tweet.name, username: tweet.username, tweet: tweet.tweet, time: tweet.time, tweetID: tweet.tweetID, likes: tweet.likes.count, rtCount: tweet.rt.count, tweetImageUrl: tweet.tweetImageUrl, videoUrl: tweet.videoUrl)) {
                                            
                                            RTCard(profileImageUrl: tweet.profileImageUrl, name: tweet.name, rtName: String(), username: tweet.username, tweet: tweet.tweet, time: tweet.time, tweetID: tweet.tweetID, likes: tweet.likes.count, rtCount: tweet.rt.count, tweetImageUrl: tweet.tweetImageUrl)
                                        }
                                        
                                        if index < userProfileViewModel.reTweets.count - 1 {
                                            Divider()
                                                .background(.gray)
                                        }
                                    }
                                }
                            } else if selection == .like {
                                ForEach(Array(userProfileViewModel.likedTweets.enumerated()), id: \.element.id) { index, tweet in
                                    VStack {
                                        NavigationLink(destination: TweetDetailsView(profileImageUrl: tweet.profileImageUrl, name: tweet.name, username: tweet.username, tweet: tweet.tweet, time: tweet.time, tweetID: tweet.tweetID, likes: tweet.likes.count, rtCount: tweet.rt.count, tweetImageUrl: tweet.tweetImageUrl, videoUrl: tweet.videoUrl)) {
                                            
                                            TweetCard(profileImageUrl: tweet.profileImageUrl, name: tweet.name, username: tweet.username, userID: tweet.userID, imageUrl: tweet.imageUrl, bio: tweet.bio, birthday: tweet.birthday, tweet: tweet.tweet, time: tweet.time, tweetID: tweet.tweetID, likes: tweet.likes.count, rtCount: tweet.rt.count, tweetImageUrl: tweet.tweetImageUrl, videoUrl: tweet.videoUrl)
                                        }
                                        
                                        if index < userProfileViewModel.likedTweets.count - 1 {
                                            Divider()
                                                .background(.gray)
                                        }
                                    }
                                }
                            }
                        }
                    }
                        
                    Spacer()
                }
            }
            .sheet(isPresented: $isPresented, content: {
                EditProfileView()
            })
            .edgesIgnoringSafeArea(.top)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: MainView()) {
                        Image(systemName: "arrow.left.circle.fill")
                            .resizable()
                            .foregroundStyle(Color(uiColor: .darkGray))
                            .frame(width: 30, height: 30)
                    }
                }
            }
            .task {
                userProfileViewModel.getDataUserBio()
                userProfileViewModel.getDataUserBirthday()
                userProfileViewModel.getDataUsername()
                userProfileViewModel.getDataUserImage()
                userProfileViewModel.getDataUserProfileImage()
                userProfileViewModel.getDataTweet()
                userProfileViewModel.getDataRT()
                userProfileViewModel.getDataLikedTweets()
                userProfileViewModel.getDataFollowerCount()
                userProfileViewModel.getDataFollowingCount()
            }
            .refreshable {
                await refreshData()
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    private func refreshData() async {
        isRefreshing = true
        
        userProfileViewModel.getDataUsername()
        userProfileViewModel.getDataUserImage()
        userProfileViewModel.getDataUserProfileImage()
        userProfileViewModel.getDataTweet()
        userProfileViewModel.getDataRT()
        userProfileViewModel.getDataLikedTweets()
        userProfileViewModel.getDataUserBio()
        userProfileViewModel.getDataUserBirthday()
        userProfileViewModel.getDataFollowerCount()
        userProfileViewModel.getDataFollowingCount()
        
        await Task.sleep(2 * 1_000_000_000)
        
        isRefreshing = false
    }
    
    private func formatDate(_ birthday: Timestamp) -> String {
        let date = birthday.dateValue()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    UserProfileView()
}
