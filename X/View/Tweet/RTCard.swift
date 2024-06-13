//
//  RTCard.swift
//  X
//
//  Created by İbrahim Ay on 31.05.2024.
//

import SwiftUI
import Firebase

struct RTCard: View {
    
    @State var profileImageUrl: String
    @State var name: String
    @State var rtName: String
    @State var username: String
    @State var tweet: String
    @State var time: Timestamp
    @State var tweetID: String
    @State var likes: Int
    @State var rtCount: Int
    @State var tweetImageUrl: String
    @State var isLiked = false
    @State var isPresented = false
    @State var isRT = false
    @State var isImageFullScreenPresented = false
    
    @ObservedObject var mainViewModel = MainViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "arrow.2.squarepath")
                    .foregroundStyle(.gray)
                    .font(.system(size: 13))
                    .bold()
                
                if !rtName.isEmpty {
                    Text(rtName)
                        .font(.system(size: 13))
                        .foregroundStyle(.gray)
                        .fontWeight(.heavy)
                    
                    Text("gönderiyi yeniden yayınladı")
                        .font(.system(size: 13))
                        .foregroundStyle(.gray)
                        .fontWeight(.heavy)
                } else {
                    Text("Gönderiyi yeniden yayınladın")
                        .font(.system(size: 13))
                        .foregroundStyle(.gray)
                        .fontWeight(.heavy)
                }
            }
            .padding(.leading)
            
            HStack(alignment: .top) {
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
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(name)
                            .foregroundStyle(.white)
                            .font(.system(size: 16))
                            .fontWeight(.heavy)
                        
                        Text("@\(username)")
                            .foregroundStyle(.gray)
                            .font(.system(size: 15))
                        
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
                            case .failure(let error):
                                Text("yükleme hatası")
                            @unknown default:
                                EmptyView()
                            }
                        }
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
                        
                        Button(action: {}, label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16))
                                .foregroundStyle(.gray)
                        })
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
    }
    
    func formatDate() -> String {
        let date = time.dateValue()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    RTCard(profileImageUrl: "", name: "İbrahim Ay", rtName: "Ferhat Ayar", username: "", tweet: "", time: Timestamp(date: Date()), tweetID: "", likes: 0, rtCount: 0, tweetImageUrl: "")
}
