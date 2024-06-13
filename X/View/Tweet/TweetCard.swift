//
//  TweetCard.swift
//  X
//
//  Created by İbrahim Ay on 24.05.2024.
//

import SwiftUI
import Firebase
import AVKit

struct TweetCard: View {
    
    @State var profileImageUrl: String
    @State var name: String
    @State var username: String
    @State var userID: String
    @State var imageUrl: String
    @State var bio: String
    @State var birthday: Timestamp
    @State var tweet: String
    @State var time: Timestamp
    @State var tweetID: String
    @State var likes: Int
    @State var rtCount: Int
    @State var tweetImageUrl: String
    @State var videoUrl: String
    @State var isLiked = false
    @State var isPresented = false
    @State var isRT = false
    @State var isImageFullScreenPresented = false
    @State var isVideoFullScreenPresented = false
    
    @ObservedObject var mainViewModel = MainViewModel()
    
    var body: some View {
        HStack(alignment: .top) {
            NavigationLink(destination: NewUserProfileView(user: UserModel(userID: userID, name: name, username: username, imageUrl: imageUrl, profileImageUrl: profileImageUrl, bio: bio, birthday: birthday))) {
                if profileImageUrl.isEmpty {
                    Image(systemName: "person")
                        .font(.system(size: 35))
                        .frame(width: 50, height: 50)
                        .cornerRadius(25)
                        .overlay(Circle().stroke(.white, lineWidth: 1))
                        .foregroundStyle(.white)
                } else {
                    AsyncImage(url: URL(string: profileImageUrl)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundStyle(.white)
                                .cornerRadius(25)
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
                }
            }
            
            VStack(alignment: .leading) {
                HStack {
                    NavigationLink(destination: NewUserProfileView(user: UserModel(userID: userID, name: name, username: username, imageUrl: imageUrl, profileImageUrl: profileImageUrl, bio: bio, birthday: birthday))) {
                        Text(name)
                            .foregroundStyle(.white)
                            .font(.system(size: 16))
                            .fontWeight(.heavy)
                        
                        Text("@\(username)")
                            .foregroundStyle(.gray)
                            .font(.system(size: 15))
                    }
                    
                    Text(formatDate())
                        .foregroundStyle(.gray)
                        .font(.system(size: 15))
                }
                
                Text(tweet)
                    .foregroundStyle(.white)
                
                if !tweetImageUrl.isEmpty {
                    AsyncImage(url: URL(string: tweetImageUrl)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .padding(.bottom)
                                .onTapGesture {
                                    isImageFullScreenPresented.toggle()
                                }
                                .fullScreenCover(isPresented: $isImageFullScreenPresented) {
                                    FullScreenImageView(imageUrl: tweetImageUrl, profileImageUrl: profileImageUrl, name: name, username: username, tweet: tweet, tweetID: tweetID, time: time, likes: likes, rtCount: rtCount)
                                }
                        case .failure(_):
                            Image("yuklemehatasi")
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .padding(.bottom)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                if !videoUrl.isEmpty {
                    VideoPlayer(player: AVPlayer(url: URL(string: videoUrl)!))
                        .onAppear {
                            let player = AVPlayer(url: URL(string: videoUrl)!)
                            player.play()
                        }
                        .scaledToFit()
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.bottom)
                        .onTapGesture {
                            isVideoFullScreenPresented.toggle()
                        }
                        .fullScreenCover(isPresented: $isVideoFullScreenPresented, content: {
                            FullScreenVideoPlayer(videoURL: URL(string: videoUrl)!)
                        })
                }
                
                HStack {
                    NavigationLink(destination: CommentView(name: name, username: username, tweet: tweet, profileImageUrl: profileImageUrl, time: time, tweetID: tweetID)) {
                        Image(systemName: "message")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        mainViewModel.reTweet(tweetID: tweetID)
                        isRT.toggle()
                        rtCount += isRT ? 1 : -1
                    }, label: {
                        Image(systemName: "arrow.2.squarepath")
                            .font(.system(size: 14))
                            .foregroundStyle(isRT ? .green : .gray)
                    })
                    
                    Text(String(rtCount))
                        .foregroundStyle(isRT ? .green : .gray)
                        .font(.system(size: 15))
                    
                    Spacer()
                    
                    Button(action: {
                        mainViewModel.likeTweet(tweetID: tweetID)
                        isLiked.toggle()
                        likes += isLiked ? 1 : -1
                    }, label: {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 16))
                            .foregroundStyle(isLiked ? .pink : .gray)
                    })
                    
                    Text(String(likes))
                        .foregroundStyle(isLiked ? .pink : .gray)
                        .font(.system(size: 15))
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 4)
            }
            
            Spacer()
        }
        .onAppear {
            mainViewModel.isTweetLiked(tweetID: tweetID) { liked in
                self.isLiked = liked
            }
            
            mainViewModel.isRT(tweetID: tweetID) { isRT in
                self.isRT = isRT
            }
        }
    }
    
    func formatDate() -> String {
        let date = time.dateValue()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

struct FullScreenImageView: View {
    @State var imageUrl: String
    @State var profileImageUrl: String
    @State var name: String
    @State var username: String
    @State var tweet: String
    @State var tweetID: String
    @State var time: Timestamp
    @State var likes: Int
    @State var rtCount: Int
    @State var isRT = false
    @State var isLiked = false
    @State var navigateToComments = false
    
    @ObservedObject var mainViewModel = MainViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showToolbar = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure(_):
                        Image("yuklemesorunu")
                            .resizable()
                            .scaledToFit()
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            .onTapGesture {
                withAnimation {
                    showToolbar.toggle()
                }
            }
            .toolbar {
                if showToolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .padding()
                        })
                    }
                    
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Button(action: {
                                navigateToComments = true
                            }, label: {
                                Image(systemName: "message")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.gray)
                            })
                            
                            Spacer()
                            
                            Button(action: {
                                mainViewModel.reTweet(tweetID: tweetID)
                                isRT.toggle()
                                rtCount += isRT ? 1 : -1
                            }, label: {
                                Image(systemName: "arrow.2.squarepath")
                                    .font(.system(size: 14))
                                    .foregroundStyle(isRT ? .green : .gray)
                            })
                            
                            Text(String(rtCount))
                                .foregroundStyle(isRT ? .green : .gray)
                                .font(.system(size: 15))
                            
                            Spacer()
                            
                            Button(action: {
                                mainViewModel.likeTweet(tweetID: tweetID)
                                isLiked.toggle()
                                likes += isLiked ? 1 : -1
                            }, label: {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .font(.system(size: 16))
                                    .foregroundStyle(isLiked ? .pink : .gray)
                            })
                            
                            Text(String(likes))
                                .foregroundStyle(isLiked ? .pink : .gray)
                                .font(.system(size: 15))
                            
                            Spacer()
                            
                            Button(action: {}, label: {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.gray)
                            })
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)
                    }
                }
            }
            .toolbarBackground(Color(red: 0.07, green: 0.07, blue: 0.07), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(red: 0.07, green: 0.07, blue: 0.07), for: .bottomBar)
            .toolbarBackground(.visible, for: .bottomBar)
            .fullScreenCover(isPresented: $navigateToComments, content: {
                CommentView(name: name, username: username, tweet: tweet, profileImageUrl: profileImageUrl, time: time, tweetID: tweetID)
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct FullScreenVideoPlayer: View {
    @State var videoURL: URL
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            let player = AVPlayer(url: videoURL)
            VideoPlayer(player: player)
                .onAppear {
                    player.play()
                }
            
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    })
                    .padding(.leading)
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    TweetCard(profileImageUrl: "", name: "İbrahim AY", username: "ibrahimmayy10", userID: "", imageUrl: "", bio: "", birthday: Timestamp(), tweet: "", time: Timestamp(date: Date()), tweetID: "", likes: 0, rtCount: 0, tweetImageUrl: "", videoUrl: "https://firebasestorage.googleapis.com:443/v0/b/twitter-39e1b.appspot.com/o/videos%2F0A23EC0D-E5F7-4003-B95E-CD983A4CDA80.mp4?alt=media&token=0ba78000-a515-4a4f-9219-7f79e4614272")
}
