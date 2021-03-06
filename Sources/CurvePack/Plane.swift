//
//  Plane.swift
//  CurvePack
//
//  Created by Paul on 8/11/15.
//  Copyright © 2022 Ceran Digital Media. All rights reserved.
//

import Foundation

/// Unbounded flat surface
public struct Plane: Equatable   {
    
    /// A point to locate the plane
    private var location: Point3D
    
    /// A vector perpendicular to the plane
    private var normal: Vector3D
    
    
    /// Records parameters and checks to see that the normal is a legitimate vector
    /// - Parameters:
    ///   - alpha:  Origin for the fresh plane
    ///   - arrow:  Unit vector that the plane will be perpendicular to
    /// - Throws:
    ///   - ZeroVectorError for any bad input vector
    ///   - NonUnitDirectionError for a different kind of badness
    /// - See: 'testFidelity' under PlaneTests
    public init(spot: Point3D, arrow: Vector3D) throws  {
        
        guard !arrow.isZero()  else  { throw ZeroVectorError(dir: arrow) }
        guard arrow.isUnit()  else  { throw NonUnitDirectionError(dir: arrow) }
        
        self.location = spot
        self.normal = arrow
        
    }
    
    
    /// Construct a plane from three points
    /// - Parameters:
    ///   - alpha:  First input point and origin of the fresh plane
    ///   - beta:  Second input point
    ///   - gamma:  Third input point
    /// - Returns: Fresh plane
    /// - Throws: CoincidentPointsError for duplicate or linear inputs
    /// - See: 'testInitPts' under PlaneTests
    public init(alpha: Point3D, beta: Point3D, gamma: Point3D) throws   {
        
        guard Point3D.isThreeUnique(alpha: alpha, beta: beta, gamma: gamma)  else  { throw CoincidentPointsError(dupePt: alpha) }
        
        // TODO: Come up with a better error type. Should ArcPointsError be changed to apply here?
        guard !Point3D.isThreeLinear(alpha: alpha, beta: beta, gamma: gamma)  else  { throw CoincidentPointsError(dupePt: alpha) }
        
        
        self.location = alpha
        
        let thisWay = Vector3D.built(from: alpha, towards: beta)
        let thatWay = Vector3D.built(from: alpha, towards: gamma)
        
        var perpTo = try! Vector3D.crossProduct(lhs: thisWay, rhs: thatWay)   // The 'linear' guard statement protects this
        perpTo.normalize()
        
        self.normal = perpTo

    }
    
    
    /// Construct a plane from a line and point
    /// - Parameters:
    ///   - straightA:  Input line
    ///   - pip: Off line location
    /// - Throws:
    ///   - CoincidentPointsError for pip being on straightA
    /// - Returns: Fresh plane
    public init(straightA: Line, pip: Point3D) throws   {
        
        guard !Line.isCoincident(straightA: straightA, pip: pip)  else  { throw CoincidentPointsError(dupePt: pip) }
        
        var between = straightA.resolveRelativeVec(yonder: pip)
        between.perp.normalize()
        
        var planeNormal = try! Vector3D.crossProduct(lhs: straightA.getDirection(), rhs: between.perp)   // Protected by the guard statement
        planeNormal.normalize()
        
        self.location = pip
        self.normal = planeNormal
    }

    
    /// Construct a plane from two lines
    /// - Parameters:
    ///   - straightA:  First input line
    ///   - straightB:  Second input line
    /// - Throws:
    ///   - CoincidentLinesError for duplicate  inputs
    ///   - NonCoPlanarLinesError for bad inputs
    /// - Returns: Fresh plane
    /// - See: 'testBuildTwoLines' under PlaneTests
    public init(straightA: Line, straightB: Line) throws   {
        
        guard !Line.isCoincident(straightA: straightA, straightB: straightB)  else  { throw CoincidentLinesError(enil: straightA) }
        
        guard Line.isCoplanar(straightA: straightA, straightB: straightB)  else  { throw NonCoPlanarLinesError(enilA: straightA, enilB: straightB) }
        
        
        let freshFlat = try! Plane(straightA: straightA, pip: straightB.getOrigin())   // Protected by the guard statements
        
        self.location = freshFlat.getLocation()
        self.normal = freshFlat.getNormal()
        
    }

    
    /// A getter for the point defining the plane
    /// - See: 'testLocationGetter' under PlaneTests
    public func getLocation() -> Point3D   {
        
        return self.location
    }
    
