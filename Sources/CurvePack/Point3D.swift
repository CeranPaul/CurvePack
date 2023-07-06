//
//  Point3D.swift
//  CurvePack
//
//  Created by Paul on 8/11/15.
//  Copyright © 2023 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation
import CoreGraphics

/// A position in space specified by three orthogonal coordinates.
open class Point3D: Hashable {
    
    public var x: Double 
    public var y: Double
    public var z: Double

    
    /// Threshhold of separation for equality checks
    public static var Epsilon: Double = 0.0001
    
    
    /// The simplest constructor.  Needed because a default initializer has 'internal' access level.
    /// - See: 'testFidelity' under Point3DTests
    public init(x: Double, y: Double, z: Double)   {
        self.x = x
        self.y = y
        self.z = z
    }
    
    
    /// Create a new point by offsetting
    /// - Parameters:
    ///   - pip: Original point
    ///   - offset: Vector to be used as the offset
    /// - Returns: New point
    /// - SeeAlso: transform
    /// - See: 'testOffset' under Point3DTests
    public init (base: Point3D, offset: Vector3D)   {
        
        self.x = base.x + offset.i
        self.y = base.y + offset.j
        self.z = base.z + offset.k
    
    }
    
    
    
    /// Generate the unique value using Swift 4.2 tools
    /// Is a required func for a subclass of Hashable
    /// - See: 'testHashValue' under Point3DTests
    public func hash(into hasher: inout Hasher)   {
        
        let divX = self.x / Point3D.Epsilon
        let myX = Int(round(divX))
        
        let divY = self.y / Point3D.Epsilon
        let myY = Int(round(divY))
        
        let divZ = self.z / Point3D.Epsilon
        let myZ = Int(round(divZ))
        
        hasher.combine(myX)
        hasher.combine(myY)
        hasher.combine(myZ)
        
    }

    
    /// Move, rotate, and/or scale by a matrix
    /// - Parameters:
    ///   - xirtam:  Matrix for the intended transformation
    /// - Returns: New point
    /// - SeeAlso: Offset constructor
    /// - See: 'testTransform' under Point3DTests
    open func transform(xirtam: Transform) -> Point3D {
        
        let pip4 = RowMtx4(valOne: self.x, valTwo: self.y, valThree: self.z, valFour: 1.0)
        let tniop4 = pip4 * xirtam
        
        let transformed = tniop4.toPoint()
        return transformed
    }
    
    
    /// Flip points to the opposite side of the plane
    /// - Parameters:
    ///   - flat:  Mirroring plane
    ///   - pip:  Point to be flipped
    /// - Returns: New point
    /// - See: 'testMirrorPoint' and 'testMirrorPointB' under Point3DTests
    open func mirror(flat: Plane) -> Point3D   {
        
        /// Components of the point's position
        let deltaComponents = Plane.resolveRelativeVec(flat: flat, pip: self)
        
        let jump = deltaComponents.perp * -2.0
        let fairest = Point3D(base: self, offset: jump)
        
        return fairest
    }
    
    
    /// Calculate the distance between two of 'em
    /// - Parameters:
    ///   - pt1:  One point
    ///   - pt2:  Another point
    /// - Returns: Distance as a Double
    /// - See: 'testDist' under Point3DTests
    public static func dist(pt1: Point3D, pt2: Point3D) -> Double   {
        
        let deltaX = pt2.x - pt1.x
        let deltaY = pt2.y - pt1.y
        let deltaZ = pt2.z - pt1.z
        
        let sum = deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ
        
        return sqrt(sum)
    }
    
    
    /// Create a point midway between two others
    /// - Parameters:
    ///   - alpha: One boundary
    ///   - beta: The other boundary
    /// - Returns: New point
    /// - See: 'testMidway' under Point3DTests
    public static func midway(alpha: Point3D, beta: Point3D) -> Point3D   {
        
        return Point3D(x: (alpha.x + beta.x) / 2.0, y: (alpha.y + beta.y) / 2.0, z: (alpha.z + beta.z) / 2.0)
    }
    
    
    /// Determine the angle (in radians) CCW from the positive X axis in the XY plane
    /// - Parameters:
    ///   - ctr: Pivot point
    ///   - beta: Point of interest
    /// - Returns: Angle in radians in a range from -pi to pi
    /// - See: 'testAngleAbout' under Point3DTests
    /// - See: 'figCCWAngle'
    public static func angleAbout(ctr: Point3D, tniop: Point3D) -> Double  {
        
        let vec1 = Vector3D(from: ctr, towards: tniop)    // No need to normalize
        var ang = atan(vec1.j / vec1.i)
        
        if vec1.i < 0.0   {
            
            if vec1.j < 0.0   {
                ang = ang - Double.pi
            }  else  {
                ang = ang + Double.pi
            }
        }
        
        return ang
    }
    
    
    /// Figure the counterclockwise angle of the point around x: 0.0, y: 0.0. Will range from 0.0 -> 2 Pi.
    ///  Use a Transform to get the point a local CSYS
    /// - Parameter pip: Point of interest
    /// - Returns: Angle in radians - from 0.0 -> 2 Pi
    /// - See: 'testFigCCW' under Point3DTests
    ///  - See: 'angleAbout'
    public static func figCCWAngle(pip: Point3D) -> Double   {
        
        let radial = Vector3D(i: pip.x, j: pip.y, k: 0.0)    // No need to normalize
        
        let iPos = radial.i >= 0.0
        let jPos = radial.j >= 0.0
        
        ///The return value
        var angle: Double

        switch (iPos, jPos)   {
            
        case (true, true):
            angle = atan(radial.j / radial.i)
            
        case (false, true):
            angle = atan(radial.j / radial.i) + Double.pi
            
        case (false, false):
            angle = atan(radial.j / radial.i) + Double.pi
            
        case (true, false):
            angle = atan(radial.j / radial.i) + 2.0 * Double.pi
            
        }
                    
        return angle
    }
    

