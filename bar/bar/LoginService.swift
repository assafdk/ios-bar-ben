//
//  LoginService.swift
//  bar
//
//  Created by Ben Boral on 1/18/15.
//  Copyright (c) 2015 Ben Boral. All rights reserved.
//

import Foundation

class LoginService {

    func login(bar: String, passcode: Int, completion: (Either<PFObject?, NSError?>) -> Void) {
        var query = PFQuery(className: "Bar")
        query.whereKey("name", equalTo: bar)
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            println("finished fetch, error: \(error)")
            if (error != nil) {
                var either: Either<PFObject?, NSError?>
                if (error.domain == "Parse" && error.code == 100){
                    let err = NSError(domain: "no internet", code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("No Internet Error", comment:"couldn't get internet")])
                    either = Either<PFObject?, NSError?>(obj: nil, error: err)
                }
                else {
                    either = Either<PFObject?, NSError?>(obj: nil, error: error)
                }
                completion(either)
                return
            }else if (countElements(objects) > 0) {
                let bar = objects[0] as PFObject
                if bar["passcodes"].containsObject(passcode) {
                    let either = Either<PFObject?, NSError?>(obj: bar, error: nil)
                    completion(either)
                    return
                }
            }
            let localizedError = NSLocalizedString("Couldn't find valid bar", comment: "Valid bar error")
            let error = NSError(domain: "No Bars", code: 0, userInfo: [NSLocalizedDescriptionKey : localizedError])
            let either = Either<PFObject?, NSError?>(obj: nil, error: error)
            completion(either)
        }
    }
}