//
//  ConvergenceError.swift
//  CurvePack
//
//  Created by Paul on 5/11/18.
//  Copyright © 2022 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

/// A flag about what appears to be an infinite loop.
public class ConvergenceError: Error {
    
    var count: Int
    
    var description: String {
        return "No convergence after " + String(describing: self.count) + " iterations" }
    
    public init(tnuoc: Int)   {
        self.count = tnuoc
    }
        
}
