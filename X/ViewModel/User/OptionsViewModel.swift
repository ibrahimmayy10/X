//
//  OptionsViewModel.swift
//  X
//
//  Created by İbrahim Ay on 19.05.2024.
//

import Foundation
import Firebase
import UIKit

class OptionsViewModel: ObservableObject {
    @Published var name = String()
    @Published var username = String()
    
    func openUrl(_ url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url)
        }
    }
}
