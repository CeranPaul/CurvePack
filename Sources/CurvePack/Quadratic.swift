//
//  Quadratic.swift
//  CurvePack
//
//  Created by Paul on 7/25/20.
//  Copyright © 2022 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation
import CoreGraphics
import simd


/// Curve defined by polynomials for each coordinate direction.
/// Parameter must fall within the range of 0.0 to 1.0.
/// Some of the functions are set up to work with a trimmed version of the curve.
public struct Quadratic: PenCurve   {
        
    var ax: Double
    var bx: Double
    var cx: Double
    
    var ay: Double
    var by: Double
    var cy: Double
    
    var az: Double
    var bz: Double
    var cz: Double
    

    /// The beginning point
    var ptAlpha: Point3D
    
    /// The end point
    var ptOmega: Point3D
    
    /// The String that hints at the meaning of the curve
    public var usage: String
    
    /// A smaller range inside 0.0...1.0
    public var trimParameters: ClosedRange<Double>
    
    
    
    /// Build from two end points and a control point.
    /// Assignment statements from an algebraic manipulation of the equations
    /// in the Wikipedia article on Bezier Curve.
    /// - Parameters:
    ///   - ptA: First end point
    ///   - controlA: Control point for first end
    ///   - ptB: Other end point
    /// There are checks here for input points that should be added!
    /// - Throws:
    ///     - CoincidentPointsError if the inputs are lame
    /// - See: 'testConstructorA' under QuadraticTests
    public init(ptA: Point3D, controlA: Point3D, ptB: Point3D) throws   {
        
        let pool = [ptA, controlA, ptB]
        guard try! Point3D.isUniquePool(flock: pool) else { throw CoincidentPointsError(dupePt: ptA)}
        
        
        self.ptAlpha = ptA
        self.ptOmega = ptB
                
        
        self.ax = self.ptAlpha.x - 2.0 * controlA.x + self.ptOmega.x
        self.bx = -2.0 * self.ptAlpha.x + 2.0 * controlA.x
        self.cx = self.ptAlpha.x
        
        self.ay = self.ptAlpha.y - 2.0 * controlA.y + self.ptOmega.y
        self.by = -2.0 * self.ptAlpha.y + 2.0 * controlA.y
        self.cy = self.ptAlpha.y
        
        self.az = self.ptAlpha.z - 2.0 * controlA.z + self.ptOmega.z
        self.bz = -2.0 * self.ptAlpha.z + 2.0 * controlA.z
        self.cz = self.ptAlpha.z
        

        self.usage = "Ordinary"
        
        self.trimParameters = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
    }
    
