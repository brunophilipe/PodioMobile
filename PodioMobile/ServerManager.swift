//
//  ServerManager.swift
//  PodioMobile
//
//  Created by Bruno Philipe on 11/7/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

import UIKit

typealias ServerCallback = ((AnyObject?, error: Bool) -> Void)
typealias NewEmptyArray = [String : AnyObject]

enum ServerOperationMethod: Int
{
	case ServerOperationGet = 1
	case ServerOperationPost = 2
}

class ServerManager: NSObject {
	private var serverDispatcher: ServerDispatcher
	private let OAuthKey = "podio-puzzle"
	private let OAuthSecret = "2u8c5SbylhvJ1uzeYMIsNS9fePA6hlkAyGtGjlWaN2r9FrThhcmwBh67EPHUpCHd"

	class var sharedManager: ServerManager {
		struct Static {
			static var instance: ServerManager?
			static var token: dispatch_once_t = 0
		}

		dispatch_once(&Static.token) {
			Static.instance = ServerManager()
		}

		return Static.instance!
	}

	override init() {
		self.serverDispatcher = ServerDispatcher()
	}

	func setAuthorization(authorization: String?)
	{
		self.serverDispatcher.authorization = authorization
	}

	func isAuthenticated() -> Bool
	{
		return self.serverDispatcher.authorization != nil
	}

	func performServerRequest(route: String, parameters: [String : AnyObject]?, method: ServerOperationMethod, completion: ServerCallback)
	{
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
			switch (method)
			{
			case .ServerOperationGet:
				if let result = self.serverDispatcher.getWithParameters(route, parameters: parameters)
				{
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						completion(result["data"], error: result["success"] as String != "OK")
					})
				}
				break

			case .ServerOperationPost:
				if let result = self.serverDispatcher.postWithParameters(route, parameters: parameters)
				{
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						completion(result["data"], error: result["success"] as String != "OK")
					})
				}
				break
			}
		})
	}

	func loginWithUsernamePassword(username: String, password: String, completion: ServerCallback)
	{
		var parameters = NewEmptyArray()
		parameters["username"] = username
		parameters["password"] = password
		parameters["grant_type"] = "password"
		parameters["client_id"] = OAuthKey
		parameters["client_secret"] = OAuthSecret

		self.performServerRequest("oauth/token", parameters: parameters, method: .ServerOperationPost, completion: completion)
	}

	func retreiveUserOrganizations(completion: ServerCallback)
	{
		self.performServerRequest("org", parameters: nil, method: .ServerOperationGet, completion: completion)
	}
}
