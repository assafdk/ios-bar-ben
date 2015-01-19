//
//  Either.swift
//  bar
//
//  Created by Ben Boral on 1/18/15.
//  Copyright (c) 2015 Ben Boral. All rights reserved.
//

import Foundation

//Struct for returning results or error, depending success of operation
struct Either <T1, NSError> {
    let obj: T1?
    let error: NSError?
    
    init(obj: T1?, error: NSError?) {
        self.obj = obj
        self.error = error
    }
    
    func either() -> Bool {
        return (self.obj != nil) || (self.error != nil)
    }
}