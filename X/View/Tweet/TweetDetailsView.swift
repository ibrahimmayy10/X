//
//  TweetDetailsView.swift
//  X
//
//  Created by İbrahim Ay on 27.05.2024.
//

import SwiftUI
import Firebase
import AVKit

struct TweetDetailsView: View {
    
    @State var profileImageUrl: String
    @State var name: String
    @State var username: String
    @State var tweet: String
    @State var time: Timestamp
    @State var tweetID: String
    @State var likes: Int
    @State var rtCount: Int
    @State var tweetImageUrl: String
    @State var videoUrl: String
    @State var isLiked = false
    @State var isRT = false
    @State var isImageFullScreenPresented = false
    @State var isVideoFullScreenPresented = false
    
    @ObservedObject var tweetDetailsViewModel = TweetDetailsViewModel()
    @ObservedObject var mainViewModel = MainViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
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
                            .foregroundStyle(.white)
                            .bold()
                        
                        Text("@\(username)")
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                }
                
                Text(tweet)
                    .foregroundStyle(.white)
                    .padding(.top)
                
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
                            Text("yükleme hatası")
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
                    Text(formatDate())
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                    
                    Text("Konum: Earth")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                }
                .padding(.top)
                
                Divider()
                    .background(.gray)
                    .padding(.vertical, 5)
                
                HStack {
                    NavigationLink(destination: UserWhoRTView(tweetID: tweetID)) {
                        Text(String(rtCount))
                            .fontWeight(.heavy)
                            .foregroundStyle(.white)
                        
                        Text("Yeniden Gönderi")
                            .foregroundStyle(.gray)
                    }
                    
                    NavigationLink(destination: UserWhoLikeView(tweetID: tweetID)) {
                        Text(String(likes))
                            .fontWeight(.heavy)
                            .foregroundStyle(.white)
                        
                        Text("Beğeni")
                            .foregroundStyle(.gray)
                    }
                }
                
                Divider()
                    .background(.gray)
                    .padding(.vertical, 5)
                
                HStack {
                    Spacer()
                    
                    NavigationLink(destination: CommentView(name: name, username: username, tweet: tweet, profileImageUrl: profileImageUrl, time: time, tweetID: tweetID)) {
                        Image(systemName: "message")
                            .font(.system(size: 18))
                            .bold()
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        mainViewModel.reTweet(tweetID: tweetID)
                        isRT.toggle()
                        rtCount += isRT ? 1 : -1
                    }, label: {
                        Image(systemName: "arrow.2.squarepath")
                            .font(.system(size: 18))
                            .bold()
                            .foregroundStyle(isRT ? .green : .gray)
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        mainViewModel.likeTweet(tweetID: tweetID)
                        isLiked.toggle()
                        likes += isLiked ? 1 : -1
                    }, label: {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .bold()
                            .foregroundStyle(isLiked ? .pink : .gray)
                    })
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                Divider()
                    .background(.gray)
                    .padding(.vertical, 5)
                
                ScrollView {
                    VStack {
                        ForEach(Array(tweetDetailsViewModel.comments.enumerated()), id: \.element.id) { index, comment in
                            CommentCard(profileImageUrl: comment.profileImageUrl, name: comment.name, username: comment.username, tweet: comment.comment, time: comment.time, tweetID: comment.tweetID, commentID: comment.commentID, likes: 0)
                            
                            if index < tweetDetailsViewModel.comments.count - 1 {
                                Divider()
                                    .background(.gray)
                                    .padding(.vertical, 10)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .onAppear {
                tweetDetailsViewModel.getDataTweetDetails(tweetID: tweetID)
                mainViewModel.isTweetLiked(tweetID: tweetID) { liked in
                    if liked {
                        self.isLiked = liked
                    }
                }
                mainViewModel.isRT(tweetID: tweetID) { rt in
                    if rt {
                        self.isRT = rt
                    }
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
                    Text("Gönderi")
                        .fontWeight(.heavy)
                        .font(.system(size: 19))
                        .foregroundStyle(.white)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    private func formatDate() -> String {
        let date = time.dateValue()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    TweetDetailsView(profileImageUrl: "", name: "İbrahim Ay", username: "ibrahimmayy10", tweet: "Selamlar", time: Timestamp(date: Date()), tweetID: "", likes: Int(), rtCount: Int(), tweetImageUrl: "", videoUrl: "")
}
