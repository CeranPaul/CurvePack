//
//  CoincidentPointsError.swift
//  CurvePack
//
//  Created by Paul on 10/28/15.
//  Copyright © 2022 Ceran Digital Media. All rights reserved.
//

import Foundation

/// Exception for when the points should not have be coincident
public class CoincidentPointsError: Error {
    
    var ptA: Point3D
    
    var description: String {
        return "Coincident points were specified - no bueno! " + String(describing: ptA)
    }
    
    public init(dupePt: Point3D)   {
        
        self.ptA = dupePt
    }
        
}
