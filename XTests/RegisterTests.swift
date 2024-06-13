//
//  XTests.swift
//  XTests
//
//  Created by İbrahim Ay on 13.06.2024.
//

import XCTest
@testable import X
import Firebase

final class RegisterTests: XCTestCase {

    var registerViewModel = RegisterViewModel()
    
    func testRegisterFunc_Success() {
        registerViewModel.email = "test@gmail.com"
        registerViewModel.password = "test1234"
        registerViewModel.name = "test name"
        registerViewModel.username = "testname"
        
        let expectation = self.expectation(description: "Register should succeed")
        
        registerViewModel.register { success in
            XCTAssertTrue(success, "Register function should succeed")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }
    
    func testRegisterFunc_Failure() {
        registerViewModel.email = "testgmailcom"
        registerViewModel.password = "test"
        registerViewModel.name = ""
        registerViewModel.username = ""
        
        let expectation = self.expectation(description: "Register should fail")
        
        registerViewModel.register { success in
            XCTAssertFalse(success, "Register function should fail")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }

}
