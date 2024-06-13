//
//  MessageCard.swift
//  X
//
//  Created by İbrahim Ay on 6.06.2024.
//

import SwiftUI
import Firebase

struct MessageCard: View {
    
    @State var message: MessageModel
    @State var isImageFullScreenPresented = false
    
    var body: some View {
        VStack {
            if message.senderID == Auth.auth().currentUser?.uid {
                HStack {
                    Spacer()
                    
                    if !message.imageUrl.isEmpty {
                        AsyncImage(url: URL(string: message.imageUrl)) { phase in
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
                                    .frame(maxWidth: UIScreen.main.bounds.size.width * 0.8, maxHeight: UIScreen.main.bounds.size.height * 0.7)
                                    .onTapGesture {
                                        isImageFullScreenPresented.toggle()
                                    }
                                    .fullScreenCover(isPresented: $isImageFullScreenPresented) {
                                        FullScreenMessageImageView(imageUrl: message.imageUrl)
                                    }
                            case .failure(_):
                                Image("yuklemehatasi")
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                    .padding(.bottom)
                                    .frame(maxWidth: UIScreen.main.bounds.size.width * 0.8, maxHeight: UIScreen.main.bounds.size.height * 0.7)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        HStack {
                            Text(message.message)
                                .foregroundStyle(.white)
                        }
                        .padding()
                        .background(.blue)
                        .cornerRadius(25)
                    }
                }
            } else {
                HStack {
                    if !message.imageUrl.isEmpty {
                        AsyncImage(url: URL(string: message.imageUrl)) { phase in
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
                                    .frame(maxWidth: UIScreen.main.bounds.size.width * 0.8, maxHeight: UIScreen.main.bounds.size.height * 0.7)
                                    .onTapGesture {
                                        isImageFullScreenPresented.toggle()
                                    }
                                    .fullScreenCover(isPresented: $isImageFullScreenPresented, content: {
                                        FullScreenMessageImageView(imageUrl: message.imageUrl)
                                    })
                            case .failure(_):
                                ProgressView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        HStack {
                            Text(message.message)
                                .foregroundStyle(.white)
                        }
                        .padding()
                        .background(Color(uiColor: .systemGray5))
                        .cornerRadius(25)
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    MessageCard(message: MessageModel(documentId: "", data: [:]))
}
