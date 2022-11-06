//
//  Loop.swift
//  CurvePack
//
//  Created by Paul on 2/3/18.
//  Copyright © 2022 Ceran Digital Media. All rights reserved.
//

import Foundation

/// An ordered collection of PenCurves that serves as a boundary. Assumed to lie on a plane.
/// Not necessarily closed. Can be used either for the perimeter, or for a cutout.
public class Loop   {
    
    /// The unsorted component list
    var rawCurves: [PenCurve]
    
    /// The nose-to-tail component list. Filled by function 'align'.
    public var orderedCurves: [PenCurve]
    
    var refCoord: CoordinateSystem   // Should this change to become an optional plane?
    

    /// Locations where curves are joined
    internal var commonEndBucket: [CommonEnd]
    
    /// Whether or not this is a complete boundary.  Will get updated each time a curve is added or deleted. See function 'isClosed'.
    internal var closedBound:  Bool
    
    
    
    //TODO: Add functionality to generate a new Loop offset from the source.
    //TODO: Add a test to see if a Point3D is somewhere on a Loop curve.

    //TODO: Will need to have a "remove" function, and will need to modify the Loop status.
        
    // May want to be able to shift the starting point
    
    
    public init(refCoord: CoordinateSystem)   {
        
        closedBound = false
        
        self.refCoord = refCoord
        
        rawCurves = [PenCurve]()
        
        commonEndBucket = [CommonEnd]()
        
        orderedCurves = [PenCurve]()
        
    }
    
    
    /// Pile on another curve.  No checks are made.
    /// Some curves may get reversed when the Loop becomes closed.
    /// Will not attempt alignment if the loop is not closed.
    /// There are a whole bunch of checks that should be done as part of this process.
    /// Need to check that a duplicate curve is not submitted.
    /// - See: 'testAdd' and 'testCount' under LoopTests
    public func add(noob: PenCurve) -> Void   {
        
        // TODO: Add code to check that the new curve is planar, and in the plane of the other curves.
        
        // Need to protect against a zero-length curve, or a duplicate curve
        // Will need a special case for a closed circle.
        
        rawCurves.append(noob)   // Blindly add this curve
        
        if commonEndBucket.count == 0   {   // First curve - start on finding common ends
            
            var pin = CommonEnd(oneCurve: noob, location: noob.getOneEnd())
            commonEndBucket.append(pin)
            
            pin = CommonEnd(oneCurve: noob, location: noob.getOtherEnd())
            commonEndBucket.append(pin)
            
        }  else  {   // Most curves
                        
            var headmate = false
            var tailmate = false
            
            // Loop through bucket members to find if either end joins up.
            for g in 0..<commonEndBucket.count   {
                
                // Paying attention only to unmated CommonEnds
                if commonEndBucket[g].other == nil    {
                    
                    if !headmate   {
                        if commonEndBucket[g].joinSpot == noob.getOneEnd()   {
                            
                            commonEndBucket[g].addMate(otherCurve: noob)   // Want this change to get passed back to bucket.
                            headmate = true
                        }
                    }
                    
                    if !tailmate   {
                        if commonEndBucket[g].joinSpot == noob.getOtherEnd()   {
                            commonEndBucket[g].addMate(otherCurve: noob)
                            tailmate = true
                        }
                    }
                    
                }   // Deal only with unmated members
                
            }   // Loop through bucket members
            
            // Create additional CommonEnds as needed
            if !headmate   { commonEndBucket.append(CommonEnd(oneCurve: noob, location: noob.getOneEnd())) }
            if !tailmate   { commonEndBucket.append(CommonEnd(oneCurve: noob, location: noob.getOtherEnd())) }
            
            
    //TODO: Attempt construction of the plane
            
        }
        
        self.closedBound = self.isClosed()   // Update the flag
        
        if self.closedBound   {
            try! self.align()
        }
    }
        
    
    /// See if the entities form a sealed boundary.
    /// - Returns: Simple flag.
    /// - See: 'testIsClosed' under LoopTests
    public func isClosed() -> Bool   {
        
        /// The flag to be returned
        var flag = false
        
    //TODO: Incorporate or delete the commented code block
        
//        if self.pieces.count == 1   {   // Special case of full circle
//
//            let unoType = type(of: self.pieces.first!)
//
//            if unoType == Arc.self   {
//
//                let myArc = self.pieces.first! as! Arc
//                flag = myArc.isFull
//
//            }
//
//        }  else  {  // The more general case
        
        let qtyflag = commonEndBucket.count == rawCurves.count
        
        /// flag to indicate that all curves are connected
        let sewedUp = commonEndBucket.reduce(true, { f1, f2 in f1 && f2.other != nil } )
        
        flag = qtyflag && sewedUp
        //        }
        
        return flag
    }
    
    
    
