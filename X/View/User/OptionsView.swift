//
//  OptionsView.swift
//  X
//
//  Created by İbrahim Ay on 19.05.2024.
//

import SwiftUI

struct OptionsView: View {
    
    @ObservedObject var viewModel = UserProfileViewModel()
    @ObservedObject var optionsViewModel = OptionsViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink(destination: UserProfileView()) {
                VStack(alignment: .leading) {
                    Text(viewModel.name)
                        .foregroundStyle(.white)
                        .bold()
                    
                    Text("@\(viewModel.username)")
                        .font(.system(size: 16))
                        .foregroundStyle(.gray)
                }
            }
            
            HStack {
                NavigationLink(destination: FollowingView(name: viewModel.name, userID: "")) {
                    Text(String(viewModel.followingCount))
                        .font(.system(size: 13))
                        .bold()
                        .foregroundStyle(.white)
                    
                    Text("Takip edilen")
                        .font(.system(size: 13))
                        .bold()
                        .foregroundStyle(.gray)
                }
                
                NavigationLink(destination: FollowingView(name: viewModel.name, userID: "")) {
                    Text(String(viewModel.followerCount))
                        .font(.system(size: 13))
                        .bold()
                        .foregroundStyle(.white)
                    
                    Text("Takipçi")
                        .font(.system(size: 13))
                        .bold()
                        .foregroundStyle(.gray)
                }
            }
            .padding(.top)
            
            NavigationLink(destination: UserProfileView()) {
                HStack {
                    Image(systemName: "person")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.white)
                    
                    Text("Profil")
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                        .fontWeight(.heavy)
                        .padding(.leading)
                }
            }
            .padding(.top)
            
            NavigationLink(destination: SettingsView(), label: {
                HStack {
                    Image(systemName: "gear")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.white)
                    
                    Text("Ayarlar ve Gizlilik")
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                        .fontWeight(.heavy)
                        .padding(.leading)
                }
            })
            .padding(.top)
            
            Button(action: {
                optionsViewModel.openUrl("https://help.twitter.com/tr/rules-and-policies/update-privacy-policy")
            }, label: {
                HStack {
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.white)
                    
                    Text("Yardım Merkezi")
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                        .fontWeight(.heavy)
                        .padding(.leading)
                }
            })
            .padding(.top)
            
            Spacer()
        }
        .padding(.top, 50)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(.black)
        .shadow(radius: 5)
        .onAppear {
            viewModel.getDataUsername()
            viewModel.getDataFollowerCount()
            viewModel.getDataFollowingCount()
            viewModel.getDataUserProfileImage()
        }
    }
}

#Preview {
    OptionsView()
}
