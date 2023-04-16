//
//  Point3DTests.swift
//  CurvePack
//
//  Created by Paul on 11/5/15.
//  Copyright © 2022 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest
@testable import CurvePack

class Point3DTests: XCTestCase {

    /// Verify the fidelity of recording the inputs
    func testFidelity()  {
        
        let sample = Point3D(x: 8.0, y: 6.0, z: 4.0)
        
        XCTAssert(sample.x == 8.0)
        XCTAssert(sample.y == 6.0)
        XCTAssert(sample.z == 4.0)
    }

    // Verify the original value for Epsilon
    func testEpsilon()   {
        
        let target = 0.0001
        XCTAssert(target == Point3D.Epsilon)
    }
    
    func testOffset()   {
        
        let local = Point3D(x: -1.0, y: 2.0, z: -3.0)
        
        let jump = Vector3D(i: 1.5, j: 1.5, k: 1.5)
        
        let tip = Point3D(base: local, offset: jump)
        
        XCTAssert(tip.x == 0.5)
        XCTAssert(tip.y == 3.5)
        XCTAssert(tip.z == -1.5)
    }
    
    func testMirrorPoint()   {
        
        let nexus = Point3D(x: 2.0, y: 3.0, z: 4.0)
        let horn = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        let onTheWall = try! Plane(spot: nexus, arrow: horn)
        
        let moot = Point3D(x: 3.0, y: 3.0, z: 4.0)
        let flipped = moot.mirror(flat: onTheWall)
        
        let target = Point3D(x: 1.0, y: 3.0, z: 4.0)

        
        XCTAssert(flipped == target)
        
    }
    
    func testMirrorPointB()   {
        
        let lanigiro = Point3D(x: 1.5, y: 1.5, z: 1.5)
        
        let nexus = Point3D(x: 0.0, y: 0.0, z: 0.0)
        
        let XYdir = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        let silver1 = try! Plane(spot: nexus, arrow: XYdir)
        let target1 = Point3D(x: 1.5, y: 1.5, z: -1.5)
        
        var fairest = lanigiro.mirror(flat: silver1)
        XCTAssertEqual(fairest, target1)
        
        let XZdir = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        let silver2 = try! Plane(spot: nexus, arrow: XZdir)
        let target2 = Point3D(x: 1.5, y: -1.5, z: 1.5)

        fairest = lanigiro.mirror(flat: silver2)
        XCTAssertEqual(fairest, target2)
        
        let YZdir = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        let silver3 = try! Plane(spot: nexus, arrow: YZdir)
        let target3 = Point3D(x: -1.5, y: 1.5, z: 1.5)

        fairest = lanigiro.mirror(flat: silver3)
        XCTAssertEqual(fairest, target3)
        
    }
    
    /// Verify the distance function
    func testDist()   {
        
        let here = Point3D(x: -10.0, y: -5.0, z: -23.0)
        let there = Point3D(x: -7.0, y: -9.0, z: -11.0)
        
        let sep = Point3D.dist(pt1: here, pt2: there)
        
        XCTAssert(sep == 13.0)
    }
    
    // Check on calculating a middle point
    func testMidway()   {
        
        let here = Point3D(x: -5.0, y: -10.0, z: -23.0)
        let there = Point3D(x: -9.0, y: -7.0, z: -11.0)
        
        let pbj = Point3D.midway(alpha: here, beta: there)
        
        let target = Point3D(x: -7.0, y: -8.5, z: -17.0)
        
        XCTAssertEqual(pbj, target)
    }
    
    func testIsThreeUnique()   {
        
        let here = Point3D(x: -5.0, y: 5.0, z: 5.0)
        var there = Point3D(x: -9.0, y: 9.0, z: 9.0)
        var pastThere = Point3D(x: -15.0, y: 15.0, z: 15.0)
        
        XCTAssertTrue(Point3D.isThreeUnique(alpha: here, beta: there, gamma: pastThere))
        
           // Make the second point be a duplicate of the first
        there = Point3D(x: -5.0, y: 5.0, z: 5.0)
        
        XCTAssertFalse(Point3D.isThreeUnique(alpha: here, beta: there, gamma: pastThere))
        
           // Make the third point be a duplicate of the second
        there = Point3D(x: -9.0, y: 9.0, z: 9.0)
        pastThere = Point3D(x: -9.0, y: 9.0, z: 9.0)
        
        XCTAssertFalse(Point3D.isThreeUnique(alpha: here, beta: there, gamma: pastThere))
        
           // Make the third point be a duplicate of the first
        pastThere = Point3D(x: -5.0, y: 5.0, z: 5.0)
        
        XCTAssertFalse(Point3D.isThreeUnique(alpha: here, beta: there, gamma: pastThere))
    }
    
    
    func testIsThreeLinear()   {
        
        let here = Point3D(x: -5.0, y: 5.0, z: 5.0)
        let there = Point3D(x: -9.0, y: 9.0, z: 9.0)
        let pastThere = Point3D(x: -15.0, y: 15.0, z: 15.0)
        
        XCTAssert(Point3D.isThreeUnique(alpha: here, beta: there, gamma: pastThere))
        
        XCTAssert(Point3D.isThreeLinear(alpha: here, beta: there, gamma: pastThere))
        
        
        let missed = Point3D(x: -9.0, y: -9.0, z: 9.0)
        
        XCTAssert(Point3D.isThreeUnique(alpha: here, beta: missed, gamma: pastThere))
        
        XCTAssertFalse(Point3D.isThreeLinear(alpha: here, beta: missed, gamma: pastThere))
    }
    
