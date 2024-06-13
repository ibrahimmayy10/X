//
//  NotificationView.swift
//  X
//
//  Created by İbrahim Ay on 30.05.2024.
//

import SwiftUI

struct NotificationView: View {
    
    @ObservedObject var userProfileViewModel = UserProfileViewModel()
    @ObservedObject var notificationViewModel = NotificationViewModel()
    
    @State var showDrawer = false
    @State private var dragOffset = CGSize.zero
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .leading) {
                VStack {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible())], spacing: 30) {
                            ForEach(Array(notificationViewModel.notifications.enumerated()), id: \.element.id) { index, notification in
                                VStack {
                                    NotificationCard(notification: notification)
                                    
                                    if index < notificationViewModel.notifications.count - 1 {
                                        Divider()
                                            .background(.gray)
                                    }
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    notificationViewModel.getDataLikeNotification()
                    userProfileViewModel.getDataUserProfileImage()
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
}

#Preview {
    NotificationView()
}
