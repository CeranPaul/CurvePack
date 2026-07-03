//
//  CircleTests.swift
//  CurvePack
//
//  Created by Paul on 7/3/26.
//

import XCTest
@testable import CurvePack

class CircleTests: XCTestCase {


    func testInside() {
        
        /// Outward from the XY plane
        let angel = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        let ctrA = Point3D(x: 1.0, y: 1.5, z: -2.0)
        let radA = 2.0
        let startA = Point3D(x: ctrA.x + radA, y: ctrA.y, z: ctrA.z)
        let circleA = try! Arc(ctr: ctrA, axis: angel, start: startA, sweep: 2.0 * Double.pi)
        
        let ctrB = Point3D(x: 2.0, y: 2.5, z: -2.0)
        let radB = 1.25
        let startB = Point3D(x: ctrB.x + radB, y: ctrB.y, z: ctrB.z)
        let circleB = try! Arc(ctr: ctrB, axis: angel, start: startB, sweep: 2.0 * Double.pi)

        let flag1 = Circle.isInside(cup: circleA, pip: circleB.getCenter())
        XCTAssert(flag1)
        
        let flag2 = Circle.isInside(cup: circleB, pip: circleA.getCenter())
        XCTAssertFalse(flag2)
        

    }
    
    /// Test a checking function
    func testIsSwallowed() {
        
        /// Outward from the XY plane
        let angel = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        
        let ctrA = Point3D(x: 1.0, y: 1.5, z: -1.2)
        let radA = 2.0
        let startA = Point3D(x: ctrA.x + radA, y: ctrA.y, z: ctrA.z)
        
        let largeA = try! Arc(ctr: ctrA, axis: angel, start: startA, sweep: 2.0 * Double.pi)

        
        let escape  = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        
        let ctrD = Point3D(x: 1.0, y: 1.0, z: -2.2)
        let radD = 0.375
        let startD = Point3D(x: ctrD.x, y: ctrD.y, z: ctrD.z + radD)
        
        let twistD = try! Arc(ctr: ctrD, axis: escape, start: startD, sweep: 2.0 * Double.pi)

        XCTAssertThrowsError(try Circle.isSwallowed(bigUn: largeA, ltlUn: twistD))
        
        
        let ctrB = Point3D(x: 1.0, y: 1.0, z: -1.2)
        let radB = 0.375
        let startB = Point3D(x: ctrB.x + radB, y: ctrB.y, z: ctrB.z)
        
        let smallB = try! Arc(ctr: ctrB, axis: angel, start: startB, sweep: 2.0 * Double.pi)
        
        XCTAssert( try! Circle.isSwallowed(bigUn: largeA, ltlUn: smallB))
        
        let ctrC = Point3D(x: 1.0, y: -0.25, z: -1.2)
        let radC = 0.625
        let startC = Point3D(x: ctrC.x + radC, y: ctrC.y, z: ctrC.z)
        
        let mediumC = try! Arc(ctr: ctrC, axis: angel, start: startC, sweep: 2.0 * Double.pi)
        
        XCTAssertFalse(try! Circle.isSwallowed(bigUn: largeA, ltlUn: mediumC))
        
    }

}