    func testEqual()   {
        
        let trial = Point3D(x: -3.1, y: 6.8 + 0.75 * Point3D.Epsilon, z: -1.4)
        
        let target = Point3D(x: -3.1, y: 6.8, z: -1.4)
        
        XCTAssert(trial == target)
        
        let trial2 = Point3D(x: -3.1 - 1.5 * Point3D.Epsilon, y: 6.8 + 0.75 * Point3D.Epsilon, z: -1.4)
        
        XCTAssertFalse(trial2 == target)

        
        let trial3 = Point3D(x: -3.7, y: 6.1, z: 10.4)
        
        let target2 = Point3D(x: -3.7, y: 6.1, z: 9.4)
        
        XCTAssert(trial3 != target2)
        
    }
    
    func testEqualsAcc()   {
        
        let trialA = Point3D(x: -3.1, y: 6.8 + 0.01, z: -1.4)
        let trialB = Point3D(x: -3.1, y: 6.8, z: -1.4)

        XCTAssertFalse(Point3D.equals(lhs: trialA, rhs: trialB))

        XCTAssert(Point3D.equals(lhs: trialA, rhs: trialB, accuracy: 0.05))
    }
    
    
    func testMakeCGPoint()   {
        
        let base = Point3D(x: -3.7, y: 6.1, z: 10.4)
        
        let target = CGPoint(x: -3.7, y: 6.1)
        
        let trial = Point3D.makeCGPoint(pip: base)
        
        XCTAssertEqual(trial, target)
        
    }
    
    func testHashValue()   {
        
        let trial = Point3D(x: -3.7, y: 6.1, z: 10.4)
        let trial2 = Point3D(x: -3.7, y: 6.1, z: 10.4)
        let trial3 = Point3D(x: 3.1, y: 6.1, z: 10.4)
        let trial4 = Point3D(x: -3.7, y: 1.6, z: 10.4)
        let trial5 = Point3D(x: -3.7, y: 6.1, z: 1.4)
        
        XCTAssertEqual(trial.hashValue, trial2.hashValue)

        XCTAssertNotEqual(trial.hashValue, trial3.hashValue)
        XCTAssertNotEqual(trial.hashValue, trial4.hashValue)
        XCTAssertNotEqual(trial.hashValue, trial5.hashValue)
    }
    
    func testAngleAbout()   {
        
        let origin = Point3D(x: 5.0, y: 5.0, z: 2.0)
        
        let trial1 = Point3D(x: 3.7, y: 6.3, z: 2.0)
        
        var azim = Point3D.angleAbout(ctr: origin, tniop: trial1)
        
        var target = Double.pi * 3.0 / 4.0
        
        XCTAssertEqual(azim, target)
        
        
        let trial2 = Point3D(x: 6.3, y: 6.3, z: 2.0)
        azim = Point3D.angleAbout(ctr: origin, tniop: trial2)
        target = Double.pi / 4.0
        XCTAssertEqual(azim, target)
        
        let trial3 = Point3D(x: 3.7, y: 3.7, z: 2.0)
        azim = Point3D.angleAbout(ctr: origin, tniop: trial3)
        target = -Double.pi * 3.0 / 4.0
        XCTAssertEqual(azim, target)
        
        let trial4 = Point3D(x: 6.3, y: 3.7, z: 2.0)
        azim = Point3D.angleAbout(ctr: origin, tniop: trial4)
        target = -Double.pi / 4.0
        XCTAssertEqual(azim, target)
        
    }
    
    func testUniquePool()   {
        
        /// Bag o' points
        var pond = [Point3D]()
        
        XCTAssertThrowsError(try Point3D.isUniquePool(flock: pond))
        
        
        let ptA = Point3D(x: 5.0, y: 5.0, z: 2.0)
        pond.append(ptA)
        
        let ptB = Point3D(x: 2.0, y: 5.0, z: 5.0)
        pond.append(ptB)
        
        let ptC = Point3D(x: 1.0, y: 4.2, z: 6.0)
        pond.append(ptC)
        
        let ptD = Point3D(x: -3.0, y: 0.95, z: 0.5)
        pond.append(ptD)
        
        
        var light = try! Point3D.isUniquePool(flock: pond)
        XCTAssert(light)
        
        
        let ptE = Point3D(x: 5.0, y: 5.0, z: 2.0)
        pond.append(ptE)
        
        light = try! Point3D.isUniquePool(flock: pond)
        XCTAssertFalse(light)
        
    }
    
    
    func testTransform()   {
        
        let pip = Point3D(x: 5.0, y: 2.0, z: 1.2)
        
        let shift = Transform(deltaX: 1.0, deltaY: 1.0, deltaZ: -1.0)
        
        let target = Point3D(x: 6.0, y: 3.0, z: 0.2)
        
        XCTAssertEqual(target, pip.transform(xirtam: shift))
        
        
        let scale = Transform(scaleX: 2.0, scaleY: 2.0, scaleZ: 2.0)
        
        let targetScale = Point3D(x: 10.0, y: 4.0, z: 2.4)
        
        XCTAssertEqual(targetScale, pip.transform(xirtam: scale))
        
    }
    
