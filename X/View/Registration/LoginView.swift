//
//  LoginView.swift
//  X
//
//  Created by İbrahim Ay on 17.05.2024.
//

import SwiftUI
import FirebaseFirestoreInternal

struct LoginView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var loginViewModel = LoginViewModel()
    
    @State var isPresented = false
    @State var showAlert = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Başlamak için ilk önce @kullanıcıadını, e-posta adresini ve şifreni gir")
                    .fontWeight(.heavy)
                    .font(.system(size: 25))
                    .padding(.horizontal)
                
                TextField("@kullanıcıadı", text: $loginViewModel.username)
                    .foregroundStyle(.white)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .padding(.bottom, 8)
                    .overlay(Rectangle().frame(height: 1).padding(.top, 35))
                    .foregroundStyle(Color(uiColor: .darkGray))
                    .padding(.top)
                    .padding(.horizontal)
                
                TextField("E-posta", text: $loginViewModel.email)
                    .foregroundStyle(.white)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .padding(.bottom, 8)
                    .overlay(Rectangle().frame(height: 1).padding(.top, 35))
                    .foregroundStyle(Color(uiColor: .darkGray))
                    .padding(.top)
                    .padding(.horizontal)
                
                SecureField("Şifre", text: $loginViewModel.password)
                    .foregroundStyle(.white)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .padding(.bottom, 8)
                    .overlay(Rectangle().frame(height: 1).padding(.top, 35))
                    .foregroundStyle(Color(uiColor: .darkGray))
                    .padding(.top)
                    .padding(.horizontal)
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        loginViewModel.login { success in
                            if success {
                                isPresented = true
                            } else {
                                showAlert = true
                            }
                        }
                    }, label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 50)
                                .frame(width: 80, height: 40)
                                .foregroundStyle(loginViewModel.isFormValid ? .white : .gray)
                            
                            if loginViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Text("Giriş yap")
                                    .foregroundStyle(.black)
                            }
                        }
                    })
                    .padding(.trailing)
                    .disabled(!loginViewModel.isFormValid)
                }
            }
        }
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("Hata"), message: Text(loginViewModel.errorMessage), dismissButton: .default(Text("Tamam")))
        })
        .background(
            NavigationLink(destination: TabBarController(), isActive: $isPresented) {
                EmptyView()
            }
        )
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
    }
}

#Preview {
    LoginView()
}
