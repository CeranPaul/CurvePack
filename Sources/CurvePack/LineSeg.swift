//
//  LineSeg.swift
//  CurvePack
//
//  Created by Paul on 10/28/15.
//  Copyright © 2022 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation
import CoreGraphics

/// A wire between two points.
public struct LineSeg: PenCurve, Equatable {
    
    
    // End points
    fileprivate var endAlpha: Point3D   // Private access to limit modification
    fileprivate var endOmega: Point3D
        
    /// The String that hints at the meaning of the curve
    public var usage: String
    
    public var trimParameters: ClosedRange<Double>
    
    
    /// Build a line segment from two points
    /// - Parameters:
    ///   - end1:  One point
    ///   - end2:  Other point
    /// - Throws: CoincidentPointsError
    /// - See: 'testFidelity' under LineSegTests
    public init(end1: Point3D, end2: Point3D) throws {
        
        guard end1 != end2 else { throw CoincidentPointsError(dupePt: end1)}
        
        self.endAlpha = end1
        self.endOmega = end2
        
        
        self.usage = "Ordinary"
        
        self.trimParameters = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
    }
    
    
    /// Fetch the location of an end
    /// - SeeAlso: 'getOtherEnd()'
    /// - See: 'testFidelity' under LineSegTests
    public func getOneEnd() -> Point3D   {
        return try! pointAt(t: self.trimParameters.lowerBound)
    }
    
