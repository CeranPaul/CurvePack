//
//  QuadraticTests.swift
//  
//
//  Created by Paul Hollingshead on 3/28/22.
//

import XCTest
import CurvePack

class QuadraticTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConstructorA()   {
        
        let topRight = Point3D(x: 5.0, y: 4.5, z: 0.5)
                
        let peak = Point3D(x: 6.75, y: 3.75, z: 0.5)
        let mitt = Point3D(x: 5.25, y: 1.5, z: 1.0)
        
        /// The test subject
        let bulge = try! Quadratic(ptA: topRight, controlA: peak, ptB: mitt)
        
        
        XCTAssertThrowsError(try Quadratic(ptA: mitt, controlA: peak, ptB: mitt))
        
        let knownLength = 3.6198
        let currentLength = bulge.getLength()
        
        XCTAssertEqual(knownLength, currentLength, accuracy: Point3D.Epsilon)

        
        let termA = try! bulge.pointAt(t: 0.0)
        
        XCTAssert(termA == topRight)

        let termB = try! bulge.pointAt(t: 1.0)
        
        XCTAssert(termB == mitt)
    }
    
    
    func testConstructorB()   {
        
        let topRight = Point3D(x: 5.0, y: 4.5, z: 0.5)
                
        let peak = Point3D(x: 6.75, y: 3.75, z: 0.5)
        let mitt = Point3D(x: 5.25, y: 1.5, z: 1.0)
        
        /// The test subject
        let bulge = try! Quadratic(ptA: topRight, controlA: peak, ptB: mitt)
        
        let aboutMiddle = try! bulge.pointAt(t: 0.52)
        
        let bulge2 = try! Quadratic(ptA: topRight, beta: aboutMiddle, betaFraction: 0.52, ptC: mitt)
        
        let termA = try! bulge.pointAt(t: 0.0)
        
        XCTAssert(termA == topRight)

        let termB = try! bulge.pointAt(t: 1.0)
        
        XCTAssert(termB == mitt)

        let knownLength = 3.6198
        let currentLength = bulge2.getLength()
        
        XCTAssertEqual(knownLength, currentLength, accuracy: Point3D.Epsilon)

        
        XCTAssertThrowsError(try Quadratic(ptA: topRight, beta: topRight, betaFraction: 0.52, ptC: mitt))
        
        XCTAssertThrowsError(try Quadratic(ptA: topRight, beta: topRight, betaFraction: 1.52, ptC: mitt))
    }
    
    
    func testPointAt()   {
        
        let topRight = Point3D(x: 5.0, y: 4.5, z: 0.5)
                
        let peak = Point3D(x: 6.75, y: 3.75, z: 0.5)
        let mitt = Point3D(x: 5.25, y: 1.5, z: 1.0)
        
        /// The test subject
        let bulge = try! Quadratic(ptA: topRight, controlA: peak, ptB: mitt)
        
        
        XCTAssertNoThrow(try bulge.pointAt(t: 0.25))
        
        XCTAssertThrowsError(try bulge.pointAt(t: -0.25))
        
        let randomA = try! bulge.pointAt(t: 0.175)
        
        let knownPoint = Point3D(x: 5.5129, y: 4.1916, z: 0.5153)
        
        XCTAssert(knownPoint == randomA)
        
    }
    
    
    func testTangentAt()   {
        
        let topRight = Point3D(x: 5.0, y: 4.5, z: 0.5)
                
        let peak = Point3D(x: 6.75, y: 3.75, z: 0.5)
        let mitt = Point3D(x: 5.25, y: 1.5, z: 1.0)
        
        /// The test subject
        let bulge = try! Quadratic(ptA: topRight, controlA: peak, ptB: mitt)
        
        
        XCTAssertNoThrow(try bulge.tangentAt(t: 0.25))
        
        XCTAssertThrowsError(try bulge.tangentAt(t: -0.25))
        
        let randomA = try! bulge.tangentAt(t: 0.175)
        
        let knownVector = Vector3D(i: 2.3625, j: -2.025, k: 0.175)
        
        XCTAssert(knownVector == randomA)
    }
    
    
    func testApproximate()   {
        
        let topRight = Point3D(x: 5.0, y: 4.5, z: 0.5)
                
        let peak = Point3D(x: 6.75, y: 3.75, z: 0.5)
        let mitt = Point3D(x: 5.25, y: 1.5, z: 1.0)
        
        /// The test subject
        let bulge = try! Quadratic(ptA: topRight, controlA: peak, ptB: mitt)
        
        let pips = try! bulge.approximate(allowableCrown: 0.003)
        
        let knownCount = 21
        
        XCTAssertEqual(knownCount, pips.count)
        
        XCTAssertThrowsError(try bulge.approximate(allowableCrown: -0.05))
        
   }
    
    
    func testPerch() throws {
        
        let alameda = Point3D(x: 1.5, y: 1.0, z: 0.0)
        let pike = Point3D(x: 0.85, y: 0.25, z: 0.0)
        let union = Point3D(x: 1.30, y: 1.26, z: 0.0)
        
        /// The sample quadratic
        let satur = try! Quadratic(ptA: alameda, controlA: union, ptB: pike)
        

        let riding = Point3D(x: 1.3575, y: 1.0417, z: 0.0)
        let applique = try! satur.isCoincident(speck: riding)
        XCTAssert(applique.flag)
        
        let bucked = Point3D(x: 1.4, y: 0.05, z: 0.0)
        
        let glued = try! satur.isCoincident(speck: bucked)
        XCTAssertFalse(glued.flag)

    }
    
    
    func testIntersect()   {
        
        let topRight = Point3D(x: 5.0, y: 4.5, z: 0.5)
                
        let peak = Point3D(x: 6.75, y: 3.75, z: 0.5)
        let mitt = Point3D(x: 5.25, y: 1.5, z: 0.5)
        
        /// The test subject
        let bulge = try! Quadratic(ptA: topRight, controlA: peak, ptB: mitt)
        
        // Represent the intersecting line
        let bladeA1 = Point3D(x: 5.25, y: 5.9, z: 0.5)
        let bladeA2 = Point3D(x: 6.0, y: 0.9, z: 0.5)

        let bladeDir = Vector3D.built(from: bladeA1, towards: bladeA2, unit: true)
        
        let cuttingLineA = try! Line(spot: bladeA1, arrow: bladeDir)
        
        var collisions = try! bulge.intersect(ray: cuttingLineA, accuracy: 0.003)
        
        XCTAssert(collisions.count == 2)


        // Represent the intersecting line
        let bladeB1 = Point3D(x: 6.75, y: 5.9, z: 0.5)
        let bladeB2 = Point3D(x: 7.5, y: 0.9, z: 0.5)

        let bladeDirB = Vector3D.built(from: bladeB1, towards: bladeB2, unit: true)
        
        let cuttingLineB = try! Line(spot: bladeB1, arrow: bladeDirB)
        
        collisions = try! bulge.intersect(ray: cuttingLineB, accuracy: 0.003)
        
        XCTAssert(collisions.count == 0)


        // Represent the intersecting line
        let bladeC1 = Point3D(x: 3.5, y: 0.9, z: 0.5)
        let bladeC2 = Point3D(x: 6.75, y: 4.9, z: 0.5)

        let bladeDirC = Vector3D.built(from: bladeC1, towards: bladeC2, unit: true)
        
        let cuttingLineC = try! Line(spot: bladeC1, arrow: bladeDirC)
        
        collisions = try! bulge.intersect(ray: cuttingLineC, accuracy: 0.003)
        
        XCTAssert(collisions.count == 1)

        XCTAssertThrowsError(try bulge.intersect(ray: cuttingLineC, accuracy: -0.05))
        


        // Represent the intersecting line
        let bladeD1 = Point3D(x: 3.5, y: 0.9, z: 0.5)
        let bladeD2 = Point3D(x: 6.75, y: 4.9, z: 0.75)   // Different Z coordinate

        let bladeDirD = Vector3D.built(from: bladeD1, towards: bladeD2, unit: true)
        
        let cuttingLineD = try! Line(spot: bladeD1, arrow: bladeDirD)
        
        XCTAssertThrowsError(try bulge.intersect(ray: cuttingLineD, accuracy: 0.003))

    }


}
