//
//  TransformPlusTests.swift
//  CurvePack
//
//  Created by Paul on 2/14/16.
//  Copyright © 2022 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest
@testable import CurvePack

class TransformTests: XCTestCase {

    
    func testIdentity()   {
        
        let noChange = Transform()
        
        XCTAssertEqual(noChange.a, 1.0)
        XCTAssertEqual(noChange.b, 0.0)
        XCTAssertEqual(noChange.c, 0.0)
        XCTAssertEqual(noChange.d, 0.0)

        XCTAssertEqual(noChange.e, 0.0)
        XCTAssertEqual(noChange.f, 1.0)
        XCTAssertEqual(noChange.g, 0.0)
        XCTAssertEqual(noChange.h, 0.0)

        XCTAssertEqual(noChange.j, 0.0)
        XCTAssertEqual(noChange.k, 0.0)
        XCTAssertEqual(noChange.m, 1.0)
        XCTAssertEqual(noChange.n, 0.0)

        XCTAssertEqual(noChange.p, 0.0)
        XCTAssertEqual(noChange.r, 0.0)
        XCTAssertEqual(noChange.s, 0.0)
        XCTAssertEqual(noChange.t, 1.0)
    }
    
    func testSingleRotations() {

        let fodder = Point3D(x: 2.0, y: 0.0, z: 0.0)
        let rowA = RowMtx4(ptIn: fodder)
        
        var simpleRot = Transform(rotationAxis: Axis.x, angleRad: Double.pi / 4.0)
        
        var multRes = rowA * simpleRot
        
        var transformed = multRes.toPoint()
        
        
        /// A handy factor in order to get precise comparisons
        let sq2rt = sqrt(2.0)
        
        let target1 = Point3D(x: 2.0, y: 0.0, z: 0.0)
        
        XCTAssert(transformed == target1)
        
        
        simpleRot = Transform(rotationAxis: Axis.y, angleRad: Double.pi / 4.0)
        
        multRes = rowA * simpleRot
        
        transformed = multRes.toPoint()
        
        let target2 = Point3D(x: sq2rt, y: 0.0, z: -sq2rt)
        
        XCTAssert(transformed == target2)
        
        
        
        simpleRot = Transform(rotationAxis: Axis.z, angleRad: Double.pi / 4.0)
        
        multRes = rowA * simpleRot
        
        transformed = multRes.toPoint()
        
        let target3 = Point3D(x: sq2rt, y: sq2rt, z: 0.0)
       
        XCTAssert(transformed == target3)
        
    }
    
