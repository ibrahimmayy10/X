//
//  NewUserProfileView.swift
//  X
//
//  Created by İbrahim Ay on 20.05.2024.
//

import SwiftUI
import Firebase

struct NewUserProfileView: View {
    
    @State var user: UserModel
    @State var isFollowed = false
    
    @ObservedObject var viewModel = NewUserProfileViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isRefreshing = false
    
    enum Section: String, CaseIterable {
        case tweets = "Gönderi sayısı"
        case like = "Beğeni"
        case rt = "Yeniden yayınlananlar"
    }
    
    @State private var selection: Section = .tweets
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    
                    if isRefreshing {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    
                    ZStack(alignment: .bottomLeading) {
                        if !user.imageUrl.isEmpty {
                            AsyncImage(url: URL(string: user.imageUrl)) { phase in
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
                        } else {
                            RoundedRectangle(cornerRadius: 0)
                                .foregroundStyle(.blue)
                                .frame(height: 130)
                        }
                        
                        if !user.profileImageUrl.isEmpty {
                            AsyncImage(url: URL(string: user.profileImageUrl)) { phase in
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
                        } else {
                            Image(systemName: "person")
                                .font(.system(size: 35))
                                .frame(width: 50, height: 50)
                                .cornerRadius(25)
                                .overlay(Circle().stroke(.white, lineWidth: 1))
                                .foregroundStyle(.white)
                                .offset(x: 0, y: 25)
                                .padding(.leading)
                        }
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(user.name)
                                .foregroundStyle(.white)
                                .font(.system(size: 22))
                                .fontWeight(.heavy)
                            
                            Text("@\(user.username)")
                                .foregroundStyle(.gray)
                                .font(.system(size: 16))
                        }
                        .padding(.top, 30)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.followUser(newUserID: user.id)
                            isFollowed.toggle()
                            viewModel.followerCount += isFollowed ? 1 : -1
                        }, label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(.gray, lineWidth: 1)
                                    .frame(width: 140, height: 35)
                                
                                Text(isFollowed ? "Takip ediliyor" : "Takip et")
                                    .foregroundStyle(.white)
                                    .bold()
                            }
                        })
                        .padding(.trailing)
                    }
                    
                    Text(user.bio)
                        .padding(.top)
                        .foregroundStyle(.white)
                    
                    Text("Doğum tarihi: \(formatDate(user.birthday))")
                        .foregroundStyle(.gray)
                        .font(.system(size: 15))
                    
                    HStack {
                        NavigationLink(destination: FollowingView(name: user.name, userID: user.id)) {
                            Text(String(viewModel.followingCount))
                                .font(.system(size: 13))
                                .bold()
                                .foregroundStyle(.white)
                            
                            Text("Takip edilen")
                                .font(.system(size: 13))
                                .bold()
                                .foregroundStyle(.gray)
                        }
                        
                        NavigationLink(destination: FollowingView(name: user.name, userID: user.id)) {
                            Text(String(viewModel.followerCount))
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
                            ForEach(Array(viewModel.tweets.enumerated()), id: \.element.id) { index, tweet in
                                VStack {
                                    NavigationLink(destination: TweetDetailsView(profileImageUrl: user.profileImageUrl, name: user.name, username: user.username, tweet: tweet.tweet, time: tweet.time, tweetID: tweet.tweetID, likes: tweet.likes.count, rtCount: tweet.rt.count, tweetImageUrl: tweet.tweetImageUrl, videoUrl: tweet.videoUrl)) {
                                        
                                        TweetCard(profileImageUrl: user.profileImageUrl, name: user.name, username: user.username, userID: user.userID, imageUrl: user.imageUrl, bio: user.bio, birthday: user.birthday, tweet: tweet.tweet, time: tweet.time, tweetID: tweet.tweetID, likes: tweet.likes.count, rtCount: tweet.rt.count, tweetImageUrl: tweet.tweetImageUrl, videoUrl: tweet.videoUrl)
                                    }
                                    
                                    if index < viewModel.tweets.count - 1 {
                                        Divider()
                                            .background(.gray)
                                    }
                                }
                            }
                        } else if selection == .rt {
                            ForEach(Array(viewModel.reTweets.enumerated()), id: \.element.id) { index, tweet in
                                VStack {
                                    NavigationLink(destination: TweetDetailsView(profileImageUrl: tweet.profileImageUrl, name: tweet.name, username: tweet.username, tweet: tweet.tweet, time: tweet.time, tweetID: tweet.tweetID, likes: tweet.likes.count, rtCount: tweet.rt.count, tweetImageUrl: tweet.tweetImageUrl, videoUrl: tweet.videoUrl)) {
                                        
                                        RTCard(profileImageUrl: tweet.profileImageUrl, name: tweet.name, rtName: user.name, username: tweet.username, tweet: tweet.tweet, time: tweet.time, tweetID: tweet.tweetID, likes: tweet.likes.count, rtCount: tweet.rt.count, tweetImageUrl: tweet.tweetImageUrl)
                                    }
                                    
                                    if index < viewModel.reTweets.count - 1 {
                                        Divider()
                                            .background(.gray)
                                    }
                                }
                            }
                        } else if selection == .like {
                            ForEach(Array(viewModel.likedTweets.enumerated()), id: \.element.id) { index, tweet in
                                VStack {
                                    NavigationLink(destination: TweetDetailsView(profileImageUrl: tweet.profileImageUrl, name: tweet.name, username: tweet.username, tweet: tweet.tweet, time: tweet.time, tweetID: tweet.tweetID, likes: tweet.likes.count, rtCount: tweet.rt.count, tweetImageUrl: tweet.tweetImageUrl, videoUrl: tweet.videoUrl)) {
                                        
                                        TweetCard(profileImageUrl: tweet.profileImageUrl, name: tweet.name, username: tweet.username, userID: tweet.userID, imageUrl: tweet.imageUrl, bio: tweet.bio, birthday: tweet.birthday, tweet: tweet.tweet, time: tweet.time, tweetID: tweet.tweetID, likes: tweet.likes.count, rtCount: tweet.rt.count, tweetImageUrl: tweet.tweetImageUrl, videoUrl: tweet.videoUrl)
                                    }
                                    
                                    if index < viewModel.likedTweets.count - 1 {
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
            .edgesIgnoringSafeArea(.top)
            .refreshable {
                await refreshData()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "arrow.left.circle.fill")
                            .resizable()
                            .foregroundStyle(Color(uiColor: .darkGray))
                            .frame(width: 30, height: 30)
                    })
                }
            }
            .onAppear {
                viewModel.getDataTweet(userID: user.id)
                viewModel.getDataFollowerCount(newUserID: user.id)
                viewModel.getDataFollowingCount(newUserID: user.id)
                viewModel.getDataRT(userID: user.id)
                viewModel.getDataLikedTweets(userID: user.id)
                viewModel.isUserFollowed(newUserID: user.id) { followed in
                    self.isFollowed = followed
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    private func formatDate(_ birthday: Timestamp) -> String {
        let date = birthday.dateValue()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    private func refreshData() async {
        isRefreshing = true
        
        viewModel.getDataTweet(userID: user.id)
        viewModel.getDataFollowerCount(newUserID: user.id)
        viewModel.getDataFollowingCount(newUserID: user.id)
        viewModel.getDataRT(userID: user.id)
        viewModel.getDataLikedTweets(userID: user.id)
        
        await Task.sleep(2 * 1_000_000_000)
        
        isRefreshing = false
    }
}

#Preview {
    NewUserProfileView(user: UserModel(userID: "5qL7wRQ9HcfRwCQlY2FTcjBwXfC2", name: "İbrahim Ay", username: "ibrahimmayy10", imageUrl: "https://firebasestorage.googleapis.com:443/v0/b/twitter-39e1b.appspot.com/o/images%2F36245035-B767-406C-875E-4B9EC3BC21B3.jpg?alt=media&token=45c7af5f-8344-4aa7-a85a-8b79f7cdab7a", profileImageUrl: "https://firebasestorage.googleapis.com:443/v0/b/twitter-39e1b.appspot.com/o/profileImages%2FF90221DB-F095-4D08-9881-67B09C1AF593.jpg?alt=media&token=0056b66b-d4d1-497b-ae78-41484834f0cb", bio: "", birthday: Timestamp()))
}
