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
    var session: PFObject? {
        didSet {
            self.delegate?.sessionManagerDidUpdateSession(self)
        }
    }
    var delegate: SessionManagerProtocol?
    
    init(bar: PFObject?){
        self.bar = bar
    }
    
    func fetchSession() {
        self.session = SessionFactory.makeSession(self.bar)
        self.beginSession()
        
        SessionService.getExistingSession(self.bar, completion: { (result: Either<PFObject?, NSError?>) -> Void in
            if (result.error == nil && result.obj != nil) {
                self.session = result.obj!!
                self.beginSession()
            }
        })
    }
    
    func beginSession(){
        //save to update the modifiedAt and createdAt
        if (self.session != nil) {
            self.session!.saveInBackgroundWithBlock({ (success: Bool, error: NSError!) -> Void in
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
        SessionService.performHouseKeeping(session)
        session = newSession
        beginSession()
    }
}