//
//  ArcTests.swift
//  SketchCurves
//
//  Created by Paul on 11/12/15.
//  Copyright © 2021 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest
@testable import CurvePack

class ArcTests: XCTestCase {

    /// Tests the simple parts for one of the inits
    func testFidelityThreePoints() {

        let sun = Point3D(x: 3.5, y: 6.0, z: 0.0)
        let earth = Point3D(x: 5.5, y: 6.0, z: 0.0)
        let atlantis = Point3D(x: 3.5, y: 8.0, z: 0.0)
        
        
        var orbit = try! Arc(center: sun, end1: earth, end2: atlantis, useSmallAngle: false)
        
        XCTAssert(orbit.getCenter() == sun)
        XCTAssert(orbit.getOneEnd() == earth)
        XCTAssert(orbit.getOtherEnd() == atlantis)
        
        
        XCTAssertEqual(orbit.getSweepAngle(), 3.0 * Double.pi / -2.0, accuracy: 0.0001)
        
        var target = 2.0
        XCTAssertEqual(orbit.getRadius(), target, accuracy: 0.0001)
        
        orbit = try! Arc(center: sun, end1: earth, end2: atlantis, useSmallAngle: true)
        
        XCTAssertEqual(orbit.getSweepAngle(), Double.pi / 2.0, accuracy: 0.0001)

        
        
           // Detect an ArcPointsError from duplicate points by bad referencing
        do   {
            let ctr = Point3D(x: 2.0, y: 1.0, z: 5.0)
    //        let e1 = Point3D(x: 3.0, y: 1.0, z: 5.0)
            let e2 = Point3D(x: 2.0, y: 2.0, z: 5.0)
            
            // Bad referencing should cause an error to be thrown
            let _ = try Arc(center: ctr, end1: e2, end2: ctr, useSmallAngle: false)
            
        }   catch is ArcPointsError   {
            XCTAssert(true)
        }   catch   {   // This code will never get run
            XCTAssert(false)
        }
        
        
        // Detect an CoincidentPointsError from duplicate points by bad referencing
        do   {
            let ctr = Point3D(x: 2.0, y: 1.0, z: 5.0)
            //        let e1 = Point3D(x: 3.0, y: 1.0, z: 5.0)
            let e2 = Point3D(x: 2.0, y: 2.0, z: 5.0)
            
            // Bad referencing should cause an error to be thrown
            let _ = try Arc(center: ctr, end1: e2, end2: e2, useSmallAngle: false)
            
        }   catch is CoincidentPointsError   {
            XCTAssert(true)
        }   catch   {   // This code will never get run
            XCTAssert(false)
        }
        
           // Detect non-equidistant points
        do   {
            let ctr = Point3D(x: 2.0, y: 1.0, z: 5.0)
            let e1 = Point3D(x: 3.0, y: 1.0, z: 5.0)
            let e2 = Point3D(x: 2.0, y: 2.5, z: 5.0)
            
            // Bad point separation should cause an error to be thrown
            let _ = try Arc(center: ctr, end1: e1, end2: e2, useSmallAngle: false)
            
        }   catch is ArcPointsError   {
            XCTAssert(true)
        }   catch   {   // This code will never get run
            XCTAssert(false)
        }
        
           // Detect collinear points
        do   {
            let ctr = Point3D(x: 2.0, y: 1.0, z: 5.0)
            let e1 = Point3D(x: 3.0, y: 1.0, z: 5.0)
            let e2 = Point3D(x: 1.0, y: 1.0, z: 5.0)
            
            // Points all on a line should cause an error to be thrown
            let _ = try Arc(center: ctr, end1: e1, end2: e2, useSmallAngle: false)
            
        }   catch is CoincidentPointsError   {
            XCTAssert(true)
        }   catch   {   // This code will never get run
            XCTAssert(false)
        }
        
        
            // Check that sweep angles get generated correctly
        
        /// Convenient values
        let sqrt22 = sqrt(2.0) / 2.0
        let sqrt32 = sqrt(3.0) / 2.0
        
        
        let earth44 = Point3D(x: 3.5 + 2.0 * sqrt32, y: 6.0 + 2.0 * 0.5, z: 0.0)
        
        // High to high
        let season = try! Arc(center: sun, end1: earth44, end2: atlantis, useSmallAngle: true)
        
        target = 1.0 * Double.pi / 3.0
        let theta = season.getSweepAngle()
        
        XCTAssertEqual(theta, target, accuracy: 0.001)
        
        
        // High to high complement
        let season3 = try! Arc(center: sun, end1: earth44, end2: atlantis, useSmallAngle: false)
        
        let target3 = -1.0 * (2.0 * Double.pi - target)
        let theta3 = season3.getSweepAngle()
        
        XCTAssertEqual(theta3, target3, accuracy: 0.001)
        
        // Low to high
        let earth2 = Point3D(x: 3.5 + 2.0 * sqrt32, y: 6.0 - 2.0 * 0.5, z: 0.0)
        
        let season2 = try! Arc(center: sun, end1: earth2, end2: atlantis, useSmallAngle: true)
        
        let target2 = 2.0 * Double.pi / 3.0
        let theta2 = season2.getSweepAngle()
        
        XCTAssertEqual(theta2, target2, accuracy: 0.001)
        
        // Low to high complement
        let season4 = try! Arc(center: sun, end1: earth2, end2: atlantis, useSmallAngle: false)
        
        let target4 = -1.0 * (2.0 * Double.pi - target2)
        let theta4 = season4.getSweepAngle()
        
        XCTAssertEqual(theta4, target4, accuracy: 0.001)
        
        
        // High to low
        let earth3 = Point3D(x: 3.5 + 2.0 * sqrt32, y: 6.0 + 2.0 * 0.5, z: 0.0)
        
        let atlantis5 = Point3D(x: 3.5 - 2.0 * sqrt22, y: 6.0 - 2.0 * sqrt22, z: 0.0)
        
        let season5 = try! Arc(center: sun, end1: earth3, end2: atlantis5, useSmallAngle: false)
        
        let target5 = -13.0 * Double.pi / 12.0
        let theta5 = season5.getSweepAngle()
        
        XCTAssertEqual(theta5, target5, accuracy: 0.001)
        
        // High to low complement
        let season6 = try! Arc(center: sun, end1: earth3, end2: atlantis5, useSmallAngle: true)
        
        let target6 = 11.0 * Double.pi / 12.0
        let theta6 = season6.getSweepAngle()
        
        XCTAssertEqual(theta6, target6, accuracy: 0.001)
        
        
        // Low to low
        let season7 = try! Arc(center: sun, end1: earth2, end2: atlantis5, useSmallAngle: false)
        
        let target7 = -17.0 * Double.pi / 12.0
        let theta7 = season7.getSweepAngle()
        
        XCTAssertEqual(theta7, target7, accuracy: 0.001)
        
        let season8 = try! Arc(center: sun, end1: earth2, end2: atlantis5, useSmallAngle: true)
        
        // Low to low complement
        let target8 = 7.0 * Double.pi / 12.0
        let theta8 = season8.getSweepAngle()
        
        XCTAssertEqual(theta8, target8, accuracy: 0.001)
        
        
           // Check generation of the axis
        let c1 = Point3D(x: 0.9, y: -1.21, z: 3.5)
        let s1 = Point3D(x: 0.9, y: -1.21 + sqrt32, z: 3.5 + 0.5)
        let f1 = Point3D(x: 0.9, y: -1.21, z: 3.5 + 1.0)
        
        let slice = try! Arc(center: c1, end1: s1, end2: f1, useSmallAngle: false)
        
        let target9 = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        let trial = slice.getAxisDir()
        
        XCTAssertEqual(trial, target9)

    }

    
    /// Has some duplication with testFidelityThreePoints
    func testInitCEE()   {
        
        let ctr = Point3D(x: 1.5, y: 4.0, z: 3.5)
        let alpha = Point3D(x: 1.5, y: 6.0, z: 3.5)
        let omega = Point3D(x: 1.5, y: 4.0, z: 5.5)
        
        let fourth = try! Arc(center: ctr, end1: alpha, end2: omega, useSmallAngle: true)
        
        XCTAssertEqual(fourth.getRadius(), 2.0, accuracy: 0.00001)
        
        let spinX = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        let spinY = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        
        XCTAssertFalse(fourth.getAxisDir() == spinY)
        
        XCTAssert(fourth.getAxisDir() == spinX)
        
        XCTAssertEqual(Double.pi / 2.0, fourth.getSweepAngle(), accuracy: 0.0001)
        
        let htgnel = 2.0 * Double.pi * fourth.getRadius() / 4.0
        XCTAssertEqual(fourth.getLength(), htgnel, accuracy: 0.001)
        
    }
    

