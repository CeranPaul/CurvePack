//
//  LoopTests.swift
//  LoopFrayMTests
//
//  Created by Paul on 6/23/21.
//  Copyright © 2022 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest
@testable import CurvePack

/// An open Loop
var cup: Loop?   // Will always be instantiated by Setup

/// A closed Loop
var perimeter: Loop?   // Will always be instantiated by Setup

class LoopTests: XCTestCase {

    override func setUp() {
                
    }
    
    
    /// Sample Loop. Originally came from project LoopBench.
    /// Useful for testing Loop functions.
    public func buildLoopB() -> [PenCurve]   {
        
        ///The return value
        var crate = [PenCurve]()
        
        let lowerLeft = Point3D(x: -1.0, y: -1.0, z: 0.5)
        let upCorner = Point3D(x: -1.0, y: 0.5, z: 0.5)
        
        ///Short vertical on left
        let curb = try! LineSeg(end1: lowerLeft, end2: upCorner)
        
        
        let upWave = Point3D(x: 0.0, y: 1.75, z: 0.5)
        let downWave = Point3D(x: 1.20, y: 2.25, z: 0.5)
        let beach = Point3D(x: 3.0, y: 4.5, z: 0.5)
        
        /// Swoosh on upper left
        let wave = try! Cubic(alpha: upCorner, beta: upWave, betaFraction: 0.33, gamma: downWave, gammaFraction: 0.67, delta: beach)
        
        
        let topRight = Point3D(x: 5.0, y: 4.5, z: 0.5)
        
        /// Mesa at the top
        let plateau = try! LineSeg(end1: beach, end2: topRight)
        
        
        let peak = Point3D(x: 6.75, y: 3.75, z: 0.5)
        let mitt = Point3D(x: 5.25, y: 1.5, z: 0.5)
        
        ///Curve on right side
        let bulge = try! Quadratic(ptA: topRight, controlA: peak, ptB: mitt)
       
        
        let sqrt2 = sqrt(2.0)   // Useful for getting Arc coordinates correct
        
        let arc1 = Point3D(x: 2.75 + sqrt2 / 2.0, y: -1.0 + sqrt2 / 2.0, z: 0.5)
        
        ///Sloped portion above notch
        let overhang = try! LineSeg(end1: mitt, end2: arc1)
        
        
        let arcCtr = Point3D(x: 2.75, y: -1.0, z: 0.5)
        let arc2 = Point3D(x: 1.75, y: -1.0, z: 0.5)
        
        /// Circular cutout
        let notch = try! Arc(center: arcCtr, end1: arc1, end2: arc2, useSmallAngle: true)

        ///Bottom piece to complete the figure
        let heel = try! LineSeg(end1: arc2, end2: lowerLeft)
        
        
        
        crate.append(curb)
        
        crate.append(wave)
        
        crate.append(plateau)
        
        crate.append(bulge)
        
        crate.append(overhang)
        
        crate.append(notch)
        
        crate.append(heel)
        

        return crate
    }


    func testCount()   {
        
        ///An Array of curves
        let curveCrate = buildLoopB()
        
        let fence = Loop(refCoord: CoordinateSystem())   // XY plane
        
        fence.add(noob: curveCrate[1])
        fence.add(noob: curveCrate[4])
        fence.add(noob: curveCrate[5])

        XCTAssert(fence.rawCurves.count == 3)
        XCTAssert(fence.orderedCurves.count == 0)
        
        XCTAssert(fence.commonEndBucket.count == 5)
        
        
        let commonPts = fence.commonEndBucket
        
        let glued = commonPts.filter( {$0.other != nil} )
        XCTAssert(glued.count == 1)

        XCTAssertFalse(fence.closedBound)
    }

    func testClosed() {

        ///An Array of curves
        let curveCrate = buildLoopB()
        
        let fence = Loop(refCoord: CoordinateSystem())   // XY plane
        
        fence.add(noob: curveCrate[0])
        fence.add(noob: curveCrate[1])
        fence.add(noob: curveCrate[2])
        fence.add(noob: curveCrate[3])
        fence.add(noob: curveCrate[4])
        fence.add(noob: curveCrate[5])

        XCTAssertFalse(fence.closedBound)
        
        fence.add(noob: curveCrate[6])

        XCTAssert(fence.closedBound)
        
        XCTAssert(fence.orderedCurves.count == 7)
        
        
        // Unordered collection of pieces
        let fenceUn = Loop(refCoord: CoordinateSystem())   // XY plane
        
        fenceUn.add(noob: curveCrate[0])
        fenceUn.add(noob: curveCrate[5])
        fenceUn.add(noob: curveCrate[2])
        fenceUn.add(noob: curveCrate[6])
        fenceUn.add(noob: curveCrate[4])
        fenceUn.add(noob: curveCrate[1])
        fenceUn.add(noob: curveCrate[3])
        
        XCTAssert(fenceUn.closedBound)
        
        XCTAssert(fenceUn.orderedCurves.count == 7)

    }

