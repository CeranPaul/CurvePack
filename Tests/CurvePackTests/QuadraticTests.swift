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
    
    
    func testSetIntent()   {
        
        let alameda = Point3D(x: 1.5, y: 1.0, z: 0.0)
        let pike = Point3D(x: 0.85, y: 0.25, z: 0.0)
        let union = Point3D(x: 1.30, y: 1.26, z: 0.0)
        
        /// The sample quadratic
        var satur = try! Quadratic(ptA: alameda, controlA: union, ptB: pike)
        
        XCTAssert(satur.usage == "Ordinary")
        
        satur.setIntent(purpose: "Selected")
        XCTAssert(satur.usage == "Selected")
        
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
    
    
    func testCopyCon()   {
        
        let aardvark = Point3D(x: 5.0, y: 4.5, z: 0.5)
                
        let monkey = Point3D(x: 6.75, y: 3.75, z: 0.5)
        let zebra = Point3D(x: 5.25, y: 1.5, z: 0.5)
        
        /// The test subject
        let zooTrail = try! Quadratic(ptA: aardvark, controlA: monkey, ptB: zebra)
        
        let zooPath = Quadratic(sourceCurve: zooTrail)
        
        let pipTA = try! zooTrail.pointAt(t: 0.23)
        let pipPA = try! zooPath.pointAt(t: 0.23)
        
        XCTAssert(pipPA == pipTA)
        
    }
    
    
    func testTrimFront()   {
        
        let aardvark = Point3D(x: 5.0, y: 4.5, z: 0.5)
                
        let monkey = Point3D(x: 6.75, y: 3.75, z: 0.5)
        let zebra = Point3D(x: 5.25, y: 1.5, z: 0.5)
        
        /// The test subject
        var zooTrail = try! Quadratic(ptA: aardvark, controlA: monkey, ptB: zebra)
        
        let pristineLength = zooTrail.getLength()
        
        XCTAssertNoThrow( try zooTrail.trimFront(lowParameter: 0.17))
        
        XCTAssertThrowsError( try zooTrail.trimFront(lowParameter: -0.05))
        
        
        try! zooTrail.trimFront(lowParameter: 0.11)
        
        let trimmedLength = zooTrail.getLength()
        
        XCTAssert(pristineLength > trimmedLength)
        
        try! zooTrail.trimFront(lowParameter: 0.08)

        let trimmedLength2 = zooTrail.getLength()

        XCTAssert(trimmedLength < trimmedLength2)
        
    }
    
    
    func testTrimBack()   {
        
        let aardvark = Point3D(x: 5.0, y: 4.5, z: 0.5)
                
        let monkey = Point3D(x: 6.75, y: 3.75, z: 0.5)
        let zebra = Point3D(x: 5.25, y: 1.5, z: 0.5)
        
        /// The test subject
        var zooTrail = try! Quadratic(ptA: aardvark, controlA: monkey, ptB: zebra)
        
        let pristineLength = zooTrail.getLength()
        
        XCTAssertNoThrow( try zooTrail.trimBack(highParameter: 0.90))
        
        XCTAssertThrowsError( try zooTrail.trimBack(highParameter: 1.05))
        
        
        try! zooTrail.trimBack(highParameter: 0.93)
        
        let trimmedLength = zooTrail.getLength()
        
        XCTAssert(pristineLength > trimmedLength)
        
        try! zooTrail.trimBack(highParameter: 0.95)

        let trimmedLength2 = zooTrail.getLength()

        XCTAssert(trimmedLength < trimmedLength2)
        
    }
    
    
    func testTrimOverlap()   {
        
        let aardvark = Point3D(x: 5.0, y: 4.5, z: 0.5)
                
        let monkey = Point3D(x: 6.75, y: 3.75, z: 0.5)
        let zebra = Point3D(x: 5.25, y: 1.5, z: 0.5)
        
        /// The test subject
        var zooTrail = try! Quadratic(ptA: aardvark, controlA: monkey, ptB: zebra)
        
        try! zooTrail.trimBack(highParameter: 0.60)
        
        XCTAssertThrowsError(try zooTrail.trimFront(lowParameter: 0.62))

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

        let bladeDir = Vector3D(from: bladeA1, towards: bladeA2, unit: true)
        
        let cuttingLineA = try! Line(spot: bladeA1, arrow: bladeDir)
        
        var collisions = try! bulge.intersect(ray: cuttingLineA, accuracy: 0.003)
        
        XCTAssert(collisions.count == 2)


        // Represent the intersecting line
        let bladeB1 = Point3D(x: 6.75, y: 5.9, z: 0.5)
        let bladeB2 = Point3D(x: 7.5, y: 0.9, z: 0.5)

        let bladeDirB = Vector3D(from: bladeB1, towards: bladeB2, unit: true)
        
        let cuttingLineB = try! Line(spot: bladeB1, arrow: bladeDirB)
        
        collisions = try! bulge.intersect(ray: cuttingLineB, accuracy: 0.003)
        
        XCTAssert(collisions.count == 0)


        // Represent the intersecting line
        let bladeC1 = Point3D(x: 3.5, y: 0.9, z: 0.5)
        let bladeC2 = Point3D(x: 6.75, y: 4.9, z: 0.5)

        let bladeDirC = Vector3D(from: bladeC1, towards: bladeC2, unit: true)
        
        let cuttingLineC = try! Line(spot: bladeC1, arrow: bladeDirC)
        
        collisions = try! bulge.intersect(ray: cuttingLineC, accuracy: 0.003)
        
        XCTAssert(collisions.count == 1)

        XCTAssertThrowsError(try bulge.intersect(ray: cuttingLineC, accuracy: -0.05))
        


        // Represent the intersecting line
        let bladeD1 = Point3D(x: 3.5, y: 0.9, z: 0.5)
        let bladeD2 = Point3D(x: 6.75, y: 4.9, z: 0.75)   // Different Z coordinate

        let bladeDirD = Vector3D(from: bladeD1, towards: bladeD2, unit: true)
        
        let cuttingLineD = try! Line(spot: bladeD1, arrow: bladeDirD)
        
        XCTAssertThrowsError(try bulge.intersect(ray: cuttingLineD, accuracy: 0.003))

    }

    
    func testReverse()   {
        
        let aardvark = Point3D(x: 5.0, y: 4.5, z: 0.5)
                
        let monkey = Point3D(x: 6.75, y: 3.75, z: 0.5)
        let zebra = Point3D(x: 5.25, y: 1.5, z: 0.5)
        
        /// The test subject
        var zooTrail = try! Quadratic(ptA: aardvark, controlA: monkey, ptB: zebra)
        
        let pen = try! zooTrail.pointAt(t: 0.45)
        let cage = try! zooTrail.pointAt(t: 0.96)
        let aviary = try! zooTrail.pointAt(t: 0.07)
        
        zooTrail.reverse()
        
        let penRev = try! zooTrail.pointAt(t: 0.55)
        
        XCTAssertEqual(pen, penRev)
        
        let cageRev = try! zooTrail.pointAt(t: 0.04)
        
        XCTAssertEqual(cage, cageRev)
        
        let aviaryRev = try! zooTrail.pointAt(t: 0.93)
        
        XCTAssertEqual(aviary, aviaryRev)
        
    }

    
    func testTransform()   {
        
        let aardvark = Point3D(x: 5.0, y: 4.5, z: 0.5)
                
        let monkey = Point3D(x: 6.75, y: 3.75, z: 0.5)
        let zebra = Point3D(x: 5.25, y: 1.5, z: 0.5)
        
        /// The test subject
        let zooTrail = try! Quadratic(ptA: aardvark, controlA: monkey, ptB: zebra)

        
        let swingZ = Transform(rotationAxis: Axis.z, angleRad: Double.pi / 2.0)
        
        let zooPath = zooTrail.transform(xirtam: swingZ)
        
        let pristine = try! zooTrail.pointAt(t: 0.31)
        
        let swung = try! zooPath.pointAt(t: 0.31, ignoreTrim: true)   // Compiler was having a fit about the second parameter.

        XCTAssertEqual(swung.x, -1.0 * pristine.y, accuracy: Point3D.Epsilon)
        XCTAssertEqual(swung.y, pristine.x, accuracy: Point3D.Epsilon)
        XCTAssertEqual(swung.z, pristine.z, accuracy: Point3D.Epsilon)
        
    }
    
    
    func testGetExtent()   {
        
        let aardvark = Point3D(x: 5.0, y: 0.5, z: 4.5)
                
        let monkey = Point3D(x: 6.75, y: 0.5, z: 4.75)
        let zebra = Point3D(x: 9.0, y: 0.5, z: 1.5)
        
        /// The test subject
        let zooTrail = try! Quadratic(ptA: aardvark, controlA: monkey, ptB: zebra)

        let brick = zooTrail.getExtent()
        
        let spanY = brick.getHeight()
        
        XCTAssert(spanY > 0.0)
        
    }
    
    
    func testSplitParam()   {
        
        let sword1 = Point3D(x: -2.9, y: 1.05, z: 0.0)
        let sword2 = Point3D(x: 0.6, y: 1.65, z: 0.0)
        let sword4 = Point3D(x: 4.2, y: 0.65, z: 0.0)
        
        /// An untrimmed Quadratic at the moment
        var beater = try! Quadratic(ptA: sword1, controlA: sword2, ptB: sword4)
        
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
