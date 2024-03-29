//
//  OrthoVolTests.swift
//  CurvePack
//
//  Created by Paul on 11/6/15.
//  Copyright © 2022 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest
@testable import CurvePack

class OrthoVolTests: XCTestCase {

    func testInit() {
        
        let corner1 = Point3D(x: -2.0, y: -2.0, z: -2.0)
        let corner2 = Point3D(x: 3.0, y: 4.0, z: 5.0)
        
        do   {
            
            let shoe = try OrthoVol(corner1: corner1, corner2: corner2)
            
            XCTAssertEqual (shoe.getWidth(), 5.0, accuracy: Point3D.Epsilon / 3.0)
            XCTAssertEqual (shoe.getHeight(), 6.0, accuracy: Point3D.Epsilon / 3.0)
            XCTAssertEqual (shoe.getDepth(), 7.0, accuracy: Point3D.Epsilon / 3.0)
            
        } catch is CoincidentPointsError  {
            print("Really?  You screwed up in a unit test?")
        }  catch  {
            print("Some other logic screw-up while testing a box")
        }
    }
    
    func testRangeInit()   {
        
        let easyVol = OrthoVol(minX: 1.0, maxX: 5.0, minY: -1.2, maxY: 2.8, minZ: 3.0, maxZ: 3.5)
        
        XCTAssertEqual (easyVol.getWidth(), 4.0, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqual (easyVol.getHeight(), 4.0, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqual (easyVol.getDepth(), 0.50, accuracy: Point3D.Epsilon / 3.0)
        
        
        let backwardsVol = OrthoVol(minX: 5.0, maxX: 1.0, minY: -1.2, maxY: 2.8, minZ: 3.0, maxZ: 3.5)
        
        XCTAssertEqual (backwardsVol.getWidth(), 4.0, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqual (backwardsVol.getHeight(), 4.0, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqual (backwardsVol.getDepth(), 0.50, accuracy: Point3D.Epsilon / 3.0)
        
        
        let backwardsVol2 = OrthoVol(minX: 1.0, maxX: 5.0, minY: 1.2, maxY: -2.8, minZ: 3.0, maxZ: 3.5)
        
        XCTAssertEqual (backwardsVol2.getHeight(), 4.0, accuracy: Point3D.Epsilon / 3.0)
        
        
        let backwardsVol3 = OrthoVol(minX: 1.0, maxX: 5.0, minY: 1.2, maxY: -2.8, minZ: 3.5, maxZ: 3.0)
        
        XCTAssertEqual (backwardsVol3.getDepth(), 0.5, accuracy: Point3D.Epsilon / 3.0)
        
        
        
        let skinnyVol = OrthoVol(minX: 1.0, maxX: 5.0, minY: -1.2, maxY: 2.8, minZ: 3.0, maxZ: 3.0)
        
        XCTAssertEqual (skinnyVol.getWidth(), 4.0, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqual (skinnyVol.getHeight(), 4.0, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertNotEqual (skinnyVol.getDepth(), 0.0, accuracy: Point3D.Epsilon / 3.0)
        
        
        let skinnyVol2 = OrthoVol(minX: 1.0, maxX: 5.0, minY: -1.2, maxY: -1.2, minZ: 3.0, maxZ: 3.5)
        
        XCTAssertEqual (skinnyVol2.getWidth(), 4.0, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertNotEqual (skinnyVol2.getHeight(), 0.0, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqual (skinnyVol2.getDepth(), 0.5, accuracy: Point3D.Epsilon / 3.0)
        
        
        let skinnyVol3 = OrthoVol(minX: 1.0, maxX: 1.0, minY: -1.2, maxY: 2.8, minZ: 3.0, maxZ: 3.5)
        
        XCTAssertNotEqual (skinnyVol3.getWidth(), 0.0, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqual (skinnyVol3.getHeight(), 4.0, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqual (skinnyVol3.getDepth(), 0.5, accuracy: Point3D.Epsilon / 3.0)
        
    }

    func testReverse()   {
        
        let corner1 = Point3D(x: -2.0, y: -2.0, z: -2.0)
        let corner2 = Point3D(x: 3.0, y: 4.0, z: 5.0)
        
        do   {
            
            let shoe = try OrthoVol(corner1: corner1, corner2: corner2)
            
            let boot = try OrthoVol(corner1: corner2, corner2: corner1)
            
            XCTAssertEqual (shoe.getWidth(), boot.getWidth(), accuracy: Point3D.Epsilon / 3.0)
            XCTAssertEqual (shoe.getHeight(), boot.getHeight(), accuracy: Point3D.Epsilon / 3.0)
            XCTAssertEqual (shoe.getDepth(), boot.getDepth(), accuracy: Point3D.Epsilon / 3.0)
            
            XCTAssert(shoe.getOrigin() == boot.getOrigin())
            
        } catch is CoincidentPointsError  {
            print("Really?  You screwed up in a unit test?")
        }  catch  {
            print("Some other logic screw-up while testing a box")
        }
    }
    
    func testDepth() {
        
        let corner1 = Point3D(x: -2.0, y: -2.0, z: -2.0)
        let corner2 = Point3D(x: 3.0, y: 4.0, z: 5.0)
        
        do   {
            
            let shoe = try OrthoVol(corner1: corner1, corner2: corner2)
                        
            XCTAssertEqual(shoe.getDepth(), 7.0, accuracy: Point3D.Epsilon / 3.0)
            
        } catch is CoincidentPointsError  {
            print("Really?  You screwed up in a unit test?")
        }  catch  {
            print("Some other logic screw-up while testing a box")
        }
    }
    
    func testCloud()   {
        
        /// A collection of random points
        var cloud = [Point3D]()
        
        let rangeLower = -5.2
        let rangeUpper = 10.5
        
        let egnar = ClosedRange<Double>(uncheckedBounds: (lower: rangeLower, upper: rangeUpper))
        
        for _ in 0...99   {
            
            let freshX = Double.random(in: egnar)
            let freshY = Double.random(in: egnar)
            let freshZ = Double.random(in: egnar)
            
            let freshPoint = Point3D(x: freshX, y: freshY, z: freshZ)
            cloud.append(freshPoint)
        }
        
        let MonteCarlo = OrthoVol(spots: cloud)
        
        
        let ext1 = Point3D(x: rangeLower, y: rangeLower, z: rangeLower)
        let ext2 = Point3D(x: rangeUpper, y: rangeUpper, z: rangeUpper)
        let standard = try! OrthoVol(corner1: ext1, corner2: ext2)
        
        XCTAssert(OrthoVol.surrounds(big: standard, little: MonteCarlo))
        
    }
    
    func testCenter()   {
        
        let ext1 = Point3D(x: -4.0, y: -5.0, z: -6.0)
        let ext2 = Point3D(x: 4.0, y: 5.0, z: 8.0)
        let standard = try! OrthoVol(corner1: ext1, corner2: ext2)
        
        let target = Point3D(x: 0.0, y: 0.0, z: 1.0)
        
        let trial = standard.getRotCenter()
        
        XCTAssertEqual(target, trial)
    }
    
    func testLongest()   {
        
        let ext1 = Point3D(x: -4.0, y: -5.0, z: -6.0)
        let ext2 = Point3D(x: -1.0, y: -1.0, z: 6.0)
        let standard = try! OrthoVol(corner1: ext1, corner2: ext2)
        
        XCTAssertEqual(standard.getLongest(), 13.0, accuracy: 0.5)
    }
    
    
    func testThicken()  {
        
        let corner1 = Point3D(x: -2.0, y: -2.0, z: 0.0)
        let corner2 = Point3D(x: 1.0, y: 2.0, z: 0.0)
        
        do   {
            
            let shoe = try OrthoVol(corner1: corner1, corner2: corner2)
            
            XCTAssertEqual (shoe.getWidth(), 3.0, accuracy: Point3D.Epsilon / 3.0)
            XCTAssertEqual (shoe.getHeight(), 4.0, accuracy: Point3D.Epsilon / 3.0)
            XCTAssertEqual (shoe.getDepth(), 1.0, accuracy: Point3D.Epsilon / 3.0)
            
        } catch is CoincidentPointsError  {
            print("Really?  You screwed up in a unit test?  A")
        }  catch  {
            print("Some other logic screw-up while testing a box")
        }
        
        
    }
    
    func testCombine()  {
        
        let cornerAlpha = Point3D(x: 1.0, y: 1.0, z: 0.0)
        let cornerBeta = Point3D(x: 1.0, y: 5.0, z: 0.0)
        let cornerDelta = Point3D(x: 8.0, y: 1.0, z: 0.0)
        let cornerGamma = Point3D(x: 8.0, y: 5.0, z: 0.0)
        
        do   {
            
            let leftBox = try OrthoVol(corner1: cornerAlpha, corner2: cornerBeta)
            
            XCTAssertEqual (leftBox.getWidth(), 0.8, accuracy: Point3D.Epsilon / 3.0)
            XCTAssertEqual (leftBox.getHeight(), 4.0, accuracy: Point3D.Epsilon / 3.0)
            XCTAssertEqual (leftBox.getDepth(), 0.8, accuracy: Point3D.Epsilon / 3.0)
            
            let rightBox = try OrthoVol(corner1: cornerDelta, corner2: cornerGamma)
            
            XCTAssertEqual (rightBox.getWidth(), 0.8, accuracy: Point3D.Epsilon / 3.0)
            XCTAssertEqual (rightBox.getHeight(), 4.0, accuracy: Point3D.Epsilon / 3.0)
            XCTAssertEqual (rightBox.getDepth(), 0.8, accuracy: Point3D.Epsilon / 3.0)
            
            
            let combi = leftBox + rightBox
            
                // 7.8 because each of the original boxes was thickened by 0.4 on each side
            XCTAssertEqual (combi.getWidth(), 7.8, accuracy: Point3D.Epsilon / 3.0)
            XCTAssertEqual (combi.getHeight(), 4.0, accuracy: Point3D.Epsilon / 3.0)
            XCTAssertEqual (combi.getDepth(), 0.8, accuracy: Point3D.Epsilon / 3.0)
            
        } catch is CoincidentPointsError  {
            print("Really?  You screwed up in a unit test?  A2")
        }  catch  {
            print("Some other logic screw-up while testing a box")
        }
    }
    
    func testOverlap()   {
        
        let ptAlpha = Point3D(x: 1.0, y: 0.0, z: 1.0)
        let ptBeta = Point3D(x: 1.0, y: 0.0, z: 5.0)
        let ptDelta = Point3D(x: 8.0, y: 0.0, z: 1.0)
        let ptGamma = Point3D(x: 8.0, y: 0.0, z: 5.0)
        
        let lineA = try! LineSeg(end1: ptAlpha, end2: ptBeta)
        
        let lineB = try! LineSeg(end1: ptDelta, end2: ptGamma)

        let flag = OrthoVol.isOverlapping(lhs: lineA.getExtent(), rhs: lineB.getExtent())
        
        XCTAssertFalse(flag)
        
        
        let ptAlpha2 = Point3D(x: 1.0, y: 1.0, z: 1.0)
        let ptBeta2 = Point3D(x: 1.0, y: 5.0, z: 5.0)
        let ptDelta2 = Point3D(x: 1.0, y: 5.0, z: 1.0)
        let ptGamma2 = Point3D(x: 1.0, y: 1.0, z: 5.0)
        
        let lineC = try! LineSeg(end1: ptAlpha2, end2: ptBeta2)
        
        let lineD = try! LineSeg(end1: ptDelta2, end2: ptGamma2)
        
        let flag2 = OrthoVol.isOverlapping(lhs: lineC.getExtent(), rhs: lineD.getExtent())
        
        XCTAssert(flag2)
    }
    
    func testTransform()   {
        
        let sourceVol = OrthoVol(minX: 1.0, maxX: 5.0, minY: -1.2, maxY: 2.8, minZ: 3.0, maxZ: 3.5)
        
        let swing = Transform()
        
        var destVol = sourceVol.transform(xirtam: swing)
        
        XCTAssertEqual(destVol.getOrigin().x, 1.0, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqual(destVol.getOrigin().y, -1.2, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqual(destVol.getOrigin().z, 3.0, accuracy: Point3D.Epsilon / 3.0)
        
        XCTAssertEqual(destVol.getWidth(), 4.0, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqual(destVol.getHeight(), 4.0, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqual(destVol.getDepth(), 0.5, accuracy: Point3D.Epsilon / 3.0)
        
           // Test a simple rotation
        let rotX = Transform(rotationAxis: Axis.x, angleRad: Double.pi / 4.0)
        
        /// Handy multiplier
        let sqrt22 = sqrt(2.0) / 2.0
        
        destVol = sourceVol.transform(xirtam: rotX)
        
        XCTAssertEqual(destVol.getOrigin().x, 1.0, accuracy: Point3D.Epsilon / 3.0)
        
        let targetY = sourceVol.getOrigin().y * sqrt22 - (sourceVol.getOrigin().z + sourceVol.getDepth()) * sqrt22
        XCTAssertEqual(destVol.getOrigin().y, targetY, accuracy: Point3D.Epsilon / 3.0)
        
        let targetZ = (sourceVol.getOrigin().z) * sqrt22 + sourceVol.getOrigin().y * sqrt22
        XCTAssertEqual(destVol.getOrigin().z, targetZ, accuracy: Point3D.Epsilon / 3.0)
        

        XCTAssertEqual(destVol.getWidth(), 4.0, accuracy: Point3D.Epsilon / 3.0)

        let targetHeight = (sourceVol.getHeight() + sourceVol.getDepth()) * sqrt22
        XCTAssertEqual(destVol.getHeight(), targetHeight, accuracy: Point3D.Epsilon / 3.0)
        
        let targetDepth = (sourceVol.getDepth() + sourceVol.getHeight()) * sqrt22
        XCTAssertEqual(destVol.getDepth(), targetDepth, accuracy: Point3D.Epsilon / 3.0)
                
    }

    func testCoincidence()   {
    
        let ptAlpha = Point3D(x: 1.0, y: 0.0, z: 1.0)
        let ptBeta = Point3D(x: 1.0, y: 0.0, z: 5.0)
        
        let ptGamma = Point3D(x: 1.0, y: 0.0, z: 5.0)
        
        XCTAssertNoThrow(try OrthoVol(corner1: ptAlpha, corner2: ptBeta))
        
        XCTAssertThrowsError(try OrthoVol(corner1: ptGamma, corner2: ptBeta))
        
    }
    
}