    /// Test the second initializer
    func testFidelityCASS()   {
        
        let sun = Point3D(x: 3.5, y: 6.0, z: 0.0)
        let earth = Point3D(x: 5.5, y: 6.0, z: 0.0)
        let solarSystemUp = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        let fourMonths = 2.0 * Double.pi / 3.0
        
        
        var orbit = try! Arc(ctr: sun, axis: solarSystemUp, start: earth, sweep: fourMonths)
        
        var target = 2.0
        
        XCTAssertEqual(orbit.getRadius(), target, accuracy: 0.0001)
        
        
        /// A handy value when checking points at angles
        let sqrt32 = sqrt(3.0) / 2.0
        
        target = 3.5 - 2.0 * 0.5
        XCTAssertEqual(orbit.getOtherEnd().x, target, accuracy: Point3D.Epsilon)
        
        target = 6.0 + 2.0 * sqrt32
        XCTAssertEqual(orbit.getOtherEnd().y, target, accuracy: Point3D.Epsilon)
        
        
        orbit = try! Arc(ctr: sun, axis: solarSystemUp, start: earth, sweep: 2.0 * Double.pi)
        
        
        do   {
            let solarSystemUp2 = Vector3D(i: 0.0, j: 0.0, k: 0.0)

            orbit = try Arc(ctr: sun, axis: solarSystemUp2, start: earth, sweep: 2.0 * Double.pi)
            
        }   catch is NonUnitDirectionError   {
            
            XCTAssert(true)
            
        }   catch   {
            
            XCTAssert(false, "Code should never have gotten here")
        }

        do   {
            let solarSystemUp2 = Vector3D(i: 0.0, j: 0.0, k: 0.5)
            
            orbit = try Arc(ctr: sun, axis: solarSystemUp2, start: earth, sweep: 2.0 * Double.pi)
            
        }   catch is NonUnitDirectionError   {
            
            XCTAssert(true)
            
        }   catch   {
            
            XCTAssert(false, "Code should never have gotten here")
        }

        
        
        do   {
            
            orbit = try Arc(ctr: sun, axis: solarSystemUp, start: earth, sweep: 0.0)
            
        }   catch is ZeroSweepError   {
            
            XCTAssert(true)
            
        }   catch   {
            
            XCTAssert(false, "Code should never have gotten here")
        }
        
        do   {
            let earth2 = Point3D(x: 3.5, y: 6.0, z: 4.0)
            
            orbit = try Arc(ctr: sun, axis: solarSystemUp, start: earth2, sweep: 2.0 * Double.pi)
            
        }   catch is NonOrthogonalPointError   {
            
            XCTAssert(true)
            
        }   catch   {
            
            XCTAssert(false, "Code should never have gotten here")
        }
        
        
        do   {
            
            orbit = try Arc(ctr: sun, axis: solarSystemUp, start: earth, sweep: -6.5)
            
        }   catch is ParameterRangeError   {
            
            XCTAssert(true)
            
        }   catch   {
            
            XCTAssert(false, "Code should never have gotten here")
        }
        

        do   {
            
            orbit = try Arc(ctr: sun, axis: solarSystemUp, start: earth, sweep: 6.5)
            
        }   catch is ParameterRangeError   {
            
            XCTAssert(true)
            
        }   catch   {
            
            XCTAssert(false, "Code should never have gotten here")
        }
        

    }
    
    
    func testTrimFront()   {
        
        let thumb = Point3D(x: 3.5, y: 6.0, z: 0.0)
        let knuckle = Point3D(x: 5.5, y: 6.0, z: 0.0)
        let tip = Point3D(x: 3.5, y: 8.0, z: 0.0)
        
        var grip2 = try! Arc(center: thumb, end1: knuckle, end2: tip, useSmallAngle: true)
        
        try! grip2.trimFront(lowParameter: 0.25)
        try! grip2.trimBack(highParameter: 0.80)
        
        XCTAssertEqual(0.25, grip2.trimParameters.lowerBound)
        
        XCTAssertThrowsError(try grip2.trimFront(lowParameter: 0.85))
        
        XCTAssertThrowsError(try grip2.trimFront(lowParameter: -0.25))
        XCTAssertThrowsError(try grip2.trimFront(lowParameter: 1.22))
    }
    
    
    func testTrimBack()   {
        
        let thumb = Point3D(x: 3.5, y: 6.0, z: 0.0)
        let knuckle = Point3D(x: 5.5, y: 6.0, z: 0.0)
        let tip = Point3D(x: 3.5, y: 8.0, z: 0.0)
        
        var grip2 = try! Arc(center: thumb, end1: knuckle, end2: tip, useSmallAngle: true)
        
        try! grip2.trimFront(lowParameter: 0.25)
        try! grip2.trimBack(highParameter: 0.80)
        
        XCTAssertEqual(0.80, grip2.trimParameters.upperBound)
        
        XCTAssertThrowsError(try grip2.trimBack(highParameter: 0.22))
        
        XCTAssertThrowsError(try grip2.trimBack(highParameter: -0.25))
        XCTAssertThrowsError(try grip2.trimBack(highParameter: 1.22))
    }
    
    
    func testPointAt()   {
        
        let thumb = Point3D(x: 3.5, y: 6.0, z: 0.0)
        let knuckle = Point3D(x: 5.5, y: 6.0, z: 0.0)
        let tip = Point3D(x: 3.5, y: 8.0, z: 0.0)
        
        do   {
            let grip = try Arc(center: thumb, end1: knuckle, end2: tip, useSmallAngle: true)
            
            var spot = try! grip.pointAt(t: 0.5)
            
            XCTAssert(spot.z == 0.0)
            XCTAssert(spot.y == 6.0 + 2.squareRoot())   // This is bizarre notation, probably from a language level comparison.
            XCTAssert(spot.x == 3.5 + 2.squareRoot())
            XCTAssert(spot.x == 3.5 + sqrt(2.0))
            
            spot = try! grip.pointAt(t: 0.0)
            
            XCTAssert(spot.z == 0.0)
            XCTAssert(spot.y == 6.0)
            XCTAssert(spot.x == 3.5 + 2.0)
            
        }  catch  {
            print("Screwed up while testing a circle 7")
        }
        
        
           // Another start-at-zero case with a different check method
        let ctr = Point3D(x: 10.5, y: 6.0, z: -1.2)
        
        /// On the horizon
        let green = Point3D(x: 11.8, y: 6.0, z: -1.2)
        
        /// Noon sun
        let checker = Point3D(x: 10.5, y: 7.3, z: -1.2)
        
        let shoulder = try! Arc(center: ctr, end1: green, end2: checker, useSmallAngle: true)
        
        
        var upRight = Vector3D(i: 1.0, j: 1.0, k: 0.0)
        upRight.normalize()
        
        /// Unit slope
        let ray = try! Line(spot: ctr, arrow: upRight)
        
        
        var plop = try! shoulder.pointAt(t: 0.5)
        
        let flag1 = Line.isCoincident(straightA: ray, pip: plop)
        
        XCTAssert(flag1)
        
        
        
           // Clockwise sweep
        let sunSetting = try! Arc(center: ctr, end1: checker, end2: green, useSmallAngle: true)
        
        var clock = Vector3D(i: 0.866, j: 0.5, k: 0.0)
        clock.normalize()
        
        let ray2 = try! Line(spot: ctr, arrow: clock)
        
        plop = try! sunSetting.pointAt(t: 0.666667)
        
        XCTAssert(Line.isCoincident(straightA: ray2, pip: plop))
        
        // TODO: Add tests in a non-XY plane

        
        
        let sunSetting2 = try! Arc(center: ctr, end1: checker, end2: green, useSmallAngle: false)
        
        
        var clock2 = Vector3D(i: 0.0, j: -1.0, k: 0.0)
        clock2.normalize()
        
        var ray3 = try! Line(spot: ctr, arrow: clock2)
        
        plop = try! sunSetting2.pointAt(t: 0.666667)
        XCTAssert(Line.isCoincident(straightA: ray3, pip: plop))
        
        
        let countdown = try! Arc(center: ctr, end1: checker, end2: green, useSmallAngle: false)
        
        clock = Vector3D(i: -1.0, j: 0.0, k: 0.0)
        ray3 = try! Line(spot: ctr, arrow: clock)
        
        plop = try! countdown.pointAt(t: 0.333333)
        XCTAssert(Line.isCoincident(straightA: ray3, pip: plop))

        
        var grip2 = try! Arc(center: thumb, end1: knuckle, end2: tip, useSmallAngle: true)
        
        try! grip2.trimFront(lowParameter: 0.25)
        try! grip2.trimBack(highParameter: 0.80)
        
        XCTAssertThrowsError(try grip2.pointAt(t: 0.90))
        
        
        do   {
            
            var grip2 = try Arc(center: thumb, end1: knuckle, end2: tip, useSmallAngle: true)
            
            try grip2.trimFront(lowParameter: 0.25)
            try grip2.trimBack(highParameter: 0.80)
            
            _ = try grip2.pointAt(t: 0.17)
            
        } catch is ParameterRangeError   {
            
            XCTAssert(true)
            
        }   catch {
            XCTAssert(false, "Code should never have gotten here")
        }
        

    }
    
    
    func testPointAtAngleGlobal()   {
        
        let axisDir = Vector3D(i: -1.0, j: 0.0, k: 0.0)
        let retnec = Point3D(x: 2.0, y: 1.0, z: 0.0)
        let adam = Point3D(x: 2.0, y: 1.0, z: 2.0)
        
        let rainbow = try! Arc(ctr: retnec, axis: axisDir, start: adam, sweep: Double.pi)
        
        let target = Point3D(x: 2.0, y: 3.0, z: 0.0)
        
        let computed = rainbow.pointAtAngleGlobal(theta: Double.pi / 2.0)
        
        XCTAssertEqual(target, computed)
        
        
        let axisDir2 = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        let retnec2 = Point3D(x: 2.0, y: 1.0, z: 0.0)
        let adam2 = Point3D(x: 4.0, y: 1.0, z: 0.0)
        
        let rainbow2 = try! Arc(ctr: retnec2, axis: axisDir2, start: adam2, sweep: Double.pi)
        
        let target2 = Point3D(x: 2.0, y: 1.0, z: -2.0)
        
        let computed2 = rainbow2.pointAtAngleGlobal(theta: Double.pi / 2.0)
        
        XCTAssertEqual(target2, computed2)
        
    }
    
