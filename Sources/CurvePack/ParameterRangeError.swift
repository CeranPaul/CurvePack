//
//  ParameterRangeError.swift
//  CurvePack
//
//  Created by Paul Hollingshead on 5/10/20.
//  Copyright © 2022 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

/// Exception for when a parameter value is outside the allowed range
public class ParameterRangeError: Error {
    
    var paramA: Double
    
    var description: String {
        return "Parameter was outside valid range! " + String(describing: paramA)
    }
    
    public init(parA: Double)   {
        
        self.paramA = parA
    }
    
}