    /// Ensure that the curves go nose-to-tail. Called after a closure check.
    /// Fills the 'ordered' array.
    /// - Throws:
    ///     - AlignmentError if there are any unconnected curve end points
    ///     See function 'isClosed'.
    public func align() throws -> Void   {
        
        let completeJoints = commonEndBucket.filter( {$0.other != nil} )
        
        guard completeJoints.count == commonEndBucket.count else  { throw AlignmentError() }
        
        
        // Simple copy if the loop has less than three members. One or more is likely a semi-circle.
        if rawCurves.count < 3   {
            
    //TODO: Deal with the case of a misaligned pair
            for wire in rawCurves   {
                orderedCurves.append(wire)
            }
            
        }  else {
            
            /// Most recent Curve in the sequence
            var cabooseCurve = rawCurves[0]
            orderedCurves.append(cabooseCurve)    // Start the sequence with this curve. This drives the direction for the entire Loop.
            
            
            /// A changing value of a point shared by two curves
            var tailVertex: Point3D

            repeat   {   // Iterate through the Array of CommonEnds
                
                tailVertex = cabooseCurve.getOtherEnd()
                
                /// A joint that uses the tail of the current caboose Curve
                if let workingTailJoint = commonEndBucket.firstIndex(where: { $0.joinSpot == tailVertex })   {
                    
                    /// First curve referenced
                    let jointFirstCurve = commonEndBucket[workingTailJoint].one   // This could refer to a Curve that has been reversed.
                    
                    /// Second curve referenced
                    let jointSecondCurve = commonEndBucket[workingTailJoint].other!   // The "completeJoints" guard statement protects this
                    
                    let sameFlag = Loop.curveSameEnds(lhs: cabooseCurve, rhs: jointFirstCurve)
                    
                    /// Curve to be appended
                    var tailCandidate: PenCurve
                    
                    if sameFlag  {
                        tailCandidate = jointSecondCurve
                    }  else  {
                        tailCandidate = jointFirstCurve
                    }
                    
                    if tailCandidate.getOneEnd() == cabooseCurve.getOtherEnd()   {
                        orderedCurves.append(tailCandidate)
                    }  else  {
                        tailCandidate.reverse()
                        orderedCurves.append(tailCandidate)
                    }
                    
                    cabooseCurve = tailCandidate
                    
                    
                }  else  {   // No suitable joint was found
                    
            //TODO: Throw an error
                    print("Trouble while aligning")
                    break
                }
                
            } while orderedCurves.count < commonEndBucket.count   // This fails if one of the CommonEnd definitions is incomplete.
            
        }   // Not the small case
        
    }   // func align
    
    
    /// This counts on an earlier check to prevent duplicate curves in the Array.
    /// - Parameter targetCurve: The curve to be matched
    /// - Returns: Optional index in the 'rawCurves' Array
    /// Should a check be added for a non-empty Array?
    public func findCurveRaw(targetCurve: PenCurve) -> Int?   {
        
        /// Location of curve to be banished in 'pieces' Array
        var foundIndex: Int? = nil
        
        for (xedni, slash) in self.rawCurves.enumerated()   {
            
            let sameFlag = Loop.curveSameEnds(lhs: targetCurve, rhs: slash)
            let oppositeFlag = Loop.curveOppositeEnds(lhs: targetCurve, rhs: slash)
            
            if sameFlag || oppositeFlag   {
                foundIndex = xedni
                break
            }
            
        }

        return foundIndex
    }
    
    
    /// This counts on an earlier check to prevent duplicate curves in the Array.
    /// - Parameter targetCurve: The curve to be matched
    /// - Returns: Optional index in the 'orderedCurves' Array
    /// Should this become a private function?
    /// Should a check be added for a non-empty Array?
    public func findCurveOrdered(targetCurve: PenCurve) -> Int?   {
        
        /// Location of curve to be banished in 'pieces' Array
        var foundIndex: Int? = nil
        
        for (xedni, slash) in self.orderedCurves.enumerated()   {
            
            let sameFlag = Loop.curveSameEnds(lhs: targetCurve, rhs: slash)
            let oppositeFlag = Loop.curveOppositeEnds(lhs: targetCurve, rhs: slash)
            
            if sameFlag || oppositeFlag   {
                foundIndex = xedni
                break
            }
            
        }

        return foundIndex
    }
    
    
    /// Not yet complete. Withdraw one curve.
    /// - Parameter vanishingCurve: Curve to be removed
    /// - Returns: Nothing. Modifies the 'rawCurves' and 'orderedCurves' Arrays
    /// - Throws:
    ///     - CoincidentPointsError if the curve cannot be found
    public func remove(vanishingCurve: PenCurve) throws -> Void   {
                
        if let vanishingCurveIndexRaw = findCurveRaw(targetCurve: vanishingCurve)   {
            
            if !orderedCurves.isEmpty   {
                
                if let vanishingCurveIndexOrdered = findCurveOrdered(targetCurve: vanishingCurve)   {
                    
                    _ = self.orderedCurves.remove(at: vanishingCurveIndexOrdered)
                    
                    self.orderedCurves.removeAll()   // Empty the Array
                    self.closedBound = false   // Change the "ordered" flag
                                        
                }  else  {
                    throw CoincidentPointsError(dupePt: vanishingCurve.getOtherEnd())   // Could stand a better error
                }
            }
            
            _ = self.rawCurves.remove(at: vanishingCurveIndexRaw)
            
            // Modify members of the "commonEndBucket" Array
        
        }  else  {
            throw CoincidentPointsError(dupePt: vanishingCurve.getOneEnd())   // Could stand a better error
        }
        
    }
    
    
    /// Check that different PenCurves use the same endpoints. Nothing tests whether or not the curves are the same type.
    /// - Parameters:
    ///   - lhs: One curve for comparison
    ///   - rhs: Other curve for comparison
    /// - Returns: Simple flag
    public static func curveSameEnds(lhs: PenCurve, rhs: PenCurve) -> Bool   {
        
        let oneFlag = lhs.getOneEnd() ==  rhs.getOneEnd()
        let otherFlag = lhs.getOtherEnd() == rhs.getOtherEnd()
        
        return oneFlag && otherFlag
    }
    
    
    /// Check that different PenCurves use the identical endpoints, but swapped. Nothing tests whether or not the curves are the same type.
    /// - Parameters:
    ///   - lhs: One curve for comparison
    ///   - rhs: Other curve for comparison
    /// - Returns: Simple flag
    public static func curveOppositeEnds(lhs: PenCurve, rhs: PenCurve) -> Bool   {
        
        let oneFlag = lhs.getOneEnd() ==  rhs.getOtherEnd()
        let otherFlag = lhs.getOtherEnd() == rhs.getOneEnd()
        
        return oneFlag && otherFlag
    }
    

