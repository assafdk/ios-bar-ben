//
//  SessionService.swift
//  bar
//
//  Created by Ben Boral on 1/19/15.
//  Copyright (c) 2015 Ben Boral. All rights reserved.
//

import Foundation

class SessionManager: ChangeSessionProtocol {
    
    var bar: PFObject?
    var session: PFObject?
    var delegate: SessionManagerProtocol?
    
    init(bar: PFObject?){
        self.bar = bar
    }
    
    func fetchSession() {
        SessionService.getExistingSession(self.bar, completion: { (result: Either<PFObject?, NSError?>) -> Void in
            if (result.error == nil && result.obj != nil) {
                self.session = result.obj!!
            } else {
                self.session = SessionFactory.makeSession(self.bar)
            }
            self.beginSession()
        })
    }
    
    func beginSession(){
            //save to update the modifiedAt and createdAt
        if (self.session != nil) {
            self.session!.saveInBackgroundWithBlock({ (success: Bool, error: NSError!) -> Void in
                println("DID SAVE WITH SUCCESS: \(success)")
                if (success) {
                    self.delegate?.sessionManagerDidUpdateSession(self)
                }
                else {
                    self.delegate?.sessionManagerFailedToUpdateSession(self, error: error)
                }
            })
        }
    }
    
    func didChangeSession(newSession: PFObject) {
        session = newSession
        beginSession()
    }
}