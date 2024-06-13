//
//  SearchView.swift
//  X
//
//  Created by İbrahim Ay on 19.05.2024.
//

import SwiftUI
import Firebase

struct SearchView: View {
    
    @ObservedObject var searchViewModel = SearchViewModel()
    @ObservedObject var userProfileViewModel = UserProfileViewModel()
    
    @State var isPresented = false
    @State var isSearching = false
    @State var showDrawer = false
    @State private var dragOffset = CGSize.zero
    
    @State var searchList = ["Sana özel", "Gündemdekiler", "Haberler", "Spor", "Eğlence"]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .leading) {
                VStack {
                    if !isSearching {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHGrid(rows: [GridItem(.flexible())], spacing: 30) {
                                ForEach(searchList, id: \.self) { text in
                                    Text(text)
                                }
                            }
                        }
                        .frame(height: 30)
                        
                        HStack {
                            Text("İlgini çekebilecek gündemler")
                                .fontWeight(.heavy)
                                .font(.system(size: 20))
                                .padding(.leading)
                            
                            Spacer()
                        }
                        .padding(.top)
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                self.isPresented.toggle()
                            }, label: {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                            })
                            .padding(.trailing)
                            .padding(.bottom)
                        }
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible())], spacing: 30) {
                                ForEach(searchViewModel.searchResult, id: \.id) { user in
                                    NavigationLink(destination: NewUserProfileView(user: user)) {
                                        UserCard(user: user)
                                    }
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    userProfileViewModel.getDataUserProfileImage()
                }
                .task {
                    searchViewModel.searchInFirestore()
                }
                .fullScreenCover(isPresented: $isPresented, content: {
                    CreateTweetView()
                })
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showDrawer.toggle()
                        }, label: {
                            if userProfileViewModel.profileImageUrl.isEmpty {
                                Image(systemName: "person")
                                    .font(.system(size: 18))
                                    .frame(width: 35, height: 35)
                                    .cornerRadius(25)
                                    .overlay(Circle().stroke(.white, lineWidth: 1))
                                    .foregroundStyle(.white)
                            } else {
                                AsyncImage(url: URL(string: userProfileViewModel.profileImageUrl)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .cornerRadius(25)
                                            .frame(width: 35, height: 35)
                                            .foregroundStyle(.white)
                                    case .failure(_):
                                        Image(systemName: "person")
                                            .font(.system(size: 18))
                                            .frame(width: 35, height: 35)
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
                    
                    ToolbarItem(placement: .principal) {
                        TextField("Ara", text: $searchViewModel.searchText, onEditingChanged: { isEditing in
                            withAnimation {
                                self.isSearching = isEditing
                            }
                        })
                        .padding(.leading)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(.gray, lineWidth: 1)
                                .frame(height: 40)
                        )
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gear")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .foregroundStyle(.white)
                        }
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged({ value in
                            if value.translation.width > 0 {
                                self.dragOffset = value.translation
                            }
                        })
                        .onEnded({ value in
                            if value.translation.width > 100 {
                                withAnimation {
                                    self.showDrawer = true
                                }
                            }
                            self.dragOffset = .zero
                        })
                )
                .onTapGesture {
                    hideKeyboard()
                }
                
                if showDrawer {
                    OptionsView()
                        .frame(width: 250)
                        .transition(.move(edge: .leading))
                        .zIndex(1)
                        .gesture(
                            DragGesture()
                                .onChanged({ value in
                                    if value.translation.width < 0 {
                                        self.dragOffset = value.translation
                                    }
                                })
                                .onEnded({ value in
                                    if value.translation.width < -100 {
                                        withAnimation {
                                            self.showDrawer = false
                                        }
                                    }
                                    self.dragOffset = .zero
                                })
                        )
                }
            }
            .offset(x: dragOffset.width)
        }
        .navigationBarBackButtonHidden()
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    SearchView()
}
