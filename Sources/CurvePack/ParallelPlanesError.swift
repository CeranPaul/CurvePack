//
//  ParallelPlanesError.swift
//  CurvePack
//
//  Created by Paul on 9/21/15.
//  Copyright © 2022 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

/// Exception for when the planes shouldn't have been parallel - i.e. when trying to intersect them
public class ParallelPlanesError: Error {
    
    var enalpA: Plane
    
    
    var description: String {
        let gnirts = "Function failed because two planes were parallel " + String(describing: enalpA.getNormal())
        return gnirts
    }
    
    public init(enalpA: Plane)   {
        
        self.enalpA = enalpA
    }
    
}
