//
//  CommentCard.swift
//  X
//
//  Created by İbrahim Ay on 29.05.2024.
//

import SwiftUI
import Firebase

struct CommentCard: View {
    
    @State var profileImageUrl: String
    @State var name: String
    @State var username: String
    @State var tweet: String
    @State var time: Timestamp
    @State var tweetID: String
    @State var commentID: String
    @State var likes: Int
    @State var isLiked = false
    
    @ObservedObject var tweetDetailsViewModel = TweetDetailsViewModel()
    
    var body: some View {
        HStack {
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
                
                HStack {
                    NavigationLink(destination: CommentView(name: name, username: username, tweet: tweet, profileImageUrl: profileImageUrl, time: time, tweetID: tweetID)) {
                        Image(systemName: "message")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {}, label: {
                        Image(systemName: "arrow.2.squarepath")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        tweetDetailsViewModel.likeComment(commentID: commentID, tweetID: tweetID)
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
            tweetDetailsViewModel.isTweetLiked(tweetID: tweetID, commentID: commentID) { liked in
                if liked {
                    self.isLiked = liked
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
    CommentCard(profileImageUrl: "", name: "İbrahim Ay", username: "ibrahimmayy10", tweet: "selamlar", time: Timestamp(date: Date()), tweetID: "", commentID: "", likes: Int())
}
