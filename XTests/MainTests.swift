//
//  MainTests.swift
//  XTests
//
//  Created by İbrahim Ay on 13.06.2024.
//

import XCTest
@testable import X
import Firebase

final class MainTests: XCTestCase {
    
    let mainViewModel = MainViewModel()
    
    func testGetDataFollowingTweet() {
        let expectation = XCTestExpectation(description: "Fetch tweets based on following list")
        
        guard let currentUserID = mainViewModel.currentUserID else { return }
        
        let userRef = mainViewModel.firestore.collection("Users").document(currentUserID)
        
        userRef.setData(["following": ["6lnofvq5zMRh0LDw5oIQu2cRy8d2", "WMKCMCT0SHTKmtsQ46jf6QRAlmg2"]]) { error in
            if let error = error {
                XCTFail("Error setting document: \(error.localizedDescription)")
                return
            }
            
            self.mainViewModel.getDataFollowingTweet()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                XCTAssertFalse(self.mainViewModel.tweets.isEmpty, "Expected tweets to be fetched")
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
}
