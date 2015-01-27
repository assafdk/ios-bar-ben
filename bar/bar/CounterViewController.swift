//
//  CounterViewController.swift
//  bar
//
//  Created by Ben Boral on 1/19/15.
//  Copyright (c) 2015 Ben Boral. All rights reserved.
//

import UIKit

class CounterViewController: BarViewController, SessionManagerProtocol, CountManagerProtocol, LocationServiceProtocol, UIGestureRecognizerDelegate {
    
    var bar: PFObject?
    var countManager: CountManager?
    var location: CLLocation?
    
    @IBOutlet weak var sessionLabel: UILabel!
    @IBOutlet weak var changeSessionButton: UIButton!
    @IBOutlet weak var manCounterLabel: UILabel!
    @IBOutlet weak var womanCounterLabel: UILabel!
    @IBOutlet weak var manImageView: UIImageView!
    @IBOutlet weak var womanImageView: UIImageView!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!

    @IBOutlet weak var undoButton: UIBarButtonItem!
    
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
    
    lazy var locationService: LocationService = {
        var locationService = LocationService()
        locationService.delegate = self
        return locationService
    }()
    
    override func viewDidLoad() {
        locationService.requestLocation()
        if (bar == nil) {
            self.navigationItem.title = NSLocalizedString("No Bar Title", comment: "Test Session")
            changeSessionButton.setTitle("", forState: UIControlState.Normal)
            changeSessionButton.userInteractionEnabled = false
        }
        else {
            self.navigationItem.title = (bar!.objectForKey("name") as String)
        }
        
        navigationController?.interactivePopGestureRecognizer.delegate = self;
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(animated: Bool) {
        if (isMovingFromParentViewController()) {
            countManager?.finishManagement()
            countManager = nil
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if (isMovingToParentViewController()){
            sessionManager.fetchSession()
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if (gestureRecognizer == navigationController?.interactivePopGestureRecognizer) {
            return false
        }
        return true
    }
    
    func sessionManagerDidUpdateSession(sessionManager: SessionManager) {
        if (sessionManager.session != nil) {
            if let startDate: NSDate = sessionManager.session!.createdAt {
                sessionLabel.text = NSLocalizedString("From: ", comment: "ex. From: Nov. 1 2014 8 PM") + dateFormatter.stringFromDate(startDate)
            }
            countManager?.finishManagement()
            countManager = nil
            
            countManager = CountManager(session: sessionManager.session!, delegate: self)
            countManager?.commenceManagement()
        }
    }
    
    func sessionManagerFailedToUpdateSession(sessionManager: SessionManager, error: NSError) {
        println("Error starting session: " + error.domain + String(error.code))
        if (error.domain == "Parse" && error.code == 100 && bar != nil) {
            showError(NSLocalizedString("No Internet Error", comment: "Can't reach Parse"))
        }
    }
    
    func countManagerDidBeginUndoing() {
    }
    
    func countManagerDidFailUndo() {
    }
    
    func countManagerDidSuccessfullyUndo() {
        var img = UIImage(named: "undo.png")
        var undoImgView = UIImageView(image: img)
        undoImgView.frame = CGRectMake(0.5 * self.view.frame.size.width, 0.5 * self.view.frame.size.height, 0, 0)
        let minDimension = min(0.5 * self.view.frame.size.width, 0.5 * self.view.frame.size.height)
        self.view.addSubview(undoImgView)
        
        let x = undoImgView.frame.origin.x - minDimension
        let y = undoImgView.frame.origin.y - minDimension
        let w = undoImgView.frame.size.width + (2 * minDimension)
        let h = undoImgView.frame.size.height + (2 * minDimension)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            undoImgView.frame = CGRectMake(x, y, w, h)
            undoImgView.alpha = 0
        }) { (Bool) -> Void in
            undoImgView.removeFromSuperview()
            if let totals = self.countManager?.getTotals() {
                self.updateLabels(totals)
            }
        }
    }
    
    func countManagerDidUpdate(counts: Dictionary<CountManager.Person, Int>) {
        updateLabels(counts)
    }
    
    private func updateLabels(counts: Dictionary<CountManager.Person, Int>){
        for(person, count) in counts {
            if (person == CountManager.Person.Male) {
                manCounterLabel.text = String(count)
            }
            if (person == CountManager.Person.Female) {
                womanCounterLabel.text = String(count)
            }
        }
    }
    
    func normalState() {
        view.backgroundColor = UIColor.whiteColor()
    }
    
    func countGestureRecognizerDidContinueSwipe(person: CountManager.Person, distance: CGFloat) {
        let max = (abs(distance) > 100 ? 100 : abs(distance))
        let alpha = 0.01 * max
        var color: UIColor
        if (person == CountManager.Person.Male) {
            if (distance < 0) {
                color = UIColor(red: 1 - (0.87 * alpha), green: 1 - (0.24 * alpha), blue: 1 - (0.06 * alpha), alpha: 1)
            }
            else {
                color = UIColor(red: 1 - (0.91 * alpha), green: 1 - (0.85 * alpha), blue: 1 - (0.73 * alpha), alpha: 1)
            }
        }
        else {
            if (distance > 0) {
                color = UIColor(red: 1 - (0.75 * alpha), green: 1 - (0.91 * alpha), blue: 1 - (0.85 * alpha), alpha: 1)
            }
            else {
                color = UIColor(red: 1 - (0.07 * alpha), green: 1 - (0.52 * alpha), blue: 1 - (0.32 * alpha), alpha: 1)
            }
        }
        view.backgroundColor = color
    }
    
    func locationServiceDidEnableLocation() {
        locationService.startTrackingLocation()
    }
    
    func locationServiceDidFailToUpdateLocation() {
        location = nil
    }
    
    func locationServiceDidNotEnableLocation() {
        location = nil
    }
    
    func locationServiceDidUpdateLocation(newLocation: CLLocation) {
        location = newLocation
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ChangeSessionSegue") {
            var changeSessionTableViewController = segue.destinationViewController as ChangeSessionTableViewController;
            changeSessionTableViewController.bar = sender as PFObject?
            changeSessionTableViewController.delegate = sessionManager
        }
    }
    
