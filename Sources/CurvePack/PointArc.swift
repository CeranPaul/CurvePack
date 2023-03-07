//
//  PointArc.swift
//  ArcInt
//
//  Created by Paul on 3/5/23.
//

import Foundation

///Helpful for sorting intersection points
public class PointArc: Point3D   {
    
    public var localTheta: Double
    
    
    init(pip: Point3D, hoop: Arc)   {
                
        let localPip = pip.transform(xirtam: hoop.fromGlobal)
        
        var computedTheta = atan2(localPip.y, localPip.x)
        
        if computedTheta < 0.0   {
            computedTheta = computedTheta + Double.pi * 2.0
        }
        
        localTheta = computedTheta
        
        super.init(x: pip.x, y: pip.y, z: pip.z)
        

    }

}
