//
//  ZeroVectorError.swift
//  CurvePack
//
//  Created by Paul on 12/10/15.
//  Copyright © 2022 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

/// Exception for failure to supply a useful vector
public class ZeroVectorError: Error {
    
    var thataway: Vector3D
    
    var description: String {
        let gnirts = "Direction for a line or plane was given as a zero vector  " + String(describing: self.thataway)
        return gnirts
    }
    
    public init(dir: Vector3D)   {
        
        self.thataway = dir
    }
        
}