    /// See if the tail is coincident with the following head. How is this different than 'isClosed'?
    /// - Parameters:
    ///   - xedni: Index of the current curve.
    /// - Returns: Simple flag.
    /// - See: 'testIsJoined' under LoopTests.
    func isjoined(xedni: Int) -> Bool   {
        
        let tail = rawCurves[xedni].getOtherEnd()
        let head = rawCurves[xedni + 1].getOneEnd()
        
        return (tail == head)
    }
    
    /// Report the sum of curve lengths
    public func getLength() -> Double   {
        
        var total = 0.0
        
        for wire in self.rawCurves   {
            total += wire.getLength()
        }
        
        return total
    }
    
    
    /// What volume is used by the collection?
    public func getExtent() -> OrthoVol   {
        
        var brick: OrthoVol
        
        brick = self.rawCurves[0].getExtent()
        
        for g in 1..<self.rawCurves.count   {
            let block = self.rawCurves[g].getExtent()
            brick = brick + block
        }
        
        return brick
    }
    
    
    /// Partial equality check
    /// Can this go in Protocol PenCurve?
    /// - Parameters:
    ///   - lhs: One curve
    ///   - rhs: Another curve
    ///   - acceptReverse: Is it okay to match up with the reverse of one of the curves?
    /// - Returns: Simple flag
    /// See 'testEquals' in LoopTests
    public static func equalsEndsType(lhs: PenCurve, rhs: PenCurve, acceptReverse: Bool) -> Bool   {
        
        var matches: Bool
        
        let oneEndSame = lhs.getOneEnd() ==  rhs.getOneEnd()
        let otherEndSame = lhs.getOtherEnd() == rhs.getOtherEnd()
        
        let matchesFwd = oneEndSame && otherEndSame
        
        matches = matchesFwd
        
        if acceptReverse   {
            
            let oneFlagRev = lhs.getOneEnd() ==  rhs.getOtherEnd()
            let otherFlagRev = lhs.getOtherEnd() == rhs.getOneEnd()
            
            let matchesRev = oneFlagRev && otherFlagRev
            
            matches = matchesFwd || matchesRev
        }
        

        let lhType = type(of: lhs)
        let rhType = type(of: rhs)

        let ditto = lhType == rhType
        
        return matches && ditto
    }
    
    
    
