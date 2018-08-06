//
//  Requestable.swift
//  RTADubai
//
//  Created by Thahir Maheen on 7/25/18.
//  Copyright © 2018 s4m. All rights reserved.
//

import Alamofire
import ObjectMapper
import AlamofireObjectMapper

protocol Requestable: URLRequestConvertible {
    var method: HTTPMethod { get }
    var module: ApiModule? { get }
    var path: ApiPath? { get }
    var defaultParameters: Parameters? { get }
    var parameters: Parameters? { get }
    var downloadFileDestination: DownloadRequest.DownloadFileDestination? { get }
    var timeoutIntervalForRequest: TimeInterval { get }
    
    @discardableResult
    func request(with responseObject: @escaping (DefaultDataResponse) -> Void) -> DataRequest
    
    @discardableResult
    func request<T: BaseMappable>(with responseObject: @escaping (DataResponse<T>) -> Void) -> DataRequest
    
    @discardableResult
    func request<T: BaseMappable>(with responseArray: @escaping (DataResponse<[T]>) -> Void) -> DataRequest
    
    @discardableResult
    func download(from url: URL, with responseObject: @escaping (DefaultDownloadResponse) -> Void) -> DownloadRequest
    
    func upload(with responseObject: @escaping (SessionManager.MultipartFormDataEncodingResult) -> Void)
}

extension Requestable {
    
    // default HTTP Method is get
    var method: HTTPMethod {
        return .get
    }
    
    // just to add nil as default path
    var path: ApiPath? {
        return nil
    }
    
    // default parameters
    var defaultParameters: Parameters? {
        return nil
    }
    
    // just to add nil as default parameter
    var parameters: Parameters? {
        return nil
    }
    
    // no default download file destination
    var downloadFileDestination: DownloadRequest.DownloadFileDestination? {
        return nil
    }
    
    // default timeoutIntervalForRequest
    var timeoutIntervalForRequest: TimeInterval {
        return 60.0
    }
    
    var url: URL {
        var url = ServiceManager.API.baseUrl
        
        if let module = module, !module.name.isEmpty {
            url = url.appendingPathComponent(module.name)
        }
        
        if let path = path, !path.name.isEmpty {
            url = url.appendingPathComponent(path.name)
        }
        
        return url
    }
    
    func asURLRequest() throws -> URLRequest {
        
        // update timeoutIntervalForRequest from router
        ServiceManager.shared.manager.session.configuration.timeoutIntervalForRequest = timeoutIntervalForRequest
        
        var requestParams = parameters
        if let defaultParameters = defaultParameters {
            requestParams = defaultParameters.merging(parameters ?? [:]) { _, custom in custom }
        }
        
        let urlRequest = try URLRequest(url: url, method: method)
        return try Alamofire.URLEncoding.default.encode(urlRequest, with: requestParams)
    }
    
    @discardableResult
    func request(with responseObject: @escaping (DefaultDataResponse) -> Void) -> DataRequest {
        return ServiceManager.shared.request(self).response(completionHandler: responseObject)//.validateErrors()
    }
    
    @discardableResult
    func request<T: BaseMappable>(with responseObject: @escaping (DataResponse<T>) -> Void) -> DataRequest {
        return ServiceManager.shared.request(self).responseObject(completionHandler: responseObject)//.validateErrors()
    }
    
    @discardableResult
    func request<T: BaseMappable>(with responseArray: @escaping (DataResponse<[T]>) -> Void) -> DataRequest {
        return ServiceManager.shared.request(self).responseArray(completionHandler: responseArray)//.validateErrors()
    }
    
    @discardableResult
    func download(from url: URL, with responseObject: @escaping (DefaultDownloadResponse) -> Void) -> DownloadRequest {
        return ServiceManager.shared.manager.download(url, to: downloadFileDestination).response(completionHandler: responseObject)
    }
    
    func upload(with responseObject: @escaping (SessionManager.MultipartFormDataEncodingResult) -> Void) {
        ServiceManager.shared.upload({ multipartFormData in
            
            if let parameters = self.parameters {
                for (key, value) in parameters {
                    
                    if let image = value as? UIImage, let imageData = UIImageJPEGRepresentation(image, 0.6) {
                        multipartFormData.append(imageData, withName: key, fileName: key+".jpg", mimeType: "image/jpeg")
                    }
                    else if let url = value as? URL {
                        if url.pathExtension == "jpeg" {
                            if let image = UIImage(contentsOfFile: url.path), let imageData = UIImageJPEGRepresentation(image , 0.001) {
                                multipartFormData.append(imageData, withName: key, fileName: key+".jpg", mimeType: "image/jpeg")
                            }
                        }
                        else if url.pathExtension == "mp4" {
                            if let data = try? Data(contentsOf: url) {
                                multipartFormData.append(data, withName: key, fileName: key+".mp4", mimeType: "video/mp4")
                            }
                        }
                        else {
                            if let data = try? Data(contentsOf: url) {
                                multipartFormData.append(data, withName: key, fileName: key+".json", mimeType: "application/json")
                            }
                        }
                    }
                    else if let intValue = value as? Int, let formData = "\(intValue)".data(using: String.Encoding.utf8) {
                        multipartFormData.append(formData, withName: key)
                    }
                    else if let data = (value as AnyObject).data?(using: String.Encoding.utf8.rawValue) {
                        multipartFormData.append(data, withName: key)
                    }
                }
            }
        }, urlRequest: self, encodingCompletion: responseObject)
    }
}
