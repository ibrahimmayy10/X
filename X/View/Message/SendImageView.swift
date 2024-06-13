//
//  SendImageView.swift
//  X
//
//  Created by İbrahim Ay on 7.06.2024.
//

import SwiftUI
import Firebase

struct SendImageView: View {
    
    @State private var image: UIImage? = nil
    @State var isShowingProfileImagePicker = false
    @State var user: UserModel
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var messageViewModel = MessageViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                if image != nil {
                    Image(uiImage: image!)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.top)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        if let selectedImage = image {
                            messageViewModel.sendImage(recipientUserID: user.id, image: selectedImage) { success in
                                if success {
                                    presentationMode.wrappedValue.dismiss()
                                    messageViewModel.loadMessage(recipientUserID: user.id)
                                }
                            }
                        }
                    }, label: {
                        Image(systemName: "paperplane.circle.fill")
                            .foregroundStyle(image == nil ? Color(red: 120/255, green:170/255, blue: 240/255) : .blue)
                            .font(.system(size: 35))
                    })
                    .disabled(image == nil)
                    .padding(.trailing)
                    .padding(.bottom)
                }
            }
            .sheet(isPresented: $isShowingProfileImagePicker) {
                ImagePicker(selectedImage: $image, isPresented: $isShowingProfileImagePicker)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.white)
                    })
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Fotoğraf seç")
                        .foregroundStyle(.white)
                        .fontWeight(.heavy)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingProfileImagePicker = true
                    }, label: {
                        Image(systemName: "photo")
                            .foregroundStyle(.blue)
                            .font(.system(size: 25))
                    })
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    SendImageView(user: UserModel(userID: "", name: "", username: "", imageUrl: "", profileImageUrl: "", bio: "", birthday: Timestamp()))
}
