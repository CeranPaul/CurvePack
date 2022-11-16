//
//  Arc.swift
//  CurvePack
//
//  Created by Paul on 8/24/19.
//  Copyright © 2022 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation
import CoreGraphics

/// Can represent a portion, or a complete circle
public struct Arc: PenCurve, Equatable   {
    
    /// Anchor point for swinging
    var center: Point3D
    
    /// Direction perpendicular to plane of the Arc
    var axis: Vector3D
    
    /// Where the Arc begins
    var startPt: Point3D
    
    /// Angle covered by the Arc - in radians.  -2pi to 2pi
    var sweepAngle: Double
    
    /// Limited to be bettween 0.0 and 1.0
    public var trimParameters: ClosedRange<Double>
    
    /// The String that hints at the meaning of the curve
    public var usage: String
    
    
    /// Turn local points into global points
    var toGlobal: Transform
    
    /// Turn global points into local
    var fromGlobal: Transform
    
    
    /// Distance of all points from the center
    var radius: Double
        
    
    /// Create a new one. Use this intializer for a half or whole circle.
    /// - Parameters:
    ///   - ctr: Point to be used as origin
    ///   - axis: Pivot direction for rotating
    ///   - start: Beginning point
    ///   - sweep: Sweep angle in radians. Positive or negative.
    /// - Throws:
    ///   - NonUnitDirectionError for a bad set of inputs
    ///   - NonOrthogonalPointError
    ///   - ParameterRangeError for a bad sweep value
    /// - See: 'testFidelityCASS' under ArcTests
    public init(ctr: Point3D, axis: Vector3D, start: Point3D, sweep: Double) throws   {
        
        guard axis.isUnit() else { throw NonUnitDirectionError(dir: axis) }
        
        /// What can be considered horizontal for this Arc
        let baseline = Vector3D.built(from: ctr, towards: start, unit: true)
        
        let myDot = Vector3D.dotProduct(lhs: axis, rhs: baseline)
        
        guard myDot < Vector3D.EpsilonV else { throw NonOrthogonalPointError(trats: start) }
        
        // TODO: Needs a more specific error type?
        let minSweep = Double.pi * -2.0
        guard sweep >= minSweep else { throw ParameterRangeError(parA: sweep) }
        
        let maxSweep = Double.pi * 2.0
        guard sweep <= maxSweep else { throw ParameterRangeError(parA: sweep) }

        
        self.center = ctr
        
        self.axis = axis
        
        self.startPt = start
        
        self.sweepAngle = sweep
        
        
        self.trimParameters = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
        self.radius = Point3D.dist(pt1: ctr, pt2: start)
        
        self.usage = "Ordinary"
        
        
        /// Coordinate system
        let csys = try CoordinateSystem(origin: self.center, refDirection: baseline, normal: self.axis)
        
        self.toGlobal = try! Transform.genToGlobal(csys: csys)
        
        self.fromGlobal = Transform.genFromGlobal(csys: csys)
        
    }
    
