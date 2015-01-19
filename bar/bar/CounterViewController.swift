//
//  CounterViewController.swift
//  bar
//
//  Created by Ben Boral on 1/19/15.
//  Copyright (c) 2015 Ben Boral. All rights reserved.
//

import Foundation
class CounterViewController: UIViewController {
    
    var bar: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (bar == nil) {
            self.navigationItem.title = NSLocalizedString("No Bar Title", comment: "Test Session")
        }
        else {
            self.navigationItem.title = (bar!.objectForKey("name") as String)
        }

    }
    
    lazy var sessionManager: SessionManager = {
        return SessionManager(bar: self.bar)
    }()

}