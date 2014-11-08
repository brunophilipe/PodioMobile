//
//  PodioMobileTests.swift
//  PodioMobileTests
//
//  Created by Bruno Philipe on 11/7/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

import UIKit
import XCTest

class PodioMobileTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testServerManagerSingleton() {
        XCTAssertEqual(ServerManager.sharedManager, ServerManager.sharedManager, "Server manager singleton should return the same object address on every call.")
    }

	func testServerManagerAuthorization() {
		var authorization = "x8q3fh8evgw78fg3euie2qa89hecfhe8"

		XCTAssertFalse(ServerManager.sharedManager.isAuthenticated(), "Server manager should not be initialized with an authorization string set.")
		ServerManager.sharedManager.setAuthorization(authorization)
		XCTAssertTrue(ServerManager.sharedManager.isAuthenticated(), "Authorization string should have been set.")
		ServerManager.sharedManager.setAuthorization(nil)
		XCTAssertFalse(ServerManager.sharedManager.isAuthenticated(), "Authorization string should not be set anymore.")
	}
}
