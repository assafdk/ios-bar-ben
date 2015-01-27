//
//  LocationService.swift
//  bar
//
//  Created by Ben Boral on 1/27/15.
//  Copyright (c) 2015 Ben Boral. All rights reserved.
//

import Foundation
import Foundation
import CoreLocation
import MapKit

class LocationService: NSObject, CLLocationManagerDelegate {
    
    class func locationStatus() -> CLAuthorizationStatus{
        return CLLocationManager.authorizationStatus()
    }
    
    private var locationManager: CLLocationManager

    var delegate: LocationServiceProtocol?
    
    override init() {
        //assign properties
        self.locationManager = CLLocationManager()
        
        //after assigning properties, then call super
        super.init()
        
        //assign delegate to self after calling super
        self.locationManager.delegate = self
    }
    
    func startTrackingLocation() {
        let status = LocationService.locationStatus()
        if (status == CLAuthorizationStatus.Authorized || status == CLAuthorizationStatus.AuthorizedWhenInUse) {
            locationManager.startUpdatingLocation()
        }
    }
    
    func requestLocation() {
        if (locationManager.respondsToSelector(Selector("requestWhenInUseAuthorization"))) {
            println("asking for verification")
            locationManager.requestWhenInUseAuthorization()
        }
        else {
            println("NOT asking for verification")
            delegate?.locationServiceDidNotEnableLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        delegate?.locationServiceDidUpdateLocation(newLocation)
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        delegate?.locationServiceDidFailToUpdateLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.Denied || status == CLAuthorizationStatus.Restricted) {
            delegate?.locationServiceDidNotEnableLocation()
        }
        else if (status == CLAuthorizationStatus.Authorized || status == CLAuthorizationStatus.AuthorizedWhenInUse){
            delegate?.locationServiceDidEnableLocation()
        }
    }
    
}