    /// Fetch the location of the opposite end
    /// - SeeAlso: 'getOneEnd()'
    /// - See: 'testFidelity' under LineSegTests
    public func getOtherEnd() -> Point3D   {
        return try! pointAt(t: self.trimParameters.upperBound)
    }
    
    
    /// Attach new meaning to the curve
    /// - See: 'testSetIntent' under LineSegTests
    public mutating func setIntent(purpose: String)   {
        
        self.usage = purpose
    }
    
    
    /// Calculate length.
    /// Part of PenCurve protocol.
    /// - Returns: Distance between the endpoints
    /// - See: 'testLength' under LineSegTests
    public func getLength() -> Double   {
        return Point3D.dist(pt1: self.endAlpha, pt2: self.endOmega)
    }
    
    
    /// Create a unit vector showing direction.
    /// - Returns: Unit vector
    public func getDirection() -> Vector3D   {
        
        return Vector3D.built(from: self.endAlpha, towards: self.endOmega, unit: true)
    }
    
    
    /// Find the point along this line segment specified by the parameter 't'
    /// Checks that  0 < t < 1
    /// - Throws:
    ///     - ParameterRangeError if the input is lame
    /// - Returns: New Point3D
    /// - See: 'testPointAt' under LineSegTests
    public func pointAt(t: Double, ignoreTrim: Bool = false) throws -> Point3D  {
        
        if ignoreTrim   {
            
            /// The entire possible parameter range.
            let wholeSheBang = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
            
            guard wholeSheBang.contains(t) else { throw ParameterRangeError(parA: t) }
            
        }  else  {
            guard self.trimParameters.contains(t) else { throw ParameterRangeError(parA: t) }
        }
        

        let wholeVector = Vector3D.built(from: self.endAlpha, towards: self.endOmega, unit: false)
        
        let scaled = wholeVector * t
        
        let spot = Point3D.offset(pip: self.endAlpha, jump: scaled)
        
        return spot
    }
    
    
    /// Return the tangent vector, which won't depend on the input parameter.
    /// Part of PenCurve protocol.
    /// Some notations show "u" as the parameter, instead of "t"
    /// - Parameters:
    ///   - t:  Parameter value
    /// - Throws:
    ///     - ParameterRangeError if the input is lame
    /// - Returns: Non-normalized vector
    /// - See: 'testTangent' under LineSegTests
    public func tangentAt(t: Double, ignoreTrim: Bool = false) throws -> Vector3D   {
        
        if ignoreTrim   {
            
            /// The entire possible parameter range.
            let wholeSheBang = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
            
            guard wholeSheBang.contains(t) else { throw ParameterRangeError(parA: t) }
            
        }  else  {
            guard self.trimParameters.contains(t) else { throw ParameterRangeError(parA: t) }
        }
        
        let along = Vector3D.built(from: self.endAlpha, towards: self.endOmega)
        return along
    }
    
    

//TODO: Would be good to have an explicit test for this function.
    /// Get the box that bounds the curve
    /// - Returns: Brick aligned to the CSYS
    public func getExtent() -> OrthoVol  {
        
        return try! OrthoVol(corner1: self.endAlpha, corner2: self.endOmega)
    }
    
    
    /// Flip the order of the end points  Used to align members of a Perimeter
    /// - See: 'testReverse' under LineSegTests
    public mutating func reverse() -> Void  {
        
        let bubble = self.endAlpha
        self.endAlpha = self.endOmega
        self.endOmega = bubble
        
        self.trimParameters = ClosedRange<Double>(uncheckedBounds: (lower: 1.0 - self.trimParameters.upperBound, upper: 1.0 - self.trimParameters.lowerBound))
        
    }
    
    
    /// Use a different portion of the curve
    /// - Parameters:
    ///   - lowParameter:  New parameter value.  Checked to be 0 < t < 1 and less than the upper bound.
    /// - Throws:
    ///     - ParameterRangeError if the input is lame
    mutating public func trimFront(lowParameter: Double) throws   {
        
        guard lowParameter >= 0.0  else  { throw ParameterRangeError(parA: lowParameter)}
        
        guard lowParameter < self.trimParameters.upperBound  else { throw ParameterRangeError(parA: lowParameter) }
        
        
        self.trimParameters = ClosedRange<Double>(uncheckedBounds: (lower: lowParameter, upper: self.trimParameters.upperBound))
        
    }
    
    
    /// Use a different portion of the curve
    /// - Parameters:
    ///   - highParameter:  New parameter value.  Checked to be 0 < t < 1 and less than the upper bound.
    /// - Throws:
    ///     - ParameterRangeError if the input is lame
    mutating public func trimBack(highParameter: Double) throws   {
        
        guard highParameter <= 1.0  else  { throw ParameterRangeError(parA: highParameter)}
        
        guard highParameter > self.trimParameters.lowerBound  else { throw ParameterRangeError(parA: highParameter) }
        
        
        self.trimParameters = ClosedRange<Double>(uncheckedBounds: (lower: self.trimParameters.lowerBound, upper: highParameter ))
        
    }
    
    
    /// Create a trimmed version
    /// - Parameters:
    ///   - stub:  New terminating point
    ///   - keepNear: Retain the near or far remnant?
    /// - Warning:  No checks are made to see that stub lies on the segment
    /// - Returns: A new LineSeg
    /// - See: 'testClipTo' under LineSegTests
    public func clipTo(stub: Point3D, keepNear: Bool) -> LineSeg   {
        
        var freshSeg: LineSeg
        
        if keepNear   {
            freshSeg = try! LineSeg(end1: self.getOneEnd(), end2: stub)
        }  else  {
            freshSeg = try! LineSeg(end1: stub, end2: self.getOtherEnd())
        }
        
        return freshSeg
    }
    
    
    /// Find the position of a point relative to the LineSeg
    /// - Parameters:
    ///   - speck:  Point of interest
    /// - Returns: Tuple of vectors - one along the seg, other perp to it
    /// - See: 'testResolveRelative' under LineSegTests
    public func resolveRelativeVec(speck: Point3D) -> (along: Vector3D, perp: Vector3D)   {
        
        /// Direction of the segment.  Is a unit vector.
        let thisWay = self.getDirection()
        
        let bridge = Vector3D.built(from: self.endAlpha, towards: speck)
        
        let along = Vector3D.dotProduct(lhs: bridge, rhs: thisWay)
        let alongVector = thisWay * along
        let perpVector = bridge - alongVector
        
        return (alongVector, perpVector)
    }
    
    
    /// Find two distances describing the position of a point relative to the LineSeg.
    /// - Parameters:
    ///   - speck:  Point of interest
    /// - Returns: Tuple of distances - one along the seg, other away from it
    public func resolveRelative(speck: Point3D) -> (along: Double, away: Double)   {
        
        let components = resolveRelativeVec(speck: speck)
        
        let a = components.along.length()
        let b = components.perp.length()
        
        return (a, b)
    }
    
    
    /// Move, rotate, and scale by a matrix
    /// - Parameters:
    ///   - xirtam:  Transform to be applied
    /// - Throws: CoincidentPointsError if it was scaled to be very small
    /// - Returns:  Modified LineSeg
    public func transform(xirtam: Transform) throws -> PenCurve {
        
        let tAlpha = endAlpha.transform(xirtam: xirtam)
        let tOmega = endOmega.transform(xirtam: xirtam)
        
        var transformed = try LineSeg(end1: tAlpha, end2: tOmega)   // Will generate a new extent
        
        try! transformed.trimFront(lowParameter: self.trimParameters.lowerBound)   // Transfer the limits
        try! transformed.trimBack(highParameter: self.trimParameters.upperBound)
        

        transformed.setIntent(purpose: self.usage)   // Copy setting instead of having the default
        
        return transformed
    }
    
    