    /// A getter for the vector defining the plane
    /// - See: 'testNormalGetter' under PlaneTests
    public func getNormal() -> Vector3D   {
        
        return self.normal
    }
    
    
    /// Build orthogonal vectors from the origin of the plane to the point
    /// - Parameters:
    ///   - flat: Reference plane
    ///   - pip:  Point of interest
    /// - Returns: Tuple of Vectors
    /// - See: 'testResolveRelative' under PlaneTests
    public static func resolveRelativeVec(flat: Plane, pip: Point3D) -> (inPlane: Vector3D, perp: Vector3D)   {
        
        //TODO: Test the way of dealing with a point that is coincident with the origin, or lies on the plane.
        
        /// Vectors on the plane, and perpendicular to it
        var inPlane, perp: Vector3D
        
        if pip == flat.getLocation()   {
            inPlane = Vector3D(i: 0.0, j: 0.0, k: 0.0)
            perp = Vector3D(i: 0.0, j: 0.0, k: 0.0)
            
            return (inPlane, perp)
        }
        
        let bridge = Vector3D.built(from: flat.getLocation(), towards: pip)
        
        let amountOut = Vector3D.dotProduct(lhs: bridge, rhs: flat.getNormal())
        perp = flat.normal * amountOut
        
        inPlane = bridge - perp
        
        return (inPlane, perp)
    }
    
    
    /// Flip points to the opposite side of the plane
    /// - Parameters:
    ///   - flat:  Mirroring plane
    ///   - pip:  Point to be flipped
    /// - Returns: New point
    /// - See: 'testMirrorPoint' under PlaneTests
    public static func mirror(flat: Plane, pip: Point3D) -> Point3D   {
        
        /// Components of the point's position
        let deltaComponents = Plane.resolveRelativeVec(flat: flat, pip: pip)
        
        let jump = deltaComponents.perp * -2.0
        let fairest = Point3D.offset(pip: pip, jump: jump)
        
        return fairest
    }
    
    
    /// Mirror a Vector3D
    /// - Parameters:
    ///   - flat:  Mirroring plane
    ///   - arrow:  Vector to be flipped
    /// - Returns: New Vector3D
    /// - See: 'testMirrorVector' under PlaneTests
    public static func mirror(flat: Plane, arrow: Vector3D) -> Vector3D   {
        
        let proportion = Vector3D.dotProduct(lhs: flat.normal, rhs: arrow)
        let along = flat.normal * proportion
        let inPlane = arrow - along
        
        let reflect = along * -1.0 + inPlane
        
        return reflect
    }
    
    
    /// Check to see that the line direction is perpendicular to the normal
    /// - Parameters:
    ///   - flat:  Reference plane
    ///   - enil:  Line for testing
    /// - Returns: Simple flag
    /// - See: 'testIsParallelLine' under PlaneTests
    public static func isParallel(flat: Plane, enil: Line) -> Bool   {
        
        let projection = Vector3D.dotProduct(lhs: enil.getDirection(), rhs: flat.normal)
        
        return abs(projection) < Vector3D.EpsilonV
    }
    
    
    /// Does the argument point lie on the plane?
    /// - Parameters:
    ///   - flat:  Plane for testing
    ///   - pip:  Point for testing
    ///   - accuracy: Distance under which a point will considered to be coincident
    /// - Throws:
    ///   - NegativeAccuracyError for bad 'accuracy' parameter
    /// - Returns: Simple flag
    /// - See: 'testIsCoincident' under PlaneTests
    public static func isCoincident(flat: Plane, pip:  Point3D, accuracy: Double = Point3D.Epsilon) throws -> Bool  {
        
        guard accuracy > 0.0 else { throw NegativeAccuracyError(acc: accuracy) }
            
        if pip == flat.getLocation()   {  return true  }   // Shortcut!
        
        
        let bridge = Vector3D.built(from: flat.location, towards: pip)
        
        // This can be positive, negative, or zero
        let distanceOffPlane = Vector3D.dotProduct(lhs: bridge, rhs: flat.getNormal())
        
        return  abs(distanceOffPlane) < accuracy
    }
    
    
    /// Check to see that the line is parallel to the plane, and lies on it
    /// - Parameters:
    ///   - enalp:  Reference plane
    ///   - enil:  Line for testing
    ///   - accuracy: Distance under which the Line will considered to be coincident
    /// - Throws:
    ///   - NegativeAccuracyError for bad 'accuracy' parameter
    /// - Returns: Simple flag
    /// - See: 'testIsCoincidentLine' under PlaneTests
    public static func isCoincident(flat: Plane, enil: Line, accuracy: Double = Point3D.Epsilon) throws -> Bool  {
        
        guard accuracy > 0.0 else { throw NegativeAccuracyError(acc: accuracy) }
            
        let flag1 = self.isParallel(flat: flat, enil: enil)
        let flag2 = try! Plane.isCoincident(flat: flat, pip: enil.getOrigin(), accuracy: accuracy)   // Protected by the guard statement
        
        return flag1 && flag2
    }
    
    
    /// Planes are parallel, and rhs location lies on lhs.
    /// Normals may be opposite, and will still return true.
    /// - Parameters:
    ///   - lhs:  One plane for testing
    ///   - rhs:  Another plane for testing
    ///   - accuracy: Distance under which planes will considered to be coincident
    /// - Throws:
    ///   - NegativeAccuracyError for bad 'accuracy' parameter
    /// - Returns: Simple flag
    /// - SeeAlso:  isParallel and ==
    /// - See: 'testIsCoincidentPlane' under PlaneTests
    public static func isCoincident(flatLeft: Plane, flatRight: Plane, accuracy: Double = Point3D.Epsilon) throws -> Bool  {
        
        guard accuracy > 0.0 else { throw NegativeAccuracyError(acc: accuracy) }
            
        let flag1 = try! Plane.isCoincident(flat: flatLeft, pip: flatRight.location, accuracy: accuracy)   // Protected by the guard statement
        let flag2 = Plane.isParallel(lhs: flatLeft, rhs: flatRight)
        
        return flag1 && flag2
    }
    
    
    /// Are the normals either parallel or opposite?
    /// - Parameters:
    ///   - lhs:  One plane for testing
    ///   - rhs:  Another plane for testing
    /// - Returns: Simple flag
    /// - SeeAlso:  isCoincident and ==
    /// - See: 'testIsParallelPlane' under PlaneTests
    public static func isParallel(lhs: Plane, rhs: Plane) -> Bool   {
        
        return lhs.normal == rhs.normal || Vector3D.isOpposite(lhs: lhs.normal, rhs: rhs.normal)
    }
    

    
    /// Construct a parallel plane offset some distance.
    /// - Parameters:
    ///   - base:  The reference plane
    ///   - offset:  Desired separation. Can be positive or negative.
    ///   - reverse:  Flip the normal, or not
    /// - Returns: Fresh plane that has separation
    /// - See: 'testBuildParallel' under PlaneTests
    public static func buildParallel(base: Plane, offset: Double, reverse: Bool) -> Plane  {
    
        let jump = base.normal * offset    // Offset could be a negative number
        
        let origPoint = base.location
        let newLoc = Point3D.offset(pip: origPoint, jump: jump)
        
        
        var newNorm = base.normal
        
        if reverse   {
            newNorm = base.normal * -1.0
        }
        
        let sparkle =  try! Plane(spot: newLoc, arrow: newNorm)   // Allowable because the new normal mimics the original
    
        return sparkle
    }
    
    
    /// Construct a new plane perpendicular to an existing plane, and through a line on that plane
    /// Normal could be the opposite of what you hoped for
    /// - Parameters:
    ///   - enil:  Location for a fresh plane
    ///   - enalp:  The reference plane
    /// - Returns: Fresh plane
    /// - Throws:
    ///   - CoincidentLinesError if line doesn't lie on the plane
    ///   - NegativeAccuracyError for bad 'accuracy' parameter
    /// - See: 'testBuildPerpThruLine' under PlaneTests
    public static func buildPerpThruLine(enil: Line, enalp: Plane, accuracy: Double = Point3D.Epsilon) throws -> Plane   {
        
        guard accuracy > 0.0 else { throw NegativeAccuracyError(acc: accuracy) }
            
        // TODO:  Better error type
        guard try Plane.isCoincident(flat: enalp, enil: enil, accuracy: accuracy)  else  { throw CoincidentLinesError(enil: enil) }
        
        let newDir = try! Vector3D.crossProduct(lhs: enil.getDirection(), rhs: enalp.normal)
        
        let sparkle = try Plane(spot: enil.getOrigin(), arrow: newDir)
        
        return sparkle
    }
    
    
    /// Generate a point by intersecting a line and a plane
    /// - Parameters:
    ///   - enil:  Line of interest
    ///   - enalp:  Flat surface to hit
    /// - Throws:
    ///   - ParallelError if the input Line is parallel to the plane
    ///   - NegativeAccuracyError for bad 'accuracy' parameter
    /// - See: 'testIntersectLinePlane' under PlaneTests
    public static func intersectLinePlane(enil: Line, enalp: Plane, accuracy: Double = Point3D.Epsilon) throws -> Point3D {
        
        // Bail if the line is parallel to the plane
        guard !Plane.isParallel(flat: enalp, enil: enil) else { throw ParallelError(enil: enil, enalp: enalp) }
        
        if try Plane.isCoincident(flat: enalp, pip: enil.getOrigin(), accuracy: accuracy)  { return enil.getOrigin() }    // Shortcut!
        
        
        // Resolve the line direction into components normal to the plane and in plane
        let lineNormMag = Vector3D.dotProduct(lhs: enil.getDirection(), rhs: enalp.getNormal())
        let lineNormComponent = enalp.getNormal() * lineNormMag
        let lineInPlaneComponent = enil.getDirection() - lineNormComponent
        
        
        let projectedLineOrigin = try Plane.projectToPlane(pip: enil.getOrigin(), enalp: enalp)
        
        let drop = Vector3D.built(from: enil.getOrigin(), towards: projectedLineOrigin, unit: true)
        
        let closure = Vector3D.dotProduct(lhs: enil.getDirection(), rhs: drop)
        
        
        let separation = Point3D.dist(pt1: projectedLineOrigin, pt2: enil.getOrigin())
        
        var factor = separation / lineNormComponent.length()
        
        if closure < 0.0 { factor = factor * -1.0 }   // Dependent on the line origin's position relative to
        //  the plane normal
        
        let inPlaneOffset = lineInPlaneComponent * factor
        
        return Point3D.offset(pip: projectedLineOrigin, jump: inPlaneOffset)
    }
    
    
    /// Construct a line by intersecting two planes
    /// - Parameters:
    ///   - flatA:  First plane
    ///   - flatB:  Second plane
    /// - Throws:
    ///   - ParallelPlanesError if the inputs are parallel
    ///   - CoincidentPlanesError if the inputs are coincident
    ///   - NegativeAccuracyError for bad 'accuracy' parameter
    /// - See: 'testIntersectPlanes' under PlaneTests
    public static func intersectPlanes(flatA: Plane, flatB: Plane, accuracy: Double = Point3D.Epsilon) throws -> Line   {
        
        guard accuracy > 0.0 else { throw NegativeAccuracyError(acc: accuracy) }
            
           // This goes first to provide a better error message.
        let flag1 = try Plane.isCoincident(flatLeft: flatA, flatRight: flatB, accuracy: accuracy)
        guard !flag1  else  { throw CoincidentPlanesError(enalpA: flatA) }
        
        guard !Plane.isParallel(lhs: flatA, rhs: flatB)  else  { throw ParallelPlanesError(enalpA: flatA) }
        
        
        /// Direction of the intersection line
        var lineDir = try! Vector3D.crossProduct(lhs: flatA.getNormal(), rhs: flatB.getNormal())
        lineDir.normalize()   // Checks in crossProduct should keep this from being a zero vector
        
        /// Vector on plane B that is perpendicular to the intersection line
        var perpInB = try! Vector3D.crossProduct(lhs: lineDir, rhs: flatB.getNormal())
        perpInB.normalize()   // Checks in crossProduct should keep this from being a zero vector
        
        // The ParallelPlanesError or CoincidentPlanesError should be avoided by the guard statements
        
        let lineFromCenterB =  try Line(spot: flatB.getLocation(), arrow: perpInB)  // Can be either towards flatA,
        // or away from it
        
        let intersectionPoint = try Plane.intersectLinePlane(enil: lineFromCenterB, enalp: flatA)
        let common = try Line(spot: intersectionPoint, arrow: lineDir)
        
        return common
    }

    
    /// Drop the point in the direction opposite of the normal
    /// - Parameters:
    ///   - pip:  Point to be projected
    ///   - enalp:  Flat surface to hit
    /// - Throws:
    ///   - NegativeAccuracyError for bad 'accuracy' parameter
    /// - Returns: Closest point on plane
    /// - See: 'testProjectToPlane' under PlaneTests
    public static func projectToPlane(pip: Point3D, enalp: Plane, accuracy: Double = Point3D.Epsilon) throws -> Point3D  {
        
        if try Plane.isCoincident(flat: enalp, pip: pip, accuracy: accuracy) {return pip }    // Shortcut!
        
        let planeCenter = enalp.getLocation()   // Referred to multiple times
        
        let bridge = Vector3D.built(from: planeCenter, towards: pip)   // Not normalized
        
        // This can be positive, or negative
        let distanceOffPlane = Vector3D.dotProduct(lhs: bridge, rhs: enalp.getNormal())
        
        // Resolve "bridge" into components that are perpendicular to the plane and are parallel to it
        let bridgeNormComponent = enalp.getNormal() * distanceOffPlane
        let bridgeInPlaneComponent = bridge - bridgeNormComponent
        
        return Point3D.offset(pip: planeCenter, jump: bridgeInPlaneComponent)   // Ignore the component normal to the plane
    }
        
}


/// Check for them being identical. Overloading of the global function.
/// - SeeAlso:  Plane.isParallel and Plane.isCoincident
/// - See: 'testEquals' under PlaneTests
public func == (lhs: Plane, rhs: Plane) -> Bool   {
    
    let sameDir = lhs.getNormal() == rhs.getNormal()    // Do they have the same direction?
    
    let sameLoc = lhs.getLocation() == rhs.getLocation()    // Do they have identical locations?
    
    return sameDir && sameLoc
}
