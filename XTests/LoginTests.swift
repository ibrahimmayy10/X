//
//  LoginTests.swift
//  XTests
//
//  Created by İbrahim Ay on 13.06.2024.
//

import XCTest
@testable import X

final class LoginTests: XCTestCase {

    let loginViewModel = LoginViewModel()
    
    func testLoginFunc_Success() {
        loginViewModel.email = "test@gmail.com"
        loginViewModel.password = "test1234"
        loginViewModel.username = "testname"
        
        let expectation = self.expectation(description: "Login should succeed")
        
        loginViewModel.login { success in
            XCTAssertTrue(success, "Login function should succeed")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }
    
    func testLoginFunc_Fail() {
        loginViewModel.email = "testgmailcom"
        loginViewModel.password = "test"
        loginViewModel.username = ""
        
        let expectation = self.expectation(description: "Login should fail")
        
        loginViewModel.login { success in
            XCTAssertFalse(success, "Login function should fail")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }

}