    /// Flip line segment to the opposite side of the plane
    /// - Parameters:
    ///   - flat:  Mirroring plane
    ///   - wire:  LineSeg to be flipped
    /// - Returns: New LineSeg
    /// - See: 'testMirrorLineSeg' under LineSeg Tests
    public static func mirror(wire: LineSeg, flat: Plane) -> LineSeg   {
        
        /// Point to be worked on
        var pip: Point3D = wire.getOneEnd()
        
        ///New point from mirroring
        let fairest1 = Plane.mirror(flat: flat, pip: pip)
        
        pip = wire.getOtherEnd()
        
        ///New point from mirroring
        let fairest2 = Plane.mirror(flat: flat, pip: pip)
        
        var mirroredLineSeg = try! LineSeg(end1: fairest1, end2: fairest2)
        // Ignoring a possible error should be no risk because it uses points from a LineSeg that has already checked out.
        
        mirroredLineSeg.setIntent(purpose: wire.usage)   // Copy setting instead of having the default
        
        try! mirroredLineSeg.trimFront(lowParameter: wire.trimParameters.lowerBound)   // Transfer the limits
        try! mirroredLineSeg.trimBack(highParameter: wire.trimParameters.upperBound)
        
        return mirroredLineSeg
    }
    
    
    /// Check whether a point is or isn't perched on the curve.
    /// - Parameters:
    ///   - speck:  Point near the curve.
    /// - Throws:
    ///   - NegativeAccuracyError for a goofy input.
    /// - Returns: Flag, and optional parameter value
    /// - See: 'testPerch' under LineSegTests
    public func isCoincident(speck: Point3D, accuracy: Double = Point3D.Epsilon) throws -> (flag: Bool, param: Double?)   {
        
        guard accuracy > 0.0 else { throw NegativeAccuracyError(acc: accuracy) }
                    
          // Shortcuts!
        if speck == self.endAlpha   { return (true, self.trimParameters.lowerBound) }
        if speck == self.endOmega   { return (true, self.trimParameters.upperBound) }
        
        /// True length along the curve
        let curveLength = self.getLength()
        
        let relPos = self.resolveRelativeVec(speck: speck)
        
        if relPos.perp.length() > accuracy   { return (false, nil) }
        else {
            if relPos.along.length() < curveLength   {
                
                let lsDir = Vector3D.built(from: self.endAlpha, towards: endOmega, unit: true)
                var dupe = relPos.along
                dupe.normalize()
                
                if Vector3D.dotProduct(lhs: lsDir, rhs: dupe) != 1.0   { return (false, nil) }
                let proportion = relPos.along.length() / curveLength
                return (true, proportion)
            }
        }
        
        return (false, nil)
    }
    
    
    /// Find possible intersection points with a line.
    /// Part of PenCurve protocol.
    /// - Parameters:
    ///   - ray:  The Line to be used for intersecting
    ///   - accuracy:  How close is close enough?
    /// - Throws:
    ///     - CoincidentLinesError if the input lies on top
    ///     - ParallelLinesError for lines that would never intersect
    /// - Returns: Possibly empty Array of points common to both curves
    /// - See: 'testIntersectLine' under LineSegTests
    public func intersect(ray: Line, accuracy: Double = Point3D.Epsilon) throws -> [PointCrv]   {
        
        /// Line built from this segment
        let unbounded = try! Line(spot: self.getOneEnd(), arrow: self.getDirection())
        
        guard !Line.isCoincident(straightA: unbounded, straightB: ray)  else  { throw CoincidentLinesError(enil: ray) }
        
        guard !Line.isParallel(straightA: unbounded, straightB: ray)  else  { throw ParallelLinesError(enil: ray) }
        

        /// The return array
        var crossings = [PointCrv]()
        
        /// Intersection point of the two lines
        let collision = try! Line.intersectTwo(straightA: unbounded, straightB: ray)
        
        /// Vector from segment origin towards intersection. Possible to be zero length.
        let towardsInt = Vector3D.built(from: self.getOneEnd(), towards: collision, unit: true)
        
        if towardsInt.isZero()   {   // Intersection at first end.
            let frontPt = PointCrv(x: self.getOneEnd().x, y: self.getOneEnd().y, z: self.getOneEnd().z, t: self.trimParameters.lowerBound)
            crossings.append(frontPt)
            return crossings
        }
        
        // Positive value for somewhere along the line, or past it.
        let sameDir = Vector3D.dotProduct(lhs: self.getDirection(), rhs: towardsInt)
        
        if sameDir > 0.0   {
            
            let dist = Point3D.dist(pt1: self.getOneEnd(), pt2: collision)
            
            if (self.getLength() - dist) > -1.0 * Point3D.Epsilon   {
                
//TODO: I think that this needs to be modified to work with a trimmed curve.
                let crossPt = PointCrv(x: collision.x, y: collision.y, z: collision.z, t: dist / self.getLength())
                crossings.append(crossPt)
            }
        }
        
        return crossings
    }
    
    
    //TODO: Should something like this be written for other PenCurves?
    /// See if another segment crosses this one.
    /// Used for seeing if a screen gesture cuts across the current seg.
    /// - Parameters:
    ///   - chop:  LineSeg of interest
    /// - Returns: Simple flag
    /// - See: 'testIsCrossing' under LineSegTests
    public func isCrossing(chop: LineSeg) -> Bool   {
        
        /// Vector components of each endpoint
        let compsA = self.resolveRelativeVec(speck: chop.endAlpha)
        let compsB = self.resolveRelativeVec(speck: chop.endOmega)
        
           // Should be negative if ends are on opposite sides
        let compliance = Vector3D.dotProduct(lhs: compsA.perp, rhs: compsB.perp)
        
        let flag1 = compliance < 0.0
        
        let farthest = self.getLength()
        
        let flag2A = compsA.along.length() <= farthest
        let flag2B = compsB.along.length() <= farthest
        
        return flag1 && flag2A && flag2B
    }
    
    
    /// Generate the perpendicular bisector for the LineSeg between two points
    /// - Parameters:
    ///   - ptA:  First point
    ///   - ptB:  Second point
    ///   - up:  Normal for the plane in which the points lie
    /// - Returns: Fresh Line
    /// - Throws:
    ///     - ZeroVectorError if the input vector is lame
    ///     - CoincidentPointsError if the points are not unique
    ///     - NonUnitDirectionError for  a bad vector
    /// - See: 'testGenBisect' under LineTests
    public static func genBisect(ptA: Point3D, ptB: Point3D, up: Vector3D) throws -> Line   {
        
        guard ptA != ptB else  { throw CoincidentPointsError(dupePt: ptA) }
        
        guard !up.isZero() else { throw ZeroVectorError(dir: up) }
        
        guard up.isUnit() else { throw NonUnitDirectionError(dir: up) }
        
        
        let along = Vector3D.built(from: ptA, towards: ptB, unit: true)
        
        var inward = try Vector3D.crossProduct(lhs: up, rhs: along)
        inward.normalize()
        
        let anchor = Point3D.midway(alpha: ptA, beta: ptB)
        
        let myLine = try Line(spot: anchor, arrow: inward)
        
        return myLine
    }
    
    
    
