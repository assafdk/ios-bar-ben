//
//  LocationServiceProtocol.swift
//  bar
//
//  Created by Ben Boral on 1/27/15.
//  Copyright (c) 2015 Ben Boral. All rights reserved.
//

import Foundation

protocol LocationServiceProtocol {
    func locationServiceDidEnableLocation()
    func locationServiceDidNotEnableLocation()
    func locationServiceDidUpdateLocation(newLocation: CLLocation)
    func locationServiceDidFailToUpdateLocation()
}