    /// Build from two end points and a mid point.
    /// Needed for transforms and offsets
    /// - Parameters:
    ///   - ptA: First end point
    ///   - beta: Mid point on curve
    ///   - betaFraction: Parameter value for the 'beta' point
    ///   - ptC: Other end point
    /// - Throws:
    ///     - ParameterRangeError if the 'betaFraction' input is lame
    ///     - CoincidentPointsError if the inputs are not unique
    /// - See: 'testConstructorB' under QuadraticTests
    public init(ptA: Point3D, beta: Point3D, betaFraction: Double, ptC: Point3D) throws   {
        
        self.trimParameters = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
        guard self.trimParameters.contains(betaFraction) else { throw ParameterRangeError(parA: betaFraction) }
        
        let pool = [ptA, beta, ptC]
        guard try! Point3D.isUniquePool(flock: pool) else { throw CoincidentPointsError(dupePt: ptA)}
        
        // TODO: Add tests to see that the guard statements are doing their job
        
        self.ptAlpha = ptA
        self.ptOmega = ptC
        
        // Rearrange coordinates into an array
        let rowX = SIMD3<Double>(ptA.x, beta.x, ptC.x)
        let rowY = SIMD3<Double>(ptA.y, beta.y, ptC.y)
        let rowZ = SIMD3<Double>(ptA.z, beta.z, ptC.z)
        
        // Build a 3x3 of parameter values to various powers
        let row1 = SIMD3<Double>(0.0, 0.0, 1.0)
        
        let betaFraction2 = betaFraction * betaFraction
        let row2 = SIMD3<Double>(betaFraction2, betaFraction, 1.0)
        
        let row3 = SIMD3<Double>(1.0, 1.0, 1.0)
        
        /// Intermediate collection for building the matrix
        var partial: [SIMD3<Double>]
        partial = [row1, row2, row3]
        
        /// Matrix of t from several points raised to various powers
        let tPowers = double3x3(partial)
        
        let trans = tPowers.transpose   // simd representation is different than what I had in college
        
        /// Inverse of the above matrix
        let nvers = trans.inverse
        
        let coeffX = nvers * rowX
        let coeffY = nvers * rowY
        let coeffZ = nvers * rowZ
        
        // Set the curve coefficients
        self.ax = coeffX[0]
        self.bx = coeffX[1]
        self.cx = coeffX[2]
        self.ay = coeffY[0]
        self.by = coeffY[1]
        self.cy = coeffY[2]
        self.az = coeffZ[0]
        self.bz = coeffZ[1]
        self.cz = coeffZ[2]

        self.usage = "Ordinary"
        
    }
    
    
    /// Copy constructor
    /// - Parameters:
    ///   - sourceCurve: Quadratic to be duplicated
    public init(sourceCurve: Quadratic)   {
        
        self.ptAlpha = try! sourceCurve.pointAt(t: 0.0, ignoreTrim: true)
        self.ptOmega = try! sourceCurve.pointAt(t: 1.0, ignoreTrim: true)
        
        // Set the curve coefficients
        self.ax = sourceCurve.ax
        self.bx = sourceCurve.bx
        self.cx = sourceCurve.cx
        self.ay = sourceCurve.ay
        self.by = sourceCurve.by
        self.cy = sourceCurve.cy
        self.az = sourceCurve.az
        self.bz = sourceCurve.bz
        self.cz = sourceCurve.cz


        self.usage = sourceCurve.usage
        
        self.trimParameters = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
    }
    
    
    /// Generate the coefficients for the three polynomials. Used in function 'reverse'.
    private mutating func genCoeff(ptA: Point3D, beta: Point3D, betaFraction: Double, ptC: Point3D) {
        
        // Rearrange coordinates into an array
        let rowX = SIMD3<Double>(ptA.x, beta.x, ptC.x)
        let rowY = SIMD3<Double>(ptA.y, beta.y, ptC.y)
        let rowZ = SIMD3<Double>(ptA.z, beta.z, ptC.z)
        
        // Build a 3x3 of parameter values to various powers
        let row1 = SIMD3<Double>(0.0, 0.0, 1.0)
        
        let betaFraction2 = betaFraction * betaFraction
        let row2 = SIMD3<Double>(betaFraction2, betaFraction, 1.0)
        
        let row3 = SIMD3<Double>(1.0, 1.0, 1.0)
        
        /// Intermediate collection for building the matrix
        var partial: [SIMD3<Double>]
        partial = [row1, row2, row3]
        
        /// Matrix of t from several points raised to various powers
        let tPowers = double3x3(partial)
        
        let trans = tPowers.transpose   // simd representation is different than what I had in college
        
        /// Inverse of the above matrix
        let nvers = trans.inverse
        
        let coeffX = nvers * rowX
        let coeffY = nvers * rowY
        let coeffZ = nvers * rowZ
        
        // Set the curve coefficients
        self.ax = coeffX[0]
        self.bx = coeffX[1]
        self.cx = coeffX[2]
        self.ay = coeffY[0]
        self.by = coeffY[1]
        self.cy = coeffY[2]
        self.az = coeffZ[0]
        self.bz = coeffZ[1]
        self.cz = coeffZ[2]
    }
    
    
    /// Supply the point on the curve for the input parameter value.
    /// Some notations show "u" as the parameter, instead of "t"
    /// - Parameters:
    ///   - t:  Curve parameter value.  Assumed 0 < t < 1.
    ///   - ignoreTrim: Flag to not limit usage to trimmed parameters
    /// - Returns: Point location at the parameter value
    /// - Throws:
    ///     - ParameterRangeError if the input is lame
    public func pointAt(t: Double, ignoreTrim: Bool = false) throws -> Point3D {
        
        if ignoreTrim   {
            
            /// The entire possible parameter range.
            let wholeSheBang = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
            
            guard wholeSheBang.contains(t) else { throw ParameterRangeError(parA: t) }
            
        }  else  {
            guard self.trimParameters.contains(t) else { throw ParameterRangeError(parA: t) }
        }
        
        let t2 = t * t

        // Warning!  The relationship of coefficients and powers of t might be unexpected, as notations vary
        let myX = ax * t2 + bx * t + cx
        let myY = ay * t2 + by * t + cy
        let myZ = az * t2 + bz * t + cz
        
        return Point3D(x: myX, y: myY, z: myZ)
        
    }
    
    
    /// Attach new meaning to the curve.
    /// - See: 'testSetIntent' under QuadraticTests
    public mutating func setIntent(purpose: String) -> Void  {
        self.usage = purpose
    }
    
    
    public func getOneEnd() -> Point3D {
        return try! pointAt(t: self.trimParameters.lowerBound)
    }
    
    
    public func getOtherEnd() -> Point3D {
        return try! pointAt(t: self.trimParameters.upperBound)
    }
    
    
    public func getExtent() -> OrthoVol {
        
        let dots = self.dice(pieces: 100)
        
        var brick = try! OrthoVol(corner1: dots.first!, corner2: dots.last!)
        
        for g in (stride(from: 2, to: dots.count - 1, by: 2))   {
            let chunk = try! OrthoVol(corner1: dots[g - 1], corner2: dots[g])
            brick = brick + chunk
        }
        
        return brick

    }
    
    
    /// Approximate the length with 100 segments.
    /// - Returns: Double
    public func getLength() -> Double {
        
        let dots = self.dice(pieces: 100)
        
        var total = 0.0
        
        for g in 1..<dots.count   {
            let hop = Point3D.dist(pt1: dots[g - 1], pt2: dots[g])
            total += hop
        }
        
        return total

    }
    
    
    /// Differentiate to find the tangent vector for the input parameter.
    /// Some notations show "u" as the parameter, instead of "t".
    /// - Parameters:
    ///   - t:  Curve parameter value.  Checked to be 0 < t < 1.
    ///   - ignoreTrim: Flag to not limit usage to trimmed parameters
    /// - Returns:  Non-normalized vector
    /// - Throws:
    ///     - ParameterRangeError if the input is lame
    public func tangentAt(t: Double, ignoreTrim: Bool = false) throws -> Vector3D   {
        
        if ignoreTrim   {
            
            /// The entire possible parameter range.
            let absoluteRange = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))