    /// Calculate the crown over a small segment
    /// - See: 'testCrown' under LineSegTests
    public func findCrown(smallerT: Double, largerT: Double) -> Double   {
        return 0.0
    }
    
    
    //TODO: Needs to be modified to handle the trimmed case.
    
    /// Find the change in parameter that meets the crown requirement
    /// - Parameters:
    ///   - allowableCrown:  Acceptable deviation from curve
    ///   - currentT:  Present value of the driving parameter
    ///   - increasing:  Whether the change in parameter should be up or down
    /// - Returns: New value for driving parameter
    /// - See: 'testFindStep' under LineSegTests
    public func findStep(allowableCrown: Double, currentT: Double, increasing: Bool) -> Double   {
        
        var trialT : Double
        
        if increasing   {
            trialT = 1.0
        }  else  {
            trialT = 0.0
        }
        
        return trialT
    }
    
    // TODO: An "isReversed" test would be good.
    
    
    /// Tally up the distances
    /// Should this be moved to be part of LineSeg? Would need to 'static'.
    /// - Parameters:
    ///   - sticks: LineSegs to be checked
    /// - Returns: Double
    public static func sumLengths(sticks: [LineSeg]) -> Double   {
        
        let spans = sticks.map( { $0.getLength() } )
        
        let total = spans.reduce(0.0, {x,y in
            x + y
        })
        
        return total
    }
    
    
    /// Check continuity of a possibly unordered Array. This should probably be in class LineSeg.
    /// Does not check for a chain that branches. There isn't anything that keeps this from working on other PenCurves.
    /// - Parameters:
    ///   - rawSegs: Collection of segments that may not be in nose-to-tail order
    /// - Returns: Simple flag
    /// - Throws:
    ///     - TinyArrayError for an Array with too few members
    /// See 'testIsClosedChain' in MeshGen.tests
    public static func isClosedChain(rawSegs: [LineSeg]) throws -> Bool   {
        
        guard rawSegs.count > 2  else { throw TinyArrayError(tnuoc: rawSegs.count) }

        
        /// Points that are used only once
        var once = Set<Point3D>()
        
        /// Points that are used twice
        var twice = Set<Point3D>()
        
        
        /// Closure to add an endpoint to the appropriate set
        let sortPlace: (Point3D) -> Void = { pip in
            
            if once.contains(pip)   {
                twice.update(with: pip)   // Move this Edge to the 'mated' set
                once.remove(pip)
            }  else  {
                once.update(with: pip)  // Insert the new Edge in the 'bachelor' set
            }
        }
        

        for bar in rawSegs   {
            sortPlace(bar.getOneEnd())
            sortPlace(bar.getOtherEnd())
        }
        
        
        let emptySingletons = once.isEmpty
        
        return emptySingletons
    }

    
    /// Order a set of LineSegs that make up a ring. The Array may come from a filtering operation. Will this work with other PenCurves?
    /// Does this belong in class LineSeg?
    /// - Parameter rawSegs: Collection of segments that may not be in nose-to-tail order
    /// - Returns: Ordered Array of LineSegs
    /// - Throws:
    ///     - TinyArrayError for an Array with too few members
    /// See 'testOrderRing' in MeshGen.tests
    public static func orderRing(rawSegs: [LineSeg]) throws -> [LineSeg]   {
        
        guard rawSegs.count > 2  else { throw TinyArrayError(tnuoc: rawSegs.count) }
        

        /// Array where members can be removed
        var erodeSegs = rawSegs
        
        
        /// Dummy starting value for a target index
        var largestXIndex = -5
        
        /// Dummy starting value for the X coordinate
        var largestX = Double.leastNonzeroMagnitude
        
        
        let startPts = rawSegs.map( { $0.getOneEnd() } )   // This assumes that the LineSeg's are consistent in point ordering
        
        for (xedni, pip) in startPts.enumerated()   {
            
            if pip.x > largestX   {
                largestX = pip.x
                largestXIndex = xedni
            }
            
        }
                
        
        /// LineSeg's in order. The return value.
        var duckChain = [LineSeg]()
        
        /// Latest LineSeg to go in the chain
        let tailSeg = rawSegs[largestXIndex]   // Initial value
        
        duckChain.append(tailSeg)   // Insert the first value
        
        /// Trailing end of the LineSeg just added
        var tailPoint = tailSeg.getOtherEnd()
        
        erodeSegs.removeAll(where: { $0 == tailSeg } )   // Since LineSeg is Equatable
        
                
        //TODO: Deal with the possibility of a broken chain.  Make a Set of Point3D's?
        
        
        while erodeSegs.count > 0   {
            
            /// Index for the chosen LineSeg
            var nextSegIndex = -5
            
            for (xedni, bar) in erodeSegs.enumerated()   {    // Hunt for the next in sequence
                
                let headPoint = bar.getOneEnd()
                
                if headPoint == tailPoint   {
                    
                    nextSegIndex = xedni
                    
                    break
                }
            }
            
            duckChain.append(erodeSegs[nextSegIndex])
            
            tailPoint = erodeSegs[nextSegIndex].getOtherEnd()
            
            erodeSegs.remove(at: nextSegIndex)
        }
        
        
        return duckChain
    }
    

