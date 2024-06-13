//
//  CreateTweetView.swift
//  X
//
//  Created by İbrahim Ay on 18.05.2024.
//

import SwiftUI
import Firebase
import AVKit

struct CreateTweetView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var createTweetViewModel = CreateTweetViewModel()
    
    @State var isPresented = false
    @State var isShowingImagePicker = false
    @State var isShowingVideoPicker = false
    @State var isShowingActionSheet = false
    
    @State private var image: UIImage? = nil
    @State private var videoURL: URL? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    HStack {
                        if createTweetViewModel.profileImageUrl.isEmpty {
                            Image(systemName: "person")
                                .font(.system(size: 20))
                                .frame(width: 30, height: 30)
                                .cornerRadius(25)
                                .overlay(Circle().stroke(.white, lineWidth: 1))
                        } else {
                            AsyncImage(url: URL(string: createTweetViewModel.profileImageUrl)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .cornerRadius(25)
                                        .scaledToFill()
                                case .failure(_):
                                    Image(systemName: "person")
                                        .font(.system(size: 20))
                                        .frame(width: 30, height: 30)
                                        .cornerRadius(25)
                                        .overlay(Circle().stroke(.white, lineWidth: 1))
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                        
                        TextField("Neler oluyor", text: $createTweetViewModel.tweet, axis: .vertical)
                    }
                    .padding(.top)
                    
                    Spacer()
                }
                
                if image != nil {
                    Image(uiImage: image!)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.bottom)
                } else if let videoURL = videoURL {
                    VideoPlayer(player: AVPlayer(url: videoURL))
                        .scaledToFit()
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.bottom)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        isShowingActionSheet = true
                    }, label: {
                        Image(systemName: "photo")
                            .font(.system(size: 35))
                    })
                    .padding(.trailing)
                    .padding(.bottom)
                }
            }
            .actionSheet(isPresented: $isShowingActionSheet) {
                ActionSheet(title: Text("Medya Seç"), message: Text("Lütfen bir seçenek belirleyin"), buttons: [
                    .default(Text("Fotoğraf Seç")) {
                        isShowingImagePicker = true
                    },
                    .default(Text("Video Seç")) {
                        isShowingVideoPicker = true
                    },
                    .cancel()
                ])
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(selectedImage: $image, isPresented: $isShowingImagePicker)
            }
            .sheet(isPresented: $isShowingVideoPicker) {
                VideoPicker(selectedVideoUrl: $videoURL, isPresented: $isShowingVideoPicker)
            }
            .navigationBarItems(leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("İptal et")
                        .foregroundStyle(.white)
                        .bold()
                })
            )
            .navigationBarItems(trailing: Button(action: {
                if let selectedImage = image {
                    createTweetViewModel.shareImageTweet(image: selectedImage) { success in
                        if success {
                            isPresented = true
                        }
                    }
                } else if let videoURL = videoURL {
                    createTweetViewModel.shareVideoTweet(videoUrl: videoURL) { success in
                        if success {
                            isPresented = true
                        }
                    }
                } else {
                    createTweetViewModel.shareTweet { success in
                        if success {
                            isPresented = true
                        } else {
                            
                        }
                    }
                }
            }, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 50)
                        .frame(width: 80, height: 35)
                        .foregroundStyle(createTweetViewModel.isFormValid ? .blue : Color(red: 120/255, green:170/255, blue: 240/255))
                    
                    if createTweetViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Gönderi")
                            .foregroundStyle(.white)
                            .bold()
                            .font(.system(size: 14))
                    }
                }
            })
            .disabled(!createTweetViewModel.isFormValid))
            .background(
                NavigationLink(destination: MainView(), isActive: $isPresented) {
                    EmptyView()
                }
             )
        }
        .onAppear {
            createTweetViewModel.getDataUserProfileImage()
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    CreateTweetView()
}
