//
//  PointCrv.swift
//  CurvePack
//
//  Created by Paul on 4/3/22.
//  Copyright © 2022 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

///For describing an intersection point. Inherits three coordinates - adds a single parameter value.
public class PointCrv: Point3D   {
    
    /// Parameter value for the curve
    public var t: Double
    
    
    /// The simplest and only initializer.  Needed because a default initializer has 'internal' access level.
    /// - See: 'testFidelity' under PointCrvTests
    public init(x: Double, y: Double, z: Double, t: Double)   {
        
        self.t = t   // I don't understand why this ordering is appropriate
        
        super.init(x: x, y: y, z: z)
        
    }

}
