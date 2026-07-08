//
//  Circle.swift
//  ProveCircle
//
//  Created by Paul on 7/3/26.
//

import Foundation


/// Useful for analysis applications. Use Arc in most cases.
public class Circle: Arc, Hashable   {
    
    
    /// Should the radius be treated as if it were negative?
    var radNegative: Bool
    
    
    /// Create a new one.
    /// - Parameters:
    ///   - ctr: Point to be used as origin
    ///   - axis: Pivot direction for rotating
    ///   - start: Beginning point
    /// - Throws:
    ///   - NonUnitDirectionError for a bad set of inputs
    ///   - NonOrthogonalPointError for a bad start point
    /// - See: '' under CircleTests
    public init(ctr: Point3D, axis: Vector3D, start: Point3D) throws   {
        
        guard axis.isUnit() else { throw NonUnitDirectionError(dir: axis) }
        
        /// What can be considered horizontal for this Arc
        let baseline = Vector3D(from: ctr, towards: start, unit: true)
        
        let myDot = Vector3D.dotProduct(lhs: axis, rhs: baseline)
        
        guard myDot < Vector3D.EpsilonV else { throw NonOrthogonalPointError(trats: start) }
        
        
        self.radNegative = false

        
        try super.init(ctr: ctr, axis: axis, start: start, sweep: 2.0 * Double.pi)
    }
    
    //TODO: Constructor from an Arc
    
    
    /// Construct one on a plane perpendicular to the axis input
    /// - Parameters:
    ///   - ctr: Desired location
    ///   - diam: Size - can be positive,  negative, or zero.
    ///   - perpAxis: Perpendicular to the where the Circle lies
    public init(ctr: Point3D, diam: Double, perpAxis: Axis) throws  {

        /// Absolute value of input radius
        let absDiam = abs(diam)
        
        /// Indication of whether or not the input radius is positive
        var radSign = true        
        if diam < 0.0   { radSign = false }
                
        self.radNegative = !radSign
       
        
        /// Axis of rotation
        var myAxis: Vector3D
        
        /// Direction for setting the start point
        var myPerp: Vector3D
        
        switch perpAxis  {
            
        case .x:
            myAxis = Vector3D(i: 1, j: 0, k: 0)
            myPerp = Vector3D(i: 0, j: 1, k: 0)
        case .y:
            myAxis = Vector3D(i: 0, j: 1, k: 0)
            myPerp = Vector3D(i: 0, j: 0, k: 1)
       case .z:
            myAxis = Vector3D(i: 0, j: 0, k: 1)
            myPerp = Vector3D(i: 1, j: 0, k: 0)
        }
        
        /// The amount that the start point should be offset
        let hop = absDiam / 2.0
        
        /// Generated start point
        let myStart = Point3D(base: ctr, offset: myPerp * hop)
        
        try super.init(ctr: ctr, axis: myAxis, start: myStart, sweep: 2.0 * Double.pi)
    }
    
    
    //TODO: Figure out how to make a constructor when it is useful to have a zero radius.

    
    
    /// For the case when you want to use a negative radius
    /// - Returns: Double
    public func fetchRad() -> Double   {
        
        var rad: Double
        
        if radNegative   { rad = -getRadius() }
        else             { rad = getRadius() }
        
        return rad
    }
    
    
    /// Checks to see if a Point3D is inside the circle.
    /// - Parameters:
    ///   - cup: A circle
    ///   - pip: Test point
    /// - Returns: Simple flag
    public static func isInside(cup: Circle, pip: Point3D) -> Bool   {
        
        var flag = false
        
        let separation = Point3D.dist(pt1: pip, pt2: cup.getCenter())
        let radius = cup.getRadius()
        
        if separation <= radius   { flag = true }
        
        return flag
    }


