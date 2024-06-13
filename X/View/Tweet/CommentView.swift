//
//  CommentView.swift
//  X
//
//  Created by İbrahim Ay on 26.05.2024.
//

import SwiftUI
import Firebase

struct CommentView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var name: String
    @State var username: String
    @State var tweet: String
    @State var profileImageUrl: String
    @State var time: Timestamp 
    @State var tweetID: String
    @State var isPresented = false
    
    @ObservedObject var commentViewModel = CommentViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    AsyncImage(url: URL(string: profileImageUrl)) { phase in
                        switch phase {
                        case .empty:
                            Image(systemName: "person")
                                .font(.system(size: 20))
                                .frame(width: 30, height: 30)
                                .cornerRadius(25)
                                .overlay(Circle().stroke(.white, lineWidth: 1))
                                .foregroundStyle(.white)
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundStyle(.white)
                                .cornerRadius(25)
                        case .failure(_):
                            Image(systemName: "person")
                                .font(.system(size: 20))
                                .frame(width: 30, height: 30)
                                .cornerRadius(25)
                                .overlay(Circle().stroke(.white, lineWidth: 1))
                                .foregroundStyle(.white)
                        @unknown default:
                            ProgressView()
                        }
                    }
                        
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(name)
                                .foregroundStyle(.white)
                                .font(.system(size: 16))
                                .fontWeight(.heavy)
                            
                            Text("@\(username)")
                                .foregroundStyle(.gray)
                                .font(.system(size: 15))
                            
                            Text(formatDate())
                                .foregroundStyle(.gray)
                                .font(.system(size: 15))
                        }
                        
                        Text(tweet)
                            .foregroundStyle(.white)
                    }
                }
                .padding(.top)
                
                HStack {
                    Text("@\(username)")
                        .foregroundStyle(.blue)
                        .font(.system(size: 13))
                    
                    Text("adlı kişiye yanıt olarak")
                        .foregroundStyle(.gray)
                        .font(.system(size: 13))
                }
                .padding(.top)
                .padding(.leading, 30)
                
                
                HStack {
                    VStack {
                        AsyncImage(url: URL(string: commentViewModel.profileImageUrl)) { phase in
                            switch phase {
                            case .empty:
                                Image(systemName: "person")
                                    .font(.system(size: 20))
                                    .frame(width: 30, height: 30)
                                    .cornerRadius(25)
                                    .overlay(Circle().stroke(.white, lineWidth: 1))
                                    .foregroundStyle(.white)
                                    .padding(.leading)
                            case .success(let image):
                                image
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.white)
                                    .cornerRadius(25)
                            case .failure(_):
                                Image(systemName: "person")
                                    .font(.system(size: 20))
                                    .frame(width: 30, height: 30)
                                    .cornerRadius(25)
                                    .overlay(Circle().stroke(.white, lineWidth: 1))
                                    .foregroundStyle(.white)
                            @unknown default:
                                ProgressView()
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                    
                    ZStack {
                        PlaceHolder()
                            .padding(.top)
                        
                        TextEditor(text: $commentViewModel.tweet)
                            .opacity(commentViewModel.tweet.isEmpty ? 0.5 : 1)
                            .padding(.top)
                    }
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
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            commentViewModel.shareComment(tweetID: tweetID) { success in
                                if success {
                                    isPresented = true
                                }
                            }
                        }, label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 50)
                                    .frame(width: 80, height: 35)
                                    .foregroundStyle(commentViewModel.isFormValid ? .blue : Color(red: 120/255, green:170/255, blue: 240/255))
                                
                                if commentViewModel.isLoading {
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
                        .disabled(!commentViewModel.isFormValid)
                    }
                }
            }
            .background(
                NavigationLink(destination: MainView(), isActive: $isPresented) {
                    EmptyView()
                }
            )
            .onAppear {
                commentViewModel.getDataCurrentUserProfileImage()
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    private struct PlaceHolder: View {
        var body: some View {
            VStack {
                HStack {
                    Text("Yanıtını gönder")
                        .foregroundStyle(Color(uiColor: .systemGray))
                        .padding(.top, 8)
                        .padding(.leading, 4)
                        
                    Spacer()
                }
                
                Spacer()
            }
        }
    }
    
    private func formatDate() -> String {
        let date = time.dateValue()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    CommentView(name: "İbrahim Ay", username: "ibrahimmayy10", tweet: "bir şeyler oluyor", profileImageUrl: "", time: Timestamp(date: Date()), tweetID: "")
}
