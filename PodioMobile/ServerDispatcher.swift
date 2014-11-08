//
//  ServerDispatcher.swift
//  PodioMobile
//
//  Created by Bruno Philipe on 11/7/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

import UIKit

class ServerDispatcher: NSObject {
	private let serviceEndpoint = "https://api.podio.com/"

	var authorization: String?

	func getWithParameters(route: String, parameters: [String : AnyObject]?) -> [String : AnyObject]?
	{
		var requestPath = serviceEndpoint.stringByAppendingString(route)

		if let urlizedParams = self.urlizeParameters(parameters)
		{
			requestPath = requestPath.stringByAppendingFormat("?%@", urlizedParams)
		}

		return self.executeServerRequest(NSURL(string: requestPath)!, method: "GET", data: nil)
	}

	func postWithParameters(route: String, parameters: [String : AnyObject]?) -> [String : AnyObject]?
	{
		var requestPath = serviceEndpoint.stringByAppendingString(route)

		if let urlizedParams = self.urlizeParameters(parameters)
		{
			let data = urlizedParams.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
			return self.executeServerRequest(NSURL(string: requestPath)!, method: "POST", data: data)
		}

		return nil
	}

	func executeServerRequest(url: NSURL, method: String, data: NSData?) -> [String : AnyObject]
	{
		var request = NSMutableURLRequest(URL: url)

		if self.authorization != nil
		{
			request.setValue("OAuth2 ".stringByAppendingString(authorization!), forHTTPHeaderField: "Authorization")
		}

		request.HTTPMethod = method
		request.HTTPBody = data

		var requestResponse: NSURLResponse?
		var error: NSError?
		if let responseData = NSURLConnection.sendSynchronousRequest(request, returningResponse: &requestResponse, error: &error)
		{
			var responseCode = 0
			if (requestResponse?.isKindOfClass(NSHTTPURLResponse) != nil)
			{
				responseCode = (requestResponse as NSHTTPURLResponse).statusCode
			}

			if (responseCode != 200)
			{
				var result = [String : AnyObject]()
				result["success"] = "ERROR"
				result["status"] = NSNumber(integer: responseCode)
				result["data"] = responseData
				return result;
			} else {
				var result = [String : AnyObject]()
				result["success"] = "OK"
				result["status"] = NSNumber(integer: responseCode)

				if let decodedJSON: AnyObject = NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions(0), error: &error)
				{
					result["data"] = decodedJSON
				}

				return result;
			}
		}

		return ["success": "ERROR", "status": "-1"]
	}

	func urlizeParameters(parameters: [String : AnyObject]?) -> String?
	{
		var result = ""

		if (parameters != nil && parameters!.count > 0)
		{
			for (key, value) in parameters!
			{
				if result != ""
				{
					result = result.stringByAppendingString("&")
				}

				if let typedValue = value as? String
				{
					result = result.stringByAppendingFormat("%@=%@", key, typedValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!)
				}
				else if let typedValue = value as? NSData
				{
					let output = typedValue.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0))
					result = result.stringByAppendingFormat("%@=%@", key, output)
				}
			}

			return result
		}

		return nil
	}
}
