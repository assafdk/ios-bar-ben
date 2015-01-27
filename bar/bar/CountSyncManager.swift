//
//  CountSyncManager.swift
//  bar
//
//  Created by Ben Boral on 1/20/15.
//  Copyright (c) 2015 Ben Boral. All rights reserved.
//

import Foundation

class CountSyncManager: NSObject {
    
    var delegate: CountSyncManagerProtocol?
    var timer: NSTimer?
    var totals: Dictionary<CountManager.Person, Int>
    var session: PFObject
    
    init(session: PFObject) {
        self.totals = Dictionary<CountManager.Person, Int>()
        self.session = session
    }
    
    deinit{
        println("CountSyncMgr: deinit")
        stopSyncing()
        unregisterForAppLifeCycleNotifications()
    }
    
    private func registerForAppLifeCycleNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("stopTimer"), name: "enteredBackgroundNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("startTimer"), name: "willEnterForegroundNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("stopTimer"), name: "willTerminate", object: nil)
    }
    
    private func unregisterForAppLifeCycleNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "enteredBackgroundNotification", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "willEnterForegroundNotification", object: nil)
    }
    
    func stopSyncing(){
        unregisterForAppLifeCycleNotifications()
        stopTimer()
    }
    
    func startSyncing(){
        registerForAppLifeCycleNotifications()
        getSessionCounts()
        println("start syncing -- before starting Timer")
        startTimer()
    }
    
    func stopTimer() {
        timer?.invalidate()
        forceSync()
    }
    
    func startTimer() {
        println("starting Timer")
        if (timer == nil || timer?.valid == false) {
            println("really starting timer")
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("sync:"), userInfo: nil, repeats: true)
            timer?.tolerance = timer!.timeInterval * 0.25
        }
    }
    
    func forceSync() {
        if (delegate != nil) {
            if let counts = delegate?.unsyncedCounts {
                delegate?.countSyncManagerProtocolDidBeginSync()
                for count in counts {
                    count.saveEventually()
                }
            }
        }
    }
    
    func getLastCount(completion: (Either<PFObject?, NSError?>) -> Void) {
        var count = PFObject(className: "Count")
        var query = PFQuery(className: "Count")
        query.orderByDescending("timeStamp")
        query.getFirstObjectInBackgroundWithBlock { (count: PFObject!, error: NSError!) -> Void in
            if (count != nil){
                completion(Either<PFObject?, NSError?>(obj: count, error: nil))
            }
            else {
                completion(Either<PFObject?, NSError?>(obj: nil, error: error))
            }
        }
    }
    
    func delete(count: PFObject, completion: (Either<Bool?, NSError?>) -> Void){
        count.deleteInBackgroundWithBlock { (result: Bool, error: NSError!) -> Void in
            if (result) {
                completion(Either<Bool?, NSError?>(obj: true, error: nil))
                self.getSessionCounts()
            }
            else {
                completion(Either<Bool?, NSError?>(obj: true, error: error))
            }
        }
    }
    
    func sync(timer: NSTimer!) {
        println("syncing" + timer.description)
        if (delegate != nil) {
            if let counts = delegate?.unsyncedCounts {
                if (!counts.isEmpty){
                    delegate?.countSyncManagerProtocolDidBeginSync()
                    PFObject.saveAllInBackground(counts, block: { (result: Bool, error: NSError!) -> Void in
                        if (result == true) {
                            self.delegate?.countSyncManagerProtocolDidFinishSync()
                        }
                        else {
                            self.delegate?.countSyncManagerProtocolDidFailToSync(error, failedCounts: counts)
                        }
                        self.getSessionCounts()
                    })
                }
            }
        }
    }
    
    private func getSessionCounts() {
        var queryMI = PFQuery(className: "Count")
        queryMI.whereKey("session", equalTo: session)
        queryMI.whereKey("operation", equalTo: CountManager.Operation.Increment.rawValue)
        queryMI.whereKey("classification", equalTo: CountManager.Person.Male.rawValue)
        queryMI.countObjectsInBackgroundWithBlock { (ctMI: Int32, errMI: NSError!) -> Void in
            if (errMI == nil) {
                var queryMD = PFQuery(className: "Count")
                queryMD.whereKey("session", equalTo: self.session)
                queryMD.whereKey("operation", equalTo: CountManager.Operation.Decrement.rawValue)
                queryMD.whereKey("classification", equalTo: CountManager.Person.Male.rawValue)
                queryMD.countObjectsInBackgroundWithBlock({ (ctMD: Int32, errMD: NSError!) -> Void in
                    if (errMD == nil) {
                        self.totals[CountManager.Person.Male] = Int(ctMI) - Int(ctMD)
                        var queryWI = PFQuery(className: "Count")
                        queryWI.whereKey("session", equalTo: self.session)
                        queryWI.whereKey("operation", equalTo: CountManager.Operation.Increment.rawValue)
                        queryWI.whereKey("classification", equalTo: CountManager.Person.Female.rawValue)
                        queryWI.countObjectsInBackgroundWithBlock({ (ctWI: Int32, errWI: NSError!) -> Void in
                            if (errWI == nil) {
                                var queryWD = PFQuery(className: "Count")
                                queryWD.whereKey("session", equalTo: self.session)
                                queryWD.whereKey("operation", equalTo: CountManager.Operation.Decrement.rawValue)
                                queryWD.whereKey("classification", equalTo: CountManager.Person.Female.rawValue)
                                queryWD.countObjectsInBackgroundWithBlock({ (ctWD: Int32, errWD: NSError!) -> Void in
                                    if (errWD == nil) {
                                        self.totals[CountManager.Person.Female] = Int(ctWI) - Int(ctWD)
                                        self.delegate?.countSyncManagerDidGetUpdate()
                                    }
                                })
                            }
                        })
                    }
                })
            }
        }
    }
}