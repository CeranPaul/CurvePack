//
//  Cubic.swift
//  CurvePack
//
//  Created by Paul on 12/14/15.
//  Copyright © 2023 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation
import CoreGraphics
import simd

// What's the right way to check for equivalence?  End points and control points?

// TODO: Will need a way to find what point, if any, has a particular slope
// TODO: Add a bisecting function for Vector3D

// TODO: Clip from either end and re-parameterize.  But what about 'undo'?  Careful with a lack of proportionality


/// Curve defined by polynomials for each coordinate direction.
/// Parameter must fall within the range of 0.0 to 1.0.
public struct Cubic: PenCurve   {
        
    var ax: Double
    var bx: Double
    var cx: Double
    var dx: Double
    
    var ay: Double
    var by: Double
    var cy: Double
    var dy: Double
    
    var az: Double   // For a curve in the XY plane, these can be ignored, or set to zero
    var bz: Double   // Sounds like a good check to run - in all three axes.
    var cz: Double
    var dz: Double
    
    /// The beginning point
    var ptAlpha: Point3D
    
    /// The end point
    var ptOmega: Point3D
    
    /// The String that hints at the meaning of the curve
    public var usage: String
    
    /// Intended to be bettween 0.0 and 1.0
    public var trimParameters: ClosedRange<Double>
    
    
    /// Build from 12 individual parameters.
    /// - See: 'testCoeffConstruct' under CubicTests
    public init(ax: Double, bx: Double, cx: Double, dx: Double, ay: Double, by: Double, cy: Double, dy: Double, az: Double, bz: Double, cz: Double, dz: Double)   {
        
        self.ax = ax
        self.bx = bx
        self.cx = cx
        self.dx = dx
        
        self.ay = ay
        self.by = by
        self.cy = cy
        self.dy = dy
        
        self.az = az
        self.bz = bz
        self.cz = cz
        self.dz = dz
        
        ptAlpha = Point3D(x: dx, y: dy, z: dz)   // Create the beginning point from parameters
        
        
        let sumX = self.ax + self.bx + self.cx + self.dx   // Create the end point from an assumed parameter value of 1.0
        let sumY = self.ay + self.by + self.cy + self.dy
        let sumZ = self.az + self.bz + self.cz + self.dz
        
        ptOmega = Point3D(x: sumX, y: sumY, z: sumZ)
        
        
        self.usage = "Ordinary"
        
        self.trimParameters = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
    }
    
    
    /// Build from two points and two slopes.
    /// The assignment statements come from an algebraic manipulation of the equations
    /// in the Wikipedia article on Cubic Hermite spline.
    /// - Parameters:
    ///   - ptA: First end point
    ///   - slopeA: Slope that goes with the first end point
    ///   - ptB: Other end point
    ///   - slopeB: Slope that goes with the second end point
    /// There are checks here for input points that should be added!
    /// - Throws:
    ///     - ZeroVectorError if either of the slopes aren't good
    ///     - CoincidentPointsError for problems with ptA and ptB
    /// - See: 'testHermite' and 'testSumsHermite' under CubicTests
    public init(ptA: Point3D, slopeA: Vector3D, ptB: Point3D, slopeB: Vector3D) throws   {
        
        guard !slopeA.isZero() else { throw ZeroVectorError(dir: slopeA) }
        guard !slopeB.isZero() else { throw ZeroVectorError(dir: slopeB) }
        
        guard !(ptA == ptB) else { throw CoincidentPointsError(dupePt: ptA) }

        ptAlpha = ptA
        ptOmega = ptB
        
        self.ax = 2.0 * ptA.x + slopeA.i - 2.0 * ptB.x + slopeB.i
        self.bx = -3.0 * ptA.x - 2.0 * slopeA.i + 3.0 * ptB.x - slopeB.i
        self.cx = slopeA.i
        self.dx = ptA.x
        
        self.ay = 2.0 * ptA.y + slopeA.j - 2.0 * ptB.y + slopeB.j
        self.by = -3.0 * ptA.y - 2.0 * slopeA.j + 3.0 * ptB.y - slopeB.j
        self.cy = slopeA.j
        self.dy = ptA.y
        
        self.az = 2.0 * ptA.z + slopeA.k - 2.0 * ptB.z + slopeB.k
        self.bz = -3.0 * ptA.z - 2.0 * slopeA.k + 3.0 * ptB.z - slopeB.k
        self.cz = slopeA.k
        self.dz = ptA.z
        
        self.usage = "Ordinary"
        
        self.trimParameters = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
    }
    
    
    /// Build from two end points and two control points.
    /// Assignment statements from an algebraic manipulation of the equations
    /// in the Wikipedia article on Bezier Curve.
    /// - Parameters:
    ///   - ptA: First end point
    ///   - controlA: Control point for first end
    ///   - ptB: Other end point
    ///   - controlB: Control point for second end
    /// There are checks here for input points that should be added!
    /// - Throws:
    ///     - CoincidentPointsError if the inputs are lame
    /// - See: 'testSumsBezier' under CubicTests
    public init(ptA: Point3D, controlA: Point3D, controlB: Point3D, ptB: Point3D) throws   {
        
        let pool = [ptA, controlA, controlB, ptB]
        guard try! Point3D.isUniquePool(flock: pool) else { throw CoincidentPointsError(dupePt: ptA)}
        
        self.ptAlpha = ptA
        self.ptOmega = ptB
                
        
        self.ax = 3.0 * controlA.x - self.ptAlpha.x - 3.0 * controlB.x + self.ptOmega.x
        self.bx = 3.0 * self.ptAlpha.x - 6.0 * controlA.x + 3.0 * controlB.x
        self.cx = 3.0 * controlA.x - 3.0 * self.ptAlpha.x
        self.dx = self.ptAlpha.x
        
        self.ay = 3.0 * controlA.y - self.ptAlpha.y - 3.0 * controlB.y + self.ptOmega.y
        self.by = 3.0 * self.ptAlpha.y - 6.0 * controlA.y + 3.0 * controlB.y
        self.cy = 3.0 * controlA.y - 3.0 * self.ptAlpha.y
        self.dy = self.ptAlpha.y
        
        self.az = 3.0 * controlA.z - self.ptAlpha.z - 3.0 * controlB.z + self.ptOmega.z
        self.bz = 3.0 * self.ptAlpha.z - 6.0 * controlA.z + 3.0 * controlB.z
        self.cz = 3.0 * controlA.z - 3.0 * self.ptAlpha.z
        self.dz = self.ptAlpha.z
        
        self.usage = "Ordinary"
        
        self.trimParameters = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
    }
    
    
    /// Construct from four points that lie on the curve.  This is the way to build an offset curve.
    /// - Parameters:
    ///   - alpha: First point
    ///   - beta: Second point
    ///   - betaFraction: Portion along the curve for point beta
    ///   - gamma: Third point
    ///   - gammaFraction: Portion along the curve for point gamma
    ///   - delta: Last point
    /// - Throws:
    ///     - ParameterRangeError if one of the fractions is lame
    ///     - CoincidentPointsError if they are not unique
    public init(alpha: Point3D, beta: Point3D, betaFraction: Double, gamma: Point3D, gammaFraction: Double, delta: Point3D) throws  {
        
        self.trimParameters = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
        guard self.trimParameters.contains(betaFraction) else { throw ParameterRangeError(parA: betaFraction) }     // Why?
        guard self.trimParameters.contains(gammaFraction) else { throw ParameterRangeError(parA: gammaFraction) }
        
        let pool = [alpha, beta, gamma, delta]
        guard try! Point3D.isUniquePool(flock: pool) else { throw CoincidentPointsError(dupePt: alpha)}
        
        // TODO: Then add tests to see that the guard statements are doing their job
        
        self.ptAlpha = alpha
        self.ptOmega = delta
        
        // Rearrange coordinates into an array
        let rowX = SIMD4<Double>(alpha.x, beta.x, gamma.x, delta.x)
        let rowY = SIMD4<Double>(alpha.y, beta.y, gamma.y, delta.y)
        let rowZ = SIMD4<Double>(alpha.z, beta.z, gamma.z, delta.z)
        
        // Build a 4x4 of parameter values to various powers
        let row1 = SIMD4<Double>(0.0, 0.0, 0.0, 1.0)
        
        let betaFraction2 = betaFraction * betaFraction
        let row2 = SIMD4<Double>(betaFraction * betaFraction2, betaFraction2, betaFraction, 1.0)
        
        let gammaFraction2 = gammaFraction * gammaFraction
        let row3 = SIMD4<Double>(gammaFraction * gammaFraction2, gammaFraction2, gammaFraction, 1.0)
        
        let row4 = SIMD4<Double>(1.0, 1.0, 1.0, 1.0)
        
        
        /// Intermediate collection for building the matrix
        var partial: [SIMD4<Double>]
        partial = [row1, row2, row3, row4]
        
        /// Matrix of t from several points raised to various powers
        let tPowers = double4x4(partial)
        
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
        self.dx = coeffX[3]
        self.ay = coeffY[0]
        self.by = coeffY[1]
        self.cy = coeffY[2]
        self.dy = coeffY[3]
        self.az = coeffZ[0]
        self.bz = coeffZ[1]
        self.cz = coeffZ[2]
        self.dz = coeffZ[3]
        
        
        self.usage = "Ordinary"
                
    }
    
    
    /// Build from a location, it's tangency, and two other locations. For a spline.
    /// The intent is that only alpha through beta will get used.
    /// - Throws:
    ///     - ParameterRangeError if one of the fractions is lame
    ///     - CoincidentPointsError if the input points are not unique
    /// - See: 'testSlopeStart' under CubicTests
    public init(alpha: Point3D, alphaPrime: Vector3D, beta: Point3D, betaFraction: Double, gamma: Point3D) throws  {
        
        let pool = [alpha, beta, gamma]
        
        guard try! Point3D.isUniquePool(flock: pool)  else  { throw CoincidentPointsError(dupePt: alpha) }
        
        
        let wholeRange = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
        guard wholeRange.contains(betaFraction)  else  { throw ParameterRangeError(parA: betaFraction) }
        
        
        // Rearrange coordinates into an array
        let rowX = SIMD4<Double>(alpha.x, alphaPrime.i, beta.x, gamma.x)
        let rowY = SIMD4<Double>(alpha.y, alphaPrime.j, beta.y, gamma.y)
        let rowZ = SIMD4<Double>(alpha.z, alphaPrime.k, beta.z, gamma.z)
        
        // Build a 4x4 of parameter values to various powers
        let row1 = SIMD4<Double>(0.0, 0.0, 0.0, 1.0)
        
        let row2 = SIMD4<Double>(0.0, 0.0, 1.0, 0.0)

        let betaFraction2 = betaFraction * betaFraction
        let row3 = SIMD4<Double>(betaFraction * betaFraction2, betaFraction2, betaFraction, 1.0)
        
        let gammaFraction = 1.0
        let gammaFraction2 = gammaFraction * gammaFraction
        let row4 = SIMD4<Double>(gammaFraction * gammaFraction2, gammaFraction2, gammaFraction, 1.0)
        
        
        /// Intermediate collection for building the matrix
        var partial: [SIMD4<Double>]
        partial = [row1, row2, row3, row4]
        
        /// Matrix of t from several points raised to various powers
        let tPowers = double4x4(partial)
        
        let trans = tPowers.transpose   // simd representation is different than what I had in college
        
        
        /// Inverse of the above matrix
        let nvers = trans.inverse
        
        let coeffX = nvers * rowX
        let coeffY = nvers * rowY
        let coeffZ = nvers * rowZ
        
        /// The resulting curve
        self.ax = coeffX[0]
        self.bx = coeffX[1]
        self.cx = coeffX[2]
        self.dx = coeffX[3]
        self.ay = coeffY[0]
        self.by = coeffY[1]
        self.cy = coeffY[2]
        self.dy = coeffY[3]
        self.az = coeffZ[0]
        self.bz = coeffZ[1]
        self.cz = coeffZ[2]
        self.dz = coeffZ[3]
        
        self.ptAlpha = alpha
        self.ptOmega = gamma
        
        self.trimParameters = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: betaFraction))
        
        self.usage = "Ordinary"
                
    }
    
    
    /// Copy constructor. Trim parameters are NOT duplicated.
    /// - Parameters:
    ///   - sourceCurve: Cubic to be duplicated
    /// - Returns: New Cubic that is not trimmed
    /// - See: 'testCopyConst' under CubicTests
    public init(sourceCurve: Cubic)   {
        
        self.ptAlpha = try! sourceCurve.pointAt(t: 0.0, ignoreTrim: true)
        self.ptOmega = try! sourceCurve.pointAt(t: 1.0, ignoreTrim: true)
        
        // Set the curve coefficients
        self.ax = sourceCurve.ax
        self.bx = sourceCurve.bx
        self.cx = sourceCurve.cx
        self.dx = sourceCurve.dx
        self.ay = sourceCurve.ay
        self.by = sourceCurve.by
        self.cy = sourceCurve.cy
        self.dy = sourceCurve.dy
        self.az = sourceCurve.az
        self.bz = sourceCurve.bz
        self.cz = sourceCurve.cz
        self.dz = sourceCurve.dz


        self.usage = sourceCurve.usage
        
        self.trimParameters = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
    }
    
    
    
    /// Generate the 12 coefficiients that define the curve
    private mutating func genCoeff(alpha: Point3D, beta: Point3D, betaFraction: Double, gamma: Point3D, gammaFraction: Double, delta: Point3D) -> Void   {
        
        // Rearrange coordinates into an array
        let rowX = SIMD4<Double>(alpha.x, beta.x, gamma.x, delta.x)
        let rowY = SIMD4<Double>(alpha.y, beta.y, gamma.y, delta.y)
        let rowZ = SIMD4<Double>(alpha.z, beta.z, gamma.z, delta.z)
        
        // Build a 4x4 of parameter values to various powers
        let row1 = SIMD4<Double>(0.0, 0.0, 0.0, 1.0)
        
        let betaFraction2 = betaFraction * betaFraction
        let row2 = SIMD4<Double>(betaFraction * betaFraction2, betaFraction2, betaFraction, 1.0)
        
        let gammaFraction2 = gammaFraction * gammaFraction
        let row3 = SIMD4<Double>(gammaFraction * gammaFraction2, gammaFraction2, gammaFraction, 1.0)
        
        let row4 = SIMD4<Double>(1.0, 1.0, 1.0, 1.0)
        
        
        /// Intermediate collection for building the matrix
        var partial: [SIMD4<Double>]
        partial = [row1, row2, row3, row4]
        
        /// Matrix of t from several points raised to various powers
        let tPowers = double4x4(partial)
        
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
        self.dx = coeffX[3]
        self.ay = coeffY[0]
        self.by = coeffY[1]
        self.cy = coeffY[2]
        self.dy = coeffY[3]
        self.az = coeffZ[0]
        self.bz = coeffZ[1]
        self.cz = coeffZ[2]
        self.dz = coeffZ[3]
        
    }
    
    
    /// Attach new meaning to the curve.
    /// - See: 'testSetIntent' under CubicTests
    public mutating func setIntent(purpose: String) -> Void  {
        self.usage = purpose
    }
    
    
    /// Fetch the location of an end.
    /// - See: 'getOtherEnd()'
    /// - See: 'testGetters' under CubicTests
    public func getOneEnd() -> Point3D   {
        let startParam = self.trimParameters.lowerBound
        return try! self.pointAt(t: startParam)
    }
    
    /// Fetch the location of the opposite end.
    /// - See: 'getOneEnd()'
    /// - See: 'testGetters' under CubicTests
    public func getOtherEnd() -> Point3D   {
        let finishParam = self.trimParameters.upperBound
        return try! self.pointAt(t: finishParam)
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
    
    

    /// Supply the point on the curve for the input parameter value.
    /// Some notations show "u" as the parameter, instead of "t"
    /// - Parameters:
    ///   - t:  Curve parameter value.  Assumed 0 < t < 1.
    /// - Returns: Point location at the parameter value
    /// - Throws:
    ///     - ParameterRangeError if the input is lame
    /// - See: 'testPointAt' under CubicTests
    public func pointAt(t: Double, ignoreTrim: Bool = false) throws -> Point3D   {
        
        if ignoreTrim   {
            
            /// The entire possible parameter range.
            let wholeSheBang = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
            
            guard wholeSheBang.contains(t) else { throw ParameterRangeError(parA: t) }
            
        }  else  {
            guard self.trimParameters.contains(t) else { throw ParameterRangeError(parA: t) }
        }
        
        let t2 = t * t
        let t3 = t2 * t
        
        // This notation came from "Fundamentals of Interactive Computer Graphics" by Foley and Van Dam
        // Warning!  The relationship of coefficients and powers of t might be unexpected, as notations vary
        let myX = ax * t3 + bx * t2 + cx * t + dx
        let myY = ay * t3 + by * t2 + cy * t + dy
        let myZ = az * t3 + bz * t2 + cz * t + dz
        
        return Point3D(x: myX, y: myY, z: myZ)
    }
    
    
    /// Differentiate to find the tangent vector for the input parameter.
    /// Some notations show "u" as the parameter, instead of "t".
    /// - Parameters:
    ///   - t:  Curve parameter value.  Checked to be 0 < t < 1.
    ///   - ignoreTrim: Whether or not to check against the boundaries for a trimmed curve.
    /// - Returns:  Non-normalized vector
    /// - Throws:
    ///     - ParameterRangeError if the input is lame
    /// - See: 'testTangentAt' under CubicTests
    public func tangentAt(t: Double, ignoreTrim: Bool = false) throws -> Vector3D   {
        
        if ignoreTrim   {
            
            /// The entire possible parameter range.
            let wholeSheBang = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
            
            guard wholeSheBang.contains(t) else { throw ParameterRangeError(parA: t) }
            
        }  else  {
            guard self.trimParameters.contains(t) else { throw ParameterRangeError(parA: t) }
        }
        
        let t2 = t * t
        
        // This is the component matrix differentiated once
        let myI = 3.0 * ax * t2 + 2.0 * bx * t + cx
        let myJ = 3.0 * ay * t2 + 2.0 * by * t + cy
        let myK = 3.0 * az * t2 + 2.0 * bz * t + cz
        
        return Vector3D(i: myI, j: myJ, k: myK)    // Notice that this is not normalized!
    }
    
    
    /// Report the length of the entire curve.
    /// Perhaps should depend on allowableCrown.
    /// - Returns: Double
    public func getLength() -> Double   {
        
        /// Evenly spaced points along the trimmed portion of the curve
        var dots = [Point3D]()
        
        for g in stride(from: self.trimParameters.lowerBound, through: self.trimParameters.upperBound, by: 0.01)   {
            let pip = try! self.pointAt(t: g)   // Parameters fall within the valid range.
            dots.append(pip)
        }
        
        /// Return value for length
        var total = 0.0
        
        for g in 1..<dots.count   {
            let hop = Point3D.dist(pt1: dots[g - 1], pt2: dots[g])
            total += hop
        }
        
        return total
    }
    

    /// Tuple of points and distances from the lower parameter.
    /// You want to compute this once, and not in the middle of using the Cubic.
    /// Where is this used?
    public var pearls: (pip: [Point3D], dists: [Double], tees: [Double])  {
        
        let span = trimParameters.upperBound - trimParameters.lowerBound
        let increment = span / 50.0
        
        ///Array of parameter values used
        var params = [Double]()
        
        var beads = [Point3D]()
        for g in 0..<50   {
            let freshT = trimParameters.lowerBound + Double(g) * increment
            params.append(freshT)
            let pip = try! pointAt(t: freshT)   // Known to be in range
            beads.append(pip)
        }
        
        params.append(trimParameters.upperBound)
        let tailEnd = try! pointAt(t: trimParameters.upperBound)
        beads.append(tailEnd)
        
        var lengths = [Double]()
        
        lengths.append(0.0)
        
        for g in 1...50   {
            let hop = lengths [g - 1] + Point3D.dist(pt1: beads[g - 1], pt2: beads[g])
            lengths.append(hop)
        }
        
        return (beads, lengths, params)   // Arrays of 51 elements that match
    }
    
    

    //TODO: Can this be consolidated with 'isCoincident'?
    
    /// Find the curve's closest point.
    /// - Parameters:
    ///   - nearby:  Target point
    ///   - accuracy:  Optional - What iteration change is close enough?
    /// - Returns: A nearby Point3D on the curve, and its parameter.
    /// - SeeAlso:  refineRangeDist()
    /// - Throws:
    ///     - CovergenceError if iterations fail
    ///     - NegativeAccuracyError for a bad input
    /// - See: 'testFindClosest' under CubicTests
    public func findClosest(nearby: Point3D, accuracy: Double = Point3D.Epsilon) throws -> (pip: Point3D, param: Double)   {
        
        guard accuracy > 0.0 else { throw NegativeAccuracyError(acc: accuracy) }
            
        
        /// Working parameter through the iterations, and part of the return tuple.
        var midRangeParameter = (self.trimParameters.lowerBound + self.trimParameters.upperBound) / 2.0
        
        /// Working value for nearest point
        var priorPt = try! self.pointAt(t: midRangeParameter)
        
        /// Working value for interval on the curve being checked
        var curRange = self.trimParameters
        
        /// Separation between current iteration and previous iteration.
        var successiveSep = Double.greatestFiniteMagnitude   // Starting value
        
        /// A counter to prevent a runaway loop
        var tally = 0
        
        repeat   {
            
            if let refinedRange = try self.refineRangeDist(nearby: nearby, span: curRange)  {
                
                midRangeParameter = (refinedRange.lowerBound + refinedRange.upperBound) / 2.0
                let midPt = try! self.pointAt(t: midRangeParameter)
                
                successiveSep = Point3D.dist(pt1: priorPt, pt2: midPt)
                
                priorPt = midPt   // Set up for the next iteration
                curRange = refinedRange
            }
            
            tally += 1
            
            if tally > 6 { throw ConvergenceError(tnuoc: tally) }
            
        } while successiveSep > accuracy  &&  tally < 7   // Fails ugly for the second clause!
        
        return (priorPt, midRangeParameter)
    }
    
    
    /// Check whether a point is or isn't perched on the curve.
    ///  Part of the PenCurve protocol.
    /// - Parameters:
    ///   - speck:  Point near the curve.
    ///   - accuracy: The small distance that defines "equal" points. Should be positive.
    /// - Throws:
    ///     - ConvergenceError if eight iterations are not sufficient
    ///     - NegativeAccuracyError for a bad input
    /// - Returns: Flag, and optional parameter value
    /// - See: 'testPerch' under CubicTests
    public func isCoincident(speck: Point3D, accuracy: Double = Point3D.Epsilon) throws -> (flag: Bool, param: Double?)   {
                
        guard accuracy > 0.0 else { throw NegativeAccuracyError(acc: accuracy) }

        
        // Shortcuts!
        if speck == self.ptAlpha   { return (true, self.trimParameters.lowerBound) }
        if speck == self.ptOmega   { return (true, self.trimParameters.upperBound) }
        
        
        /// Itty-bitty ranges along the curve
        let smallRanges = self.diceRange(pristine: self.trimParameters, chunks: 40)
        
        /// Distances to the target point (and parameter ranges)
        let seps = smallRanges.map( { rangeDist(egnar: $0, curve: self, awaySpeck: speck) } )
        
        /// True length along the curve
        let curveLength = self.getLength()
        
        /// Ranges whose midpoint is close enough to be of interest.
        let rangesOfInterest = seps.filter( { $0.dist < curveLength / 4.0 } )
        
        /// Exit if the speck isn't close to any range
        if rangesOfInterest.count == 0   { return (false, nil) }
        
        
        /// Ranges to speck in increasing order
        let rankedRanges = rangesOfInterest.sorted(by: { $0.dist < $1.dist } )
        
        /// Range of parameter to use for a refined check on the closest range
        let closestSpan = rankedRanges[0].range
        
        /// Parameter for the curve point that is nearest
        let closestParam = try convergeMinDist(speck: speck, span: closestSpan, curve: self, layersRemaining: 8)
        
        let closestPoint = try self.pointAt(t: closestParam)
        let flag = Point3D.dist(pt1: closestPoint, pt2: speck) < accuracy
        
        return (flag, closestParam)
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
    private func convergeMinDist(speck: Point3D, span: ClosedRange<Double>, curve: Cubic, layersRemaining: Int) throws -> Double   {
        
        if layersRemaining == 0  { throw ConvergenceError(tnuoc: 0) }   // Safety valve
        
        /// Parameter value to be returned
        var closest: Double
        
        /// Smaller ranges within the second passed parameter
        let bittyspans = self.diceRange(pristine: span, chunks: 5)
        
        /// Ranges and distances from the middle of each of the smaller ranges.
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
    
    
    /// For use in 'isCoincident' and 'convergeMinDist'
    private struct rangeDist   {
        
        /// Parameter range on the Cubic
        var range: ClosedRange<Double>
        var dist: Double
        
        init(egnar: ClosedRange<Double>, curve: Cubic, awaySpeck: Point3D)   {
            
            self.range = egnar
            
            let middleParam = (egnar.lowerBound + egnar.upperBound) / 2.0
            let onCurve = try! curve.pointAt(t: middleParam)   // Since the range is well-behaved
            self.dist = Point3D.dist(pt1: onCurve, pt2: awaySpeck)
            
        }
        
        
        // Find the span across the parameter range
        func getBridgeDist(curve: Cubic) -> Double   {
            
            let hyar = try! curve.pointAt(t: self.range.lowerBound)
            let thar = try! curve.pointAt(t: self.range.upperBound)
            
            return Point3D.dist(pt1: hyar, pt2: thar)
        }
    }
    
    
    /// Generate the plane that the curve lies in, if possible.
    /// - Returns: Optional Plane
    public func genPlane() -> Plane?   {
        
        let midPoint = try! self.pointAt(t: 0.53, ignoreTrim: true)
        
        let linearFlag = Point3D.isThreeLinear(alpha: self.ptAlpha, beta: midPoint, gamma: self.ptOmega)
        
        if !linearFlag   {
            
            /// Trial plane
            let flat = try! Plane(alpha: self.ptAlpha, beta: midPoint, gamma: self.ptOmega)   // Points are unique and non-linear
            
            for g in stride(from: 0.1, through: 0.9, by: 0.10)   {
                
                let pip = try! self.pointAt(t: g, ignoreTrim: true)   // Values of 'g' are in range
                
                let flatFlag = try! Plane.isCoincident(flat: flat, pip: pip)    // Default value for accuracy is positive
                
                if !flatFlag { return nil }   // Bail on any point out of plane
            }
            
            return flat   // Nine points along the curve were on the plane.
        }
        
        return nil
    }
    
    
    /// Create a new curve translated, scaled, and rotated by the matrix.
    /// - Parameters:
    ///   - xirtam: Matrix containing translation, rotation, and scaling to be applied
    /// - See: 'testTransform' under CubicTests
    public func transform(xirtam: Transform) -> PenCurve   {
        
        let tAlpha = self.ptAlpha.transform(xirtam: xirtam)
        let tOmega = self.ptOmega.transform(xirtam: xirtam)
        
        let t1 = 0.33
        let betaLoc = try! self.pointAt(t: t1, ignoreTrim: true)
        let beta = betaLoc.transform(xirtam: xirtam)

        let t2 = 0.67
        let gammaLoc = try! self.pointAt(t: t2, ignoreTrim: true)
        let gamma = gammaLoc.transform(xirtam: xirtam)

        
        var fresh = try! Cubic(alpha: tAlpha, beta: beta, betaFraction: t1, gamma: gamma, gammaFraction: t2, delta: tOmega)
        try! fresh.trimFront(lowParameter: self.trimParameters.lowerBound)   // Transfer the limits
        try! fresh.trimBack(highParameter: self.trimParameters.upperBound)
        
        fresh.setIntent(purpose: self.usage)   // Copy setting instead of having the default
        
        return fresh
    }
    
    
    /// Flip the order of the end points (and control points).  Used to align members of a Loop.
    /// Ignores trim parameters.
    /// - See: 'testReverse' under CubicTests
    public mutating func reverse() -> Void  {
        
        let freshDelta = self.ptAlpha
        let freshAlpha = self.ptOmega
        
        let freshBeta = try! self.pointAt(t: 0.70, ignoreTrim: true)
        let freshGamma = try! self.pointAt(t: 0.35, ignoreTrim: true)
        
        self.genCoeff(alpha: freshAlpha, beta: freshBeta, betaFraction: 0.30, gamma: freshGamma, gammaFraction: 0.65, delta: freshDelta)
        
        self.ptAlpha = freshAlpha
        self.ptOmega = freshDelta
        
    }
    
    

    /// Calculate the proper surrounding box
    /// Increase the number of intermediate points as necessary
    /// This same techniques could be used for other parametric curves
    /// - Returns: OrthoVol
    /// - See: 'testExtent' under CubicTests
    public func getExtent() -> OrthoVol   {
        
        /// Number of check points along the curve
        let pieces = 15
        
        let step = (self.trimParameters.upperBound - self.trimParameters.lowerBound) / Double(pieces)
        let limit = pieces - 1
        
        var bucketX = [Double]()
        var bucketY = [Double]()
        var bucketZ = [Double]()

        for u in 1...limit   {
            let pip = try! self.pointAt(t: self.trimParameters.lowerBound + Double(u) * step)
            bucketX.append(pip.x)
            bucketY.append(pip.y)
            bucketZ.append(pip.z)
        }
        
        bucketX.append(ptOmega.x)
        bucketY.append(ptOmega.y)
        bucketZ.append(ptOmega.z)

        var maxX = bucketX.reduce(ptAlpha.x, max)
        var minX = bucketX.reduce(ptAlpha.x, min)
                
        var maxY = bucketY.reduce(ptAlpha.y, max)
        var minY = bucketY.reduce(ptAlpha.y, min)
        
        var maxZ = bucketZ.reduce(ptAlpha.z, max)
        var minZ = bucketZ.reduce(ptAlpha.z, min)
        
        
        // Avoid the case of zero thickness
        let diffX = maxX - minX
        let diffY = maxY - minY
        let diffZ = maxZ - minZ
        
        let bigDiff = max(diffX, diffY, diffZ)
        
        /// Minimum thickness for the volume
        let minThick = 0.01 * bigDiff
        
        let skinny = min(diffX, diffY, diffZ)
        
           // Check if any direction is too thin
        if skinny < minThick   {
            
            switch skinny   {
                
            case diffX:
                maxX += 0.5 * minThick
                minX -= 0.5 * minThick
                
            case diffY:
                maxY += 0.5 * minThick
                minY -= 0.5 * minThick
                
            case diffZ:
                maxZ += 0.5 * minThick
                minZ -= 0.5 * minThick
                
            default:   // Never should get here
                maxZ += 0.5 * minThick
                minZ -= 0.5 * minThick
                
            }
            
        }
        
        let box = OrthoVol(minX: minX, maxX: maxX, minY: minY, maxY: maxY, minZ: minZ, maxZ: maxZ)
        
        return box
    }
    
    /// Create a String with X coefficient values to be printed
    public func coeffX() -> String   {
        
        let axF = String(format: "%.3f", self.ax)
        let bxF = String(format: "%.3f", self.bx)
        let cxF = String(format: "%.3f", self.cx)
        let dxF = String(format: "%.3f", self.dx)

        let gnirts = "X:  " + axF + "  " + bxF + "  " + cxF + "  " + dxF
        
        return gnirts
    }
    
    /// Create a String with Y coefficient values to be printed
    public func coeffY() -> String   {
        
        let ayF = String(format: "%.3f", self.ay)
        let byF = String(format: "%.3f", self.by)
        let cyF = String(format: "%.3f", self.cy)
        let dyF = String(format: "%.3f", self.dy)

        let gnirts = "Y:  " + ayF + "  " + byF + "  " + cyF + "  " + dyF
        
        return gnirts
    }
    
    /// Create a String with Z coefficient values to be printed
    public func coeffZ() -> String   {
        
        let azF = String(format: "%.3f", self.az)
        let bzF = String(format: "%.3f", self.bz)
        let czF = String(format: "%.3f", self.cz)
        let dzF = String(format: "%.3f", self.dz)

        let gnirts = "Z:  " + azF + "  " + bzF + "  " + czF + "  " + dzF
        
        return gnirts
    }
    

    /// Split a range into pieces
    /// - Parameters:
    ///   - pristine: Original parameter range
    ///   - chunks: Desired number of pieces
    /// - Returns: Array of equal smaller ranges
    /// - SeeAlso: dice
    public func diceRange(pristine: ClosedRange<Double>, chunks: Int) -> [ClosedRange<Double>]   {
                
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
    
    
     /// Break the curve up into segments every 0.01 in parameter space.
    /// - Returns: Array of Point3D.
    public func dice() -> [Point3D]   {
        
        /// The array to be returned
        var pearls = [Point3D]()
        
        for g in stride(from: self.trimParameters.lowerBound, through: self.trimParameters.upperBound, by: 0.01)   {
            let pip = try! self.pointAt(t: g)
            pearls.append(pip)
        }
        
        return pearls
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
    
    
    /// Intersection points with a line.
    /// Needs to be a thread safe function.
    /// Ineffective if the intersection is either endpoint.
    /// - Parameters:
    ///   - ray:  The Line to be used for intersecting
    ///   - accuracy:  Optional - How close is close enough?
    /// - Returns: Array of points common to both curves - though for now it will return only the first one
    /// - SeeAlso:  crossing()
    /// - See: 'testIntLine1' and 'testIntLine2' under CubicTests
    public func intersect(ray: Line, accuracy: Double = Point3D.Epsilon) throws -> [PointCrv] {
        
        guard accuracy > 0.0 else { throw NegativeAccuracyError(acc: accuracy) }
                    
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
    

    /// Could return 0, 1, 2, or 3 smaller ranges
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

        let bittyspans = chopRange(pristine: span, chunks: 5)
        
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
                    return collide
                }
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
    public func chopRange(pristine: ClosedRange<Double>, chunks: Int) -> [ClosedRange<Double>]   {
                
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
    public func findStep(allowableCrown: Double, currentT: Double) throws -> Double   {
        
        guard allowableCrown > 0.0 else { throw NegativeAccuracyError(acc: allowableCrown) }
            
        guard self.trimParameters.contains(currentT) else { throw ParameterRangeError(parA: currentT) }

        //TODO: This needs testing for boundary conditions and the decreasing flag condition.

        /// How quickly to refine the parameter guess
        let divisor = 1.60
        
        /// Change in parameter - constantly refined.
        var step = self.trimParameters.upperBound - currentT
        
        /// Working value of the parameter
        var trialT: Double
        
        /// Calculated crown
        var deviation: Double
        
        /// Counter to prevent loop runaway
        var safety = 0
        
        repeat   {
            
            trialT = currentT + step
            if currentT > (self.trimParameters.upperBound - step)   {   // Prevent parameter value > curve limits
                trialT = self.trimParameters.upperBound
            }
            
            deviation = try! self.findCrown(smallerT: currentT, largerT: trialT)

            step = step / divisor     // Prepare for the next iteration
            safety += 1
            
        }  while deviation > allowableCrown  && safety < 16    // Fails ugly!
        
        if safety > 15 { throw ConvergenceError(tnuoc: safety) }

        return trialT
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
    
    /// Calculate deviation from a LineSeg. Also used by Quadratic and Involute.
    /// - Parameters:
    ///   - dots:  Array of Point3D.  Order is assumed.
    /// - Throws:
    ///     - TinyArrayError if less than three points are passed in
    ///     - CoincidentPointsError if first and last points are not different
    /// - Returns: Largest separation.
    public static func crownCalcs(dots: [Point3D]) throws -> Double   {
        
        guard dots.count > 2 else { throw TinyArrayError(tnuoc: dots.count)}
        
        /// Chord between the first and last points of the input Array.
        let baseline = try LineSeg(end1: dots.first!, end2: dots.last!)   // The guard statement ensures that there will be three or more values.
        
        /// Separation values from the chord line
        let seps = dots.map( { baseline.resolveRelative(speck: $0).away } )
        let curCrown = seps.max()!   // The guard statement ensures that there will be three or more values.
        
        return curCrown
    }
    
    /// Generate a series of points along the curve that meet the crown criteria
    /// - Parameters:
    ///   - allowableCrown: Maximum deviation from the actual curve
    /// - Returns: Array of points evenly spaced to comply with the crown parameter
    /// - Throws:
    ///   - NegativeAccuracyError for an input less than zero
    ///   - ParameterRangeError if things go awry
    ///   - ConvergenceError in bizarre cases
    /// - See: 'testApproximate' under CubicTests
    public func approximate(allowableCrown: Double) throws -> [Point3D]   {
        
        guard allowableCrown > 0.0 else { throw NegativeAccuracyError(acc: allowableCrown) }
            
        //TODO: This needs to be tested for the degenerate case of the Cubic being the same as a LineSeg.
        
        /// Collection of points to be returned
        var chain = [Point3D]()
        
        var currentT = self.trimParameters.lowerBound   // Starting value
        let startPoint = try self.pointAt(t: currentT)
        chain.append(startPoint)
        
        while currentT < self.trimParameters.upperBound   {
            let primoT = try findStep(allowableCrown: allowableCrown, currentT: currentT)
            let milestoneL = try self.pointAt(t: primoT)
            chain.append(milestoneL)
            currentT = primoT
        }
        
        return chain
    }
    
    
    /// Second derivative of the curve equation.
    ///   - t:  Value of the driving parameter
    /// - Returns: A non-normalized Vector3D.
    /// - Throws:
    ///     - ParameterRangeError if the input parameter is lame
    public func deriv2(t: Double) throws -> Vector3D   {
        
        guard self.trimParameters.contains(t) else { throw ParameterRangeError(parA: t) }
    
        // This is the component matrix differentiated twice
        let myI = 6.0 * ax * t + 2.0 * bx
        let myJ = 6.0 * ay * t + 2.0 * by
        let myK = 6.0 * az * t + 2.0 * bz
    
        return Vector3D(i: myI, j: myJ, k: myK)    // Notice that this is not normalized!
    
    }
    
    
    
    /// Find the range of the parameter where the point is closest to the curve.
    /// - Parameters:
    ///   - nearby:  Target point
    ///   - span:  A range of the curve parameter t in which to hunt
    /// - Returns: A smaller ClosedRange<Double>.
    /// - Throws:
    ///     - ParameterRangeError if either end of  the span input is lame
    /// - See: 'testRefine' under CubicTests
    public func refineRangeDist(nearby: Point3D, span: ClosedRange<Double>) throws -> ClosedRange<Double>?   {
        
        // Would be good to check that 'span' is a valid range.
        guard self.trimParameters.contains(span.lowerBound) else { throw ParameterRangeError(parA: span.lowerBound)}
        
        guard self.trimParameters.contains(span.upperBound) else { throw ParameterRangeError(parA: span.upperBound)}
        
        /// Number of pieces to divide range
        let chunks = 10  // What's the most efficient number?
        
        /// The return value
        var tighter: ClosedRange<Double>? = nil
        
        
        /// Parameter step
        let parStep = (span.upperBound - span.lowerBound) / Double(chunks)
        
        /// Array of equally spaced parameter values within the range.
        var params = [Double]()
        
        for g in 0...chunks   {
            let freshT = span.lowerBound + Double(g) * parStep
            params.append(freshT)
        }
        
        /// Array of separations
        let seps = params.map{ Point3D.dist(pt1: nearby, pt2: try! self.pointAt(t: $0)) }
        
        /// Smallest distance
        if let closest = seps.min()   {
            
            /// Index of smallest distance
            if let thumb = seps.firstIndex(of: closest)   {
                
                switch thumb   {
                    
                    // First subrange
                case 0:  tighter = ClosedRange<Double>(uncheckedBounds: (lower: params[0], upper: params[1]))
                    
                    // Last subrange
                case seps.count - 1:  tighter = ClosedRange<Double>(uncheckedBounds: (lower: params[seps.count - 2], upper: params[seps.count - 1]))
                    
                    // General case
                default:  tighter = ClosedRange<Double>(uncheckedBounds: (lower: params[thumb - 1], upper: params[thumb + 1]))
                    
                }
                
            }
            
        }
        
        return tighter
    }
    
    
    /// Plot the curve segment.  This will be called by the UIView 'drawRect' function
    /// - Parameters:
    ///   - context: In-use graphics framework
    ///   - tform:  Model-to-display transform
    ///   - allowableCrown: Maximum deviation from the actual curve
    /// - Throws:
    ///     - NegativeAccuracyError for a bad input
    public func draw(context: CGContext, tform: CGAffineTransform, allowableCrown: Double) throws -> Void  {
        
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
