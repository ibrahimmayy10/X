//
//  MessageView.swift
//  X
//
//  Created by İbrahim Ay on 5.06.2024.
//

import SwiftUI
import Firebase

struct MessageView: View {
    
    @State var user: UserModel
    
    @ObservedObject var messageViewModel = MessageViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    ScrollViewReader { proxy in
                        VStack {
                            ForEach(messageViewModel.messages, id: \.id) { message in
                                MessageCard(message: message)
                            }
                            
                            HStack {
                                Spacer()
                            }
                            .id("Empty")
                        }
                        .onReceive(messageViewModel.$count) { _ in
                            withAnimation(.easeOut(duration: 0.5)) {
                                proxy.scrollTo("Empty", anchor: .bottom)
                            }
                        }
                    }
                }
                .background(.black)
                .safeAreaInset(edge: .bottom, content: {
                    VStack {
                        Divider()
                            .background(.gray)
                        
                        HStack {
                            ZStack {
                                HStack {
                                    NavigationLink(destination: SendImageView(user: user)) {
                                        Image(systemName: "photo")
                                            .foregroundStyle(Color(uiColor: .systemGray))
                                    }
                                    
                                    TextField("Bir mesaj başlat", text: $messageViewModel.messageText, axis: .vertical)
                                }
                            }
                            .frame(height: 45)
                            
                            HStack {
                                Button(action: {
                                    guard !messageViewModel.messageText.isEmpty else { return }
                                    messageViewModel.sendMessage(recipientUserID: user.id, message: messageViewModel.messageText)
                                    messageViewModel.messageText = ""
                                }, label: {
                                    Image(systemName: "paperplane.circle.fill")
                                        .foregroundStyle(.blue)
                                        .font(.system(size: 40))
                                })
                                .padding(.leading, 5)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                })
            }
            .onAppear {
                messageViewModel.loadMessage(recipientUserID: user.id)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: MessagedUsersView()) {
                        Image(systemName: "arrow.left")
                            .foregroundStyle(.white)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    NavigationLink(destination: NewUserProfileView(user: user)) {
                        HStack {
                            if !user.profileImageUrl.isEmpty {
                                AsyncImage(url: URL(string: user.profileImageUrl)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .cornerRadius(25)
                                    case .failure(_):
                                        Image(systemName: "person")
                                            .font(.system(size: 15))
                                            .frame(width: 30, height: 30)
                                            .cornerRadius(25)
                                            .overlay(Circle().stroke(.white, lineWidth: 1))
                                            .foregroundStyle(.white)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Image(systemName: "person")
                                    .font(.system(size: 15))
                                    .frame(width: 30, height: 30)
                                    .cornerRadius(25)
                                    .overlay(Circle().stroke(.white, lineWidth: 1))
                                    .foregroundStyle(.white)
                            }
                            
                            Text(user.name)
                                .foregroundStyle(.white)
                                .fontWeight(.heavy)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    MessageView(user: UserModel(userID: "", name: "ibrahim ay", username: "ibrahimmayy10", imageUrl: "", profileImageUrl: "", bio: "", birthday: Timestamp()))
}

struct FullScreenMessageImageView: View {
    
    @State var imageUrl: String
    @State private var showToolBar = false
    
    @Environment(\.presentationMode) var presentationMode
    
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
                    showToolBar.toggle()
                }
            }
            .toolbar {
                if showToolBar {
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
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
