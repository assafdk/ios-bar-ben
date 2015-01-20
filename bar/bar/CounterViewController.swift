//
//  CounterViewController.swift
//  bar
//
//  Created by Ben Boral on 1/19/15.
//  Copyright (c) 2015 Ben Boral. All rights reserved.
//

import UIKit

class CounterViewController: BarViewController, SessionManagerProtocol {
    
    var bar: PFObject?
    @IBOutlet weak var sessionLabel: UILabel!
    @IBOutlet weak var changeSessionButton: UIButton!
    
    override func viewDidLoad() {
        if (bar == nil) {
            self.navigationItem.title = NSLocalizedString("No Bar Title", comment: "Test Session")
            changeSessionButton.setTitle("", forState: UIControlState.Normal)
            changeSessionButton.userInteractionEnabled = false
        }
        else {
            self.navigationItem.title = (bar!.objectForKey("name") as String)
        }
        sessionManager.fetchSession()
        super.viewDidLoad()
    }
    
    func sessionManagerDidUpdateSession(sessionManager: SessionManager) {
        if (sessionManager.session != nil) {
            let startDate: NSDate = sessionManager.session!.createdAt
            sessionLabel.text = NSLocalizedString("From: ", comment: "From: Nov. 1 2014 8 PM") + dateFormatter.stringFromDate(startDate)
        }
    }
    
    func sessionManagerFailedToUpdateSession(sessionManager: SessionManager, error: NSError) {
        println("Error starting session: " + error.localizedDescription)
        if (error.domain == "Parse" && error.code == 100 && bar != nil) {
            showError(NSLocalizedString("No Internet Error", comment: "Can't reach Parse"))
        }
    }
    
    @IBAction func didTapChangeSessionButton(sender: AnyObject) {
        self.performSegueWithIdentifier("ChangeSessionSegue", sender: bar)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ChangeSessionSegue") {
            var changeSessionTableViewController = segue.destinationViewController as ChangeSessionTableViewController;
            changeSessionTableViewController.bar = sender as PFObject?
            changeSessionTableViewController.delegate = sessionManager
        }
    }
    
    lazy var sessionManager: SessionManager = {
        let session = SessionManager(bar: self.bar)
        session.delegate = self
        return session
    }()
    
    lazy var dateFormatter: NSDateFormatter = {
        var dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle;
        dateFormatter.locale = NSLocale.currentLocale()
        return dateFormatter
    }()

}