            guard absoluteRange.contains(t) else { throw ParameterRangeError(parA: t) }
            
        }  else  {
            guard self.trimParameters.contains(t) else { throw ParameterRangeError(parA: t) }
        }
        
        
        // This is the component matrix differentiated once
        let myI = 2.0 * ax * t + bx
        let myJ = 2.0 * ay * t + by
        let myK = 2.0 * az * t + bz
        
        return Vector3D(i: myI, j: myJ, k: myK)    // Notice that this is not normalized!
    }
    
    
    /// Use a different portion of the curve
    /// - Parameters:
    ///   - lowParameter:  New parameter value.  Checked to be 0 < t < 1 and less than the upper bound.
    /// - Throws:
    ///     - ParameterRangeError if the input is lame
    /// - See: 'testTrimFront' under QuadraticTests
    mutating public func trimFront(lowParameter: Double) throws   {
        
        guard lowParameter >= 0.0  else  { throw ParameterRangeError(parA: lowParameter)}
        
        guard lowParameter < self.trimParameters.upperBound  else { throw ParameterRangeError(parA: lowParameter) }
        
        
        self.trimParameters = ClosedRange<Double>(uncheckedBounds: (lower: lowParameter, upper: self.trimParameters.upperBound))
        
    }
    
    
    /// Use a different portion of the curve
    /// - Parameters:
    ///   - highParameter:  New parameter value.  Checked to be 0 < t < 1 and greater than the lower bound.
    /// - Throws:
    ///     - ParameterRangeError if the input is lame
    /// - See: 'testTrimBack' under QuadraticTests
    mutating public func trimBack(highParameter: Double) throws   {
        
        guard highParameter <= 1.0  else  { throw ParameterRangeError(parA: highParameter)}
        
        guard highParameter > self.trimParameters.lowerBound  else { throw ParameterRangeError(parA: highParameter) }
        
        
        self.trimParameters = ClosedRange<Double>(uncheckedBounds: (lower: self.trimParameters.lowerBound, upper: highParameter ))
        
    }
    
    
    /// Check whether a point is or isn't perched on the curve.
    ///  What's the right thing to do here for a trimmed curve?
    /// - Parameters:
    ///   - speck:  Point near the curve.
    /// - Throws:
    ///     - ParameterRangeError for a bad parameter near the end of this code
    /// - Returns: Flag, and optional parameter value
    /// - See: 'testPerch' under QuadraticTests
    public func isCoincident(speck: Point3D, accuracy: Double = Point3D.Epsilon) throws -> (flag: Bool, param: Double?)   {
        
           // Shortcuts!
        if speck == self.ptAlpha   { return (true, self.trimParameters.lowerBound) }
        if speck == self.ptOmega   { return (true, self.trimParameters.upperBound) }
        
        /// Points along the curve
        let crumbs = Quadratic.diceRange(pristine: self.trimParameters, chunks: 40)
        
        /// Distances to the target point (and parameter ranges)
        let seps = crumbs.map( { rangeDist(egnar: $0, curve: self, awaySpeck: speck) } )
        
        /// True length along the curve
        let curveLength = self.getLength()
        
        /// Ranges whose midpoint is close enough to be of interest.
        let moreScrutiny = seps.filter( { $0.dist < curveLength / 4.0 } )
        
        /// Whether or not speck is too far away
        if moreScrutiny.count == 0   { return (false, nil) }
        
        
        let rankedRanges = moreScrutiny.sorted(by: { $0.dist < $1.dist } )

        /// Range of parameter to use for a refined check on the closest range
        let startSpan = rankedRanges[0].range

        /// Parameter for the curve point that is nearest
        var nearCurveParam: Double
        
        nearCurveParam = try convergeMinDist(speck: speck, span: startSpan, curve: self, layersRemaining: 8)
        
        let nearCurvePoint = try self.pointAt(t: nearCurveParam)
        let flag = Point3D.dist(pt1: nearCurvePoint, pt2: speck) < accuracy
        
        return (flag, nearCurveParam)
    }
    
    
    /// Recursively converge to a parameter value where speck is closest.
    /// - Parameters:
    ///   - speck: Target point
    ///   - span: Parameter range to work in
    ///   - curve: Curve to check against
    ///   - layersRemaining: Iterations left before ending the effort
    /// - Returns: Parameter value for the curve point closest to speck
    /// - Throws:
    ///     - ConvergenceError when a range can't be refined closely enough in 8 iterations.
    ///     - ParameterRangeError when a range is off the curve.
    private func convergeMinDist(speck: Point3D, span: ClosedRange<Double>, curve: Quadratic, layersRemaining: Int) throws -> Double   {
        
        if layersRemaining == 0  { throw ConvergenceError(tnuoc: 0) }   // Safety valve
        
        /// Parameter value to be returned
        var closest: Double
        
        /// Smaller ranges within the second passed parameter
        let bittyspans = Quadratic.diceRange(pristine: span, chunks: 5)
        
        /// Distances from the middle of each of the smaller ranges.
        let trips = bittyspans.map( { rangeDist(egnar: $0, curve: curve, awaySpeck: speck) } )
        
        /// Sorted version
        let sorTrips = trips.sorted(by: { $0.dist < $1.dist })
        
        /// rangeDist with the smallest distance
        let shrimp = sorTrips[0]
        
        if shrimp.getBridgeDist(curve: curve) < Point3D.Epsilon  {
            closest = (shrimp.range.lowerBound + shrimp.range.upperBound) / 2.0
            return closest
        }  else  {
            closest = try convergeMinDist(speck: speck, span: shrimp.range, curve: curve, layersRemaining: layersRemaining - 1)
        }
        
        return closest
    }

    
    private struct rangeDist   {
        
        var range: ClosedRange<Double>
        var dist: Double
        
        init(egnar: ClosedRange<Double>, curve: Quadratic, awaySpeck: Point3D)   {
            
            self.range = egnar
            
            let middleParam = (egnar.lowerBound + egnar.upperBound) / 2.0
            let onCurve = try! curve.pointAt(t: middleParam)
            self.dist = Point3D.dist(pt1: onCurve, pt2: awaySpeck)
            
        }
        
        func getBridgeDist(curve: Quadratic) -> Double   {
            
            let hyar = try! curve.pointAt(t: self.range.lowerBound)
            let thar = try! curve.pointAt(t: self.range.upperBound)
            
            return Point3D.dist(pt1: hyar, pt2: thar)
        }
    }
    
    
    /// Calculate the crown over a small segment.
    /// Works even with the smaller and larger values reversed?
    /// - Parameters:
    ///   - smallerT:  One location on the curve
    ///   - largerT:  One location on the curve.
    /// - Returns: Maximum distance away from line between ends
    /// - Throws:
    ///     - ParameterRangeError if either end of  the span input is lame
    /// - See: 'testFindCrown' under CubicTests
    public func findCrown(smallerT: Double, largerT: Double) throws -> Double   {
        
        guard self.trimParameters.contains(smallerT) else { throw ParameterRangeError(parA: smallerT) }
        guard self.trimParameters.contains(largerT) else { throw ParameterRangeError(parA: largerT) }

        /// Number of divisions to generate and check
        var count = 20
        
        /// Parameter difference
        let deltaTee = largerT - smallerT
        
        /// A larger number of divisions for a long curve
        let biggerCount = Int(round(abs(deltaTee) * 100.0))
        
        if biggerCount > 20   {
            count = biggerCount
        }
        
        /// Parameter increment to be used
        let step = deltaTee / Double(count)
        
        /// Points to be checked along the curve
        var crownDots = [Point3D]()
        
        /// First point in range
        let anchorA = try! self.pointAt(t: smallerT)
        crownDots.append(anchorA)
        
        for g in 1...count - 1   {
            
            let pip = try! self.pointAt(t: smallerT + Double(g) * step)
            crownDots.append(pip)
        }
        
        /// Last point in range
        let anchorB = try! self.pointAt(t: largerT)
        crownDots.append(anchorB)
        
        let deviation = try! Cubic.crownCalcs(dots: crownDots)
        return deviation
    }
    
    
    /// Finds a higher parameter that meets the crown requirement.
    /// - Parameters:
    ///   - allowableCrown:  Acceptable deviation from curve
    ///   - currentT:  Present value of the driving parameter
    ///   - increasing:  Whether the change in parameter should be up or down
    /// - Returns: New value for driving parameter
    /// - Throws:
    ///     - NegativeAccuracyError for bad allowable crown
    ///     - ParameterRangeError if currentT is lame
    ///     - ConvergenceError if no new value can be found
    public func findStep(allowableCrown: Double, currentT: Double, increasing: Bool) throws -> Double   {
        
        guard allowableCrown > 0.0 else { throw NegativeAccuracyError(acc: allowableCrown) }
            
        guard self.trimParameters.contains(currentT) else { throw ParameterRangeError(parA: currentT) }

        //TODO: This needs testing for boundary conditions and the decreasing flag condition.

        /// How quickly to refine the parameter guess
        let factor = 1.60
        
        /// Change in parameter - constantly refined.
        var step = self.trimParameters.upperBound - currentT
        
        if !increasing   {
            step = -0.9999 * currentT   // I don't remember why that couldn't be -1.0
        }
        
        /// Working value of the parameter
        var trialT: Double
        
        /// Calculated crown
        var deviation: Double
        
        /// Counter to prevent loop runaway
        var safety = 0
        
        repeat   {
            
            if increasing   {
                trialT = currentT + step
                if currentT > (self.trimParameters.upperBound - step)   {   // Prevent parameter value > upperBound
                    trialT = self.trimParameters.upperBound
                }
            }  else {
                trialT = currentT - step
                if currentT < step   {   // Prevent parameter value < 0.0
                    trialT = self.trimParameters.lowerBound
                }
            }
            
            deviation = try! self.findCrown(smallerT: currentT, largerT: trialT)

            step = step / factor     // Prepare for the next iteration
            safety += 1
            
        }  while deviation > allowableCrown  && safety < 16    // Fails ugly!
        
        if safety > 15 { throw ConvergenceError(tnuoc: safety) }

        return trialT
    }
    
    
    /// Generate a series of points along the curve that meet the crown criteria
    /// - Parameters:
    ///   - allowableCrown: Maximum deviation from the actual curve
    /// - Returns: Array of points evenly spaced to comply with the crown parameter
    /// - Throws:
    ///   - NegativeAccuracyError for an input less than zero
    ///   - ParameterRangeError if things go awry
    ///   - ConvergenceError in bizarre cases
    public func approximate(allowableCrown: Double) throws -> [Point3D]   {
        
        guard allowableCrown > 0.0 else { throw NegativeAccuracyError(acc: allowableCrown) }
            
        //TODO: This needs to be tested for the degenerate case of the Quadratic being the same as a LineSeg.
        
        /// Collection of points to be returned
        var chain = [Point3D]()
        
        var currentT = self.trimParameters.lowerBound   // Starting value
        let startPoint = try self.pointAt(t: currentT)
        chain.append(startPoint)
        
        while currentT < self.trimParameters.upperBound   {
            let primoT = try findStep(allowableCrown: allowableCrown, currentT: currentT, increasing: true)
            let milestone = try self.pointAt(t: primoT)
            chain.append(milestone)
            currentT = primoT
        }
        
        return chain
    }
    
    
    /// Construct the plane that contains the curve.
    /// May not work for a trimmed curve.
    /// - Returns: Plane built from end points
    public func buildPlane() -> Plane   {
        
        let alpha = self.getOneEnd()
        let omega = self.getOtherEnd()
        
        let beta = try! self.pointAt(t: 0.52)   // Might not work for a trimmed curve!
        
        let forward = Vector3D(from: beta, towards: alpha, unit: true)
        let rearward = Vector3D(from: beta, towards: omega, unit: true)
        
        var upAndAway = try! Vector3D.crossProduct(lhs: forward, rhs: rearward)
        upAndAway.normalize()
        
        let containingPlane = try! Plane(spot: beta, arrow: upAndAway)   // Vector is know to be a unit vector
        
        return containingPlane
    }
    

    /// Generate even intervals by parameter value.
    /// - Parameters:
    ///   - divs: Number of intervals
    /// - Returns: divs + 1 parameter values
    public func splitParam(divs: Int) -> [Double]   {
        
        let deltaParam = self.trimParameters.upperBound - self.trimParameters.lowerBound
        let paramStep = deltaParam / Double(divs)
        
        /// Evenly split parameter values
        var pins = [Double]()
        
        pins.append(self.trimParameters.lowerBound)
        
        for g in 1..<divs   {
            let pad = self.trimParameters.lowerBound + Double(g) * paramStep
            pins.append(pad)
        }
        
        pins.append(self.trimParameters.upperBound)
        
        return pins
    }
    
    
    /// Intersection points with a line, if the line is in the plane of the curve.
    /// Needs to be a thread safe function.
    /// Ineffective if the intersection is either endpoint.
    /// - Parameters:
    ///   - ray:  The Line to be used for intersecting
    ///   - accuracy:  Optional - How close is close enough?
    /// - Throws:
    ///   - NegativeAccuracyError for an accuracy input less than zero
    ///   - NonCoPlanarLinesError for a Line that isn't in the plane of the curve.
    /// - Returns: Array of points common to both curves
    /// - SeeAlso:  crossing()
    /// - See: 'testIntLine1' and 'testIntLine2' under CubicTests
    public func intersect(ray: Line, accuracy: Double = Point3D.Epsilon) throws -> [PointCrv] {
        
        guard accuracy > 0.0 else { throw NegativeAccuracyError(acc: accuracy) }
        
        let curvePlane = self.buildPlane()
        guard try! Plane.isCoincident(flat: curvePlane, enil: ray)  else  { throw NonCoPlanarLinesError(enilA: ray, enilB: ray) }
                    
        //TODO: Don't forget the nearly tangent case and comparing tangent vectors.
        
        /// The return array
        var crossings = [PointCrv]()
        
        /// Interval in parameter space for hunting
        let shebang = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
        /// Small set of narrow ranges where crossings have been found.
        let targets = crossing(ray: ray, span: shebang, chunks: 100)
        
        for narrowRange in targets   {
            
            if let onecross = try converge(ray: ray, span: narrowRange, accuracy: accuracy, layersRemaining: 8)   {
                crossings.append(onecross)
            }
        }
        
        return crossings
    }
    

    /// Could return 0, 1, or 2 smaller ranges
    public func crossing(ray: Line, span: ClosedRange<Double>, chunks: Int) -> [ClosedRange<Double>]   {
        
        var targetRanges = [ClosedRange<Double>]()
        
        let increment = (span.upperBound - span.lowerBound) / Double(chunks)
        
        /// Working array of smaller intervals
        var chopped = [ClosedRange<Double>]()
        
        /// Lower bound for the current range
        var priorT = 0.0
        
        for g in 1...chunks   {
            let freshT = span.lowerBound + Double(g) * increment
            let bittyRange = ClosedRange<Double>(uncheckedBounds: (lower: priorT, upper: freshT))
            chopped.append(bittyRange)
            
            priorT = freshT   // Prepare for the next iteration
        }
        
        let traffic = chopped.map( { doesCross(span: $0, ray: ray) })
        
        for g in 0..<chunks   {
            if traffic[g] <= 0.0   { targetRanges.append(chopped[g]) }
        }
        
        return targetRanges
    }
    
    
    /// Recursive function to get close enough to the intersection point.
    /// The hazard here for an infinite loop is if the span input doesn't contain a crossing.
    func converge(ray: Line, span: ClosedRange<Double>, accuracy: Double, layersRemaining: Int) throws -> PointCrv?   {
        
        if layersRemaining == 0  { throw ConvergenceError(tnuoc: 0) }   // Safety valve
        
        var collide: PointCrv?
        var orthog: Point3D
        
        let bittyspans = Quadratic.diceRange(pristine: span, chunks: 5)
        
        for onebitty in bittyspans   {
            let proj = doesCross(span: onebitty, ray: ray)
            
            let low = try! self.pointAt(t: onebitty.lowerBound)
            let high = try! self.pointAt(t: onebitty.upperBound)

            if proj == 0.0   {     // I wonder how frequently this will get run?
                if Line.isCoincident(straightA: ray, pip: low)   {
                    collide = PointCrv(x: low.x, y: low.y, z: low.z, t: onebitty.lowerBound)
                    return collide
                }  else  {
                    collide = PointCrv(x: high.x, y: high.y, z: high.z, t: onebitty.upperBound)
                    return collide                }
            }
            
            if proj < 0.0   {
                let sep = Point3D.dist(pt1: low, pt2: high)
                
                if sep < accuracy   {
                    orthog = Point3D.midway(alpha: low, beta: high)
                    let param = (onebitty.lowerBound + onebitty.upperBound) / 2.0
                    collide = PointCrv(x: orthog.x, y: orthog.y, z: orthog.z, t: param)
                    break
                }  else  {
                    collide = try converge(ray: ray, span: onebitty, accuracy: accuracy, layersRemaining: layersRemaining - 1)
                }
                
            }
        }
        
        return collide
    }
    
    
    /// Split a range into pieces
    /// - Parameters:
    ///   - pristine: Original parameter range
    ///   - chunks: The desired number of pieces
    /// - Returns: Array of equal smaller ranges
    /// - SeeAlso: dice
    public static func diceRange(pristine: ClosedRange<Double>, chunks: Int) -> [ClosedRange<Double>]   {
                
        let increment = (pristine.upperBound - pristine.lowerBound) / Double(chunks)
        
        /// Array of smaller ranges
        var rangeHerd = [ClosedRange<Double>]()
        
        var freshLower = pristine.lowerBound
        
        for g in 1...chunks   {
            let freshUpper = pristine.lowerBound + Double(g) * increment
            let freshRange = ClosedRange<Double>(uncheckedBounds: (lower: freshLower, upper: freshUpper))
            rangeHerd.append(freshRange)
            
            freshLower = freshUpper   // Prepare for the next iteration
        }
        
        return rangeHerd
    }
    
    
    /// Find the projection of difference vectors.
    /// - Parameters:
    ///   - span:  Parameter range to be checked
    ///   - ray:  The Line to be used for intersecting
    /// - Returns: Projection - negative if crossing, zero if one point lies on the line. Such as at the vertex of a shape.
    func doesCross(span: ClosedRange<Double>, ray: Line) -> Double   {
        
        // Add a check for a really small parameter range?
        
        /// Closure to develop a vector off the line towards the point.
        let jumpDir: (Double) -> Vector3D = { t in
            
            let pip = try! self.pointAt(t: t)
            let components = ray.resolveRelativeVec(yonder: pip)
            return components.perp
        }
        
        let diffVecNear = jumpDir(span.lowerBound)
        let diffVecFar = jumpDir(span.upperBound)
        
        let projection = Vector3D.dotProduct(lhs: diffVecNear, rhs: diffVecFar)
        
        return projection
    }
    
    
    /// Needed for aligning a curve in a Loop
    public mutating func reverse() {
        
        let freshOmega = self.ptAlpha
        let freshAlpha = self.ptOmega
        
        self.ptAlpha = freshAlpha
        self.ptOmega = freshOmega
        
        let midway = try! self.pointAt(t: 0.5, ignoreTrim: true)
        
        genCoeff(ptA: freshAlpha, beta: midway, betaFraction: 0.5, ptC: freshOmega)
        
        self.ptAlpha = freshAlpha
        self.ptOmega = freshOmega
        
    }
    

    /// Untested version
    /// - Parameters:
    ///   - xirtam: Martix to rotate, translate, and scale.
    /// - Returns: New Quadratic
    public func transform(xirtam: Transform) -> PenCurve {
        
        let midway = try! self.pointAt(t: 0.5, ignoreTrim: true)   // 0.5 is a legitimate value
        let freshMidway = midway.transform(xirtam: xirtam)
        
        var moved = try! Quadratic(ptA: self.ptAlpha.transform(xirtam: xirtam), beta: freshMidway, betaFraction: 0.5, ptC: self.ptOmega.transform(xirtam: xirtam))     // Known good points
        
        try! moved.trimFront(lowParameter: self.trimParameters.lowerBound)   // Transfer the limits
        try! moved.trimBack(highParameter: self.trimParameters.upperBound)
        
        moved.setIntent(purpose: self.usage)   // Copy setting instead of having the default
        
        return moved
    }
    
    
    /// Break the curve up into segments independent of crown.
    /// - Parameters:
    ///   - pieces:  Desired number of blocks
    /// - Returns: Array of Point3D.
    /// - SeeAlso: 'diceRange' and 'approximate'
    public func dice(pieces: Int) -> [Point3D]   {
        
        let interval = (self.trimParameters.upperBound - self.trimParameters.lowerBound) / Double(pieces)
        
        /// The array to be returned
        var pearls = [Point3D]()
        
        for g in stride(from: self.trimParameters.lowerBound, through: self.trimParameters.upperBound, by: interval)   {
            let pip = try! self.pointAt(t: g)
            pearls.append(pip)
        }
        
        return pearls
    }
    

    public func draw(context: CGContext, tform: CGAffineTransform, allowableCrown: Double) throws {
                
        guard allowableCrown > 0.0 else { throw NegativeAccuracyError(acc: allowableCrown) }
            
        /// Array of points in the local coordinate system
        let dots = try! self.approximate(allowableCrown: allowableCrown)
        
        /// Closure to generate a point for display
        let toScreen = { (spot: Point3D) -> CGPoint in
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
    
}
