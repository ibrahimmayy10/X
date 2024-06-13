//
//  SettingsView.swift
//  X
//
//  Created by İbrahim Ay on 11.06.2024.
//

import SwiftUI
import Firebase

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel = UserProfileViewModel()
    
    @State var isPresented = false
    
    var body: some View {
        VStack {
            NavigationLink(destination: EditProfileView()) {
                HStack {
                    Text("Kullanıcı adı")
                        .foregroundStyle(.white)
                        .fontWeight(.heavy)
                    
                    Spacer()
                    
                    Text("@\(viewModel.username)  >")
                        .foregroundStyle(.gray)
                }
            }
            
            HStack {
                Text("E-posta")
                    .foregroundStyle(.white)
                    .fontWeight(.heavy)
                
                Spacer()
                
                Text(Auth.auth().currentUser?.email ?? "")
                    .foregroundStyle(.white)
            }
            .padding(.top)
            
            Button(action: {
                viewModel.signOut { success in
                    if success {
                        if let window = UIApplication.shared.windows.first {
                            window.rootViewController = UIHostingController(rootView: FirstScreenView())
                            window.makeKeyAndVisible()
                        }
                    }
                }
            }, label: {
                Text("Çıkış yap")
                    .foregroundStyle(.red)
            })
            .padding(.top)
            
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "arrow.backward")
                        .foregroundStyle(.white)
                })
            }
            
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Hesap")
                        .foregroundStyle(.white)
                        .fontWeight(.heavy)
                    
                    Text("@\(viewModel.username)")
                }
            }
        }
        .onAppear {
            viewModel.getDataUsername()
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    SettingsView()
}
