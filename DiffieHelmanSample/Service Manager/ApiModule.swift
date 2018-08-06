//
//  Module.swift
//  RTADubai
//
//  Created by Thahir Maheen on 7/25/18.
//  Copyright © 2018 s4m. All rights reserved.
//

import Foundation

enum ApiModule: String {
    
    case vehicleTestCenters = "vehicle-test-centers"
    
    var name: String {
        return rawValue
    }
}
