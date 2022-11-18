//
//  CubicTests.swift
//  CurvePack
//
//  Created by Paul on 7/16/16.
//  Copyright © 2022 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest
@testable import CurvePack

class CubicTests: XCTestCase {

    var cup: Cubic?
    
    override func setUp() {
        super.setUp()
        
        let alpha = Point3D(x: 2.3, y: 1.5, z: 0.7)
        let alSlope = Vector3D(i: 0.866, j: 0.5, k: 0.0)
        
        let beta = Point3D(x: 3.1, y: 1.6, z: 0.7)
        let betSlope = Vector3D(i: 0.866, j: -0.5, k: 0.0)
        
        cup = try! Cubic(ptA: alpha, slopeA: alSlope, ptB: beta, slopeB: betSlope)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testHermite() {
        
        let alpha = Point3D(x: 2.3, y: 1.5, z: 0.7)
        let alSlope = Vector3D(i: 0.866, j: 0.5, k: 0.0)
        
        let beta = Point3D(x: 3.1, y: 1.6, z: 0.7)
        let betSlope = Vector3D(i: 0.866, j: -0.5, k: 0.0)
        
        let bump = try! Cubic(ptA: alpha, slopeA: alSlope, ptB: beta, slopeB: betSlope)
        
        let oneTrial = try! bump.pointAt(t: 0.0)
        
           // Gee, this would be a grand place for an extension of XCTAssert that compares points
        let flag1 = Point3D.dist(pt1: oneTrial, pt2: alpha) < (Point3D.Epsilon / 3.0)
        
        XCTAssert(flag1)
        
        let otherTrial = try! bump.pointAt(t: 1.0)
        let flag2 = Point3D.dist(pt1: otherTrial, pt2: beta) < (Point3D.Epsilon / 3.0)
        
        XCTAssert(flag2)
        
        let badSlope = Vector3D(i: 0.0, j: 0.0, k: 0.0)
        
        XCTAssertThrowsError(try Cubic(ptA: alpha, slopeA: badSlope, ptB: beta, slopeB: betSlope))
        XCTAssertThrowsError(try Cubic(ptA: alpha, slopeA: alSlope, ptB: beta, slopeB: badSlope))

    }

    func testBezier()   {
        
        let alpha = Point3D(x: 2.3, y: 1.5, z: 0.7)
        let alSlope = Vector3D(i: 0.866, j: 0.5, k: 0.0)
        
        let control1 = Point3D(base: alpha, offset: alSlope)
        
        let beta = Point3D(x: 3.1, y: 1.6, z: 0.7)
        let betSlope = Vector3D(i: 0.866, j: -0.5, k: 0.0)
        let bReverse = betSlope.reverse()
        let control2 = Point3D(base: beta, offset: bReverse)
        
        let bump = try! Cubic(ptA: alpha, controlA: control1, controlB: control2, ptB: beta)
        
        let oneTrial = try! bump.pointAt(t: 0.0)
        
        // Gee, this would be a grand place for an extension of XCTAssert that compares points
        let flag1 = Point3D.dist(pt1: oneTrial, pt2: alpha) < (Point3D.Epsilon / 3.0)
        
        XCTAssert(flag1)
        
        let otherTrial = try! bump.pointAt(t: 1.0)
        let flag2 = Point3D.dist(pt1: otherTrial, pt2: beta) < (Point3D.Epsilon / 3.0)
        
        XCTAssert(flag2)
        
    }
    
    func testGetters()   {
        
        let alpha = Point3D(x: 2.3, y: 1.5, z: 0.7)
        let alSlope = Vector3D(i: 0.866, j: 0.5, k: 0.0)
        
        let control1 = Point3D(base: alpha, offset: alSlope)
        
        let beta = Point3D(x: 3.1, y: 1.6, z: 0.7)
        let betSlope = Vector3D(i: 0.866, j: -0.5, k: 0.0)
        let bReverse = betSlope.reverse()
        let control2 = Point3D(base: beta, offset: bReverse)
        
        let bump = try! Cubic(ptA: alpha, controlA: control1, controlB: control2, ptB: beta)
        
        
        let retAlpha = bump.getOneEnd()
        XCTAssertEqual(alpha, retAlpha)
        
        let retBeta = bump.getOtherEnd()
        XCTAssertEqual(beta, retBeta)
        
    }
    
    func testPointAt()   {
        
        let spot = try! cup?.pointAt(t: 0.5)
        
        let targetPt = Point3D(x: 2.7, y: 1.675, z: 0.7)
        
        XCTAssert(spot == targetPt)
                
        do   {
            _ = try cup?.pointAt(t: 1.7)
        } catch let screwup as ParameterRangeError {   // A contrived way to exercise the computed property
            _ = screwup.description
            XCTAssert(true)
        } catch {
            XCTFail()
        }
        
    }

    func testTangentAt()   {
        
        let dir = try! cup?.tangentAt(t: 0.4)
        
        let targetDir = Vector3D(i: 0.7709, j: 0.2440, k: 0.0)
        
        XCTAssert(dir == targetDir)
        
        do   {
            _ = try cup?.tangentAt(t: -2.7)
        } catch is ParameterRangeError   {
            
            XCTAssert(true)
        } catch   {
            XCTFail()
        }
        
        let alpha = Point3D(x: 2.3, y: 1.5, z: 0.7)
        let alSlope = Vector3D(i: 0.866, j: 0.5, k: 0.0)
        
        let beta = Point3D(x: 3.1, y: 1.6, z: 0.7)
        let betSlope = Vector3D(i: 0.866, j: -0.5, k: 0.0)
        
        var bump = try! Cubic(ptA: alpha, slopeA: alSlope, ptB: beta, slopeB: betSlope)
        
        try! bump.trimFront(lowParameter: 0.15)
        try! bump.trimBack(highParameter: 0.75)
        
        XCTAssertThrowsError(try bump.tangentAt(t: 0.12))
        
        XCTAssertNoThrow(try bump.tangentAt(t: 0.12, ignoreTrim: true))

        XCTAssertThrowsError(try bump.tangentAt(t: 2.12, ignoreTrim: true))


    }
    
    func testSetIntent()   {
        
        XCTAssert(cup!.usage == "Ordinary")
        
        cup!.setIntent(purpose: "Selected")
        XCTAssert(cup!.usage == "Selected")
        
    }
    

    func testSumsHermite()   {
        
        let alpha = Point3D(x: 2.3, y: 1.5, z: 0.7)
        let alSlope = Vector3D(i: 0.866, j: 0.5, k: 0.0)
        
        let beta = Point3D(x: 3.1, y: 1.6, z: 0.7)
        let betSlope = Vector3D(i: 0.866, j: -0.5, k: 0.0)
        
        let bump = try! Cubic(ptA: alpha, slopeA: alSlope, ptB: beta, slopeB: betSlope)
        
        let sumX = bump.ax + bump.bx + bump.cx + bump.dx
        let sumY = bump.ay + bump.by + bump.cy + bump.dy
        let sumZ = bump.az + bump.bz + bump.cz + bump.dz
        
        XCTAssertEqual(beta.x, sumX, accuracy: 0.0001)
        XCTAssertEqual(beta.y, sumY, accuracy: 0.0001)
        XCTAssertEqual(beta.z, sumZ, accuracy: 0.0001)
    }
    
    func testSumsBezier()   {
        
        let alpha = Point3D(x: 2.3, y: 1.5, z: 0.7)
        let alSlope = Vector3D(i: 0.866, j: 0.5, k: 0.0)
        
        let control1 = Point3D(base: alpha, offset: alSlope)
        
        let beta = Point3D(x: 3.1, y: 1.6, z: 0.7)
        let betSlope = Vector3D(i: 0.866, j: -0.5, k: 0.0)
        let bReverse = betSlope.reverse()
        let control2 = Point3D(base: beta, offset: bReverse)
        
        let bump = try! Cubic(ptA: alpha, controlA: control1, controlB: control2, ptB: beta)
        
        let sumX = bump.ax + bump.bx + bump.cx + bump.dx
        let sumY = bump.ay + bump.by + bump.cy + bump.dy
        let sumZ = bump.az + bump.bz + bump.cz + bump.dz
        
        XCTAssertEqual(beta.x, sumX, accuracy: 0.0001)
        XCTAssertEqual(beta.y, sumY, accuracy: 0.0001)
        XCTAssertEqual(beta.z, sumZ, accuracy: 0.0001)
    }
    
    func testCoeffConstruct()   {
        
        let upCorner = Point3D(x: -1.0, y: 0.5, z: 0.5)
        let upWave = Point3D(x: 0.0, y: 1.75, z: 0.5)
        let downWave = Point3D(x: 1.0, y: 2.25, z: 0.5)
        let beach = Point3D(x: 3.0, y: 4.5, z: 0.5)
        
        let wave = try! Cubic(alpha: upCorner, beta: upWave, betaFraction: 0.3, gamma: downWave, gammaFraction: 0.5, delta: beach)
       
        let dupeWave = Cubic(ax: wave.ax, bx: wave.bx, cx: wave.cx, dx: wave.dx, ay: wave.ay, by: wave.by, cy: wave.cy, dy: wave.dy, az: wave.az, bz: wave.bz, cz: wave.cz, dz: wave.dz)
        
        var yin = try! wave.pointAt(t: 0.04)
        var yang = try! dupeWave.pointAt(t: 0.04)
        
        XCTAssert(yang == yin)

        yin = try! wave.pointAt(t: 0.47)
        yang = try! dupeWave.pointAt(t: 0.47)
        
        XCTAssert(yang == yin)
        
        yin = try! wave.pointAt(t: 0.71)
        yang = try! dupeWave.pointAt(t: 0.71)
        
        XCTAssert(yang == yin)

        yin = try! wave.pointAt(t: 0.98)
        yang = try! dupeWave.pointAt(t: 0.98)
        
        XCTAssert(yang == yin)
        
    }
    
    func testApproximate()   {
        
        let upCorner = Point3D(x: -1.0, y: 0.5, z: 0.5)
        let upWave = Point3D(x: 0.0, y: 1.75, z: 0.5)
        let downWave = Point3D(x: 1.0, y: 2.25, z: 0.5)
        let beach = Point3D(x: 3.0, y: 4.5, z: 0.5)
        
        var wave = try! Cubic(alpha: upCorner, beta: upWave, betaFraction: 0.3, gamma: downWave, gammaFraction: 0.5, delta: beach)
        
        let maxPts = try! wave.approximate(allowableCrown: 0.003)
        
        let notSoMany = try! wave.approximate(allowableCrown: 0.010)
        
        XCTAssert(maxPts.count > notSoMany.count)
        
        
        try! wave.trimFront(lowParameter: 0.10)
        
        let frontShave = try! wave.approximate(allowableCrown: 0.003)
        
        XCTAssert(maxPts.count > frontShave.count)
        
        
        try! wave.trimBack(highParameter: 0.73)
        
        let backShave = try! wave.approximate(allowableCrown: 0.003)
        
        XCTAssert(backShave.count < frontShave.count)
        
    }
    
    
    func testTransform100()   {
        
        let pt1 = Point3D(x: 2.0, y: 0.5, z: 4.0)
        let pt2 = Point3D(x: 2.0, y: 1.0, z: 2.0)
        let pt2Fraction = 0.38
        let pt3 = Point3D(x: 2.0, y: 2.0, z: 0.75)
        let pt3Fraction = 0.72
        let pt4 = Point3D(x: 2.0, y: 3.5, z: 0.5)
        
        let waist = try! Cubic(alpha: pt1, beta: pt2, betaFraction: pt2Fraction, gamma: pt3, gammaFraction: pt3Fraction, delta: pt4)

        let nose = waist.dice()
        
           // Try out the transform function of a Cubic
        let swing = Transform(rotationAxis: Axis.z, angleRad: Double.pi / 3.0)

        let hokie = waist.transform(xirtam: swing) as! Cubic

        let pokie = hokie.dice()
        
        var diff = [Double]()
        
        for g in 0..<pokie.count   {
            let erocks = nose[g].transform(xirtam: swing)
            let delta = Point3D.dist(pt1: pokie[g], pt2: erocks)
            diff.append(delta)
        }

        let whitney = diff.max()!
        XCTAssert(whitney < Point3D.Epsilon)
        
    }
    
    func testReverse()   {
        
        let pt1 = Point3D(x: 2.0, y: 0.5, z: 4.0)
        let pt2 = Point3D(x: 2.0, y: 1.0, z: 2.0)
        let pt2Fraction = 0.38
        let pt3 = Point3D(x: 2.0, y: 2.0, z: 0.75)
        let pt3Fraction = 0.72
        let pt4 = Point3D(x: 2.0, y: 3.5, z: 0.5)
        
        var waist = try! Cubic(alpha: pt1, beta: pt2, betaFraction: pt2Fraction, gamma: pt3, gammaFraction: pt3Fraction, delta: pt4)

        let nose = waist.dice()
        
        waist.reverse()
        
        let tail = waist.dice()
        let backwards = [Point3D](tail.reversed())
        
        var diff = [Double]()
        
        for g in 0..<backwards.count   {
            let delta = Point3D.dist(pt1: nose[g], pt2: backwards[g])   // Will always be positive
            diff.append(delta)
        }
        
        let acme = diff.max()!
        
        XCTAssert(acme < Point3D.Epsilon)
        
    }
    
    func testExtent()   {
        
        let alpha = Point3D(x: -2.3, y: 1.5, z: 0.7)
        
        let control1 = Point3D(x: -3.1, y: 0.0, z: 0.7)
        
        let control2 = Point3D(x: -3.1, y: -1.6, z: 0.7)
        
        let beta = Point3D(x: -2.7, y: -3.4, z: 0.7)
        
        let bump = try! Cubic(ptA: alpha, controlA: control1, controlB: control2, ptB: beta)
        
        
        let box = bump.getExtent()
        
        XCTAssertEqual(box.getOrigin().x, -2.9624, accuracy: 0.0001)
    }
    
    func testFindCrown()   {
        
        let hump =  try! cup!.findCrown(smallerT: 0.20, largerT: 0.85)
        
        XCTAssertEqual(hump, 0.0543, accuracy: 0.0001)
    }
    
    func testCrossing()   {
        
        let pt1 = Point3D(x: -1.2, y: 0.39, z: 0.0)
        let pt2 = Point3D(x: 1.1, y: 1.05, z: 0.0)
        let pt3 = Point3D(x: 1.95, y: -0.5, z: 0.0)
        let pt4 = Point3D(x: 3.64, y: 0.04, z: 0.0)

        let rolling = try! Cubic(alpha: pt1, beta: pt2, betaFraction: 0.45, gamma: pt3, gammaFraction: 0.65, delta: pt4)
        
        let kansas = Vector3D(i: 1.0, j: 0.0, k: 0.0)

        /// Origin for a high line that misses.
        let mama = Point3D(x: -2.2, y: 3.0, z: 0.0)
        let tooHigh = try! Line(spot: mama, arrow: kansas)
        
        let chubby = Point3D(x: -1.8, y: 1.75, z: 0.0)
        let high = try! Line(spot: chubby, arrow: kansas)
        
        let everett = Point3D(x: -1.9, y: 0.25, z: 0.0)
        let low = try! Line(spot: everett, arrow: kansas)
        
        let cody = Point3D(x: -1.45, y: -1.78, z: 0.0)
        let tooLow = try! Line(spot: cody, arrow: kansas)
        
        let wholeCurve = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
        let collide2High = rolling.crossing(ray: tooHigh, span: wholeCurve, chunks: 100)
        XCTAssertEqual(0, collide2High.count)

        let collideHigh = rolling.crossing(ray: high, span: wholeCurve, chunks: 100)
        XCTAssertEqual(2, collideHigh.count)

        let collideLow = rolling.crossing(ray: low, span: wholeCurve, chunks: 100)
        XCTAssertEqual(1,  collideLow.count)
        
        let collide2Low = rolling.crossing(ray: tooLow, span: wholeCurve, chunks: 100)
        XCTAssertEqual(0, collide2Low.count)

    }
    
    func testPerch()   {
        
        let pt1 = Point3D(x: -1.2, y: 0.39, z: 1.0)
        let pt2 = Point3D(x: -1.2, y: 0.71, z: 0.65)
        let pt3 = Point3D(x: -1.2, y: 0.98, z: 0.42)
        let pt4 = Point3D(x: -1.2, y: 1.24, z: 0.31)

        let rolling = try! Cubic(alpha: pt1, beta: pt2, betaFraction: 0.39, gamma: pt3, gammaFraction: 0.65, delta: pt4)
        
        let t1 = Point3D(x: -1.2, y: 0.01, z: -0.2)
        
        var sitRep = try! rolling.isCoincident(speck: t1)
        
        XCTAssertFalse(sitRep.flag)
        
           // Set up a point known to be on the curve
        let t2 = Point3D(x: -1.2, y: 0.5448, z: 0.8165)
        
        sitRep = try! rolling.isCoincident(speck: t2)
        XCTAssert(sitRep.flag)
        
        let t3 = Point3D(x: -1.2, y: 1.25, z: 0.30)
        
        sitRep = try! rolling.isCoincident(speck: t3)
        XCTAssertFalse(sitRep.flag)
        
    }
    
    func testIntersect()   {
        
        let pt1 = Point3D(x: -1.2, y: 0.39, z: 0.0)
        let pt2 = Point3D(x: 1.1, y: 1.05, z: 0.0)
        let pt3 = Point3D(x: 1.95, y: -0.5, z: 0.0)
        let pt4 = Point3D(x: 3.64, y: 0.04, z: 0.0)

        let rolling = try! Cubic(alpha: pt1, beta: pt2, betaFraction: 0.45, gamma: pt3, gammaFraction: 0.65, delta: pt4)
        
        let kansas = Vector3D(i: 1.0, j: 0.0, k: 0.0)

        let chubby = Point3D(x: -1.8, y: 1.75, z: 0.0)
        let high = try! Line(spot: chubby, arrow: kansas)
        
        let whacks = try! rolling.intersect(ray: high, accuracy: 0.001)
        XCTAssertEqual(2, whacks.count)

        
        let lowerLeft = Point3D(x: -1.20, y: -1.0, z: 1.25)
        let controlA = Point3D(x: -0.60, y: 2.5, z: 1.25)
        let controlB = Point3D(x: 2.25, y: 0.8, z: 1.25)
        let upperRight = Point3D(x: 3.8, y: 4.0, z: 1.25)
        
        let wave = try! Cubic(ptA: lowerLeft, controlA: controlA, controlB: controlB, ptB: upperRight)
        
        let scissorA1 = Point3D(x: -2.0, y: -1.5, z: 1.25)
        let scissorA2 = Point3D(x: 3.5, y: 4.75, z: 1.25)
        
        
        var traj = Vector3D(from: scissorA1, towards: scissorA2, unit: true)
        
        var zorro = try! Line(spot: scissorA1, arrow: traj)
        
        let nicksA = try! wave.intersect(ray: zorro, accuracy: Point3D.Epsilon)
        
        XCTAssertEqual(2, nicksA.count)


        let scissorB1 = Point3D(x: -1.5, y: 2.8, z: 1.25)
        let scissorB2 = Point3D(x: 3.5, y: 0.875, z: 1.25)
        
        
        traj = Vector3D(from: scissorB1, towards: scissorB2, unit: true)
        
        zorro = try! Line(spot: scissorB1, arrow: traj)
        
        let nicksB = try! wave.intersect(ray: zorro, accuracy: Point3D.Epsilon)
        
        XCTAssertEqual(1, nicksB.count)


        let scissorC1 = Point3D(x: -1.5, y: -0.65, z: 1.25)
        let scissorC2 = Point3D(x: 4.15, y: 4.05, z: 1.25)
        
        
        traj = Vector3D(from: scissorC1, towards: scissorC2, unit: true)
        
        zorro = try! Line(spot: scissorC1, arrow: traj)
        
        let nicksC = try! wave.intersect(ray: zorro, accuracy: Point3D.Epsilon)
        
        XCTAssertEqual(3, nicksC.count)

    }
    
    func testRefine()   {
        
        let near = Point3D(x: 2.9, y: 1.4, z: 0.7)
        
        let startRange = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
        let narrower = try! cup!.refineRangeDist(nearby: near, span: startRange)
        
        XCTAssert(narrower?.lowerBound == 0.8)
        XCTAssert(narrower?.upperBound == 1.0)
        
        let narrower3 = try! cup!.refineRangeDist(nearby: near, span: narrower!)
        
        XCTAssert(narrower3?.lowerBound == 0.86)
        XCTAssert(narrower3?.upperBound == 0.90)
        

        let near2 = Point3D(x: 2.65, y: 1.45, z: 0.7)
        
        let narrower2 = try! cup!.refineRangeDist(nearby: near2, span: startRange)
        
        XCTAssert(narrower2?.lowerBound == 0.2)
        XCTAssert(narrower2?.upperBound == 0.4)
        

        let near3 = Point3D(x: 2.40, y: 1.45, z: 0.7)
        
        let narrower4 = try! cup!.refineRangeDist(nearby: near3, span: startRange)
        
        XCTAssert(narrower4?.lowerBound == 0.0)
        XCTAssert(narrower4?.upperBound == 0.2)
                
    }
    
    
    func testFindClosest()   {
        
        let near = Point3D(x: 2.9, y: 1.4, z: 0.7)
        
        let buddy = try! cup!.findClosest(nearby: near).pip
        
        let target = Point3D(x: 2.99392, y: 1.65063, z: 0.70000)
        
        XCTAssertEqual(buddy, target)
        
        do   {
            _ = try cup!.findClosest(nearby: near, accuracy: -0.001)
        } catch let screwup as NegativeAccuracyError {
            _ = screwup.description
            XCTAssert(true)
        } catch {
            XCTFail()
        }
    }
    
    func testCopyConst()   {
        
        let launch = Point3D(x: 0.5, y: 0.5, z: 0.5)
        let leo = Point3D(x: 1.5, y: 1.875, z: 1.5)
        let transfer = Point3D(x: 2.5, y: 2.5, z: 2.80)
        let geo = Point3D(x: 3.5, y: 3.5, z: 3.5)
        
        var traj = try! Cubic(alpha: launch, beta: leo, betaFraction: 0.33, gamma: transfer, gammaFraction: 0.67, delta: geo)
        
        try! traj.trimFront(lowParameter: 0.40)
        try! traj.trimBack(highParameter: 0.78)
        
        let target1 = try! traj.pointAt(t: 0.0, ignoreTrim: true)
        let target2 = try! traj.pointAt(t: 0.45)
        let target3 = try! traj.pointAt(t: 1.0, ignoreTrim: true)

        let imit = Cubic(sourceCurve: traj)
        
        let trial1 = try! imit.pointAt(t: 0.0, ignoreTrim: true)
        
        XCTAssert(trial1 == target1)
        
        
        XCTAssertNoThrow(try imit.pointAt(t: 0.29))
        
        let trial2 = try! imit.pointAt(t: 0.45)
        
        XCTAssert(trial2 == target2)
        
        let trial3 = try! imit.pointAt(t: 1.0)
        
        XCTAssert(trial3 == target3)
        
    }
        
    
    func testGenPlane()   {
        
        let launch = Point3D(x: 0.5, y: 0.5, z: 0.5)
        let leo = Point3D(x: 1.5, y: 1.875, z: 1.5)
        let transfer = Point3D(x: 2.5, y: 2.5, z: 2.80)
        let geo = Point3D(x: 3.5, y: 3.5, z: 3.5)
        
        let traj = try! Cubic(alpha: launch, beta: leo, betaFraction: 0.33, gamma: transfer, gammaFraction: 0.67, delta: geo)
        
        XCTAssertNil(traj.genPlane())
        
        
        let spuds = Point3D(x: 1.2, y: -1.6, z: 0.1)
        let radish = Point3D(x: 1.2, y: -0.2, z: 0.8)
        let egg = Point3D(x: 1.2, y: 0.65, z: 1.44)
        let onion = Point3D(x: 1.2, y: 1.05, z: 2.05)
        
        let salad = try! Cubic(ptA: spuds, controlA: radish, controlB: egg, ptB: onion)
        
        XCTAssertNotNil(salad.genPlane())
        
    }
    
    
    func testSlopeStart()   {
        
        let spuds = Point3D(x: -1.6, y: 1.2, z: 0.1)
//        let radish = Point3D(x: -0.2, y: 1.2, z: 0.8)
        let egg = Point3D(x: 0.65, y: 1.2, z: 1.44)
        let onion = Point3D(x: 1.05, y: 1.2, z: 2.05)
        
        var startSlope = Vector3D(i: 0.7, j: 0.0, k: 0.7)
        startSlope.normalize()
        
        XCTAssertNoThrow(try Cubic(alpha: spuds, alphaPrime: startSlope, beta: egg, betaFraction: 0.6, gamma: onion))
        
        XCTAssertThrowsError(try Cubic(alpha: spuds, alphaPrime: startSlope, beta: egg, betaFraction: 1.16, gamma: onion))

        XCTAssertThrowsError(try Cubic(alpha: spuds, alphaPrime: startSlope, beta: spuds, betaFraction: 0.6, gamma: onion))
    }
    
    func testSplitParam()   {
        
        let sword1 = Point3D(x: -2.9, y: 1.05, z: 0.0)
        let sword2 = Point3D(x: -0.1, y: 1.65, z: 0.0)
        let sword3 = Point3D(x: 2.2, y: 1.55, z: 0.0)
        let sword4 = Point3D(x: 4.2, y: 0.65, z: 0.0)
        
        /// An untrimmed Cubic at the moment
        var beater = try! Cubic(ptA: sword1, controlA: sword2, controlB: sword3, ptB: sword4)
        
        let milestones = beater.splitParam(divs: 5)
        
        XCTAssertEqual(milestones.count, 6)
        
        XCTAssertEqual(milestones[1], 0.2, accuracy: 0.001)
        
        
        try! beater.trimFront(lowParameter: 0.40)

        try! beater.trimBack(highParameter: 0.88)

        let milestonesTr = beater.splitParam(divs: 4)
        
        XCTAssertEqual(milestonesTr.count, 5)
        
        XCTAssertEqual(milestonesTr[1], 0.52, accuracy: 0.001)
        
    }
    
    
}
