//
//  Triangle.swift
//  Prove7
//
//  Created by Paul on 6/25/26.
//

import Foundation


/// Not to be confused with a "Facet" of a Mesh
public class Triangle {
    
    var alpha: Point3D
    var beta: Point3D
    var gamma: Point3D
    
    
    /// Simplest initializer
    init(alpha: Point3D, beta: Point3D, gamma: Point3D) {
        
        self.alpha = alpha
        self.beta = beta
        self.gamma = gamma
        
    }
    
    
    
    /// Calculate theamount of surface covered. Assumes that there is never an acute angle
    /// - Returns: Always positive number
    public func getArea() -> Double {
        
        var area: Double = -1.0
        
        let distAB = Point3D.dist(pt1: alpha, pt2: beta)
        let distBC = Point3D.dist(pt1: beta, pt2: gamma)
        let distCA = Point3D.dist(pt1: gamma, pt2: alpha)

        if distAB >= distBC && distAB >= distCA {
            
            /// Direction of this longest LineSeg
            let dir = Vector3D(from: alpha, towards: beta, unit: true)
            let longLine = try! Line(spot: alpha, arrow: dir)
            let local = longLine.resolveRelative(yonder: gamma)
            
            let height = local.perp
            
            area = 0.5 * distAB * height
            
        }
        
        
        if distBC > distAB && distBC >= distCA {
            
            /// Direction of this longest LineSeg
            let dir = Vector3D(from: beta, towards: gamma, unit: true)
            let longLine = try! Line(spot: beta, arrow: dir)
            let local = longLine.resolveRelative(yonder: alpha)
            
            let height = local.perp
            
            area = 0.5 * distBC * height
            
        }
        
        if distCA > distAB && distCA > distBC {
            
            let dir = Vector3D(from: gamma, towards: alpha, unit: true)
            let longLine = try! Line(spot: gamma, arrow: dir)
            let local = longLine.resolveRelative(yonder: beta)
            
            let height = local.perp
            
            area = 0.5 * distCA * height
            
        }
        
        return area
    }
    
    /// Condense a tiny triangle to a point
    func getCentroid() -> Point3D {
        
        let pip = Point3D.avgPoint(pool: [alpha, beta, gamma])
        
        return pip
    }
    
    
    /// Report the longest edge
    func getLongestEdge() -> Double {
        
        var lengths = [Double]()
        
        lengths.append(Point3D.dist(pt1: alpha, pt2: beta))
        lengths.append(Point3D.dist(pt1: beta, pt2: gamma))
        lengths.append(Point3D.dist(pt1: gamma, pt2: alpha))
        
        return lengths.max()!
    }
    
    
}   // Class Triangle
