//
//  BarViewController.swift
//  bar
//
//  Created by Ben Boral on 1/19/15.
//  Copyright (c) 2015 Ben Boral. All rights reserved.
//

import UIKit

class BarViewController : UIViewController {
    
    func showError(errorMessage: String) {
        let errorTitle = NSLocalizedString("Error", comment: "General Error")
        let okayTitle = NSLocalizedString("OK", comment: "OK")
        let alert = UIAlertView(title: errorTitle, message: errorMessage, delegate: nil, cancelButtonTitle: okayTitle)
        alert.show()
    }
    
}