    /// Create from center and two endpoints.
    /// Use the other initializer for a half or whole circle.
    /// - Parameters:
    ///   - ctr: Point to be used as origin
    ///   - end1: Starting point
    ///   - end2: Final point
    ///   - useSmallAngle: Flag to indicate which of the two possible Arcs to use
    ///   - accuracy: When to consider radii equal
    /// - Throws:
    ///   - ArcPointsError for a bad set of inputs
    ///   - CoincidentPointsError for identical endpoints
    ///   - CoincidentPointsError for collinear points
    /// - See: 'testFidelityThreePoints' under ArcTests
    public init(center: Point3D, end1: Point3D, end2: Point3D, useSmallAngle: Bool, accuracy: Double = Point3D.Epsilon) throws   {
        
        let rad1 = Point3D.dist(pt1: center, pt2: end1)
        let rad2 = Point3D.dist(pt1: center, pt2: end2)
        
        guard abs(rad1 - rad2) < accuracy else { throw ArcPointsError(badPtA: center, badPtB: end1, badPtC: end2) }

        //TODO: Consider changes here to account for accuracy input
        guard end1 != end2 else { throw CoincidentPointsError(dupePt: end1) }
        
        //TODO: Needs a better error type
        guard !Point3D.isThreeLinear(alpha: center, beta: end1, gamma: end2) else { throw CoincidentPointsError(dupePt: end1) }
        
        
        self.center = center
        
        self.startPt = end1
        
        self.radius = rad1
        
        /// What can be considered horizontal for this Arc
        let baseline = Vector3D.built(from: center, towards: end1, unit: true)
        
        let buttress = Vector3D.built(from: center, towards: end2, unit: true)
        
        var up = try Vector3D.crossProduct(lhs: baseline, rhs: buttress)
        up.normalize()
        
        self.axis = up
        
        var vert = try Vector3D.crossProduct(lhs: up, rhs: baseline)
        vert.normalize()
        
        let vComponent = Vector3D.dotProduct(lhs: vert, rhs: buttress)
        let hComponent = Vector3D.dotProduct(lhs: baseline, rhs: buttress)
        
        let endAngle = atan2(vComponent, hComponent)
        
        if useSmallAngle   {
            self.sweepAngle = endAngle
        }  else  {
            self.sweepAngle = endAngle - Double.pi * 2.0
        }
        
        self.trimParameters = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
        self.usage = "Ordinary"
        
        /// Coordinate system
        let csys = try CoordinateSystem(origin: self.center, refDirection: baseline, normal: self.axis)
        
        self.toGlobal = try! Transform.genToGlobal(csys: csys)
        
        self.fromGlobal = Transform.genFromGlobal(csys: csys)
        
    }
    
    /// Build a concentric Arc with larger or smaller radius
    /// - Parameters:
    ///   - alpha: Original Arc
    ///   - delta: Increase in size
    /// - Throws:
    ///   - CoincidentPointsError for a reduction that would leave nothing but a point.
    /// - See: 'testConcentric' under ArcTests
    public static func concentric(alpha: Arc, delta: Double) throws -> Arc  {
        
        guard delta > -1.0 * alpha.getRadius() else { throw CoincidentPointsError(dupePt: alpha.getCenter())  }
        
        /// Normalized vector towards the start of the Arc.
        let thataway = Vector3D.built(from: alpha.getCenter(), towards: alpha.getOneEnd(), unit: true)
         
        let startOffset = Point3D.offset(pip: alpha.getOneEnd(), jump: thataway * delta)
        
        let freshArc = try! Arc(ctr: alpha.getCenter(), axis: alpha.getAxisDir(), start: startOffset, sweep: alpha.getSweepAngle())
        
        return freshArc
    }
    
    /// Attach new meaning to the curve
    /// - Parameter: purpose:PenTypes
    /// - See: 'testSetIntent' under ArcTests
    public mutating func setIntent(purpose: String)   {
        
        self.usage = purpose
    }
    
    /// Fetch the location of the pivot point
    public func getCenter() -> Point3D   {
        return self.center
    }
    
    /// Fetch the location of an end
    /// - See: 'getOtherEnd()'
    public func getOneEnd() -> Point3D   {
        return try! pointAt(t: self.trimParameters.lowerBound)
    }
    
    /// Fetch the location of the opposite end
    /// - See: 'getOneEnd()'
    public func getOtherEnd() -> Point3D   {
        return try! pointAt(t: self.trimParameters.upperBound)
    }
    
    public func getRadius() -> Double   {
        return self.radius
    }
    
    public func getAxisDir() -> Vector3D   {
        return self.axis
    }
    
    public func getSweepAngle() -> Double   {
        return self.sweepAngle
    }
    
