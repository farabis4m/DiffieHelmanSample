//
//  ServiceManager.swift
//  RTADubai
//
//  Created by Thahir Maheen on 7/25/18.
//  Copyright © 2018 s4m. All rights reserved.
//

import Alamofire
import RealmSwift

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
            urlRequest.allHTTPHeaderFields?.merge(Alamofire.SessionManager.defaultHTTPHeaders) { (current, _) in current }
            
            // customize
            
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
