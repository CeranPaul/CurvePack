//
//  Line.swift
//  CurvePack
//
//  Created by Paul on 8/12/15.
//  Copyright © 2023 Ceran Digital Media.  See LICENSE.md
//

import Foundation

/// Unbounded and straight.  Contrast with LineSeg.
public struct Line: Equatable {
    
    /// A point to locate the line
    fileprivate var origin: Point3D
    
    /// Which way it extends
    fileprivate var direction: Vector3D
    
    
    /// Build a fresh one - with error checking.
    /// - Parameters:
    ///   - spot:  Origin for the fresh line
    ///   - arrow:  Direction for the fresh line.  Must have unit length
    /// - Throws: 
    ///   - ZeroVectorError if the input Vector3D has no length
    ///   - NonUnitDirectionError for a bad input Vector3D
    /// - See: 'testFidelity' under LineTests
    public init (spot: Point3D, arrow: Vector3D) throws  {
        
        guard !arrow.isZero() else  {throw ZeroVectorError(dir: arrow)}
        guard arrow.isUnit() else  {throw NonUnitDirectionError(dir: arrow)}
        
        self.origin = spot
        self.direction = arrow
    }
    
    
    
    /// Construct one based on a LineSeg
    /// - See: 'testBuildFromSeg' under LineTests
    public init (bar: LineSeg)   {
        
        self.origin = try! bar.pointAt(t: bar.trimParameters.lowerBound)
        
        self.direction = Vector3D(from: bar.getOneEnd(), towards: bar.getOtherEnd(), unit: true)
        
    }
    
    
    /// Simple getter for the origin
    /// - See: 'testFidelity' under LineTests
    public func getOrigin() -> Point3D  {
        
        return self.origin
    }
    
    
    /// Simple getter for the direction
    /// - See: 'testFidelity' under LineTests
    public func getDirection() -> Vector3D  {
        
        return self.direction
    }
    
    
    
    /// Find the position of a point relative to the line and its origin.
    /// The returned perp distance will always be positive.
    /// - Parameters:
    ///   - yonder:  Trial point
    /// - Returns: Tuple of distances
    /// - SeeAlso:  'resolveRelative(Vector)'
    /// - See: 'testResolveRelativePoint' under LineTests
    public func resolveRelative(yonder: Point3D) -> (along: Double, perp: Double)   {
        
        let bridge = Vector3D(from: self.origin, towards: yonder)
        let along = Vector3D.dotProduct(lhs: bridge, rhs: self.direction)
        
        let alongVector = self.direction * along
        let perpVector = bridge - alongVector
        let perp = perpVector.length()
        
        return (along, perp)
    }
    

    /// Find the vector components for the point relative to the line.
    /// - Parameters:
    ///   - yonder:  Target point
    /// - Returns: Tuple of Vector3D
    /// - SeeAlso:  'resolveRelative(Point)'
    public func resolveRelativeVec(yonder: Point3D) -> (along: Vector3D, perp: Vector3D)   {
        
        let bridge = Vector3D(from: self.origin, towards: yonder)
        let distAlong = Vector3D.dotProduct(lhs: bridge, rhs: self.direction)
        
        let along = self.direction * distAlong
        let perp = bridge - along
        
        return (along, perp)
    }
    
    
    /// Find the components of a vector relative to the line
    /// - Parameters:
    ///   - arrow:  Trial Vector
    /// - Returns: Tuple of Vectors
    /// - SeeAlso:  'resolveRelativeVec(Point)'
    public func resolveRelativeVec(arrow: Vector3D) -> (along: Vector3D, perp: Vector3D)   {
        
        let along = Vector3D.dotProduct(lhs: arrow, rhs: self.direction)
        let alongVector = self.direction * along
        
        let perpVector = arrow - alongVector
        
        return (alongVector, perpVector)
    }
    
    
    /// Project a point to the Line
    /// - Parameters:
    ///   - away:  Hanging point
    /// - Returns: Nearest point on line
    /// - See: 'testDropPoint' under LineTests
    public func dropPoint(away: Point3D) -> Point3D   {
        
        if Line.isCoincident(straightA: self, pip: away)   {  return away  }   // Shortcut!
        
        let bridge = Vector3D(from: self.origin, towards: away)
        let along = Vector3D.dotProduct(lhs: bridge, rhs: self.direction)
        let alongVector = self.direction * along
        let onLine = Point3D(base: self.origin, offset: alongVector)
        
        return onLine
    }
    
    
    /// Checks to see if the trial point lies on the line
    /// - Parameters:
    ///   - straightA:  Reference line
    ///   - pip:  Point to test
    /// - Returns: Simple flag
    /// - SeeAlso:  Overloaded ==
    /// - See: 'testIsCoincident' under LineTests
    public static func isCoincident(straightA: Line, pip: Point3D) -> Bool   {
        
        let vectorDiff = straightA.resolveRelativeVec(yonder: pip)
        let flag = vectorDiff.perp.length() < Point3D.Epsilon
        
        return flag
    }
    

