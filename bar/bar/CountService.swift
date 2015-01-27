//
//  CountService.swift
//  bar
//
//  Created by Ben Boral on 1/21/15.
//  Copyright (c) 2015 Ben Boral. All rights reserved.
//

import Foundation

class CountService {
    class func totalsForCounts(counts: [PFObject]) -> Dictionary <CountManager.Person, Int> {
        var totals = Dictionary <CountManager.Person, Int>()
        for count: PFObject in counts {
            if (count.objectForKey("classification") != nil && count.objectForKey("operation") != nil){
            if ((count.objectForKey("classification") as NSString) == CountManager.Person.Male.rawValue) {
                if (totals[CountManager.Person.Male] == nil) {
                    totals[CountManager.Person.Male] = 0
                }
                var total = totals[CountManager.Person.Male]
                if (count.objectForKey("operation") as NSString == CountManager.Operation.Increment.rawValue){
                    totals[CountManager.Person.Male] = total! + 1
                }
                else {
                    totals[CountManager.Person.Male] = total! - 1
                }
            }
            else {
                
                if (totals[CountManager.Person.Female] == nil) {
                    totals[CountManager.Person.Female] = 0
                }
                var total = totals[CountManager.Person.Female]
                
                if ((count.objectForKey("operation") as NSString) == CountManager.Operation.Increment.rawValue){
                    totals[CountManager.Person.Female] = total! + 1
                }
                else {
                    totals[CountManager.Person.Female] = total! - 1
                }
            }
            }
        }
        
        return totals
    }
}