    func testApproximate()   {
        
        let up = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        let pivot = Point3D(x: 2.0, y: 1.0, z: 0.0)
        let adam = Point3D(x: 3.5, y: 1.0, z: 0.0)
        
        let rainbow = try! Arc(ctr: pivot, axis: up, start: adam, sweep: Double.pi / 2.0)
        
        let hops = try! rainbow.approximate(allowableCrown: 0.001)
        XCTAssert(try! Point3D.isUniquePool(flock: hops))
        
        XCTAssertNoThrow(try rainbow.approximate(allowableCrown: 0.001))
        XCTAssertThrowsError(try rainbow.approximate(allowableCrown: -0.05))

    }
    
    func testGetExtent()   {
        
        let up = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        let pivot = Point3D(x: 2.0, y: 1.0, z: 0.0)
        let adam = Point3D(x: 3.5, y: 1.0, z: 0.0)
        
        let rainbow = try! Arc(ctr: pivot, axis: up, start: adam, sweep: Double.pi * 2.0)
        
        let brick = rainbow.getExtent()
        print(brick.getOrigin())
        
        let minCorner = Point3D(x: 0.45, y: -0.55, z: -0.05)
        let maxCorner = Point3D(x: 3.55, y: 2.55, z: 0.05)
        let target = try! OrthoVol(corner1: minCorner, corner2: maxCorner)
        
        XCTAssert(OrthoVol.surrounds(big: target, little: rainbow.getExtent()))
    }
    
    
    func testIntersect()   {
        
        let up = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        let pivot = Point3D(x: 2.0, y: 1.0, z: 0.0)
        let adam = Point3D(x: 3.5, y: 1.0, z: 0.0)
        
        let rainbow = try! Arc(ctr: pivot, axis: up, start: adam, sweep: Double.pi / -0.65)
        
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
        
        
        let whack2high = try! rainbow.intersect(ray: tooHigh, accuracy: 0.001)
        XCTAssertEqual(0, whack2high.count)
        
        let whackhigh = try! rainbow.intersect(ray: high, accuracy: 0.001)
        XCTAssertEqual(1, whackhigh.count)
        
        let whacklow = try! rainbow.intersect(ray: low, accuracy: 0.001)
        XCTAssertEqual(2, whacklow.count)
        
        let whack2low = try! rainbow.intersect(ray: tooLow, accuracy: 0.001)
        XCTAssertEqual(0, whack2low.count)
        
        
        
        let thumb = Point3D(x: -1.0, y: 1.5, z: 3.0)
        let knuckle = Point3D(x: -1.0, y: 3.5, z: 3.0)
        let tip = Point3D(x: -1.0, y: 1.5, z: 5.0)
        
        let grip2 = try! Arc(center: thumb, end1: knuckle, end2: tip, useSmallAngle: true)
        
        let oakley = Point3D(x: -1.45, y: -1.5, z: 3.0)
        let wichita = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        let wayOff = try! Line(spot: oakley, arrow: wichita)
        
        do   {
            
            let whacklow = try grip2.intersect(ray: wayOff, accuracy: -0.005)
            XCTAssertEqual(2, whacklow.count)
                        
        } catch is NegativeAccuracyError   {
            
            XCTAssert(true)
            
        }   catch {
            XCTAssert(false, "Code should never have gotten here")
        }
        
        let missed1 = try! grip2.intersect(ray: wayOff, accuracy: 0.001)
        XCTAssert(missed1.isEmpty)
        
        
        let goodland = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        let parOffset = try! Line(spot: oakley, arrow: goodland)
        
        let missed2 = try! grip2.intersect(ray: parOffset, accuracy: 0.001)
        XCTAssert(missed2.isEmpty)
        

    }
    
    
    func testConcentric()   {
        
        let ctr = Point3D(x: 1.0, y: 1.0, z: 2.0)
        let start = Point3D(x: 1.5, y: 1.0, z: 2.0)
        let zee = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        let cup = try! Arc(ctr: ctr, axis: zee, start: start, sweep: Double.pi / 2.0)
        
        let jug = try! Arc(basis: cup, delta: 0.3)
        
        XCTAssertEqual(jug.getRadius(), 0.80, accuracy: 0.00001)
        
        let straw = try! Arc(basis: cup, delta: -0.3)
        
        XCTAssertEqual(straw.getRadius(), 0.20, accuracy: 0.00001)
        
        XCTAssertThrowsError( try Arc(basis: cup, delta: -0.6) )
        
        XCTAssertThrowsError( try Arc(basis: cup, delta: -0.5) )
        
    }
    