    private func gestureMeaning(sender: UIPanGestureRecognizer) -> (person: CountManager.Person, distance: CGFloat) {
        let translation = sender.translationInView(self.view)
        
        if (abs(translation.y) > abs(translation.x)) {
            return (person: CountManager.Person.Male, distance:translation.y)
        }
        return (person: CountManager.Person.Female, distance:translation.x)
    }
    
    private func updateCount(person: CountManager.Person, operation: CountManager.Operation) {
        countManager?.updateCount(person, operation: operation, location: location)
        var confirmationView: UIImageView?
        if (person == CountManager.Person.Female) {
            confirmationView = UIImageView(image: womanImageView.image)
            confirmationView?.frame = womanImageView.frame
            womanImageView.superview?.addSubview(confirmationView!)
        }
        else if (person == CountManager.Person.Male) {
            confirmationView = UIImageView(image: manImageView.image)
            confirmationView?.frame = manImageView.frame
            manImageView.superview?.addSubview(confirmationView!)
        }
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        var w: CGFloat = 0
        var h: CGFloat = 0
        
        if (confirmationView != nil) {
            x = confirmationView!.frame.origin.x
            y = confirmationView!.frame.origin.y
            w = confirmationView!.frame.width
            h = confirmationView!.frame.height
            confirmationView!.contentMode = UIViewContentMode.ScaleAspectFit
        }
        
        if (confirmationView != nil) {
            UIView.animateWithDuration(0.07, animations: { () -> Void in
                if (confirmationView != nil) {
                    confirmationView?.frame = CGRectMake(x - 10, y - 10, w + 20, h + 20)
                }
            }, completion: { (succ: Bool) -> Void in
                if (succ && confirmationView != nil) {
                    UIView.animateWithDuration(0.07, animations: { () -> Void in
                        confirmationView!.frame = CGRectMake(x, y, w, h)
                    }, completion: { (succ: Bool) -> Void in
                        if (confirmationView != nil) {
                            confirmationView!.removeFromSuperview()
                        }
                    })
                }
            })
        }
    }
    
    @IBAction func tappedUndoButton(sender: AnyObject) {
        countManager?.undoLastCount()
    }
    
    @IBAction func didTapChangeSessionButton(sender: AnyObject) {
        self.performSegueWithIdentifier("ChangeSessionSegue", sender: bar)
    }
    
    @IBAction func didSwipe(sender: UIPanGestureRecognizer) {
        switch (sender.state) {
        case UIGestureRecognizerState.Possible:
            normalState()
            break
        case UIGestureRecognizerState.Began:
            normalState()
            break
        case UIGestureRecognizerState.Changed:
            let gestureMeaning = self.gestureMeaning(sender)
            countGestureRecognizerDidContinueSwipe(gestureMeaning.person, distance: gestureMeaning.distance)
            break
        case UIGestureRecognizerState.Ended:
            normalState()
            let gestureMeaning = self.gestureMeaning(sender)
            if (abs(gestureMeaning.distance) > 100) {
                var operation: CountManager.Operation
                operation = gestureMeaning.distance < 0 ? CountManager.Operation.Increment : CountManager.Operation.Decrement
                updateCount(gestureMeaning.person, operation: operation)
            }
            break
        case UIGestureRecognizerState.Failed:
            normalState()
            break
        case UIGestureRecognizerState.Cancelled:
            normalState()
            break
        }
        
    }
}