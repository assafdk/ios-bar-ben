//
//  CountManager.swift
//  bar
//
//  Created by Ben Boral on 1/20/15.
//  Copyright (c) 2015 Ben Boral. All rights reserved.
//

import Foundation

class CountManager : CountSyncManagerProtocol {
    
    var session: PFObject
    var unsyncedCounts: [PFObject]
    var countSyncManager: CountSyncManager
    var delegate: CountManagerProtocol?
    
    init(session: PFObject, delegate: CountManagerProtocol){
        self.session = session
        self.unsyncedCounts = Array<PFObject>()
        self.delegate = delegate
        self.countSyncManager = CountSyncManager(session: session)
        self.countSyncManager.delegate = self
    }
    
    deinit {
        println("deinit count manager")
        finishManagement()
    }
    
    func getTotals() -> Dictionary<CountManager.Person, Int> {
        var parseTotals = countSyncManager.totals
        var unsyncedTotals = CountService.totalsForCounts(unsyncedCounts)
        
        for (person, count) in unsyncedTotals {
            var parseTotal = 0
            if (parseTotals[person] != nil) {
                parseTotal = parseTotals[person]!
            }
            parseTotals[person] = parseTotal + count
        }
        
        return parseTotals
    }

    func commenceManagement(){
        println("Commence MGMT")
        countSyncManager.startSyncing()
    }
    
    func finishManagement(){
        println("finishing management. Should stop syncing now")
        countSyncManager.stopSyncing()
        countSyncManager.forceSync()
    }
    
    func updateCount(person: Person, operation: Operation, location: CLLocation?) {
        println(person.rawValue + operation.rawValue)
        let count = PFObject(className: "Count",dictionary: ["classification" : person.rawValue,
            "operation" : operation.rawValue,
            "timeStamp" : NSDate(),
            "device": DeviceService.sharedDeviceService.deviceIdentifier,
            "session": session])
        if (location != nil) {
            count.addObject(location!.coordinate.latitude as Double, forKey: "latidude")
            count.addObject(location!.coordinate.longitude as Double, forKey: "longitude")
            count.addObject(location!.altitude as Double, forKey: "altitude")
        }
        unsyncedCounts.append(count)
        delegate?.countManagerDidUpdate(getTotals())
    }
    
    func undoLastCount() {
        delegate?.countManagerDidBeginUndoing()
        if (!unsyncedCounts.isEmpty){
            var lastIdx: Int = 0
            for (index, count) in enumerate(unsyncedCounts) {
                let timeStamp = count.objectForKey("timeStamp") as NSDate
                let lastTimeStamp = unsyncedCounts[lastIdx].objectForKey("timeStamp") as NSDate
                if (timeStamp.compare(lastTimeStamp) == NSComparisonResult.OrderedDescending){
                    lastIdx = index
                }
            }
            unsyncedCounts.removeAtIndex(lastIdx)
            delegate?.countManagerDidSuccessfullyUndo()
        }
        else {
            countSyncManager.getLastCount({ (result1: Either<PFObject?, NSError?>) -> Void in
                if (result1.obj != nil) {
                    self.countSyncManager.delete((result1.obj as PFObject!!), completion: { (result2: Either<Bool?, NSError?>) -> Void in
                        if (result2.obj != nil && result2.obj! == true) {
                            self.delegate?.countManagerDidSuccessfullyUndo()
                        }
                        else{
                            self.delegate?.countManagerDidFailUndo()
                        }
                    })
                }
                else {
                    self.delegate?.countManagerDidFailUndo()
                }
            })
        }
    }
    
    func countSyncManagerProtocolDidBeginSync() {
        unsyncedCounts.removeAll(keepCapacity: false)
    }
    
    func countSyncManagerProtocolDidFailToSync(error: NSError, failedCounts: [PFObject]) {
        for count in failedCounts {
            unsyncedCounts.append(count)
        }
    }
    
    func countSyncManagerProtocolDidFinishSync() {
    }
    
    func countSyncManagerDidGetUpdate() {
        delegate?.countManagerDidUpdate(getTotals())
    }

    enum Person: String {
        case Male = "male"
        case Female = "female"
    }
    
    enum Operation: String {
        case Increment = "increment"
        case Decrement = "decrement"
    }
}
