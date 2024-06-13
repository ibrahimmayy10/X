//
//  XApp.swift
//  X
//
//  Created by İbrahim Ay on 15.05.2024.
//

import SwiftUI
import FirebaseCore

@main
struct XApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
    }
}