    /// Intersections of a Line with the Loop
    /// - Parameters:
    ///   - enil: Cutting line
    /// - Throws:
    ///     - ConvergenceError when a range can't be refined closely enough in 8 iterations of the intersect function.
    ///     - Other error if bad parameters are passed to the Milestone constructor
    /// - Returns: Array of unique points, sorted by location along the line..
    public func genMilestones(enil: Line) throws -> [Milestone]   {
        
        /// Unsorted list of intersections
        var rawMarkers = [Milestone]()
        
           // Iterate through the components of the Loop to generate the unsorted list.
        for (index, wire) in self.orderedCurves.enumerated()   {
            
            /// Intersection points
            let pointsOnly = try wire.intersect(ray: enil, accuracy: Point3D.Epsilon)
            
               // Generate a milestone for each intersection point.
            for pip in pointsOnly   {
                let spot = Point3D(x: pip.x, y: pip.y, z: pip.z)
                let marker = try Milestone(spot: spot, refLine: enil, xedni: index)
                rawMarkers.append(marker)
            }
        }
        
        /// Set of Milestones
        let unique = Set<Milestone>(rawMarkers)   // Ignore any duplicate curve endpoints
            
        /// Array from the Set
        let markerArray = Array<Milestone>(unique)
        
        /// Sorted array
        let ordered = markerArray.sorted( by: { $0.along < $1.along } )
        
        return ordered
    }
    
    
    /// Closure to find any intersections on an edge.
    /// Used for masking triangles with a Loop
    public static func findSplit(a: Point3D, b: Point3D, perimeter: Loop) throws -> [Milestone]   {
        
        let dir = Vector3D.built(from: a, towards: b, unit: true)
        
        /// Line along edge
        let enil = try! Line(spot: a, arrow: dir)
        
        /// Spots where the infinite line intersects the Loop
        let spots = try! perimeter.genMilestones(enil: enil)

        ///Milestones where the Edge intersects the Loop
        var markers = [Milestone]()
        
           // Filter out intersections that are not on the edge
        if spots.count > 0   {
            let cap = Point3D.dist(pt1: a, pt2: b)
            markers = spots.filter( { $0.along > -1.0 * Point3D.Epsilon && $0.along < cap + Point3D.Epsilon })
        }
        
        if markers.count > 2 { throw SplittingError() }
        
        return markers
    }
    
    
    /// See if a Point3D is inside the Loop by checking six directions
    public func isInside(target: Point3D) -> Bool   {
        
        /// The return value
        var flag = false
        
        /// The set of test directions
        var compass = [Vector3D]()
        
        let clock3 = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        compass.append(clock3)
        
        var clock2 = Vector3D(i: 0.866, j: 0.5, k: 0.0)
        clock2.normalize()
        compass.append(clock2)
        
        var clock1 = Vector3D(i: 0.5, j: 0.866, k: 0.0)
        clock1.normalize()
        compass.append(clock1)
        
        let clock12 = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        compass.append(clock12)

        var clock11 = Vector3D(i: -0.5, j: 0.866, k: 0.0)
        clock11.normalize()
        compass.append(clock11)
        
        var clock10 = Vector3D(i: -0.866, j: 0.5, k: 0.0)
        clock10.normalize()
        compass.append(clock10)
        
        
        /// Closure to verify that the point is inside in the passed direction
        let checkSwing: (Vector3D) -> Bool = { dir in
            
            let ray = try! Line(spot: target, arrow: dir)
            let dots = try! self.genMilestones(enil: ray)   // Find the intersection points
            
            var stripeFlag = false
            
            for g in (stride(from: 1, through: dots.count - 1, by: 2)) {
                
                if dots[g - 1].along <= 0.0 && dots[g].along >= 0.0   {
                    stripeFlag = true
                    break
                }
            }
            
            return stripeFlag
        }
        
        
//        let ray3 = try! Line(spot: target, arrow: clock3)
//
//        let dots3 = try! self.genStripe(enil: ray3)   // Find the intersection points
//
//        var stripeFlag = false
//
//        for g in (stride(from: 1, through: dots3.count - 1, by: 2)) {
//
//            if dots3[g - 1].along <= 0.0 && dots3[g].along >= 0.0   {
//                stripeFlag = true
//                break
//            }
//        }
//
//        flag = stripeFlag
//

        let dirFlags = compass.map( { checkSwing($0) } )
        
        flag = dirFlags.reduce(true, {$0 && $1})

        return flag
    }
    
    
    /// Incomplete. Generate a small Arc starting from two LineSegs.
    public func genFillet(alpha: LineSeg, beta: LineSeg, rad: Double) -> Void   {
        
        
    }
    
