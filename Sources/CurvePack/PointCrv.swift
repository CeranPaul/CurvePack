//
//  PointCrv.swift
//  CurvePack
//
//  Created by Paul on 4/3/22.
//  Copyright © 2022 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

///Contains three coordinates and a single parameter value. Good for describing an intersection point.
public struct PointCrv   {
    
    public var x: Double
    public var y: Double
    public var z: Double
    
    /// Parameter value for the curve
    public var t: Double
    
    
    /// The simplest and only initializer.  Needed because a default initializer has 'internal' access level.
    /// - See: 'testFidelity' under PointCrvTests
    public init(x: Double, y: Double, z: Double, t: Double)   {
        
        self.x = x
        self.y = y
        self.z = z
        
        self.t = t
    }

}