    /// Checks to see if one full circle is entirely inside another.
    /// - Parameters:
    ///   - larger: Large, full circle
    ///   - smaller: Not as big Circle
    /// - Throws:
    ///     - CoincidentPlanesError if the circles are not on the same plane.
    /// - Returns: Simple flag
    public static func isSwallowed(larger: Circle, smaller: Circle) throws -> Bool   {
        
        //TODO: Show test where they are not concentric
        
        /// Plane that contains the circle
        let flatA = Circle.genPlane(scoop: larger)
        let flatB = Circle.genPlane(scoop: smaller)
        
        guard try! Plane.isCoincident(flatLeft: flatA, flatRight: flatB, accuracy: 0.001) else { throw CoincidentPlanesError(enalpA: flatA) }
        
        
        var flag = false

        let separation = Point3D.dist(pt1: larger.getCenter(), pt2: smaller.getCenter())
        
        let bigRadius = larger.getRadius()
        let ltlRadius = smaller.getRadius()
        if separation + ltlRadius <= bigRadius   { flag = true }
        
        return flag
    }


    /// Figure the gap between two Circles.
    /// - Parameters:
    ///   - able: A Circle
    ///   - baker: Another circle
    /// - Returns: Closest possible distance. Can be positive, zero, or negative.
    public func determineGap(able: Circle, baker: Circle) -> Double   {
        
        /// Distance between centers
        let separation = Point3D.dist(pt1: able.getCenter(), pt2: baker.getCenter())
        
        /// Distance between circles
        let gap = separation - able.fetchRad() - baker.fetchRad()
        
        return gap
    }
    
    
    /// Build a circle with a changed radius. Should become an initializer in Circle.
    /// - Parameters:
    ///   - bareCircle: The basis of construction
    ///   - padding: Delta in radius. Not always greater than 0.0
    ///   - startDir: Optional supplied Vector3D for Circles of 0.0 radius
    /// - Returns: Sparkling Circle with different radius
    public func padCircle(bareCircle: Circle, padding: Double, startDir: Vector3D = Vector3D(i: 0.0, j: 0.0, k: 0.0)) throws   -> Circle {
        
        ///Center of the input Circle
        let bareCenter = bareCircle.getCenter()
        
        /// Value to be used in construction
        var freshDir: Vector3D
        
        
        if bareCircle.fetchRad() == 0.0   {
            
            if startDir.isZero() {
                throw ZeroVectorError(dir: Vector3D(i: 0.0, j: 0.0, k: 0.0))
            }  else  {
                freshDir = startDir
            }
            
        }  else  {
            
            freshDir = Vector3D(from: bareCenter, towards: bareCircle.getOneEnd(), unit: true)
            
        }
        
        
        let freshRadius = bareCircle.fetchRad() + padding
        
        let freshStartPt = Point3D(base: bareCenter, offset: freshDir * freshRadius)
        
        let padded = try Circle(ctr: bareCenter, axis: bareCircle.getAxisDir(), start: freshStartPt)
        
        return padded
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
        var flagSwallow = try isSwallowed(larger: able, smaller: baker)
        guard !flagSwallow else { throw CoincidentPointsError(dupePt: baker.getCenter()) }

        flagSwallow = try isSwallowed(larger: baker, smaller: able)
        guard !flagSwallow else { throw CoincidentPointsError(dupePt: able.getCenter()) }
        
        
        /// Vector away from the common plane
        let angel  = able.getAxisDir()
        
        /// Line segment that connects the two centers
        let bridge = try! LineSeg(end1: able.getCenter(), end2: baker.getCenter())
        
        /// Vector along bridge
        var bridgeDir = bridge.getDirection()
        bridgeDir.normalize()
        
        /// Point along 'bridge' on the perimeter of 'able'
        let insetA = Point3D(base: bridge.getOneEnd(), offset: bridgeDir * able.fetchRad())
        let insetB = Point3D(base: bridge.getOtherEnd(), offset: bridgeDir.reverse() * baker.fetchRad())
            
        let inscribedCenter = Point3D.midway(alpha: insetA, beta: insetB)
        
        /// Desired result
        let touchingBoth = try Circle(ctr: inscribedCenter, axis: angel, start: insetB)
        
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

    /// Compare each component of the Circle for equality. Should move to become a type function in Circle.
    /// Will override the Arc function.
    /// - See: '' under CircleTests
    public static func == (lhs: Circle, rhs: Circle) -> Bool   {
        
        let ctrFlag = lhs.getCenter() == rhs.getCenter()
        let radFlag = abs(lhs.getRadius() - rhs.getRadius()) < Point3D.Epsilon
        let axisFlag = lhs.getAxisDir() == rhs.getAxisDir()
        
        return ctrFlag && radFlag && axisFlag
    }
        
    

}