    func testTranslate()   {
        
        let source = Point3D(x: 1.0, y: 5.0, z: 2.0)
        
        let tform = Transform(deltaX: -2.0, deltaY: 3.0, deltaZ: 1.5)
        
        let trial = source.transform(xirtam: tform)
        
        XCTAssertEqual(trial.x, -1.0)
        XCTAssertEqual(trial.y, 8.0)
        XCTAssertEqual(trial.z, 3.5)
        
    }
    
    
    func testScale()   {
        
        let source = Point3D(x: 5.0, y: -5.0, z: -5.0)
        
        let shrink = Transform(scaleX: 0.8, scaleY: -0.5, scaleZ: 1.4)
        
        let trial = source.transform(xirtam: shrink)
        
        XCTAssertEqual(trial.x, 4.0)
        XCTAssertEqual(trial.y, 2.5)
        XCTAssertEqual(trial.z, -7.0)

    }

    
    func testRollYourOwn() {
        
        let shortAxis = Vector3D(i: 0.75, j: 0.0, k: 0.0)
        let longAxis = Vector3D(i: 0.0, j: 1.2, k: 0.0)
        let oversized = Vector3D(i: 0.0, j: 0.0, k: 26.5)
        let dupe = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        
        let justRightX = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        let justRightY = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        let justRightZ = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        XCTAssertThrowsError( try Transform(localX: justRightX, localY: longAxis, localZ: justRightZ) )
        
        XCTAssertThrowsError( try Transform(localX: shortAxis, localY: justRightY, localZ: justRightZ) )

        XCTAssertThrowsError( try Transform(localX: justRightX, localY: justRightY, localZ: oversized) )

        XCTAssertNoThrow( try Transform(localX: justRightX, localY: justRightY, localZ: justRightZ) )

        
           // Check that one guard statement generates the proper error
        do {
                        
            _ = try Transform(localX: dupe, localY: justRightY, localZ: justRightZ)
            
        }  catch is NonOrthogonalCSYSError {
            
            XCTAssert(true)
            
        }  catch  {   // I don't see how you avoid writing this code, and having it be untested
        
            XCTAssert(false)
        }
        

        
        let fodder = Point3D(x: 2.0, y: 0.0, z: 0.0)
        let rowA = RowMtx4(ptIn: fodder)
        
        /// A handy factor in order to get precise comparisons
        let sq2rt = sqrt(2.0)
        let halfSq2rt = sq2rt / 2.0
        
           // Generate an equivalent to a rotation around the Z axis
        let freshXAxis = Vector3D(i: halfSq2rt, j: halfSq2rt, k: 0.0)
        let freshYAxis = Vector3D(i: -halfSq2rt, j: halfSq2rt, k: 0.0)
        let freshZAxis = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        let hardRot = try! Transform(localX: freshXAxis, localY: freshYAxis, localZ: freshZAxis)
        
        let multRes = rowA * hardRot
        
        let transformed = multRes.toPoint()
        
        let target3 = Point3D(x: sq2rt, y: sq2rt, z: 0.0)
        
        XCTAssert(transformed == target3)
        
        
        
    }
    
    func testGenToGlobal()   {
        
        let fred = CoordinateSystem()
        
        let pebbles = try! Transform.genToGlobal(csys: fred)
        
        let pristine = Transform()
        
        XCTAssert(pebbles == pristine)
        
        let barney = Point3D(x: 1.0, y: 2.0, z: 3.0)
        
        let wilma = CoordinateSystem.relocate(startingCSYS: fred, betterOrigin: barney)
        
        let bambam = try! Transform.genToGlobal(csys: wilma)
        
        XCTAssertFalse(bambam == pristine)
        
        XCTAssert(bambam.p == 1.0)
        XCTAssert(bambam.r == 2.0)
        XCTAssert(bambam.s == 3.0)
        
    }
    
    
    func testGenFromGlobal()   {
        
        let fred = CoordinateSystem()
        
        let barney = Point3D(x: 1.0, y: 2.0, z: 3.0)
        
        let wilma = CoordinateSystem.relocate(startingCSYS: fred, betterOrigin: barney)
        
        let betty = Transform.genFromGlobal(csys: wilma)
        
        XCTAssert(betty.p == -1.0)
        XCTAssert(betty.r == -2.0)
        XCTAssert(betty.s == -3.0)
        
        let dino = try! Transform.genToGlobal(csys: wilma)
        
        
        let local1 = Point3D(x: 5.0, y: 4.0, z: 3.0)
        let global1 = local1.transform(xirtam: dino)
        
        XCTAssert(global1.x == 6.0)
        XCTAssert(global1.y == 6.0)
        XCTAssert(global1.z == 6.0)
        
        let local2 = global1.transform(xirtam: betty)
        
        XCTAssert(local2 == local1)
        
    }
    
    
    func testRowMtx4Init()   {
        
        let vec = Vector3D(i: 0.5, j: 0.866, k: 0.7)
        
        let trial = RowMtx4(vecIn: vec)
        
        XCTAssert(trial.a == 0.5)
        XCTAssert(trial.b == 0.866)
        XCTAssert(trial.c == 0.7)
        XCTAssert(trial.d == 0.0)

    }
    
}
