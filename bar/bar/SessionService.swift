//
//  SessionService.swift
//  bar
//
//  Created by Ben Boral on 1/19/15.
//  Copyright (c) 2015 Ben Boral. All rights reserved.
//

import Foundation

class SessionService {
    
    struct Constants{
        static let timeOut: NSTimeInterval = 7200
    }
    
    class func getAllSessions(bar: PFObject?, completion: (Either<[PFObject]?, NSError?>) -> Void) {
        if (bar == nil) {
            let errorMsg = NSLocalizedString("No Bar", comment: "Error referring to fact that user not logged in")
            let error = NSError(domain: "No Bar", code: 0, userInfo: [NSLocalizedDescriptionKey : errorMsg])
            completion(Either<[PFObject]?, NSError?>(obj: nil, error: error))
        }
        
        var query = PFQuery(className: "Session")
        query.whereKey("bar", equalTo: bar)
        query.orderByDescending("updatedAt")
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            println("finished fetch, error: \(error)")
            if (countElements(objects) > 0) {
                let either = Either<[PFObject]?, NSError?>(obj: (objects as [PFObject]), error: nil)
                completion(either)
            }
            else {
                let either = Either<[PFObject]?, NSError?>(obj: nil, error: error)
                completion(either)
            }
        }
    }
    
    class func getExistingSession(bar: PFObject?, completion: (Either<PFObject?, NSError?>) -> Void) {
        var query = PFQuery(className: "Session")
        if (bar != nil) {
            query.whereKey("bar", equalTo: bar)
        }
        query.whereKey("updatedAt", lessThan: NSDate())
        query.whereKey("updatedAt", greaterThan: NSDate(timeIntervalSinceNow: (-1 * SessionService.Constants.timeOut)))
        query.orderByDescending("updatedAt")
        
        query.getFirstObjectInBackgroundWithBlock { (object: AnyObject!, error: NSError!) -> Void in
            println("finished fetch, error: \(error)")
            if (error != nil) {
                let either = Either<PFObject?, NSError?>(obj: nil, error: error)
                completion(either)
            }
            else if object != nil {
                let session = object as PFObject
                let either = Either<PFObject?, NSError?>(obj: session, error: nil)
                completion(either)
            }
            else {
                let error = NSError(domain: "No Session", code: 0, userInfo: [NSLocalizedDescriptionKey : "No Sessions Found"])
                completion(Either<PFObject?, NSError?>(obj: nil, error: error))
            }
        }
    }
}