//
//  SmartTouch.swift
//  DiffieHelmanSample
//
//  Created by Sanu Sathyaseelan on 8/6/18.
//  Copyright © 2018 Farabi. All rights reserved.
//


import ObjectMapper
import PromiseKit
import Alamofire
import KSAUtils
import BigInt

class ServerDateFormatTransform: DateFormatterTransform {
    
    public init(formatString: String, timeZone: String?) {
        let formatter = DateFormatter()
        formatter.dateFormat = formatString
        if let timeZone = timeZone {
            formatter.locale = Locale(identifier: "en_US")
            formatter.timeZone = TimeZone(identifier: timeZone)
        }
        
        super.init(dateFormatter: formatter)
    }
}

class Object: Mappable {
    
    required init?(map: Map) {}

    init() {}

    func mapping(map: Map) {}
}


class SmarrtTouch: Object {
    
    var prime = ""
    var generator = ""
    var publicKey = ""
    var timeZone = ""
    
    var date: Date?

//    var clientPublickey = ""
//    var otp = ""
    
    // diffieeee
    private lazy var diffieeee: FTDiffieHellman = {
        guard let diffie = FTDiffieHellman(prime: prime, andGenerator: generator) else { return FTDiffieHellman() }
        diffie.generateKeyPairs()
        return diffie
    }()
    
    
    private lazy var dhelman: DHKey = {
        
        let dhGroup = DHGroup(primeString: prime, generate: generator)
        let dhKey = DHKey(dhGroup: dhGroup)
        return dhKey ?? DHKey()
    }()
    
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        prime     <- map["PRIME"]
        generator <- map["GENERATOR"]
        publicKey <- map["PUBLICKEY"]
        timeZone  <- map["TIMEZONE"]
        date      <- (map["DATE"], ServerDateFormatTransform(formatString: "dd/MM/yyyy HH:mm:ss", timeZone: timeZone))
    }
}

extension SmarrtTouch {
    
    class SuccessResponse: Object {
        
        var result: String?
        
        override func mapping(map: Map) {
            result  <- map["success"]
        }
    }
    
}


extension SmarrtTouch {
    
    enum Router: Requestable {
        
        case generateKeys(String)
        case validatePublicKey(SmarrtTouch)
        
        var method: HTTPMethod {
            return .post
        }
        
        var module: ApiModule? {
            return .scsAdmin
        }
        
        var path: ApiPath? {
            switch self {
            case .generateKeys:
                return .generateKeys
            case .validatePublicKey:
                return .registerTouchId
            }
            
        }
        
        var parameters: Parameters? {
            switch self {
            case .generateKeys(let code):
                return ["code": code]
            case .validatePublicKey(let smartTouch):
                return ["publickey": smartTouch.clientPublickey, "code": smartTouch.otp]
            }
        }
    }
}

extension SmarrtTouch {
    
    @discardableResult
    static func generateKeys() -> Promise<SmarrtTouch> {
        
        return Promise { resolver in
            
            Router.generateKeys("1234").request { (response: DataResponse<SmarrtTouch>) in
                
                guard response.error == nil else {
                    if let error = response.error {
                        resolver.reject(error)
                    }
                    return
                }
                
                guard let smartTouch = response.value else {
                    let error = NSError(domain: "JSONResponseError", code: 3841, userInfo: nil)
                    resolver.reject(error)
                    return
                }
                
                resolver.fulfill(smartTouch)
            }
        }
    }
    
    func validateClientPublicKey() -> Promise<SuccessResponse> {

        return Promise { resolver in
            
            Router.validatePublicKey(self).request{ (response: DataResponse<SuccessResponse>) in
                
                guard response.error == nil else {
                    if let error = response.error {
                        resolver.reject(error)
                    }
                    return
                }
                
                guard let success = response.value else {
                    let error = NSError(domain: "JSONResponseError", code: 3841, userInfo: nil)
                    resolver.reject(error)
                    return
                }
                resolver.fulfill(success)
            }
        }
    }
}


//extension SmarrtTouch {
//
//    @discardableResult
//    func createCredentials() -> Promise<Void> {
//
//        return Promise { resolver in
//
//            let error = NSError(domain: "TouchId", code: -999, userInfo: [NSLocalizedDescriptionKey: "Something went wrong"])
//
//            guard let diffieee = FTDiffieHellman(prime: prime, andGenerator: generator) else { return resolver.reject(error) }
//            diffieee.generateKeyPairs()
//
//            clientPublickey = diffieee.base64PublicKey
//
//            let serverPublickeyBase64 = Data(base64Encoded: publicKey, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)
//            guard let sharedSecretkey = try? diffieee.computeSharedSecretKey(withOtherPartyPublicKey: serverPublickeyBase64), let date = date else { return resolver.reject(error) }
//
//            let tOtpGenerator = TOTPGenerator(secret: sharedSecretkey, algorithm: kOTPGeneratorSHA1Algorithm, digits: 6, period: 30)
//            guard let code = tOtpGenerator?.generateOTP(for: date) else { return resolver.reject(error) }
//
//            otp = code
//            resolver.fulfill(())
//        }
//    }
//}

extension SmarrtTouch {
    
    var clientPublickey: String {
        
//        let pkKeyData = dhelman.publicKey
//        let pkString = pkKeyData?.base64EncodedString(options: Data.Base64EncodingOptions.)
        
//        let pkkString = String(data: pkKeyData!, encoding: String.Encoding.utf8)
//        print("pkkString" + pkkString!)
        
//        return
        let pkString = diffieeee.base64PublicKey
        print(">>>>>>" + pkString!)
        return pkString?.uppercased() ?? ""
//        return dhelman.publicKeyBase64 ?? ""
    }
    
    var otp: String {
        
        let serverPublickeyBase64 = Data(base64Encoded: publicKey, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)
        guard let sharedSecretkey = try? diffieeee.computeSharedSecretKey(withOtherPartyPublicKey: serverPublickeyBase64), let date = date else { return "" }
        
        let tOtpGenerator = TOTPGenerator(secret: sharedSecretkey, algorithm: kOTPGeneratorSHA1Algorithm, digits: 6, period: 30)
        guard let code = tOtpGenerator?.generateOTP(for: date) else { return "" }
        return code
    }
}