    /// Generate a global point at the given angle
    /// - Parameters:
    ///   - theta - desired angle
    /// - Returns: A point in the global CSYS
    /// - See: 'testPointAtAngleGlobal' under ArcTests
    public func pointAtAngleGlobal(theta: Double) -> Point3D   {
        
        //TODO: Range checking would be good
        let horiz = cos(theta) * self.radius
        let vert = sin(theta) * self.radius
        
        let localPt = Point3D(x: horiz, y: vert, z: 0.0)        
        let globalPt = localPt.transform(xirtam: self.toGlobal)
        
        return globalPt
    }
    
    
    /// Generate a point at the given angle
    /// - Parameters:
    ///   - theta - desired angle
    /// - Returns: A point in the local CSYS
    public func pointAtAngle(theta: Double) -> Point3D   {
        
        //TODO: Range checking would be good
        let horiz = cos(theta) * self.radius
        let vert = sin(theta) * self.radius
        
        let localPt = Point3D(x: horiz, y: vert, z: 0.0)
        
        return localPt
    }
    
    
    /// Return a point based on its parameter, as contrasted to its angle.
    /// - Parameters:
    ///   - t: Parameter
    ///   - ignoreTrim: Flag to not limit usage to trimmed parameters
    /// - Returns: A point in the global CSYS
    /// - Throws:
    ///     - ParameterRangeError if the input is lame
    /// - See: 'testPointAt' under ArcTests
    public func pointAt(t: Double, ignoreTrim: Bool = false) throws -> Point3D   {
        
        if ignoreTrim   {
            
            /// The entire possible parameter range.
            let wholeSheBang = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
            
            guard wholeSheBang.contains(t) else { throw ParameterRangeError(parA: t) }
            
        }  else  {
            guard self.trimParameters.contains(t) else { throw ParameterRangeError(parA: t) }
        }
        
        let ratioedAngle = self.sweepAngle * t
        let localPt = self.pointAtAngle(theta: ratioedAngle)
        let globalPt = localPt.transform(xirtam: self.toGlobal)
        
        return globalPt
    }
    
    // TODO: Add 'tangentAt' function
    