    //TODO: Is it possible to write a "filletAll" function?
    
}


/// A way of tracking whether or not curves are joined.
/// Does not contain any directionality.
/// Should access control be something more restrictive?
public struct CommonEnd   {
    
    var one: PenCurve
    var other: PenCurve?
    var joinSpot: Point3D
    
    
    public init(oneCurve: PenCurve, location: Point3D)   {
        
        self.one = oneCurve
        self.joinSpot = location
        
    }
    
    
    /// Specify the other Curve. Does not check for overflowing.
    /// - Parameter otherCurve: Curve that connects
    /// - Returns: Nothing - it modifies an instance
    public mutating func addMate(otherCurve: PenCurve) -> Void   {
        
        //TODO: This needs an ability to detect and report any attempt to join a third curve.
        
        self.other = otherCurve
        
    }
    
    
    /// Check to see if this one covers a desired location.
    /// - Parameter location: Point to be tested
    /// - Returns: Simple flag
    public func contains(location: Point3D) -> Bool   {
        
        if self.joinSpot == location   { return true }
        
        return false
    }
    
    
    /// Does the CommonEnd reference the trial curve?
    /// - Parameter trialCurve: The curve to be tested
    /// - Returns: Simple flag
    /// See 'testCEContains' in LoopTests
    public func contains(trialCurve: PenCurve) -> Bool   {
        
    //TODO: Is there some finessing to be done with the 'acceptReverse' parameter?
        
        ///The return value
        var flag: Bool
        
        ///Is the trial curve the same as the first reference?
        let flagOne = Loop.equalsEndsType(lhs: self.one, rhs: trialCurve, acceptReverse: false)
        
        flag = flagOne
        
        
        if let secondCurve = self.other   {
            
            ///Is the trial curve the same as the second reference?
            let flagOther = Loop.equalsEndsType(lhs: secondCurve, rhs: trialCurve, acceptReverse: false)
            
            flag = flagOne || flagOther
        }

        return flag
    }
    
    
    /// Assumes that this instance of CommonEnd has already been selected because it references 'vanishingCurve'.
    /// - Parameter vanishingCurve: Curve that is being removed
    /// - Returns: Nothing. It affects the references in the instance of CommonEnd.
    /// See func 'contains'.
    public mutating func removeCurve(vanishingCurve: PenCurve) -> Void   {
        
        let oneFlag = vanishingCurve.getOneEnd() ==  self.one.getOneEnd()
        let otherFlag = vanishingCurve.getOtherEnd() == self.one.getOtherEnd()
        
        let matches = oneFlag && otherFlag
        
        let revOneFlag = vanishingCurve.getOneEnd() ==  self.one.getOtherEnd()
        let revOtherFlag = vanishingCurve.getOtherEnd() == self.one.getOneEnd()
        
        let revMatches = revOneFlag && revOtherFlag
        

        if matches || revMatches   {
            self.one = self.other!
        }
        
        self.other = nil
    }
    
    
}   // End of struct CommonEnd