    /// Generate array points suitable for drawing.
    /// Part of PenCurve protocol.
    /// - Parameter allowableCrown: Acceptable deviation from the curve
    /// - Throws: NegativeAccuracyError even though allowableCrown is ignored.
    /// - Returns: Array of two Point3D's
    public func approximate(allowableCrown: Double) throws -> [Point3D]   {
        
        guard allowableCrown > 0.0 else { throw NegativeAccuracyError(acc: allowableCrown) }
            
        /// Collection of points to be returned
        var chain = [Point3D]()
        
        chain.append(getOneEnd())
        chain.append(getOtherEnd())
        
        return chain
    }
    
    
    /// Plot the line segment.  This will be called by the UIView 'drawRect' function.
    /// Part of PenCurve protocol.
    /// - Parameters:
    ///   - context: In-use graphics framework
    ///   - tform:  Model-to-display transform
    ///   - allowableCrown: Maximum deviation from the actual curve. Ignored for this struct.
    public func draw(context: CGContext, tform: CGAffineTransform, allowableCrown: Double) throws   {
        
        context.beginPath()
        
        var spot = Point3D.makeCGPoint(pip: self.endAlpha)    // Throw out Z coordinate
        let screenSpotAlpha = spot.applying(tform)
        context.move(to: screenSpotAlpha)
        
        spot = Point3D.makeCGPoint(pip: self.endOmega)    // Throw out Z coordinate
        let screenSpotOmega = spot.applying(tform)
        context.addLine(to: screenSpotOmega)
        
        context.strokePath()
    }
    
    
    /// Compare each endpoint of the segment.
    /// - Parameters:
    ///   - lhs:  One LineSeg for comparison
    ///   - rhs:  Another LineSeg for comparison
    /// - See: 'testEquals' under LineSegTests.
    public static func == (lhs: LineSeg, rhs: LineSeg) -> Bool   {
        
        let flagOne = lhs.endAlpha == rhs.endAlpha
        let flagOther = lhs.endOmega == rhs.endOmega
        
        return flagOne && flagOther
    }
    
}