    func testGetLength()   {
        
        let ctr = Point3D(x: 1.0, y: 1.0, z: 2.0)
        let start = Point3D(x: 1.5, y: 1.0, z: 2.0)
        let zee = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        let cup = try! Arc(ctr: ctr, axis: zee, start: start, sweep: Double.pi / 2.0)
        
        let target = Double.pi / 2.0 * 0.5
        XCTAssertEqual(cup.getLength(), target, accuracy: 0.00001)
    }
    
    
    func testTransform()   {
        
        let ctr = Point3D(x: 1.0, y: 1.0, z: 2.0)
        let start = Point3D(x: 1.5, y: 1.0, z: 2.0)
        let zee = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        let cup = try! Arc(ctr: ctr, axis: zee, start: start, sweep: Double.pi)
        
        let pristine = cup.pointAtAngleGlobal(theta: Double.pi / 2.0)
        
        let shift = Vector3D(i: 0.0, j: 0.5, k: 0.0)
        let target = Point3D(base: pristine, offset: shift)
        
        let swing = Transform(deltaX: 0.0, deltaY: 0.5, deltaZ: 0.0)
        
        let altered = try! cup.transform(xirtam: swing) as! Arc
        
        let computed = altered.pointAtAngleGlobal(theta: Double.pi / 2.0)
        
        XCTAssertEqual(target, computed)

        // TODO: Perform tests for other kinds of transforms
    }
    
    
    func testReverse()   {
        
        let ctr = Point3D(x: 1.0, y: 1.0, z: 2.0)
        let start = Point3D(x: 1.5, y: 1.0, z: 2.0)
        let zee = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        var cup = try! Arc(ctr: ctr, axis: zee, start: start, sweep: Double.pi / 2.0)
        
        let lengthA = cup.getLength()
        
        let alphaA = cup.getOneEnd()
        let omegaA = cup.getOtherEnd()
        
        cup.reverse()
        
        let lengthB = cup.getLength()
        
        XCTAssertEqual(lengthA, lengthB, accuracy: 0.00001)
        
        let alphaB = cup.getOneEnd()
        let omegaB = cup.getOtherEnd()
        
        XCTAssert(alphaB == omegaA)
        
        XCTAssert(omegaB == alphaA)
    }
    
    
    func testPerch()   {
        
        let sun = Point3D(x: 3.5, y: 6.0, z: 1.0)
        let earth = Point3D(x: 5.5, y: 6.0, z: 1.0)
        let atlantis = Point3D(x: 3.5, y: 6.0, z: 3.0)
        
        let solarSystem1 = try! Arc(center: sun, end1: earth, end2: atlantis, useSmallAngle: true)
        
           // Not on Arc
        let t1 = Point3D(x: 4.5, y: 6.0, z: 1.35)

        var sitRep = try! solarSystem1.isCoincident(speck: t1)
        XCTAssertFalse(sitRep.flag)

           // Far end
        let t2 = Point3D(x: 3.5, y: 6.0, z: 3.0)

        sitRep = try! solarSystem1.isCoincident(speck: t2)
        XCTAssert(sitRep.flag)

           // Right radius with good angle
        let t3 = Point3D(x: 3.5 + 2.0 * sqrt(2.0) / 2.0, y: 6.0, z: 1.0 + 2.0 * sqrt(2.0) / 2.0)
        
        sitRep = try! solarSystem1.isCoincident(speck: t3)
        XCTAssert(sitRep.flag)
        
           // Right radius with bad angle
        let solarSystem2 = try! Arc(center: sun, end1: earth, end2: atlantis, useSmallAngle: false)
        
        sitRep = try! solarSystem2.isCoincident(speck: t3)
        XCTAssertFalse(sitRep.flag)
        
           // Out of plane
        let t4 = Point3D(x: 3.5 + 2.0 * sqrt(2.0) / 2.0, y: 7.0, z: 1.0 + 2.0 * sqrt(2.0) / 2.0)
        
        sitRep = try! solarSystem1.isCoincident(speck: t4)
        XCTAssertFalse(sitRep.flag)
        
    }
    
