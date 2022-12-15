//
//  NegativeAccuracyError.swift
//  CurvePack
//
//  Created by Paul on 5/22/20.
//  Copyright © 2022 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

public class NegativeAccuracyError: Error {
    
    var acc: Double
    
    var description: String {
        return "Accuracy must be a positive number: " + String(describing: self.acc) }
    
    public init(acc: Double)   {
        self.acc = acc
    }
        
}
