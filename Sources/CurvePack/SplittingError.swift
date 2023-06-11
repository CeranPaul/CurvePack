//
//  SplittingError.swift
//  CurvePack
//
//  Created by Paul on 7/22/20.
//  Copyright © 2022 Paul. All rights reserved.
//

import Foundation

/// Exception for when the Loop can't be aligned
class SplittingError: Error {
    
    var coord: Double
    
    var description: String {
        return "Wrong number of intersections!" + String(coord)
    }
    
    public init(vert: Double)   {
        
        self.coord = vert
    }
    
}
