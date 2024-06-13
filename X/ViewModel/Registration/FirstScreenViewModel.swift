//
//  RegisterViewModel.swift
//  X
//
//  Created by İbrahim Ay on 15.05.2024.
//

import Foundation
import UIKit

class FirstScreenViewModel: ObservableObject {
    func openURL(_ url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url)
        }
    }
}
