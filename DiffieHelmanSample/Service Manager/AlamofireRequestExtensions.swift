//
//  AlamofireRequestExtensions.swift
//  ENBDFitness
//
//  Created by Thahir Maheen on 19-10-17.
//  Copyright © 2017 Solutions 4 Mobility. All rights reserved.
//

import Alamofire
import SwiftyBeaver
import ObjectMapper

typealias Log = SwiftyBeaver

public extension Alamofire.Request {
    
    /// Prints the log for the request
    @discardableResult
    func debug() -> Self {
        Log.info(self.debugDescription)
        return self
    }
}

public extension Alamofire.DataRequest {
    
    @discardableResult
    func validateErrors() -> Self {
        return validate { [weak self] (request, response, data) -> Alamofire.Request.ValidationResult in
            
            // get status code from server
            let code = response.statusCode

            // check the request url
            let requestURL = String(describing: request?.url?.absoluteString ?? "NO URL")
            
            // check if response is empty
            guard let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any], let json = jsonData  else {
                self?.log(code: code, url: requestURL, message: "Empty response" as AnyObject, isError: false, request: request)
                return .success
            }
            
            var result: Alamofire.Request.ValidationResult = .success
            
            // check if response is html
            if (response.allHeaderFields["Content-Type"] as? String)?.contains("text/html") == true {
                self?.log(code: code, url: requestURL, message: json as AnyObject, isError: true, request: request)

                let error = NSError(domain: "html", code: -999, userInfo: ["html": data, NSLocalizedDescriptionKey: "locale.common.somethingWentWrong"])
                result = .failure(error)
            }
            else if let message = (json["error_description"] as? String ?? json["error"] as? String) {
                
                //create the error object
//                let info = [NSLocalizedDescriptionKey: message]
//                let error = NSError(domain: domain, code: code, userInfo: info)

//                let domain = json["code"] as? String ?? "error"
//                let error = EFError(code: domain, message: message)
//
//                //log error
//                self?.log(code: code, url: requestURL, message: json as AnyObject, isError: true, request: request)
//
//                //return failure
//                result = .failure(error)
                
                print("Message is \(message)")
            }
            else {
                self?.log(code: code, url: requestURL, message: json as AnyObject, isError: false, request: request)
                result = .success
            }

            return result
        }
            // validate for request errors
            .validate()
            
            // log request
            .debug()
    }
    
    
    private func log(code: Int, url: String, message: AnyObject, isError: Bool, request: URLRequest?) {
        
        if isError {
            Log.error("FAILED")
        }
        
        Log.info("Status Code >> \(code)")
        Log.info("URL >> \(url)")
        Log.info("Request >> \(request?.allHTTPHeaderFields)")
        Log.info("Response >> \(message)")
    }
}
