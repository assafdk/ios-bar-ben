//
//  CountSyncManagerProtocol.swift
//  bar
//
//  Created by Ben Boral on 1/20/15.
//  Copyright (c) 2015 Ben Boral. All rights reserved.
//

import Foundation

protocol CountSyncManagerProtocol {
    
    var unsyncedCounts: [PFObject] { get }
    
    func countSyncManagerProtocolDidBeginSync()
    func countSyncManagerProtocolDidFinishSync()
    func countSyncManagerDidGetUpdate()
    func countSyncManagerProtocolDidFailToSync(error: NSError, failedCounts: [PFObject])
}