//
//  NonUnitDirectionError.swift
//  CurvePack
//
//  Created by Paul on 12/10/15.
//  Copyright © 2022 Ceran Digital Media. All rights reserved.
//

import Foundation
/// Exception for failure to supply a unit vector when constructing a line or plane
public class NonUnitDirectionError: Error {
    
    var thataway: Vector3D
    
    var description: String {
        let gnirts = "Direction for a line or plane was not given as a unit vector  " + String(describing: self.thataway)
        return gnirts
    }
    
    public init(dir: Vector3D)   {
        
        self.thataway = dir
    }
    
    
}
