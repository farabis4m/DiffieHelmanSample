//
//  ServiceManager.swift
//  RTADubai
//
//  Created by Thahir Maheen on 7/25/18.
//  Copyright © 2018 s4m. All rights reserved.
//

import Alamofire

class ServiceManager {
    
    static let shared = ServiceManager()
    
    var manager: Alamofire.SessionManager
    
    private init() {
        
        // manager
        manager = Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
        
        manager.adapter = ServiceAdapter()
    }
    
    func request(_ urlRequest: URLRequestConvertible) -> DataRequest {
        return manager.request(urlRequest)
    }
    
    func upload(_ multipartFormData: @escaping (MultipartFormData) -> Void, urlRequest: URLRequestConvertible, encodingCompletion: ((SessionManager.MultipartFormDataEncodingResult) -> Void)?) {
        manager.upload(multipartFormData: multipartFormData, with: urlRequest, encodingCompletion: encodingCompletion)
    }
    
    func download(_ urlRequest: URLRequestConvertible, to destination: DownloadRequest.DownloadFileDestination? = nil) -> DownloadRequest {
        return manager.download(urlRequest, to: destination)
    }
}

extension ServiceManager {
    class ServiceAdapter: RequestAdapter {
        
        func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
            var urlRequest = urlRequest
            
            
            // update default http headers
            var defaultHTTPHeaders = Alamofire.SessionManager.defaultHTTPHeaders
            defaultHTTPHeaders.updateValue("application/json", forKey: "Content-Type")

            urlRequest.allHTTPHeaderFields?.merge(defaultHTTPHeaders) { (current, _) in current }
            
            // customize
            /*
             let configuration = URLSessionConfiguration.default
             var allHeaders = Alamofire.SessionManager.default.session.configuration.httpAdditionalHeaders ?? [:]
             allHeaders.updateValue(["application/json","text/plain"], forKey: "Accept")
             allHeaders.updateValue("application/json", forKey: "Content-Type")
             
             if Environment.Configuration.current.mockEnabled {
             allHeaders.updateValue("true", forKey: "mock")
             }
             
             configuration.httpAdditionalHeaders = allHeaders
 */
            return urlRequest
        }
    }
}

extension ServiceManager {
    struct API {
        static var baseUrl: URL {
            return Configuration.current.baseURL
        }
    }
}

class Configuration {
    
    // the current singleton configuration
    static let current = Configuration()
    
    
    // the base url
    var baseURL: URL {
        let stringURL = "http://10.10.100.178:8090"
        return URL(string: stringURL) ?? URL(fileURLWithPath: "")
    }
    
}
