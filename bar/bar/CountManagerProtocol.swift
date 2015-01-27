//
//  CountManagerProtocol.swift
//  bar
//
//  Created by Ben Boral on 1/20/15.
//  Copyright (c) 2015 Ben Boral. All rights reserved.
//

import Foundation

protocol CountManagerProtocol{
    func countManagerDidBeginUndoing()
    func countManagerDidFailUndo()
    func countManagerDidSuccessfullyUndo()
    func countManagerDidUpdate(counts: Dictionary <CountManager.Person, Int>)
}