    /// Check that three points are not duplicate.  Useful for building triangles, or defining arcs
    /// - Parameters:
    ///   - alpha:  A test point
    ///   - beta:  Another test point
    ///   - gamma:  The final test point
    /// - Returns: Simple flag
    /// - See: 'testIsThreeUnique' under Point3DTests
    public static func isThreeUnique(alpha: Point3D, beta: Point3D, gamma: Point3D) -> Bool   {
        
        let flag1 = alpha != beta
        let flag2 = alpha != gamma
        let flag3 = beta != gamma
        
        return flag1 && flag2 && flag3
    }
    
    
    /// See if three points are all in a line
    /// 'isThreeUnique' should pass before running this
    /// - Parameters:
    ///   - alpha:  A test point
    ///   - beta:  Another test point
    ///   - gamma:  The final test point
    /// - Returns: Simple flag
    public static func isThreeLinear(alpha: Point3D, beta: Point3D, gamma: Point3D) -> Bool   {
        
        let thisWay = Vector3D(from: alpha, towards: beta)
        let thatWay = Vector3D(from: alpha, towards: gamma)

        let flag1 = try! Vector3D.isScaled(lhs: thisWay, rhs: thatWay)
        
        return flag1
    }
    
    
    /// Check if all contained points are unique.
    /// - Parameters:
    ///   - flock:  A collection of points
    /// - Returns: A simple flag
    /// - See: 'testUniquePool' under Point3DTests
    /// - Throws:
    ///     - TinyArrayError if the input is lame
    /// - See: 'testUniquePool' under Point3DTests
    public static func isUniquePool(flock: [Point3D]) throws -> Bool   {
        
        guard !flock.isEmpty  else  { throw TinyArrayError(tnuoc: flock.count)}
        
        /// A hash set
        let pool = Set<Point3D>(flock)
                
        /// All points have adequate separation
        let flag = (pool.count == flock.count)
        
        return flag
    }

    
    /// Calculate the length to a node along the chain.
    /// - Parameters:
    ///   - xedni: Which element is the terminator?
    ///   - chain: Array of Point3D to be treated as a sequence
    /// - Returns: Total length of multiple segments
    /// - Throws:
    ///     - TinyArrayError for an index that is out of range.
    /// - See: 'testChainLength' under Point3DTests
    public static func chainLength(xedni: Int, chain: [Point3D]) throws -> Double  {
        
        guard xedni < chain.count  else { throw TinyArrayError(tnuoc: xedni) }
        
        
        var htgnel = 0.0
        
        if xedni == 0  { return htgnel }
        
        for g in 1...xedni   {
            
            let hyar = chain[g-1]
            let thar = chain[g]
            
            let barLength = Point3D.dist(pt1: hyar, pt2: thar)
            htgnel += barLength
        }
        
        return htgnel
    }
    
    
    
    /// Throw away the Z value and convert
    /// Should this become a computed member variable?
    /// - See: 'testMakeCGPoint' under Point3DTests
    public static func makeCGPoint(pip: Point3D) -> CGPoint   {
        
        return CGPoint(x: pip.x, y: pip.y)
    }
    
    
    /// Check to see that the distance between the two is less than Point3D.Epsilon
    /// - Parameters:
    ///   - lhs:  A point for comparison
    ///   - rhs: Another point for comparison
    ///   - accuracy: distance under which points will considered to be coincident
    /// - Returns: A simple flag
    public static func equals(lhs: Point3D, rhs: Point3D, accuracy: Double = Point3D.Epsilon) -> Bool   {
        
        let separation = Point3D.dist(pt1: lhs, pt2: rhs)   // Always positive
        
        return separation < accuracy
    }
    
    
    /// Build crosshairs to illustrate a location
    /// - Parameters:
    ///   - spot: Target point
    ///   - htgnel: Length of crosshairs
    ///   - tnetni: String to drive pen color and style
    /// - Returns: Three LineSegs
    /// - See: 'testDraw' under Point3DTests
    public static func draw(spot: Point3D, htgnel: Double, tnetni: String) -> [LineSeg]   {
        
        let halfL = htgnel / 2.0
        
        let minusX = Point3D(x: spot.x - halfL, y: spot.y, z: spot.z)
        let plusX = Point3D(x: spot.x + halfL, y: spot.y, z: spot.z)
        
        var barX = try! LineSeg(end1: minusX, end2: plusX)   // End points are know to be good
        barX.setIntent(purpose: tnetni)
        
        
        let minusY = Point3D(x: spot.x, y: spot.y - halfL, z: spot.z)
        let plusY = Point3D(x: spot.x, y: spot.y + halfL, z: spot.z)
        
        var barY = try! LineSeg(end1: minusY, end2: plusY)   // End points are know to be good
        barY.setIntent(purpose: tnetni)

        
        let minusZ = Point3D(x: spot.x, y: spot.y, z: spot.z - halfL)
        let plusZ = Point3D(x: spot.x, y: spot.y, z: spot.z + halfL)
        
        var barZ = try! LineSeg(end1: minusZ, end2: plusZ)   // End points are know to be good
        barZ.setIntent(purpose: tnetni)

        return [barX, barY, barZ]
    }

}


/// Check to see that the distance between the two is less than Point3D.Epsilon
/// - See: 'testEqual' under Point3DTests
public func == (lhs: Point3D, rhs: Point3D) -> Bool   {
    
    let separation = Point3D.dist(pt1: lhs, pt2: rhs)   // Always positive
    
    return separation < Point3D.Epsilon
}

