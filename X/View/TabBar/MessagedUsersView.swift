//
//  MessageView.swift
//  X
//
//  Created by İbrahim Ay on 30.05.2024.
//

import SwiftUI

struct MessagedUsersView: View {
    
    @ObservedObject var userProfileViewModel = UserProfileViewModel()
    @ObservedObject var messageViewModel = MessageViewModel()
    
    @State var isPresented = false
    @State var isRefreshing = false
    @State var showDrawer = false
    @State private var dragOffset = CGSize.zero
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .leading) {
                VStack {
                    ZStack {
                        VStack {
                            ScrollView {
                                VStack(spacing: 20) {
                                    ForEach(messageViewModel.messagedUsers, id: \.id) { user in
                                        NavigationLink(destination: MessageView(user: user)) {
                                            MessagedUserCard(user: user)
                                        }
                                    }
                                }
                            }
                            
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    isPresented = true
                                }, label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 25.0)
                                            .foregroundStyle(.blue)
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: "envelope.badge.person.crop")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 21))
                                    }
                                })
                                .padding(.trailing)
                                .padding(.bottom)
                            }
                        }
                    }
                }
                .fullScreenCover(isPresented: $isPresented, content: {
                    AddNewUserView()
                })
                .onAppear {
                    messageViewModel.loadMessagedUsers()
                    userProfileViewModel.getDataUserProfileImage()
                }
                .refreshable {
                    await refreshData()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showDrawer.toggle()
                        }, label: {
                            if userProfileViewModel.profileImageUrl.isEmpty {
                                Image(systemName: "person")
                                    .font(.system(size: 18))
                                    .frame(width: 35, height: 35)
                                    .cornerRadius(25)
                                    .overlay(Circle().stroke(.white, lineWidth: 1))
                                    .foregroundStyle(.white)
                            } else {
                                AsyncImage(url: URL(string: userProfileViewModel.profileImageUrl)) { phase in
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
                                            .font(.system(size: 18))
                                            .frame(width: 35, height: 35)
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
                    
                    ToolbarItem(placement: .principal) {
                        Text("Mesajlar")
                            .foregroundStyle(.white)
                            .font(.system(size: 18))
                            .fontWeight(.heavy)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gear")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .foregroundStyle(.white)
                        }
                    }
                }
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
        messageViewModel.loadMessagedUsers()
    }
}

#Preview {
    MessagedUsersView()
}
