//
//  ChangeSessionsTableViewController.swift
//  bar
//
//  Created by Ben Boral on 1/19/15.
//  Copyright (c) 2015 Ben Boral. All rights reserved.
//

import UIKit

class ChangeSessionTableViewController: BarViewController, UITableViewDelegate, UITableViewDataSource {
    
    var bar: PFObject?
    var sessions: [PFObject] = Array()
    var delegate: ChangeSessionProtocol?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startNewSessionButton: UIButton!
    
    lazy var dateFormatter: NSDateFormatter = {
        var dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle;
        dateFormatter.locale = NSLocale.currentLocale()
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        SessionService.getAllSessions(bar, completion: { (result: Either<[PFObject]?, NSError?>) -> Void in
            
            if (result.obj != nil) {
                self.sessions = result.obj!!
                self.tableView.reloadData()
                return
            }
            
            if let err = result.error? {
                if (err.domain == "No Bar" && err.code == 0){
                    self.showError(err.localizedDescription)
                }
            }
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Session Cell") as UITableViewCell?
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Session Cell")
        }
        
        let session: PFObject = sessionForIndexPath(indexPath)
        let lastUpdated: String = NSLocalizedString("Last Updated", comment: "ex Last Updated: 8/4/14 9PM")
        cell?.textLabel?.text = dateFormatter.stringFromDate(session.updatedAt)
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let session: PFObject = sessionForIndexPath(indexPath)
        didSelectSession(session)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sessions.isEmpty ? 0 : 1
    }
    
    func sessionForIndexPath(indexPath: NSIndexPath) -> PFObject {
        let position = indexPath.row
        return sessions[position]
    }
    
    func didSelectSession(session: PFObject) {
        delegate?.didChangeSession(session)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didTapStartNewSessionButton(sender: AnyObject) {
        didSelectSession(SessionFactory.makeSession(bar))
    }
}

protocol ChangeSessionProtocol {
    func didChangeSession(newSession: PFObject)
}