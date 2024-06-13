//
//  RegisterViewModel.swift
//  X
//
//  Created by İbrahim Ay on 15.05.2024.
//

import SwiftUI
import FirebaseFirestoreInternal

struct RegisterView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var registerViewModel = RegisterViewModel()
    
    @State var isPresented = false
    @State var showAlert = false
    
    var body: some View {
        NavigationStack {
            VStack {
                
                
                HStack {
                    Text("Hesabını oluştur")
                        .fontWeight(.heavy)
                        .font(.system(size: 25))
                        .padding(.leading)
                    
                    Spacer()
                }
                
                TextField("İsim", text: $registerViewModel.name)
                    .foregroundStyle(.white)
                    .padding(.bottom, 8)
                    .overlay(Rectangle().frame(height: 1).padding(.top, 35))
                    .foregroundStyle(Color(uiColor: .darkGray))
                    .padding(.horizontal)
                
                TextField("@kullanıcıadı", text: $registerViewModel.username)
                    .foregroundStyle(.white)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .padding(.bottom, 8)
                    .overlay(Rectangle().frame(height: 1).padding(.top, 35))
                    .foregroundStyle(Color(uiColor: .darkGray))
                    .padding(.horizontal)
                    .padding(.top)
                
                TextField("E-posta", text: $registerViewModel.email)
                    .foregroundStyle(.white)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .padding(.top)
                    .padding(.bottom, 23)
                    .overlay(Rectangle().frame(height: 1).padding(.top, 35))
                    .foregroundStyle(Color(uiColor: .darkGray))
                    .padding(.horizontal)
                
                SecureField("Şifre", text: $registerViewModel.password)
                    .foregroundStyle(.white)
                    .padding(.bottom, 8)
                    .overlay(Rectangle().frame(height: 1).padding(.top, 35))
                    .foregroundStyle(Color(uiColor: .darkGray))
                    .padding(.horizontal)
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        registerViewModel.register { success in
                            if success {
                                isPresented = true
                            } else {
                                showAlert = true
                            }
                        }
                    }, label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 50)
                                .frame(width: 70, height: 40)
                                .foregroundStyle(registerViewModel.isFormValid ? .white : .gray)
                            
                            if registerViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Text("Kayıt ol")
                                    .foregroundStyle(.black)
                            }
                        }
                    })
                    .padding(.trailing)
                    .disabled(!registerViewModel.isFormValid)
                }
            }
        }
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("Hata"), message: Text(registerViewModel.errorMessage), dismissButton: .default(Text("Tamam")))
        })
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("İptal et")
                .foregroundStyle(.white)
        }))
        .toolbar {
            ToolbarItem(placement: .principal) {
                    Image("x")
                        .resizable()
                        .frame(width: 110, height: 110)
                        .padding(.top, 5)
            }
        }
        .toolbarBackground(Color(red: 0.07, green: 0.07, blue: 0.07), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .background(
            NavigationLink(destination: TabBarController(), isActive: $isPresented) {
                EmptyView()
            }
        )
    }
}

#Preview {
    RegisterView()
}
