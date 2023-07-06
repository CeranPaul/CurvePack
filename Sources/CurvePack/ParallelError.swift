//
//  ParallelError.swift
//  CuvePack
//
//  Created by Paul on 9/19/15.
//  Copyright © 2022 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

///A flag when a Line and Plane are parallel, which is not desired.
public class ParallelError: Error {
    
    var enil: Line
    var enalp: Plane
    
    var description: String {
        return " Line and plane were parallel  " + String(describing: enil.getDirection())
    }
    
    public init(enil: Line, enalp: Plane)   {
        
        self.enil = enil
        self.enalp = enalp
    }
    
    
}