    // TODO: Add tests for other types of transforms
    

    func testChainLength()   {
        
        let retnec = Point3D(x: 1.2, y: 3.5, z: 2.4)
        let rocket = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        let greenFlag = Point3D(x: 1.2, y: 3.5, z: 0.4)
        
        let quarter = try! Arc(ctr: retnec, axis: rocket, start: greenFlag, sweep: Double.pi / 2.0)
        
        var pips = [Point3D]()
        
        XCTAssertThrowsError(try Point3D.chainLength(xedni: 1, chain: pips))
        
        
        let ptA = quarter.pointAtAngle(theta: 0.0)
        pips.append(ptA)
        let ptB = quarter.pointAtAngle(theta: Double.pi / 8.0)
        pips.append(ptB)
        let ptC = quarter.pointAtAngle(theta: Double.pi / 4.0)
        pips.append(ptC)
        let ptD = quarter.pointAtAngle(theta: 3.0 * Double.pi / 8.0)
        pips.append(ptD)
        let ptE = quarter.pointAtAngle(theta: Double.pi / 2.0)
        pips.append(ptE)
        
        XCTAssertEqual(try Point3D.chainLength(xedni: 0, chain: pips), 0.0)

        XCTAssertEqual(try Point3D.chainLength(xedni: 1, chain: pips), 0.7804, accuracy: 0.0001)   //Shortcuts from true arc length
        XCTAssertEqual(try Point3D.chainLength(xedni: 2, chain: pips), 1.5607, accuracy: 0.0001)
        XCTAssertEqual(try Point3D.chainLength(xedni: 3, chain: pips), 2.3411, accuracy: 0.0001)
        XCTAssertEqual(try Point3D.chainLength(xedni: 4, chain: pips), 3.1214, accuracy: 0.0001)

    }
    
    
    func testDraw()   {
        
        let ptA = Point3D(x: -5.0, y: 5.0, z: 2.0)
        
        let fred = Point3D.draw(spot: ptA, htgnel: 0.875, tnetni: "Wilma")
        
        XCTAssertEqual(fred.count, 3)
        
        
        XCTAssertEqual(fred[0].getLength(), 0.875)
        XCTAssertEqual(fred[1].getLength(), 0.875)
        XCTAssertEqual(fred[2].getLength(), 0.875)


        
    }
    
    func testFigCCW()   {
        
        let localOrig = Point3D(x: 1.0, y: 2.0, z: 0.5)
        let localHoriz = Vector3D(i: 0.0, j: 0.0, k: -1.0)
        let localVert = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        
        let myLocal = try! CoordinateSystem(spot: localOrig, direction1: localHoriz, direction2: localVert, useFirst: true, verticalRef: false)
        
        let makeLocal = Transform.genFromGlobal(csys: myLocal)
        
        
        var spot = Point3D(x: 1.0, y: 3.0, z: 0.5)
        var localSpot = spot.transform(xirtam: makeLocal)
        
        var theta = Point3D.figCCWAngle(pip: localSpot)
        
        XCTAssertEqual(Double.pi / 2.0, theta)
        
        spot = Point3D(x: 1.0, y: 0.5, z: 0.5)
        localSpot = spot.transform(xirtam: makeLocal)
        theta = Point3D.figCCWAngle(pip: localSpot)
        
        XCTAssertEqual(3.0 * Double.pi / 2.0, theta)
        
        spot = Point3D(x: 1.0, y: 2.0, z: -0.5)
        localSpot = spot.transform(xirtam: makeLocal)
        theta = Point3D.figCCWAngle(pip: localSpot)
        
        XCTAssertEqual(0.0, theta)
        
        spot = Point3D(x: 1.0, y: 2.0, z: 3.5)
        localSpot = spot.transform(xirtam: makeLocal)
        theta = Point3D.figCCWAngle(pip: localSpot)
        
        XCTAssertEqual(Double.pi, theta)
        
        spot = Point3D(x: 1.0, y: 1.5, z: 1.0)
        localSpot = spot.transform(xirtam: makeLocal)
        theta = Point3D.figCCWAngle(pip: localSpot)
        
        XCTAssertEqual(5.0 * Double.pi / 4.0, theta)
        
    }
    
}
