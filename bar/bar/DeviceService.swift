//
//  DeviceService.swift
//  bar
//
//  Created by Ben Boral on 1/21/15.
//  Copyright (c) 2015 Ben Boral. All rights reserved.
//

import Foundation
import AdSupport

private let _deviceServiceSharedInstance = DeviceService()

//Used to identify devices
class DeviceService {

    class var sharedDeviceService: DeviceService {
        return _deviceServiceSharedInstance
    }
    
    lazy var deviceIdentifier: String = {
        return ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString
    }()
    
}