/// An aid in sorting the intersection points along a cutting Line. Does this belong in Ribbon?
/// The point location is the only attribute that gets hashed. Where and why does this get hashed?
/// Should access control be something more restrictive to hide the details?
public struct Milestone: Hashable   {
    
    /// Intersection point
    public var pip: Point3D
    
    /// Distance of intersection from the cutting Line origin. For sorting. Can be positive or negative.
    public var along: Double
    
    /// Index of intersected curve in Loop's pieces array
    public var loopIndex: Int
    
    
    /// - Parameters:
    ///   - spot: Location of an intersection.
    ///   - refLine: Line doing the intersection.
    ///   - xedni: Index of the curve in the Loop's pieces array.
    /// - Throws:
    ///     - NonCoPlanarLinesError for a point that isn't on the Line
    public init(spot: Point3D, refLine: Line, xedni: Int) throws   {
        
        guard Line.isCoincident(straightA: refLine, pip: spot) else { throw NonCoPlanarLinesError(enilA: refLine, enilB: refLine) }
        
        self.pip = spot
        
        /// This must get used somewhere
        self.loopIndex = xedni
        
        var thataway = Vector3D.built(from: refLine.getOrigin(), towards: pip)
        
        /// Distance from the origin of the intersecting line. Always positive.
        let dist = thataway.length()
        
        thataway.normalize()   // Not truly needed
        
        
        let sense = Vector3D.dotProduct(lhs: refLine.getDirection(), rhs: thataway)
        
        var factor: Double
        
        if sense > 0.0   {
            factor = 1.0
        } else {
            factor = -1.0
        }
        
        self.along = dist * factor
    }
    
    
    /// Generate the unique value using Swift 4.2 tools. For making a Set.
    /// Is a required func for a subclass of Hashable
    public func hash(into hasher: inout Hasher)   {
        
        let divX = self.pip.x / Point3D.Epsilon
        let myX = Int(round(divX))
        
        let divY = self.pip.y / Point3D.Epsilon
        let myY = Int(round(divY))
        
        let divZ = self.pip.z / Point3D.Epsilon
        let myZ = Int(round(divZ))
        
        hasher.combine(myX)
        hasher.combine(myY)
        hasher.combine(myZ)
        
    }
    
    
}   // End of struct Milestone