    public func testFindIndex()   {
        
        ///The return value
        var crate = [PenCurve]()
        
        let lowerLeft = Point3D(x: -1.0, y: -1.0, z: 0.5)
        let upCorner = Point3D(x: -1.0, y: 0.5, z: 0.5)
        
        ///Short vertical on left
        let curb = try! LineSeg(end1: lowerLeft, end2: upCorner)
        
        
        let upWave = Point3D(x: 0.0, y: 1.75, z: 0.5)
        let downWave = Point3D(x: 1.20, y: 2.25, z: 0.5)
        let beach = Point3D(x: 3.0, y: 4.5, z: 0.5)
        
        /// Swoosh on upper left
        let wave = try! Cubic(alpha: upCorner, beta: upWave, betaFraction: 0.33, gamma: downWave, gammaFraction: 0.67, delta: beach)
        
        
        let topRight = Point3D(x: 5.0, y: 4.5, z: 0.5)
        
        /// Mesa at the top
        let plateau = try! LineSeg(end1: beach, end2: topRight)
        
        
        let peak = Point3D(x: 6.75, y: 3.75, z: 0.5)
        let mitt = Point3D(x: 5.25, y: 1.5, z: 0.5)
        
        ///Curve on right side
        let bulge = try! Quadratic(ptA: topRight, controlA: peak, ptB: mitt)
       
        
        let sqrt2 = sqrt(2.0)   // Useful for getting Arc coordinates correct
        
        let arc1 = Point3D(x: 2.75 + sqrt2 / 2.0, y: -1.0 + sqrt2 / 2.0, z: 0.5)
        
        ///Sloped portion above notch
        let overhang = try! LineSeg(end1: mitt, end2: arc1)
        
        
        let arcCtr = Point3D(x: 2.75, y: -1.0, z: 0.5)
        let arc2 = Point3D(x: 1.75, y: -1.0, z: 0.5)
        
        /// Circular cutout
        let notch = try! Arc(center: arcCtr, end1: arc1, end2: arc2, useSmallAngle: true)

        ///Bottom piece to complete the figure
        let heel = try! LineSeg(end1: arc2, end2: lowerLeft)
        
        crate.append(curb)
        
        crate.append(wave)
        
        crate.append(plateau)
        
        crate.append(bulge)
        
        crate.append(overhang)
        
        crate.append(notch)
        
        crate.append(heel)
        
        
        let fence = Loop(refCoord: CoordinateSystem())   // XY plane
        
        fence.add(noob: crate[0])
        fence.add(noob: crate[1])
        fence.add(noob: crate[2])
        fence.add(noob: crate[3])
        fence.add(noob: crate[4])
        fence.add(noob: crate[5])
        fence.add(noob: crate[6])


        let golden = fence.findCurveRaw(targetCurve: plateau)!
        
        XCTAssertEqual(2, golden)
        
        
        let golden2 = fence.findCurveOrdered(targetCurve: notch)!
        
        XCTAssertEqual(5, golden2)
        
    }
    
    
    public func testEquals()   {
        
        ///Container for seven curves
        var crate = [PenCurve]()
        
        let lowerLeft = Point3D(x: -1.0, y: -1.0, z: 0.5)
        let upCorner = Point3D(x: -1.0, y: 0.5, z: 0.5)
        
        ///Short vertical on left
        let curb = try! LineSeg(end1: lowerLeft, end2: upCorner)
        
        
        let upWave = Point3D(x: 0.0, y: 1.75, z: 0.5)
        let downWave = Point3D(x: 1.20, y: 2.25, z: 0.5)
        let beach = Point3D(x: 3.0, y: 4.5, z: 0.5)
        
        /// Swoosh on upper left
        let wave = try! Cubic(alpha: upCorner, beta: upWave, betaFraction: 0.33, gamma: downWave, gammaFraction: 0.67, delta: beach)
        
        
        let topRight = Point3D(x: 5.0, y: 4.5, z: 0.5)
        
        /// Mesa at the top
        let plateau = try! LineSeg(end1: beach, end2: topRight)
        
        
        let peak = Point3D(x: 6.75, y: 3.75, z: 0.5)
        let mitt = Point3D(x: 5.25, y: 1.5, z: 0.5)
        
        ///Curve on right side
        let bulge = try! Quadratic(ptA: topRight, controlA: peak, ptB: mitt)
       
        
        let sqrt2 = sqrt(2.0)   // Useful for getting Arc coordinates correct
        
        let arc1 = Point3D(x: 2.75 + sqrt2 / 2.0, y: -1.0 + sqrt2 / 2.0, z: 0.5)
        
        ///Sloped portion above notch
        let overhang = try! LineSeg(end1: mitt, end2: arc1)
        
        
        let arcCtr = Point3D(x: 2.75, y: -1.0, z: 0.5)
        let arc2 = Point3D(x: 1.75, y: -1.0, z: 0.5)
        
        /// Circular cutout
        let notch = try! Arc(center: arcCtr, end1: arc1, end2: arc2, useSmallAngle: true)

        ///Bottom piece to complete the figure
        let heel = try! LineSeg(end1: arc2, end2: lowerLeft)
        
        crate.append(curb)
        
        crate.append(wave)
        
        crate.append(plateau)
        
        crate.append(bulge)
        
        crate.append(overhang)
        
        crate.append(notch)
        
        crate.append(heel)
        
        
        
        let trialSegA = try! LineSeg(end1: lowerLeft, end2: topRight)
        
        XCTAssertFalse(Loop.equalsEndsType(lhs: trialSegA, rhs: curb, acceptReverse: false))
        
        
        let trialSegB = try! LineSeg(end1: lowerLeft, end2: upCorner)
        
        XCTAssert(Loop.equalsEndsType(lhs: trialSegB, rhs: curb, acceptReverse: false))
        
        
        let trialSegC = try! LineSeg(end1: upCorner, end2: lowerLeft)
        
        XCTAssertFalse(Loop.equalsEndsType(lhs: trialSegC, rhs: curb, acceptReverse: false))
        
        XCTAssert(Loop.equalsEndsType(lhs: trialSegC, rhs: curb, acceptReverse: true))
        
        
    }
    