    /// Do two lines have the same direction, even with opposite sense?
    /// - Parameters:
    ///   - straightA:  First test line
    ///   - straightB:  Second test line
    /// - Returns: Simple flag
    /// - SeeAlso:  Overloaded ==
    /// - See: 'testIsParallel' under LineTests
    public static func isParallel(straightA: Line, straightB: Line) -> Bool   {
        
        let sameFlag = straightA.getDirection() == straightB.getDirection()
        let oppFlag = Vector3D.isOpposite(lhs: straightA.getDirection(), rhs: straightB.getDirection())
        
        return sameFlag  || oppFlag
    }
    
    
    /// Check two lines  See that the either origin lies on the other line, and
    /// that they have the same direction, even with the opposite sense
    /// - Returns: Simple flag
    /// - SeeAlso:  Overloaded ==
    /// - See: 'testIsCoincidentLine' under LineTests
    public static func isCoincident(straightA: Line, straightB: Line) -> Bool   {
        
        if !Line.isParallel(straightA: straightA, straightB: straightB)   { return false }
        
        if !Line.isCoincident(straightA: straightA, pip: straightB.getOrigin())   { return false }
        
        return true
    }
    
    
    /// Verify that two lines could form a plane.
    /// Will fail if lines are really, really close together.
    /// - Parameters:
    ///   - straightA:  First test line
    ///   - straightB:  Second test line
    /// - Returns: Simple flag
    /// - SeeAlso:  Overloaded ==
    /// - SeeAlso:  Line.isParallel()
    /// - See: 'testIsCoPlanar' under LineTests
    public static func isCoplanar(straightA: Line, straightB: Line) -> Bool   {
        
        if Line.isCoincident(straightA: straightA, straightB: straightB) { return true }   // Shortcut!
        if Line.isParallel(straightA: straightA, straightB: straightB) { return true }
        
        /// Between the origins of the two lines
        let bridgeVector = Vector3D(from: straightA.getOrigin(), towards: straightB.getOrigin(), unit: true)
        
        if bridgeVector.isZero() { return true }   // Having the same origin means that they intersect.
        
        
        if try! Vector3D.isScaled(lhs: bridgeVector, rhs: straightA.getDirection()) { return true }   // The origin of straightB lies on straightA, therefore they intersect, and are coplanar.
        
        if try! Vector3D.isScaled(lhs: bridgeVector, rhs: straightB.getDirection()) { return true }   // The origin of straightA lies on straightB, therefore they intersect, and are coplanar.
        

        var perp1 = try! Vector3D.crossProduct(lhs: straightA.getDirection(), rhs: bridgeVector)
        perp1.normalize()
        
        var perp2 = try! Vector3D.crossProduct(lhs: bridgeVector, rhs: straightB.getDirection())
        perp2.normalize()   
        
        let sameFlag = perp1 == perp2
        let oppFlag = Vector3D.isOpposite(lhs: perp1, rhs: perp2)
        
        return sameFlag  || oppFlag
    }
    
    
    /// Generate a point by intersecting two Lines
    /// - Parameters:
    ///   - straightA:  First test line
    ///   - straightB:  Second test line
    /// - Returns: Common point
    /// - Throws:
    ///     - CoincidentLinesError if the inputs are the same
    ///     - ParallelLinesError if the inputs are parallel
    ///     - NonCoPlanarLinesError if the inputs don't lie in the same plane
    /// - See: 'testIntersectTwo' under LineTests
    public static func intersectTwo (straightA: Line, straightB: Line) throws -> Point3D  {
        
        guard !Line.isCoincident(straightA: straightA, straightB: straightB) else { throw CoincidentLinesError(enil: straightA)}
        
        guard !Line.isParallel(straightA: straightA, straightB: straightB)  else { throw ParallelLinesError(enil: straightA) }
        
        guard Line.isCoplanar(straightA: straightA, straightB: straightB)  else { throw NonCoPlanarLinesError(enilA: straightA, enilB: straightB) }
        
        if straightA.getOrigin() == straightB.getOrigin()   { return straightA.getOrigin() }
        if Line.isCoincident(straightA: straightA, pip: straightB.getOrigin())   { return straightB.getOrigin() }
        if Line.isCoincident(straightA: straightB, pip: straightA.getOrigin())   { return straightA.getOrigin() }
        
        
        let bridgeVector = Vector3D(from: straightA.getOrigin(), towards: straightB.getOrigin())
        
        /// Components (vectors) of the full-length bridge vector relative to Line straightA
        let comps = straightA.resolveRelativeVec(arrow: bridgeVector)
        
        let perpLen = comps.perp.length()   // Do this before the vector gets normalized

        var perpDir = comps.perp
        perpDir.normalize()  // The coincidence checks above should keep the vector from having zero length
        
        let propor = Vector3D.dotProduct(lhs: perpDir, rhs: straightB.getDirection())
        
        /// Length along B to the intersection
        let lengthB =  -1.0 * perpLen / propor;
        
        let alongB = straightB.getDirection() * lengthB;
        
        return Point3D(base: straightB.getOrigin(), offset: alongB);
    }
    
    
    /// Move, rotate, and scale.
    /// - Parameters:
    ///   - arrow: Source Line
    ///   - xirtam: Transform to be applied
    /// - Returns: Fresh line that has been rotated, moved, and scaled
    /// - See: 'testLineTransform' under LineTests
    public func transform(xirtam: Transform) -> Line   {
        
        let freshOrigin = self.getOrigin().transform(xirtam: xirtam)
        let freshDir = self.getDirection().transform(xirtam: xirtam)

        let freshLine = try! Line(spot: freshOrigin, arrow: freshDir)   // Should carry over validity
        
        return freshLine
    }
    
    
}    // End of definition for struct Line



/// Check to see that two have the same definition.
/// - SeeAlso:  isCoincident
/// - See: 'testIEquals' under LineTests
public func == (lhs: Line, rhs: Line) -> Bool   {
    
    let flag1 = lhs.origin == rhs.origin
    
    let flag2 = lhs.direction == rhs.direction
    
    return flag1 && flag2    
}

