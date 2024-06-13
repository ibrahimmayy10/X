//
//  TabBarController.swift
//  X
//
//  Created by İbrahim Ay on 7.06.2024.
//

import SwiftUI

struct TabBarController: View {
    
    var body: some View {
        NavigationView {
            TabView {
                MainView()
                    .tabItem {
                        Label("", systemImage: "house")
                    }
                
                SearchView()
                    .tabItem {
                        Label("", systemImage: "magnifyingglass")
                    }
                
                NotificationView()
                    .tabItem {
                        Label("", systemImage: "bell")
                    }
                
                MessagedUsersView()
                    .tabItem {
                        Label("", systemImage: "message")
                    }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    TabBarController()
}
