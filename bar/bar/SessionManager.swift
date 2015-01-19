//
//  SessionService.swift
//  bar
//
//  Created by Ben Boral on 1/19/15.
//  Copyright (c) 2015 Ben Boral. All rights reserved.
//

import Foundation

class SessionManager {
    
    let timeOut: NSTimeInterval = 7200
    var bar: PFObject?
    var session: PFObject?
    
    init(bar: PFObject?){
        self.bar = bar
    }
    
    func beginSession(){
        getExistingSession { (result: Either<PFObject?, NSError?>) -> Void in
            if (result.error == nil && result.obj != nil) {
                self.session = result.obj!!
            } else {
                self.session = PFObject(className: "Session")
            }
            if (self.bar != nil && self.session!.objectForKey("bar") != nil) {
                self.session!.addObject(self.bar, forKey: "bar")
            }
        }
    }
    
    private func getExistingSession(completion: (Either<PFObject?, NSError?>) -> Void) {
        var query = PFQuery(className: "Session")
        if (bar != nil) {
            query.whereKey("bar", equalTo: bar)
        }
        query.whereKey("updatedAt", lessThan: NSDate())
        query.whereKey("updatedAt", greaterThan: NSDate(timeIntervalSinceNow: (-1 * timeOut)))
        query.orderByAscending("updatedAt")
        
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