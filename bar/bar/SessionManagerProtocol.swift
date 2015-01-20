//
//  SessionManagerProtocol.swift
//  bar
//
//  Created by Ben Boral on 1/19/15.
//  Copyright (c) 2015 Ben Boral. All rights reserved.
//

import Foundation

protocol SessionManagerProtocol {
    func sessionManagerDidUpdateSession(sessionManager: SessionManager)
    func sessionManagerFailedToUpdateSession(sessionManager: SessionManager, error: NSError)
}