    func testEquals() {
        
        let sun = Point3D(x: 3.5, y: 6.0, z: 0.0)
        let earth = Point3D(x: 5.5, y: 6.0, z: 0.0)
        let atlantis = Point3D(x: 3.5, y: 8.0, z: 0.0)
        
        let betelgeuse = Point3D(x: 3.5, y: 6.0, z: 0.0)
        let planetX = Point3D(x: 5.5, y: 6.0, z: 0.0)
        let planetY = Point3D(x: 3.5, y: 8.0, z: 0.0)
        
        let solarSystem1 = try! Arc(center: sun, end1: earth, end2: atlantis, useSmallAngle: false)
        
        let solarSystem2 = try! Arc(center: betelgeuse, end1: planetX, end2: planetY, useSmallAngle: false)
        
        XCTAssert(solarSystem1 == solarSystem2)
        
    }
    
    //TODO: Add tests to compare results from the different types of initializers

    func testSetIntent()   {
        
        let sun = Point3D(x: 3.5, y: 6.0, z: 0.0)
        let earth = Point3D(x: 5.5, y: 6.0, z: 0.0)
        let atlantis = Point3D(x: 3.5, y: 8.0, z: 0.0)
        
        var solarSystem1 = try! Arc(center: sun, end1: earth, end2: atlantis, useSmallAngle: false)
        

        XCTAssert(solarSystem1.usage == "Ordinary")
        
        solarSystem1.setIntent(purpose: "Selected")
        
        XCTAssert(solarSystem1.usage == "Selected")
        
    }
        
    
    func testArcPlane()   {
        
        let retnec = Point3D(x: 1.0, y: 1.0, z: 1.0)
        
        let pivot = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        let start = Point3D(x: 1.0, y: 2.2, z: 1.0)
        
        let hump = try! Arc(ctr: retnec, axis: pivot, start: start, sweep: 0.5 * Double.pi)
        
        let target = try! Plane(spot: retnec, arrow: pivot)
        
        let derived = Arc.genPlane(scoop: hump)
        
        XCTAssert(try! Plane.isCoincident(flatLeft: target, flatRight: derived))
        
    }
    
    
    func testBuildFillet()   {
        
        let filletRad = 0.25
        
        let orig1 = Point3D(x: 1.0, y: 0.5, z: -2.0)
        let dir1 = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        let laser1 = try! Line(spot: orig1, arrow: dir1)
        
        let orig2 = Point3D(x: 4.2, y: 1.2, z: -2.0)
        var dir2 = Vector3D(i: -0.707, j: -0.707, k: 0.0)
        dir2.normalize()
        
        let laser2 = try! Line(spot: orig2, arrow: dir2)
        
        XCTAssertNoThrow(try Arc.buildFillet(straight1: laser1, straight2: laser2, rad: filletRad, keepNear1: true, keepNear2: true) )
                         
        let myFillet = try! Arc.buildFillet(straight1: laser1, straight2: laser2, rad: filletRad, keepNear1: true, keepNear2: true)
        
        let targetPlane = try! Plane(spot: orig1, arrow: Vector3D(i: 0.0, j: 0.0, k: 1.0))
        
        let derived = Arc.genPlane(scoop: myFillet)
        
        XCTAssert(try! Plane.isCoincident(flatLeft: targetPlane, flatRight: derived))
        
        let comp1 = laser1.resolveRelative(yonder: myFillet.getCenter())
        
        XCTAssertEqual(filletRad, comp1.perp, accuracy: 0.001)
        
        let comp2 = laser2.resolveRelative(yonder: myFillet.getCenter())
        
        XCTAssertEqual(filletRad, comp2.perp, accuracy: 0.001)
        
        XCTAssertThrowsError(try Arc.buildFillet(straight1: laser1, straight2: laser2, rad: -0.375, keepNear1: true, keepNear2: true) )
        
        XCTAssertThrowsError(try Arc.buildFillet(straight1: laser1, straight2: laser1, rad: filletRad, keepNear1: true, keepNear2: true) )
        
        
        let wonkyOrig = Point3D(x: 1.5, y: 1.0, z: 1.0)
        let wonkyDir = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        
        let wonkyLine = try! Line(spot: wonkyOrig, arrow: wonkyDir)
        
        XCTAssertThrowsError(try Arc.buildFillet(straight1: laser1, straight2: wonkyLine, rad: filletRad, keepNear1: true, keepNear2: true) )
        
        /// Intersection point of the two boundary lines
        let crux = try! Line.intersectTwo(straightA: laser1, straightB: laser2)
        
        let heading1 = Vector3D(from: crux, towards: myFillet.getCenter())
        
        var iPos = heading1.i > 0.0   // This works only in a plane parallel to XY
        var jPos = heading1.j > 0.0
        
        XCTAssert(iPos == false && jPos == true)
        
        let myFillet2 = try! Arc.buildFillet(straight1: laser1, straight2: laser2, rad: filletRad, keepNear1: false, keepNear2: true)
        
        let heading2 = Vector3D(from: crux, towards: myFillet2.getCenter())
        
        iPos = heading2.i > 0.0   // This works only in a plane parallel to XY
        jPos = heading2.j > 0.0
        
        XCTAssert(iPos == false && jPos == false)
        
        let myFillet3 = try! Arc.buildFillet(straight1: laser1, straight2: laser2, rad: filletRad, keepNear1: true, keepNear2: false)
        
        let heading3 = Vector3D(from: crux, towards: myFillet3.getCenter())
        
        iPos = heading3.i > 0.0   // This works only in a plane parallel to XY
        jPos = heading3.j > 0.0
        
        XCTAssert(iPos == true && jPos == true)
        
        
        let myFillet4 = try! Arc.buildFillet(straight1: laser1, straight2: laser2, rad: filletRad, keepNear1: false, keepNear2: false)
        
        let heading4 = Vector3D(from: crux, towards: myFillet4.getCenter())
        
        iPos = heading4.i > 0.0   // This works only in a plane parallel to XY
        jPos = heading4.j > 0.0
        
        XCTAssert(iPos == true && jPos == false)
        
    }

