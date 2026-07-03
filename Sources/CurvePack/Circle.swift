//
//  Circle.swift
//  ProveCircle
//
//  Created by Paul on 7/3/26.
//

import Foundation


/// Useful for analysis applications. Use Arc in most cases.
public class Circle: Arc, Hashable   {
    
    /// Create a new one.
    /// - Parameters:
    ///   - ctr: Point to be used as origin
    ///   - axis: Pivot direction for rotating
    ///   - start: Beginning point
    /// - Throws:
    ///   - NonUnitDirectionError for a bad set of inputs
    ///   - NonOrthogonalPointError for a bad start point
    ///   - ParameterRangeError for a bad sweep value
    /// - See: 'testFidelityCASS' under ArcTests
    public init(ctr: Point3D, axis: Vector3D, start: Point3D) throws   {
        
        guard axis.isUnit() else { throw NonUnitDirectionError(dir: axis) }
        
        /// What can be considered horizontal for this Arc
        let baseline = Vector3D(from: ctr, towards: start, unit: true)
        
        let myDot = Vector3D.dotProduct(lhs: axis, rhs: baseline)
        
        guard myDot < Vector3D.EpsilonV else { throw NonOrthogonalPointError(trats: start) }
        
        try super.init(ctr: ctr, axis: axis, start: start, sweep: 2.0 * Double.pi)
        
//        self.center = ctr
//        
//        self.axis = axis
//        
//        self.startPt = start
//        
//        self.sweepAngle = 2.0 * Double.pi
//        
//        
//        self.trimParameters = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
//        
//        self.radius = Point3D.dist(pt1: ctr, pt2: start)
//        
//        self.usage = "Ordinary"
//        
//        
//        /// Coordinate system
//        let csys = try CoordinateSystem(origin: self.center, refDirection: baseline, normal: self.axis)
//        
//        self.toGlobal = try! Transform.genToGlobal(csys: csys)
//        
//        self.fromGlobal = Transform.genFromGlobal(csys: csys)
        
    }
    
    
    //TODO: Figure out how to make a constructor when it is useful to have a zero radius.

    
    /// Checks to see if a Point3D is inside the circle.
    /// - Parameters:
    ///   - cup: A circle
    ///   - pip: Test point
    /// - Returns: Simple flag
    public static func isInside(cup: Arc, pip: Point3D) -> Bool   {
        
        var flag = false
        
        let separation = Point3D.dist(pt1: pip, pt2: cup.getCenter())
        let radius = cup.getRadius()
        
        if separation <= radius   { flag = true }
        
        return flag
    }


    /// Checks to see if an Arc (full circle) is fully inside another.
    /// - Parameters:
    ///   - bigUn: Large Arc - treated as a full circle
    ///   - ltlUn: Smaller Arc
    /// - Throws:
    ///     - CoincidentPlanesError if the circles are not on the same plane.
    /// - Returns: Simple flag
    public static func isSwallowed(bigUn: Arc, ltlUn: Arc) throws -> Bool   {
        
        //TODO: Consider adding verification that they are both full circles
        
        /// Plane that contains the circle
        let flatA = Arc.genPlane(scoop: bigUn)
        let flatB = Arc.genPlane(scoop: ltlUn)
        
        guard try! Plane.isCoincident(flatLeft: flatA, flatRight: flatB, accuracy: 0.001) else { throw CoincidentPlanesError(enalpA: flatA) }
        
        var flag = false
        

        let separation = Point3D.dist(pt1: bigUn.getCenter(), pt2: ltlUn.getCenter())
        
        let bigRadius = bigUn.getRadius()
        let ltlRadius = ltlUn.getRadius()
        if separation + ltlRadius <= bigRadius   { flag = true }
        
        return flag
    }


    /// Build Circle that inscribes the two inputs.
    /// - Parameters:
    ///   - able: One circle
    ///   - baker: Another circle
    /// - Throws:
    ///     - ZeroSweepError if either figure isn't a full circle.
    ///     - CoincidentPointsError if the two circles are identical.
    ///     - CoincidentPlanesError if the circles are not on the same plane.
    ///     - CoincidentPointsError if either circle is completely inside the other
    /// - Returns: The inscribing circle
    public static func inscribeTwo(able: Circle, baker: Circle) throws   -> Circle {
        
        //TODO: Test in multiple plane orientations
        
        // Avoid identical circles
        guard able != baker else { throw CoincidentPointsError(dupePt: able.getCenter()) }
              
        
        // Be certain that they are coplanar
        
        /// Plane that contains the circle
        let flatA = Arc.genPlane(scoop: able)
        let flatB = Arc.genPlane(scoop: baker)
        
        guard try! Plane.isCoincident(flatLeft: flatA, flatRight: flatB, accuracy: Point3D.Epsilon) else { throw CoincidentPlanesError(enalpA: flatA) }
        
        
        // Avoid cases where one circle is completely inside the other
        var flagSwallow = try! isSwallowed(bigUn: able, ltlUn: baker)
        guard !flagSwallow else { throw CoincidentPointsError(dupePt: baker.getCenter()) }

        flagSwallow = try! isSwallowed(bigUn: baker, ltlUn: able)
        guard !flagSwallow else { throw CoincidentPointsError(dupePt: able.getCenter()) }
        
        /// Vector away from the common plane
        let angel  = able.getAxisDir()
        
        /// Line segment that connects the two centers
        let bridge = try! LineSeg(end1: able.getCenter(), end2: baker.getCenter())
        
        /// Vector along bridge
        var bridgeDir = bridge.getDirection()
        bridgeDir.normalize()
        
        let insetA = Point3D(base: bridge.getOneEnd(), offset: bridgeDir * able.getRadius())
        let insetB = Point3D(base: bridge.getOtherEnd(), offset: bridgeDir.reverse() * baker.getRadius())
            
        let inscribedCenter = Point3D.midway(alpha: insetA, beta: insetB)
        
        /// Desired result
        let touchingBoth = try! Circle(ctr: inscribedCenter, axis: angel, start: insetB)
        
        return touchingBoth
    }
    
    //TODO: Distribute points evenly around the circumference
    
    //TODO: Function to circumscribe a set of inputs - either Circles, or Point3D's

    


    /// Generate the unique value using Swift 4.2 tools.
    /// Is a required func for a class conforming to protocol Hashable
    ///  Should this be modified to include the axis?
    public func hash(into hasher: inout Hasher)   {
        
        let divX = self.center.x / Point3D.Epsilon
        let myX = Int(round(divX))
        
        let divY = self.center.y / Point3D.Epsilon
        let myY = Int(round(divY))
        
        let divZ = self.center.z / Point3D.Epsilon
        let myZ = Int(round(divZ))
        
        let divRad = self.radius / Point3D.Epsilon
        let myRad = Int(round(divRad))
        
        hasher.combine(myX)
        hasher.combine(myY)
        hasher.combine(myZ)
        hasher.combine(myRad)

    }

    
}
