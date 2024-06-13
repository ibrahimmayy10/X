//
//  AddNewUserView.swift
//  X
//
//  Created by İbrahim Ay on 5.06.2024.
//

import SwiftUI

struct AddNewUserView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var followingViewModel = FollowViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 30) {
                        ForEach(followingViewModel.followingList, id: \.id) { user in
                            NavigationLink(destination: MessageView(user: user)) {
                                UserCard(user: user)
                            }
                        }
                    }
                }
                .padding(.top)
            }
            .onAppear {
                followingViewModel.getDataFollowing()
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
                    Text("Yeni mesaj")
                        .foregroundStyle(.white)
                        .fontWeight(.heavy)
                        .font(.system(size: 18))
                }
            }
        }
    }
}

#Preview {
    AddNewUserView()
}
