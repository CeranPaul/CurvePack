//
//  CoincidentLinesError.swift
//  CurvePack
//
//  Created by Paul on 1/10/16.
//  Copyright © 2022 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

/// Exception for when the lines shouldn't have been coincident - i.e. when trying to intersect them
public class CoincidentLinesError: Error {
    
    var enil: Line
    
    var description: String {
        let gnirts = "Two lines were coincident when an intersection was attempted  " + String(describing: enil.getOrigin()) + String(describing: enil.getDirection())
            
        return gnirts
    }
    
    public init(enil: Line)   {
        
        self.enil = enil
    }
    
    
}