    public func testCEContains()   {
        
        ///The collection of curves
        var crate = [PenCurve]()
        
        let lowerLeft = Point3D(x: -1.0, y: -1.0, z: 0.5)
        let upCorner = Point3D(x: -1.0, y: 0.5, z: 0.5)
        
        ///Short vertical on left
        let curb = try! LineSeg(end1: lowerLeft, end2: upCorner)
        
        
        let upWave = Point3D(x: 0.0, y: 1.75, z: 0.5)
        let downWave = Point3D(x: 1.20, y: 2.25, z: 0.5)
        let beach = Point3D(x: 3.0, y: 4.5, z: 0.5)
        
        /// Swoosh on upper left
        let wave = try! Cubic(alpha: upCorner, beta: upWave, betaFraction: 0.33, gamma: downWave, gammaFraction: 0.67, delta: beach)
        
        
        let topRight = Point3D(x: 5.0, y: 4.5, z: 0.5)
        
        /// Mesa at the top
        let plateau = try! LineSeg(end1: beach, end2: topRight)
        
        
        let peak = Point3D(x: 6.75, y: 3.75, z: 0.5)
        let mitt = Point3D(x: 5.25, y: 1.5, z: 0.5)
        
        ///Curve on right side
        let bulge = try! Quadratic(ptA: topRight, controlA: peak, ptB: mitt)
       
        
        let sqrt2 = sqrt(2.0)   // Useful for getting Arc coordinates correct
        
        let arc1 = Point3D(x: 2.75 + sqrt2 / 2.0, y: -1.0 + sqrt2 / 2.0, z: 0.5)
        
        ///Sloped portion above notch
        let overhang = try! LineSeg(end1: mitt, end2: arc1)
        
        
        let arcCtr = Point3D(x: 2.75, y: -1.0, z: 0.5)
        let arc2 = Point3D(x: 1.75, y: -1.0, z: 0.5)
        
        /// Circular cutout
        let notch = try! Arc(center: arcCtr, end1: arc1, end2: arc2, useSmallAngle: true)

        ///Bottom piece to complete the figure
        let heel = try! LineSeg(end1: arc2, end2: lowerLeft)
        
        crate.append(curb)
        
        crate.append(wave)
        
        crate.append(plateau)
        
        crate.append(bulge)
        
        crate.append(overhang)
        
        crate.append(notch)
        
        crate.append(heel)
        
        
        let fence = Loop(refCoord: CoordinateSystem())   // XY plane
        
        fence.add(noob: crate[0])
        fence.add(noob: crate[1])
        fence.add(noob: crate[2])
        fence.add(noob: crate[3])
        fence.add(noob: crate[4])
        fence.add(noob: crate[5])
        fence.add(noob: crate[6])
        
        var tally = 0
        
        
        for joint in fence.commonEndBucket   {
            
            if joint.contains(trialCurve: overhang)   {
                tally += 1
            }
        }

        XCTAssertEqual(2, tally)

    }
    
    
    public func testCERemoveCurve()   {
        
        ///The collection of curves
        var crate = [PenCurve]()
        
        let lowerLeft = Point3D(x: -1.0, y: -1.0, z: 0.5)
        let upCorner = Point3D(x: -1.0, y: 0.5, z: 0.5)
        
        ///Short vertical on left
        let curb = try! LineSeg(end1: lowerLeft, end2: upCorner)
        
        
        let upWave = Point3D(x: 0.0, y: 1.75, z: 0.5)
        let downWave = Point3D(x: 1.20, y: 2.25, z: 0.5)
        let beach = Point3D(x: 3.0, y: 4.5, z: 0.5)
        
        /// Swoosh on upper left
        let wave = try! Cubic(alpha: upCorner, beta: upWave, betaFraction: 0.33, gamma: downWave, gammaFraction: 0.67, delta: beach)
        
        
        let topRight = Point3D(x: 5.0, y: 4.5, z: 0.5)
        
        /// Mesa at the top
        let plateau = try! LineSeg(end1: beach, end2: topRight)
        
        
        let peak = Point3D(x: 6.75, y: 3.75, z: 0.5)
        let mitt = Point3D(x: 5.25, y: 1.5, z: 0.5)
        
        ///Curve on right side
        let bulge = try! Quadratic(ptA: topRight, controlA: peak, ptB: mitt)
       
        
        let sqrt2 = sqrt(2.0)   // Useful for getting Arc coordinates correct
        
        let arc1 = Point3D(x: 2.75 + sqrt2 / 2.0, y: -1.0 + sqrt2 / 2.0, z: 0.5)
        
        ///Sloped portion above notch
        let overhang = try! LineSeg(end1: mitt, end2: arc1)
        
        
        let arcCtr = Point3D(x: 2.75, y: -1.0, z: 0.5)
        let arc2 = Point3D(x: 1.75, y: -1.0, z: 0.5)
        
        /// Circular cutout
        let notch = try! Arc(center: arcCtr, end1: arc1, end2: arc2, useSmallAngle: true)

        ///Bottom piece to complete the figure
        let heel = try! LineSeg(end1: arc2, end2: lowerLeft)
        
        crate.append(curb)
        
        crate.append(wave)
        
        crate.append(plateau)
        
        crate.append(bulge)
        
        crate.append(overhang)
        
        crate.append(notch)
        
        crate.append(heel)
        
        
        let fence = Loop(refCoord: CoordinateSystem())   // XY plane
        
        fence.add(noob: crate[0])
        fence.add(noob: crate[1])
        fence.add(noob: crate[2])
        fence.add(noob: crate[3])
        fence.add(noob: crate[4])
        fence.add(noob: crate[5])
        fence.add(noob: crate[6])
        
        
        var tally = 0
                
        for (index, joint) in fence.commonEndBucket.enumerated()   {
            
            if joint.contains(trialCurve: overhang)   {
                tally += 1
                
                fence.commonEndBucket[index].removeCurve(vanishingCurve: overhang)
                
            }
        }

        XCTAssertEqual(2, tally)

        let commonPts = fence.commonEndBucket
        
        let glued = commonPts.filter( {$0.other == nil} )
        XCTAssertEqual(glued.count, 2)

    }
    
}
