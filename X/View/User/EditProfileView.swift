//
//  EditProfileView.swift
//  X
//
//  Created by İbrahim Ay on 23.05.2024.
//

import SwiftUI
import Firebase

struct EditProfileView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var image: UIImage? = nil
    @State private var profileImage: UIImage? = nil
    @State private var isShowingImagePicker = false
    @State private var isShowingProfileImagePicker = false
    @State private var isShowingImageLoading = false
    @State private var isShowingProfileImageLoading = false
    @State var isPresented = false
    @State var showAlert = false
    
    @ObservedObject var viewModel = EditProfileViewModel()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                ZStack(alignment: .bottomLeading) {
                    if image != nil {
                        Image(uiImage: image!)
                            .resizable()
                            .frame(height: 130)
                    } else {
                        Button(action: {
                            isShowingImagePicker = true
                        }, label: {
                            if viewModel.imageUrl.isEmpty {
                                RoundedRectangle(cornerRadius: 0)
                                    .foregroundStyle(.blue)
                                    .frame(height: 130)
                            } else {
                                AsyncImage(url: URL(string: viewModel.imageUrl)) { phase in
                                    switch phase {
                                        case .empty:
                                            ProgressView()
                                                .offset(x: 0, y: 25)
                                                .padding(.leading)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .frame(height: 130)
                                        case .failure(_):
                                            RoundedRectangle(cornerRadius: 0)
                                                .foregroundStyle(.blue)
                                                .frame(height: 130)
                                        @unknown default:
                                            EmptyView()
                                    }
                                }
                            }
                        })
                    }
                    
                    if profileImage != nil {
                        Image(uiImage: profileImage!)
                            .font(.system(size: 35))
                            .frame(width: 50, height: 50)
                            .cornerRadius(25)
                            .overlay(Circle().stroke(.white, lineWidth: 1))
                            .foregroundStyle(.white)
                            .offset(x: 0, y: 25)
                            .padding(.leading)
                    } else {
                        Button(action: {
                            isShowingProfileImagePicker = true
                        }, label: {
                            if viewModel.profileImageUrl.isEmpty {
                                Image(systemName: "person")
                                    .font(.system(size: 35))
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(25)
                                    .overlay(Circle().stroke(.white, lineWidth: 1))
                                    .foregroundStyle(.white)
                                    .offset(x: 0, y: 25)
                                    .padding(.leading)
                            } else {
                                AsyncImage(url: URL(string: viewModel.profileImageUrl)) { phase in
                                    switch phase {
                                    case .empty:
                                        HStack {
                                            Spacer()
                                            
                                            ProgressView()
                                                .frame(height: 130)
                                            
                                            Spacer()
                                        }
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .foregroundStyle(.white)
                                            .cornerRadius(25)
                                            .offset(x: 0, y: 25)
                                            .padding(.leading)
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
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("İsim")
                            .foregroundStyle(.white)
                            .bold()
                        
                        Text("@kullaniciadi")
                            .foregroundStyle(.white)
                            .bold()
                            .padding(.top)
                        
                        Text("Kişisel bilgiler")
                            .foregroundStyle(.white)
                            .bold()
                            .padding(.top)
                        
                        Text("Doğum tarihi")
                            .foregroundStyle(.white)
                            .bold()
                            .padding(.top)
                    }
                    
                    VStack(alignment: .leading) {
                        TextField(text: $viewModel.name) {
                            Text(viewModel.name)
                                .foregroundStyle(.blue)
                        }
                        .foregroundStyle(.blue)
                        .padding(.leading, 40)
                        
                        TextField(text: $viewModel.username) {
                            Text(viewModel.username)
                                .foregroundStyle(.blue)
                        }
                        .foregroundStyle(.blue)
                        .padding(.top)
                        .padding(.leading, 40)

                        TextField(text: $viewModel.bio) {
                            Text(viewModel.bio)
                                .foregroundStyle(.blue)
                        }
                        .padding(.top)
                        .padding(.leading, 40)
                        
                        HStack {
                            Text(formatDate(viewModel.getBirthday ?? Timestamp()))
                                .foregroundStyle(.blue)
                                .padding(.top)
                                .padding(.leading, 40)
                            
                            DatePicker("", selection: $viewModel.birthday, displayedComponents: .date)
                                .padding(.top)
                        }
                    }
                }
                .padding(.top, 40)
                
                Spacer()
            }
            .onAppear {
                viewModel.getDataUserInfo()
                viewModel.getDataUserImage()
                viewModel.getDataUserProfileImage()
                viewModel.getDataUserBio()
                viewModel.getDataUserBirthday()
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(selectedImage: self.$image, isPresented: self.$isShowingImagePicker)
            }
            .sheet(isPresented: $isShowingProfileImagePicker) {
                ImagePicker(selectedImage: self.$profileImage, isPresented: self.$isShowingProfileImagePicker)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("İptal et")
                            .foregroundStyle(.white)
                    })
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Profili düzenle")
                        .foregroundStyle(.white)
                        .fontWeight(.heavy)
                        .font(.system(size: 19))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.updateUserInfo { success in
                            if success {
                                showAlert = true
                            }
                        }
                        if let selectedImage = image {
                            viewModel.addImage(image: selectedImage) { success in
                                if success {
                                    showAlert = true
                                }
                            }
                        } else if let selectedProfileImage = profileImage {
                            viewModel.addProfileImage(image: selectedProfileImage) { success in
                                if success {
                                    showAlert = true
                                }
                            }
                        }
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Kaydet")
                            .fontWeight(.heavy)
                            .foregroundStyle(.white)
                            .font(.system(size: 19))
                    })
                }
            }
            .alert(isPresented: $showAlert, content: {
                Alert(title: Text("Bilgileriniz güncellendi"), dismissButton: .default(Text("Tamam")))
            })
        }
        .navigationBarBackButtonHidden()
    }
    
    private func formatDate(_ birthday: Timestamp) -> String {
        let date = birthday.dateValue()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    EditProfileView()
}
