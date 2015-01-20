//
//  SessionFactory.swift
//  bar
//
//  Created by Ben Boral on 1/19/15.
//  Copyright (c) 2015 Ben Boral. All rights reserved.
//

import Foundation

class SessionFactory {
    
    class func makeSession(bar: PFObject?) -> PFObject {
        var session = PFObject(className: "Session")
        if (bar != nil) {
            session.setObject(bar, forKey: "bar")
        }
        return session
    }
}