    /// Figure the arc length
    /// - See: 'testGetLength' under ArcTests
    public func getLength() -> Double   {
        
        let includedAngle = abs(getSweepAngle())
        return includedAngle * self.getRadius()
    }
    
    
    /// Figure the global brick that contains the curve
    /// - See: 'testGetExtent' under ArcTests
    public func getExtent() -> OrthoVol   {
        
        let divs = 20.0
        
        let sweepInc = self.sweepAngle / divs
        
        /// Global points on the curve
        var droplets = [Point3D]()
        
        for g in 0...Int(divs)   {
            let theta = Double(g) * sweepInc
            let localPip = self.pointAtAngle(theta: theta)
            let globalPip = localPip.transform(xirtam: self.toGlobal)
            droplets.append(globalPip)
        }
        
        /// The end result and return value
        var brick = try! OrthoVol(corner1: droplets[0], corner2: droplets[1])   // Might fail for a really small Arc
        
        for g in 2..<droplets.count   {
            let smallBrick = try! OrthoVol(corner1: droplets[g - 1], corner2: droplets[g])
            brick = brick + smallBrick
        }

        return brick
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
    
    
    /// Create only enough points for line segments tthat will meet the crown limit.
    /// - Parameters:
    ///   - allowableCrown: Maximum deviation from the actual curve
    /// - Returns: Array of evenly spaced points in the local coordinate system
    /// - Throws:
    ///     - NegativeAccuracyError for an input less than zero
    /// - See: 'testApproximate' under ArcTests
    public func approximate(allowableCrown: Double) throws -> [Point3D]   {
        
        guard allowableCrown > 0.0 else { throw NegativeAccuracyError(acc: allowableCrown) }
            
        
        let ratio = 1.0 - allowableCrown / self.radius
        
        /// Step in angle that meets the allowable crown limit
        let maxSwing =  2.0 * acos(ratio)
        
        let count = ceil(abs(self.sweepAngle / maxSwing))
        
        /// The increment in angle that results in an even number of portions
        let angleStep = self.sweepAngle / count
        
        
        /// Collection of points in the local CSYS
        var chainL = [Point3D]()
        
        let firstPt = pointAtAngle(theta: 0.0)
        chainL.append(firstPt)
        
        for index in 1...Int(count)   {
            let theta = Double(index) * angleStep
            let freshPt = pointAtAngle(theta: theta)
            chainL.append(freshPt)
        }
        
        /// Points in the global CSYS
        let chainG = chainL.map( { $0.transform(xirtam: self.toGlobal) } )
        
        return chainG
    }
    

    /// Check whether a point is or isn't perched on the curve.
    /// - Parameters:
    ///   - speck:  Point near the curve.
    ///   - accuracy: When to consider radii equal
    /// - Returns: Flag, and optional parameter value
    /// - See: 'testPerch' under ArcTests
    public func isCoincident(speck: Point3D, accuracy: Double = Point3D.Epsilon) throws -> (flag: Bool, param: Double?)   {
        
        /// The target point in the local coordinate system
        let speckLocal = speck.transform(xirtam: self.fromGlobal)
        
        if abs(speckLocal.z) > accuracy    { return (false, nil) }

           // Shortcuts!
        if speck == self.startPt   { return (true, self.trimParameters.lowerBound) }
        let endPt = self.pointAtAngle(theta: self.sweepAngle)
        
        if speckLocal == endPt   { return (true, self.trimParameters.upperBound) }
        
        let speckRad = Point3D.dist(pt1: self.center, pt2: speck)
        
        if abs(speckRad - self.radius) > Point3D.Epsilon { return (false, nil) }
        else   {
            let hAxis = try! LineSeg(end1: self.center, end2: self.startPt)
            let relPos = hAxis.resolveRelative(speck: speck)
            let speckAngle = atan2(relPos.away, relPos.along)
            if speckAngle < self.sweepAngle { return (true, speckAngle / sweepAngle)}
        }
        
        return (false, nil)
    }
    
    /// Untested version
    /// - Parameters:
    ///   - xirtam: Martix to rotate, translate, and scale.
    /// - Returns: New Arc
    /// - Throws:
    ///   - NonUnitDirectionError for a bad set of inputs
    ///   - NonOrthogonalPointError
    ///   - ParameterRangeError for a bad sweep value
    /// - See: 'testTransform' under ArcTests
    public func transform(xirtam: Transform) throws -> PenCurve {
        
        let freshCtr = self.center.transform(xirtam: xirtam)
        
        let freshDir = self.axis.transform(xirtam: xirtam)
        
        let freshStart = self.startPt.transform(xirtam: xirtam)
        
        
        var fresh = try Arc(ctr: freshCtr, axis: freshDir, start: freshStart, sweep: self.sweepAngle)
        
        try! fresh.trimFront(lowParameter: self.trimParameters.lowerBound)   // Transfer the limits
        try! fresh.trimBack(highParameter: self.trimParameters.upperBound)
        
        fresh.setIntent(purpose: self.usage)   // Copy setting instead of having the default
        
        return fresh
    }
    
        
    /// Same start and end, but different direction. Used to align members of a Loop
    /// - See: 'testReverse' under ArcTests.
    public mutating func reverse() -> Void  {
        
        let oldFinish = self.getOtherEnd()
        let freshSweep = -1.0 * self.sweepAngle
        
        self.startPt = oldFinish
        self.sweepAngle = freshSweep
        
        let baseline = Vector3D.built(from: self.center, towards: self.startPt, unit: true)
        
        /// Coordinate system
        let csys = try! CoordinateSystem(origin: self.center, refDirection: baseline, normal: self.axis)
        
        self.toGlobal = try! Transform.genToGlobal(csys: csys)
        
        self.fromGlobal = Transform.genFromGlobal(csys: csys)
    }
    
    
    /// Find if the two curves cross.
    /// - Parameters:
    ///   - ray: Line to use to check for overlap
    ///   - accuracy: What is close enough for the result
    /// - Throws:
    ///   - NegativeAccuracyError for a goofy input.
    /// - Returns: 0, 1, or 2 points
    /// - See: 'testIntersect' under ArcTests for a few tests.
    public func intersect(ray: Line, accuracy: Double = Point3D.Epsilon) throws -> [PointCrv]   {
        
        guard accuracy > 0.0 else { throw NegativeAccuracyError(acc: accuracy) }
                    
        /// Intersection points. The return array.
        var crossings = [PointCrv]()
        
        /// Variable for comparison with the trigonometric results
        var sweepRange: ClosedRange<Double>
        
        if self.sweepAngle > 0.0   {
            sweepRange = ClosedRange(uncheckedBounds: (lower: 0.0, upper: self.sweepAngle))
        } else {
            sweepRange = ClosedRange(uncheckedBounds: (lower: self.sweepAngle, upper: 0.0))
        }
        
        /// Distances along and perpendicular to the Line to a point closest to the Arc center.
        let legs = ray.resolveRelative(yonder: self.center)
        if legs.perp > self.radius { return crossings }
        
        var projection = Vector3D.dotProduct(lhs: self.axis, rhs: ray.getDirection())
        if projection > Vector3D.EpsilonV { return crossings }
        
        
           // For the case of the line being parallel and offset to the plane of the circle.
        let bridge = Vector3D.built(from: ray.getOrigin(), towards: self.getCenter(), unit: true)
        projection = Vector3D.dotProduct(lhs: bridge, rhs: self.axis)
        
        if abs(projection) > 0.0   { return crossings }
        
        
        var jump = ray.getDirection() * legs.along
        
        /// Point on the line that is closest to the Arc center.
        let lineNearest = Point3D.offset(pip: ray.getOrigin(), jump: jump)
        
        /// Distance along the line to potential intersection points.
        let component = sqrt(self.radius * self.radius - legs.perp * legs.perp)
        
        jump = ray.getDirection() * component
        let possible1 = Point3D.offset(pip: lineNearest, jump: jump)
        
        let poss1Loc = possible1.transform(xirtam: self.fromGlobal)
        let theta1 = atan2(poss1Loc.y, poss1Loc.x)   // Be careful with the range of the result!
        
        /// Closure to determine if the possible point is on the used portion of the Arc.
        let isCrossing: (Double) -> Bool = { theta in
            var flag: Bool = false
            
            if abs(self.sweepAngle) <= Double.pi   {
                if sweepRange.contains(theta)   { flag = true }
            } else {    // sweepAngle > Double.pi
                if self.sweepAngle < 0.0   {
                    if theta >= 0.0   {
                        flag = sweepRange.contains(theta - 2.0 * Double.pi)
                    }  else  {
                        flag = sweepRange.contains(theta)
                    }
                }  else  {
                    if theta < 0.0   {
                        flag = sweepRange.contains(theta + 2.0 * Double.pi)
                    }  else  {
                        flag = sweepRange.contains(theta)
                    }
                }
            }
            
            return flag
        }
        
        var keepFlag = isCrossing(theta1)
        let crossPt = PointCrv(x: possible1.x, y: possible1.y, z: possible1.z, t: theta1 / self.sweepAngle)
        if keepFlag { crossings.append(crossPt) }

        
        jump = jump.reverse()
        let possible2 = Point3D.offset(pip: lineNearest, jump: jump)

        let poss2Loc = possible2.transform(xirtam: self.fromGlobal)
        let theta2 = atan2(poss2Loc.y, poss2Loc.x)   // Be careful with the range of the result!
        
        keepFlag = isCrossing(theta2)
        let crossPt2 = PointCrv(x: possible2.x, y: possible2.y, z: possible2.z, t: theta2 / self.sweepAngle)
        if keepFlag { crossings.append(crossPt2) }

        return crossings
    }
    
    
//    /// Assumed to all be happening in the XY plane
//    /// Needs work!
//    public static func intersectLineCircle(arrow: Line, hoop: Arc) -> Point3D   {
//
//        /// The return value
//        var RHintersect = Point3D(x: 0.0, y: 0.0, z: 0.0)
//
//        /// Relative position of the circle center to the line origin
//        let relCenter = arrow.resolveRelative(yonder: hoop.getCenter())
//
//        if relCenter.perp > hoop.getRadius()   {   // There are a number of ways that this could be handled
//            print("No intersection")
//        } else {
//
//            let lineAnchor = arrow.getOrigin()
//            let jump = arrow.getDirection() * relCenter.along
//            let middleChord = lineAnchor.offset(jump: jump)
//            let stem = Point3D.dist(pt1: hoop.getCenter(), pt2: middleChord)   // Will be the same as relCenter.perp
//
//            /// Magnitude of distance between middleChord and the intersection point
//            let halfChord = sqrt(hoop.getRadius() * hoop.getRadius() - stem * stem)
//
//            let intersectJump = arrow.getDirection() * halfChord
//
//            RHintersect = middleChord.offset(jump: intersectJump)   // One of two possibilities
//        }
//
//        return RHintersect
//    }


    /// Generate the Arc between two Lines. The goal is to have this work independent of plane, and relative angles.
    /// - Parameters:
    ///   - straight1: One line on the boundary
    ///   - straight2: Another line. Checked to be coplanar with straight1
    ///   - rad: Desired radius
    ///   - keepNear1: Whether to keep the origin of straight1
    ///   - keepNear2: Whether to keep the origin of straight2
    /// - Returns: Small arc
    /// - Throws:
    ///     - NegativeAccuracyError for a bad radius
    ///     - NonCoPlanarLinesError for a bad pair of Lines
    ///     - ParallelLinesError for inputs that would never intersect
    ///     - CoincidentLinesError
    public static func buildFillet(straight1: Line, straight2: Line, rad: Double, keepNear1: Bool, keepNear2: Bool) throws -> Arc   {
        
        guard rad > 0.0  else  { throw NegativeAccuracyError(acc: rad) }
        
            // These checks are also part of Line.intersectTwo()
        guard Line.isCoplanar(straightA: straight1, straightB: straight2)  else  { throw NonCoPlanarLinesError(enilA: straight1, enilB: straight2) }
        
        guard !Line.isParallel(straightA: straight1, straightB: straight2)  else  { throw ParallelLinesError(enil: straight1) }
                
        guard !Line.isCoincident(straightA: straight1, straightB: straight2)  else  { throw CoincidentLinesError(enil: straight1) }
        
        ///The intersection of the Lines
//        let crux = try! Line.intersectTwo(straightA: straight1, straightB: straight2)
                
        let twoRelative = straight1.resolveRelativeVec(yonder: straight2.getOrigin())
        var twoRelativeOne = twoRelative.perp
        twoRelativeOne.normalize()
        
        let oneRelative = straight2.resolveRelativeVec(yonder: straight1.getOrigin())
        var oneRelativeTwo = oneRelative.perp
        oneRelativeTwo.normalize()
        
        ///Offsets for parallel lines to determine the center
        var offset1Vec, offset2Vec: Vector3D
        
        
        //TODO: Can this be simplified to a couple of 'if' statements?
        switch (keepNear1, keepNear2)   {
            
        case (false, false):
            offset1Vec = twoRelativeOne * -rad
            offset2Vec = oneRelativeTwo * -rad
                        
        case (false, true):
            offset1Vec = twoRelativeOne * -rad
            offset2Vec = oneRelativeTwo * rad
                        
        case (true, false):
            offset1Vec = twoRelativeOne * rad
            offset2Vec = oneRelativeTwo * -rad
            
        case (true, true):
            offset1Vec = twoRelativeOne * rad
            offset2Vec = oneRelativeTwo * rad
        }
        
        
        let constLine1Origin = Point3D.offset(pip: straight1.getOrigin(), jump: offset1Vec)
        let constLine2Origin = Point3D.offset(pip: straight2.getOrigin(), jump: offset2Vec)
        
        let constLine1 = try! Line(spot: constLine1Origin, arrow: straight1.getDirection())
        let constLine2 = try! Line(spot: constLine2Origin, arrow: straight2.getDirection())
        
        ///Point equidistant from both lines
        let filletCenter = try! Line.intersectTwo(straightA: constLine1, straightB: constLine2)
        
        let tangent1 = straight1.dropPoint(away: filletCenter)
        let tangent2 = straight2.dropPoint(away: filletCenter)
        
        ///The desired small Arc. Direction of the curve is unknown.
        let lePrize = try! Arc(center: filletCenter, end1: tangent1, end2: tangent2, useSmallAngle: true)
        
        return lePrize
    }
    
    
    //TODO: Build a slightly higher level function that works from LineSeg's and trims them.
    
    /// Fillet from a line to an Arc
    /// - Parameters:
    ///   - straight1: Line to be blended
    ///   - circleFrag: Partial circle to be blended
    ///   - rad: Size of fillet Arc
    ///   - keepNear1: Whether to keep or remove the origin of the line.
    ///   - keepNear2: Whether or not to keep the start point of the Arc
    /// - Returns: Small Arc
    /// - Throws:
    ///     - NegativeAccuracyError for a bad radius
    ///     - CoincidentPlanesError when the Line and the Arc are NOT coincident
    public static func buildFillet(straight1: Line, circleFrag: Arc, rad: Double, keepNear1: Bool, keepNear2: Bool) throws -> Arc   {
        
        guard rad > 0.0  else  { throw NegativeAccuracyError(acc: rad) }
        
        
        let arcPlane = try! Plane(spot: circleFrag.getCenter(), arrow: circleFrag.getAxisDir())
        
        guard try! Plane.isCoincident(flat: arcPlane, enil: straight1)  else  { throw CoincidentPlanesError(enalpA: arcPlane)}
        
    //TODO: Add check of whether or not the circle and line intersect.
        
        var jump: Double
        
        let offsetDir = try! Vector3D.crossProduct(lhs: straight1.getDirection(), rhs: circleFrag.getAxisDir())
        
        if keepNear1 { jump = rad }  else  { jump = -rad }
        let offsetSpot = Point3D.offset(pip: straight1.getOrigin(), jump: offsetDir * jump)
                
        let offsetLine = try! Line(spot: offsetSpot, arrow: straight1.getDirection())
        
        let inward = Vector3D.built(from: circleFrag.getOneEnd(), towards: circleFrag.getCenter(), unit: true)
        
        if keepNear2 { jump = rad }  else  { jump = -rad }
        
        let offsetStart = Point3D.offset(pip: circleFrag.getOneEnd(), jump: inward * jump)
        let offsetArc = try! Arc(ctr: circleFrag.getCenter(), axis: circleFrag.getAxisDir(), start: offsetStart, sweep: circleFrag.getSweepAngle())
        
        ///Intersection between the offset Line and the offset Arc.
        let intPts = try! offsetArc.intersect(ray: offsetLine)
        let filletCtr = Point3D(x: intPts[0].x, y: intPts[0].y, z: intPts[0].z)   //This makes a precarious assumption.
        
        /// Tangent point on straight1
        let lineTan = straight1.dropPoint(away: filletCtr)
        
        let radial = Vector3D.built(from: circleFrag.getCenter(), towards: filletCtr, unit: true)
        let myJump = radial * circleFrag.getRadius()
        
        /// Tangent point on the input Arc
        let circleTan = Point3D.offset(pip: circleFrag.getCenter(), jump: myJump)
        
        let filletArc = try! Arc(center: filletCtr, end1: circleTan, end2: lineTan, useSmallAngle: true)
        
        
        return filletArc
    }
    
    
    /// Mostly used for checking
    /// - Parameter scoop: Source Arc
    /// - Returns: Resulting plane
    public static func genPlane(scoop: Arc) -> Plane   {
        
        let ctr = scoop.getCenter()
        let thatAway = scoop.getAxisDir()

        let flat = try! Plane(spot: ctr, arrow: thatAway)
        
        return flat
    }

    /// Generate points on a 90 degree Arc that is either a concave fillet or a convex rounded edge.
    /// - Parameters:
    ///   - pip: Point3D on the original edge curve.
    ///   - faceNormalB: Outward from the other face
    ///   - faceNormalA: Outward from one of the faces
    ///   - filletRad: Radius of the desired fillet
    ///   - convex: Flag for the desired curvature
    ///   - allowableCrown: Acceptable deviation from the curve
    /// - Returns: A set of points on a fillet
    /// - Throws:
    ///     - NonUnitDirectioError for a bad faceNormal.
    ///     - NegativeAccuracyError for an improper filletRad or allowableCrown
    public static func edgeFilletArc(pip: Point3D, faceNormalB: Vector3D, faceNormalA: Vector3D, filletRad: Double, convex: Bool, allowableCrown: Double) throws -> Arc   {
        
        
        guard faceNormalA.isUnit() else { throw NonUnitDirectionError(dir: faceNormalA) }
        guard faceNormalB.isUnit() else { throw NonUnitDirectionError(dir: faceNormalB) }
        
        let projection = Vector3D.dotProduct(lhs: faceNormalA, rhs: faceNormalB)
        
        // See if the two vectors are perpendicular
        guard abs(projection) < 0.001 else { throw NonUnitDirectionError(dir: faceNormalA) }   // Needs a better error
        
        
        guard filletRad > 0.0 else { throw NegativeAccuracyError(acc: filletRad) }
        guard allowableCrown > 0.0 else { throw NegativeAccuracyError(acc: allowableCrown) }

                
        /// Points to define an Arc in the convex case
        var arcEndSurfA = Point3D.offset(pip: pip, jump: faceNormalB * -filletRad)
        var arcEndSurfB = Point3D.offset(pip: pip, jump: faceNormalA * -filletRad)
        var center = Point3D.offset(pip: arcEndSurfA, jump: faceNormalA * -filletRad)

        if !convex   {
            
            arcEndSurfA = Point3D.offset(pip: pip, jump: faceNormalA * filletRad)
            arcEndSurfB = Point3D.offset(pip: pip, jump: faceNormalB * filletRad)
            center = Point3D.offset(pip: arcEndSurfA, jump: faceNormalB * filletRad)

        }
        
        
        /// Arc representing the fillet or rounded edge
        let dip = try! Arc(center: center, end1: arcEndSurfA, end2: arcEndSurfB, useSmallAngle: true)

        
        /// A short chain that could be a return value
        var dipChain = [Point3D]()
        
        dipChain = try! dip.approximate(allowableCrown: allowableCrown)
                
        if dipChain.count < 4   {
            
            let cee = try! dip.pointAt(t: 0.33)
            let dee = try! dip.pointAt(t: 0.67)
            
            dipChain = [arcEndSurfA, cee, dee, arcEndSurfB]   // Redefine to have a minimum of three segments
        }
        
        
        
        return dip
    }
    
    
    

    /// Plot the circle segment.  This will be called by the UIView 'drawRect' function
    /// - Parameters:
    ///   - context: In-use graphics framework
    ///   - tform:  Model-to-display transform
    ///   - allowableCrown: Maximum deviation from the actual curve
    /// - Throws:
    ///     - NegativeAccuracyError for a bad input
    public func draw(context: CGContext, tform: CGAffineTransform, allowableCrown: Double) throws -> Void  {
        
        guard allowableCrown > 0.0 else { throw NegativeAccuracyError(acc: allowableCrown) }
            
        /// Array of points in the global coordinate system
        let dots = try! self.approximate(allowableCrown: allowableCrown)
        
        /// Closure to generate a point for display
        let toScreen = { (spot: Point3D) -> CGPoint in
//            let global = spot.transform(xirtam: self.toGlobal)   // Transform from local to global CSYS
            let asCG = CGPoint(x: spot.x, y: spot.y)   // Make a CGPoint
            let onScreen = asCG.applying(tform)   // Shift and scale for screen
            return onScreen
        }
        
        let screenDots = dots.map( { toScreen($0) } )
        
        context.move(to: screenDots.first!)
                
        for index in 1..<screenDots.count   {
            context.addLine(to: screenDots[index])
        }
        
        context.strokePath()
        
    }
        
    /// Compare each component of the Arc for equality
    /// - See: 'testEquals' under ArcTests
    public static func == (lhs: Arc, rhs: Arc) -> Bool   {
        
        let ctrFlag = lhs.center == rhs.center
        let axisFlag = lhs.getAxisDir() == rhs.getAxisDir()
        let startFlag = lhs.getOneEnd() == rhs.getOneEnd()
        let sweepFlag = lhs.getSweepAngle() == rhs.getSweepAngle()
        
        return ctrFlag && axisFlag && startFlag && sweepFlag
    }
        
}
