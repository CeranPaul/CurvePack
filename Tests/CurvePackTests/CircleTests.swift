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
        let circleA = try! Circle(ctr: ctrA, axis: angel, start: startA)
        
        let ctrB = Point3D(x: 2.0, y: 2.5, z: -2.0)
        let radB = 1.25
        let startB = Point3D(x: ctrB.x + radB, y: ctrB.y, z: ctrB.z)
        let circleB = try! Circle(ctr: ctrB, axis: angel, start: startB)

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
        
        let largeA = try! Circle(ctr: ctrA, axis: angel, start: startA)

        
        let escape  = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        
        let ctrD = Point3D(x: 1.0, y: 1.0, z: -2.2)
        let radD = 0.375
        let startD = Point3D(x: ctrD.x, y: ctrD.y, z: ctrD.z + radD)
        
        let twistD = try! Circle(ctr: ctrD, axis: escape, start: startD)

        XCTAssertThrowsError(try Circle.isSwallowed(larger: largeA, smaller: twistD))
        
        
        let ctrB = Point3D(x: 1.0, y: 1.0, z: -1.2)
        let radB = 0.375
        let startB = Point3D(x: ctrB.x + radB, y: ctrB.y, z: ctrB.z)
        
        let smallB = try! Circle(ctr: ctrB, axis: angel, start: startB)
        
        XCTAssert( try! Circle.isSwallowed(larger: largeA, smaller: smallB))
        
        let ctrC = Point3D(x: 1.0, y: -0.25, z: -1.2)
        let radC = 0.625
        let startC = Point3D(x: ctrC.x + radC, y: ctrC.y, z: ctrC.z)
        
        let mediumC = try! Circle(ctr: ctrC, axis: angel, start: startC)
        
        XCTAssertFalse(try! Circle.isSwallowed(larger: largeA, smaller: mediumC))
        
    }

}
