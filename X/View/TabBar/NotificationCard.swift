//
//  NotificationCard.swift
//  X
//
//  Created by İbrahim Ay on 10.06.2024.
//

import SwiftUI
import Firebase

struct NotificationCard: View {
    
    @State var notification: NotificationModel
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "star.fill")
                .font(.system(size: 30))
                .foregroundStyle(.purple)
            
            VStack(alignment: .leading) {
                if notification.profileImageUrl.isEmpty {
                    Image(systemName: "person")
                        .font(.system(size: 25))
                        .frame(width: 40, height: 40)
                        .cornerRadius(25)
                        .overlay(Circle().stroke(.white, lineWidth: 1))
                        .foregroundStyle(.white)
                } else {
                    AsyncImage(url: URL(string: notification.profileImageUrl)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(.white)
                                .cornerRadius(25)
                        case .failure(_):
                            Image(systemName: "person")
                                .font(.system(size: 25))
                                .frame(width: 40, height: 40)
                                .cornerRadius(25)
                                .overlay(Circle().stroke(.white, lineWidth: 1))
                                .foregroundStyle(.white)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                HStack {
                    Text(notification.name)
                        .foregroundStyle(.white)
                        .fontWeight(.heavy)
                    
                    Text("gönderini beğendi")
                        .foregroundStyle(.gray)
                }
            }
            
            Spacer()
        }
        .padding(.leading)
    }
}

#Preview {
    NotificationCard(notification: NotificationModel(senderID: "", recipientID: "", time: Timestamp(), name: "İbrahim Ay", profileImageUrl: ""))
}
