//
//  SplashScreenView.swift
//  X
//
//  Created by İbrahim Ay on 13.06.2024.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        VStack(alignment: .center) {
            Image("x")
                .resizable()
                .frame(width: 200, height: 200)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: FirstScreenView())
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