    func testLineFillet()  {

        let rocket = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        let nigiro = Point3D(x: 0.0, y: 0.0, z: 0.0)
        
        let greenFlag = Point3D(x: 2.0, y: 0.0, z: 0.0)
        
        let adamArc = try! Arc(ctr: nigiro, axis: rocket, start: greenFlag, sweep: Double.pi * 3.0 / 2.0)
        
        ///Origin for the intersecting Line
//        let hub = Point3D(x: -2.125, y: -1.50, z: 0.0)
        let hub = Point3D(x: -0.875, y: 0.50, z: 0.0)

        ///Direction for the intersecting Line
//        var oneThirty = Vector3D(i: 0.707, j: 0.707, k: 0.0)
//        oneThirty.normalize()
        
        var five = Vector3D(i: 0.5, j: -0.866, k: 0.0)
        five.normalize()
        
        ///Slicer
        let zig = try! Line(spot: hub, arrow: five)
        
                
        ///The resulting fillet
        let heScores = try! Arc.lineFillet(ray: zig, filletRadius: 0.250, hump: adamArc, inside: true, firstCCW: true, lead: false)

        let curl = heScores.getCenter()
        
        ///Single intersection, True, True, False
        let targetSTTF = Point3D(x: -1.4450, y: 0.9872, z: 0.0)
        let sweepSTTF = 2.0186
        
        XCTAssertEqual(targetSTTF, curl)
        XCTAssertEqual(sweepSTTF, heScores.getSweepAngle(), accuracy: 0.0001)
        
        
        ///The resulting fillet
        let heScores2 = try! Arc.lineFillet(ray: zig, filletRadius: 0.250, hump: adamArc, inside: false, firstCCW: true, lead: false)

        let curl2 = heScores2.getCenter()
        
        print(curl2.x)
        print(curl2.y)
        print(curl2.z)
        print(heScores2.getSweepAngle())

        
        do   {
            
            var badFive = Vector3D(i: 0.5, j: -0.866, k: 0.2)
            badFive.normalize()
            
            let badZig = try! Line(spot: hub, arrow: badFive)
            
            _ = try Arc.lineFillet(ray: badZig, filletRadius: 0.250, hump: adamArc, inside: true, firstCCW: true, lead: false)

        } catch is NonCoPlanarLinesError   {
            
            XCTAssert(true)
            
        }   catch {
            XCTAssert(false, "Code should never have gotten here")
        }
        
        
        do   {
            
            _ = try Arc.lineFillet(ray: zig, filletRadius: -0.080, hump: adamArc, inside: true, firstCCW: true, lead: false)

        } catch is NegativeAccuracyError   {
            
            XCTAssert(true)
            
        }   catch {
            XCTAssert(false, "Code should never have gotten here")
        }
        
        
        do   {
            
            let badHub = Point3D(x: -5.875, y: 0.50, z: 0.0)
            
            let badZig = try! Line(spot: badHub, arrow: five)
            
            _ = try Arc.lineFillet(ray: badZig, filletRadius: 0.250, hump: adamArc, inside: true, firstCCW: true, lead: false)

        } catch is CoincidentLinesError   {
            
            XCTAssert(true)
            
        }   catch {
            XCTAssert(false, "Code should never have gotten here")
        }
        
        
    }

    
    func testShortFillet()   {
        
        let locat = Point3D(x: 2.0, y: 1.5, z: 1.0)
        
        let planePerp = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        let planeOrig = Point3D(x: 1.0, y: 1.35, z: 0.5)
        let myFloor = try! Plane(spot: planeOrig, arrow: planePerp)
        
        let sep = Plane.resolveRelativeVec(flat: myFloor, pip: locat)
        
        XCTAssertEqual(0.15, sep.perp.length(), accuracy: 0.0001)
        
        let curvePerp = Vector3D(i: 0.0, j: 0.0, k: -1.0)
        
        let filletRad = 0.25
        
        XCTAssertNoThrow(try! Arc.shortFillet(spot: locat, toCtr: curvePerp, floor: myFloor, filletRadius: filletRad))
        
        
        do   {
            
            let badRad = 0.0
            _ = try Arc.shortFillet(spot: locat, toCtr: curvePerp, floor: myFloor, filletRadius: badRad)
                        
        } catch is NegativeAccuracyError   {
            
            XCTAssert(true)
            
        }   catch {
            XCTAssert(false, "Code should never have gotten here")
        }
        
        
        do   {
            
            let badDir = Vector3D(i: 0.0, j: 0.0, k: 0.33)
            _ = try Arc.shortFillet(spot: locat, toCtr: badDir, floor: myFloor, filletRadius: filletRad)
                        
        } catch is NonUnitDirectionError   {
            
            XCTAssert(true)
            
        }   catch {
            XCTAssert(false, "Code should never have gotten here")
        }
        
        
        do   {
            
            var badDir = Vector3D(i: 0.0, j: 0.33, k: 0.33)
            badDir.normalize()
            _ = try Arc.shortFillet(spot: locat, toCtr: badDir, floor: myFloor, filletRadius: filletRad)
                        
        } catch is NonUnitDirectionError   {
            
            XCTAssert(true)
            
        }   catch {
            XCTAssert(false, "Code should never have gotten here")
        }
        
        
        do   {
            
            let badSpot = Point3D(x: 2.0, y: 1.35, z: 2.0)
            
            _ = try Arc.shortFillet(spot: badSpot, toCtr: curvePerp, floor: myFloor, filletRadius: filletRad)
            
        } catch is CoincidentPointsError   {
            
            XCTAssert(true)
            
        }   catch {
            XCTAssert(false, "Code should never have gotten here")
        }
        
        
    }
    
    
    func testEdgeFillet()   {
        
        let locat = Point3D(x: 5.0, y: 1.0, z: 2.0)
        
        let normA = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        let normB = Vector3D(i: -1.0, j: 0.0, k: 0.0)
        
        let filletRad = 0.1875
        
        let allowableCrown = 0.004

        XCTAssertNoThrow(try Arc.edgeFilletArc(pip: locat, faceNormalB: normB, faceNormalA: normA, filletRad: filletRad, convex: true, allowableCrown: allowableCrown))
        
        
        do   {
            
            let badNormB = Vector3D(i: 3.0, j: 3.0, k: 3.0)
                

            _ = try Arc.edgeFilletArc(pip: locat, faceNormalB: badNormB, faceNormalA: normA, filletRad: filletRad, convex: true, allowableCrown: allowableCrown)
            
        } catch is NonUnitDirectionError   {
            
            XCTAssert(true)
            
        }   catch {
            XCTAssert(false, "Code should never have gotten here")
        }
        
        
        do   {
            
            let badNormA = Vector3D(i: 3.0, j: 3.0, k: 3.0)
                

            _ = try Arc.edgeFilletArc(pip: locat, faceNormalB: normB, faceNormalA: badNormA, filletRad: filletRad, convex: true, allowableCrown: allowableCrown)
            
        } catch is NonUnitDirectionError   {
            
            XCTAssert(true)
            
        }   catch {
            XCTAssert(false, "Code should never have gotten here")
        }
        
        
        do   {
            
            _ = try Arc.edgeFilletArc(pip: locat, faceNormalB: normB, faceNormalA: normA, filletRad: -0.25, convex: true, allowableCrown: allowableCrown)
            
        } catch is NegativeAccuracyError   {
            
            XCTAssert(true)
            
        }   catch {
            XCTAssert(false, "Code should never have gotten here")
        }
        
        
        do   {
            
            _ = try Arc.edgeFilletArc(pip: locat, faceNormalB: normB, faceNormalA: normA, filletRad: filletRad, convex: true, allowableCrown: -0.0001)
            
        } catch is NegativeAccuracyError   {
            
            XCTAssert(true)
            
        }   catch {
            XCTAssert(false, "Code should never have gotten here")
        }
        
        
        do   {
            
            var badNormB = Vector3D(i: 0.0, j: 0.8, k: -0.8)
            badNormB.normalize()
            
            _ = try Arc.edgeFilletArc(pip: locat, faceNormalB: badNormB, faceNormalA: normA, filletRad: filletRad, convex: true, allowableCrown: allowableCrown)
            

        } catch is NonUnitDirectionError   {
            
            XCTAssert(true)
            
        }   catch {
            XCTAssert(false, "Code should never have gotten here")
        }
        
        

    }
    
    func testSetSweep()   {
        
        let nexus = Point3D(x: 1.0, y: 1.0, z: 1.2)
        let myAxis = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        let greenFlag = Point3D(x: 1.0, y: 1.0, z: 1.8)
        
        var semi = try! Arc(ctr: nexus, axis: myAxis, start: greenFlag, sweep: Double.pi / 2.0)
        
        try! semi.setSweep(freshSweep: Double.pi * 3.0 / 2.0)
        XCTAssertEqual(Double.pi * 1.50, semi.getSweepAngle())
        
        
        do   {
                        
            try semi.setSweep(freshSweep: Double.pi * 3.0)
            

        } catch is ParameterRangeError   {
            
            XCTAssert(true)
            
        }   catch {
            XCTAssert(false, "Code should never have gotten here")
        }
        
        do   {
                        
            try semi.setSweep(freshSweep: Double.pi * -4.0)
            

        } catch is ParameterRangeError   {
            
            XCTAssert(true)
            
        }   catch {
            XCTAssert(false, "Code should never have gotten here")
        }
        
    }
    
    
}
