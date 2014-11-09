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
	var testDispatcher: ServerDispatcher!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
		self.testDispatcher = ServerDispatcher()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testServerManagerSingleton() {
        XCTAssertEqual(ServerManager.sharedManager, ServerManager.sharedManager, "Server manager singleton should return the same object address on multiple calls.")
    }

	func testServerManagerAuthorization() {
		var authorization = "x8q3fh8evgw78fg3euie2qa89hecfhe8"

		XCTAssertFalse(ServerManager.sharedManager.isAuthenticated(), "Server manager should not be initialized with an authorization string set.")
		ServerManager.sharedManager.setAuthorization(authorization)
		XCTAssertTrue(ServerManager.sharedManager.isAuthenticated(), "Authorization string should have been set.")
		ServerManager.sharedManager.setAuthorization(nil)
		XCTAssertFalse(ServerManager.sharedManager.isAuthenticated(), "Authorization string should not be set anymore.")
	}

	func testServerDispatcherURLRequestBuilder()
	{
		let testCases: [[String : AnyObject]] = [
			["url": NSURL(string: "http://www.google.com")!, "method": "GET", "data": NSNull()],
			["url": NSURL(string: "http://www.yahoo.com/news")!, "method": "POST", "data": String("This is just a random string.").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!],
			["url": NSURL(string: "https://x2048.net")!, "method": "POST", "data": NSNull()],
			["url": NSURL(string: "http://www.bbc.co.uk")!, "method": "GET", "data": String("This is another random string.").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!]]

		for testCase in testCases
		{
			var data: NSData?
			if (testCase["data"]?.isKindOfClass(NSData) != nil)
			{
				data = testCase["data"] as? NSData
			}
			let urlRequest = self.testDispatcher.buildURLRequest(testCase["url"] as NSURL!, method: testCase["method"] as String!, data: data)

			XCTAssertNotNil(urlRequest, "Test assumes all request creation attributes are valid objects.")
			XCTAssertEqual(urlRequest.URL, testCase["url"] as NSURL!, "URLs should be equal.")
			XCTAssertEqual(urlRequest.HTTPMethod!, testCase["method"] as String!, "URLs should be equal.")

			if data != nil
			{
				XCTAssertNotNil(urlRequest.HTTPBody, "HTTPBody should have been set.")
				XCTAssertEqual(urlRequest.HTTPBody!, data!, "Data should be equal.")
			}
			else
			{
				XCTAssertNil(urlRequest.HTTPBody, "HTTPBody should not have been set.")
			}
		}
	}

	func testServerDispatcherURLizer()
	{
		let testCases: [[String: AnyObject]] = [
			["username": "something", "password": "d7u3g8efge"],
			["email": "brunoph@me.com", "confirmation": "0G@07OxVCL)7gTHT$S8trg%vE!i(TXnv(a!GUwB1*)Zo3#*zOy)1rx%hm5IriRgK"],
			["user-id": "1297234", "operation": "55+37*7"],
			["template": "something \"inside\" quotes", "symbols": ")(*&^%$#"]]

		let testResults: [String] = [
			"password=d7u3g8efge&username=something",
			"email=brunoph%40me%2Ecom&confirmation=0G%4007OxVCL%297gTHT%24S8trg%25vE%21i%28TXnv%28a%21GUwB1%2A%29Zo3%23%2AzOy%291rx%25hm5IriRgK",
			"user-id=1297234&operation=55%2B37%2A7",
			"template=something%20%22inside%22%20quotes&symbols=%29%28%2A%26%5E%25%24%23"]

		for (var i=0; i<testCases.count; i++)
		{
			let urlizedParameters = self.testDispatcher.urlizeParameters(testCases[i])!
			XCTAssertEqual(urlizedParameters, testResults[i], "URLized parameters do not match correct output.")
		}
	}
}
