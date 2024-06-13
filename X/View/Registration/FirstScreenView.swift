//
//  ContentView.swift
//  X
//
//  Created by İbrahim Ay on 15.05.2024.
//

import SwiftUI
import Firebase

struct FirstScreenView: View {
    
    @ObservedObject var firstScreenViewModel = FirstScreenViewModel()
    
    @State var isSignedIn = false
        
    var body: some View {
        Group {
            if isSignedIn {
                TabBarController()
            } else {
                NavigationView {
                    VStack {
                        HStack {
                            Spacer()
                            Image("x")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .padding(.top, 50)
                            Spacer()
                        }
                        .background(Color.black.brightness(0.07))
                        .edgesIgnoringSafeArea(.top)
                        
                        Spacer()
                        
                        Text("Şu anda dünyada olup bitenleri gör.")
                            .font(.system(size: 25))
                            .fontWeight(.heavy)
                            
                        Spacer()
                        
                        NavigationLink(destination: RegisterView()) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 50)
                                    .frame(width: 340, height: 35)
                                    .foregroundStyle(.white)
                                
                                Text("Hesap Oluştur")
                                    .foregroundStyle(.black)
                                    .bold()
                            }
                        }
                            
                        Button(action: {
                            firstScreenViewModel.openURL("https://help.twitter.com/tr/rules-and-policies/update-privacy-policy")
                        }, label: {
                            Text("Kaydolarak Hizmet Şartlarımızı, Gizlilik Politikamızı ve Çerez Kullanım Politikamızı kabul etmiş olursun")
                                .font(.system(size: 14))
                                .padding(.horizontal)
                                .padding(.top, 30)
                        })
                            
                        HStack {
                            Text("Zaten bir hesabın var mı?")
                                .foregroundStyle(Color(uiColor: .systemGray))
                                .font(.system(size: 16))

                            NavigationLink(destination: LoginView()) {
                                Text("Giriş yap")
                            }
                        }
                        .padding(.top)
                    }
                }
                .navigationBarBackButtonHidden()
                .onAppear {
                    autoSignIn()
                }
            }
        }
    }
    
    private func autoSignIn() {
        if Auth.auth().currentUser != nil {
            isSignedIn = true
        } else {
            isSignedIn = false
        }
    }
}

#Preview {
    FirstScreenView()
}
