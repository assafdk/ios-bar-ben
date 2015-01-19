//
//  WelcomeViewController.swift
//  bar
//
//  Created by Ben Boral on 1/18/15.
//  Copyright (c) 2015 Ben Boral. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var barNameLabel: UILabel!
    @IBOutlet weak var barNameTextField: UITextField!
    @IBOutlet weak var passcodeLabel: UILabel!
    @IBOutlet weak var passcodeTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var justTryItOutButton: UIButton!
    @IBOutlet weak var registerButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false;
    }
    
    func canAttemptLogin() -> Either<Bool, NSError> {
        
        if (Reachability.reachabilityForInternetConnection().currentReachabilityStatus().value == 0){
            let localizedDescription = NSLocalizedString("No Internet Error", comment: "Error Description")
            let error = NSError(domain: "Reachability Error", code: 0, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
            return Either(obj: false, error: error)
        }
        if (barNameTextField.text? == nil || countElements(barNameTextField.text!) < 4){
            let localizedDescription = NSLocalizedString("Login Bar Name Error", comment: "Error Description")
            let error = NSError(domain: "Login Error", code: 0, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
            return Either(obj: false, error: error)
        }
        if (passcodeTextField.text? == nil || countElements(passcodeTextField.text!) < 2){
            let localizedDescription = NSLocalizedString("Login Passcode Error", comment: "Error Description")
            let error = NSError(domain: "Login Error", code: 1, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
            return Either(obj: false, error: error)
        }
        return Either(obj: true, error: nil)
    }
    
    func showError(errorMessage: String) {
        let errorTitle = NSLocalizedString("Error", comment: "General Error")
        let okayTitle = NSLocalizedString("OK", comment: "OK")
        let alert = UIAlertView(title: errorTitle, message: errorMessage, delegate: nil, cancelButtonTitle: okayTitle)
        alert.show()
    }
    
    @IBAction func didTapRegisterButton(sender: AnyObject) {
        let registrationUrl = NSLocalizedString("registrationUrl", comment: "Link to the url where bars can register")
        UIApplication.sharedApplication().openURL(NSURL(string:registrationUrl)!)
    }
    
    @IBAction func didTapLoginButton(sender: AnyObject) {
        
        let canAttempt = canAttemptLogin();
        
        if (canAttempt.error != nil){
            showError(canAttempt.error!.localizedDescription)
            return
        }
        
        let loginService = LoginService()
        loginService.login(barNameTextField.text!, passcode: passcodeTextField.text!.toInt()!) { (result: Either<PFObject?, NSError?>) -> Void in
            if let error = result.error {
                self.showError(error!.localizedDescription)
            }
            else if (result.obj != nil) {
                var bar = result.obj!!
                self.performSegueWithIdentifier("ToCountSegue", sender: bar)
            }
        }
    }
    
    @IBAction func didTapJustTryItOutButton(sender: AnyObject) {
        self.performSegueWithIdentifier("ToCountSegue", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if (segue?.identifier == "ToCountSegue") {
            var counterViewController = segue?.destinationViewController as CounterViewController;
            counterViewController.bar = sender as PFObject?
        }
    }
}