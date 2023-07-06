//
//  PenCurve.swift
//  CurvePack
//
//  Created by Paul on 10/30/15.
//  Copyright © 2023 Ceran Digital Media. All Rights Reserved. See LICENSE.md
//

import Foundation
import CoreGraphics

/// The common data and functions so that each member in a group of curves can be treated the same.
///
/// When in the course of human events it becomes necessary
public protocol PenCurve   {
    
    /// A String that hints at the meaning of the curve
    var usage: String   { get set }
    
    /// Used for error checking
    var trimParameters: ClosedRange<Double>   { get set }

    
    /// Supply the point on the curve for the input parameter value
    func pointAt(t: Double, ignoreTrim: Bool) throws -> Point3D
    
    /// Retrieve the starting end
    func getOneEnd() -> Point3D
    
    /// Retrieve the finishing end
    func getOtherEnd() -> Point3D
    
    /// Figure the volume that encloses the curve.
    /// Must have finite thickness in all three axes.
    func getExtent() -> OrthoVol
    
    /// Report the distance covered along the curve
    func getLength() -> Double
    
    /// Break the curve into small line segments for plotting
    func approximate(allowableCrown: Double) throws -> [Point3D]
    
    /// Find 0 to N points in common with a Line
    func intersect(ray: Line, accuracy: Double) throws -> [PointCrv]
        
    func isCoincident(speck: Point3D, accuracy: Double) throws -> (flag: Bool, param: Double?) 

    mutating func reverse()
    
    func transform(xirtam: Transform) throws -> PenCurve
    
    
    /// Figure how far the point is off the curve, and how far along the curve it is.  Useful for picks  
//    func resolveRelative(speck: Point3D) -> (along: Double, away: Double)
    
    /// Plot the curve.  Your classic example of polymorphism
    func draw(context: CGContext, tform: CGAffineTransform, allowableCrown: Double) throws
    
}
