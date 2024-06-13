//
//  MainView.swift
//  X
//
//  Created by İbrahim Ay on 17.05.2024.
//

import SwiftUI
import Firebase

struct MainView: View {
    
    @State var isPresented = false
    @State var showDrawer = false
    @State private var isRefreshing = false
    @State private var dragOffset = CGSize.zero
    
    @ObservedObject var mainViewModel = MainViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .leading) {
                VStack {
                    ZStack {
                        ScrollView {
                            VStack {
                                ForEach(Array(mainViewModel.tweets.enumerated()), id: \.element.id) { index, tweet in
                                    VStack {
                                        NavigationLink(destination: TweetDetailsView(profileImageUrl: tweet.profileImageUrl, name: tweet.name, username: tweet.username, tweet: tweet.tweet, time: tweet.time, tweetID: tweet.tweetID, likes: tweet.likes.count, rtCount: tweet.rt.count, tweetImageUrl: tweet.tweetImageUrl, videoUrl: tweet.videoUrl)) {
                                            
                                            TweetCard(profileImageUrl: tweet.profileImageUrl, name: tweet.name, username: tweet.username, userID: tweet.userID, imageUrl: tweet.imageUrl, bio: tweet.bio, birthday: tweet.birthday, tweet: tweet.tweet, time: tweet.time, tweetID: tweet.tweetID, likes: tweet.likes.count, rtCount: tweet.rt.count, tweetImageUrl: tweet.tweetImageUrl, videoUrl: tweet.videoUrl)
                                        }
                                        
                                        if index < mainViewModel.tweets.count - 1 {
                                            Divider()
                                                .background(.gray)
                                        }
                                    }
                                }
                            }
                        }
                        
                        VStack {
                            Spacer()
                            
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    self.isPresented.toggle()
                                }, label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(.blue)
                                })
                                .padding(.trailing)
                                .padding(.bottom)
                            }
                        }
                    }
                }
                .refreshable {
                    await refreshData()
                }
                .fullScreenCover(isPresented: $isPresented, content: {
                    CreateTweetView()
                })
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Image("x")
                            .resizable()
                            .frame(width: 110, height: 110)
                            .padding(.top, 5)
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation {
                                self.showDrawer.toggle()
                            }
                        }, label: {
                            if mainViewModel.profileImageUrl.isEmpty {
                                Image(systemName: "person")
                                    .font(.system(size: 18))
                                    .frame(width: 35, height: 35)
                                    .cornerRadius(25)
                                    .overlay(Circle().stroke(.white, lineWidth: 1))
                                    .foregroundStyle(.white)
                            } else {
                                AsyncImage(url: URL(string: mainViewModel.profileImageUrl)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .cornerRadius(25)
                                            .frame(width: 35, height: 35)
                                            .foregroundStyle(.white)
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
                        })
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onChanged({ value in
                            if value.translation.width > 0 {
                                self.dragOffset = value.translation
                            }
                        })
                        .onEnded({ value in
                            if value.translation.width > 100 {
                                withAnimation {
                                    self.showDrawer = true
                                }
                            }
                            self.dragOffset = .zero
                        })
                )
                
                if showDrawer {
                    OptionsView()
                        .frame(width: 250)
                        .transition(.move(edge: .leading))
                        .zIndex(1)
                        .gesture(
                            DragGesture()
                                .onChanged({ value in
                                    if value.translation.width < 0 {
                                        self.dragOffset = value.translation
                                    }
                                })
                                .onEnded({ value in
                                    if value.translation.width < -100 {
                                        withAnimation {
                                            self.showDrawer = false
                                        }
                                    }
                                    self.dragOffset = .zero
                                })
                        )
                }
            }
            .offset(x: dragOffset.width)
        }
        .navigationBarBackButtonHidden()
    }
    
    private func refreshData() async {
        await Task.sleep(2 * 1_000_000_000)
        
        mainViewModel.getDataFollowingTweet()
    }
}

#Preview {
    MainView()
}
