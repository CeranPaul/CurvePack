//
//  LineSegTests.swift
//  CurvePack
//
//  Created by Paul on 11/3/15.
//  Copyright © 2022 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest
@testable import CurvePack

class LineSegTests: XCTestCase {

    
    func testFidelity()   {
        
        let alpha = Point3D(x: 2.5, y: 2.5, z: 2.5)
        let beta = Point3D(x: 4.5, y: 4.5, z: 2.5)
        
        let stroke = try! LineSeg(end1: alpha, end2: beta)
        
        XCTAssert(alpha == stroke.getOneEnd())
        XCTAssert(beta == stroke.getOtherEnd())
        
        XCTAssert(stroke.usage == "Ordinary")
        
        let gamma = Point3D(x: 2.5, y: 2.5, z: 2.5)
        
        XCTAssertThrowsError(try LineSeg(end1: alpha, end2: gamma))
        
    }
    
    func testSetIntent()   {
        
        let alpha = Point3D(x: 2.5, y: 2.5, z: 2.5)
        let beta = Point3D(x: 4.5, y: 4.5, z: 2.5)
        
        var stroke = try! LineSeg(end1: alpha, end2: beta)
        
        XCTAssert(stroke.usage == "Ordinary")
        
        stroke.setIntent(purpose: "Selected")
        XCTAssert(stroke.usage == "Selected")
        
    }
    


    /// Test a point at some proportion along the line segment
    func testPointAt() {
        
        let pt1 = Point3D(x: 1.0, y: 1.0, z: 1.0)
        let pt2 = Point3D(x: 5.0, y: 5.0, z: 5.0)
        
        var slash = try! LineSeg(end1: pt1, end2: pt2)
        
        let ladybug = try! slash.pointAt(t: 0.6)
        
        let home = Point3D(x: 3.4, y: 3.4, z: 3.4)
        
        XCTAssert(ladybug == home)
        
        XCTAssertThrowsError(try slash.pointAt(t: -0.4))
        XCTAssertThrowsError(try slash.pointAt(t: 1.7))
        
        
        try! slash.trimFront(lowParameter: 0.25)
        
        XCTAssertNoThrow(try slash.pointAt(t: 0.38))

        XCTAssertThrowsError(try slash.pointAt(t: 0.20))

        XCTAssertNoThrow(try slash.pointAt(t: 0.20, ignoreTrim: true))

        XCTAssertThrowsError(try slash.pointAt(t: 1.15, ignoreTrim: true))

   }
    

    func testTangent()   {
        
        let alpha = Point3D(x: 2.5, y: 2.5, z: 2.5)
        let beta = Point3D(x: 2.5, y: 4.5, z: 2.5)
        
        let stroke = try! LineSeg(end1: alpha, end2: beta)
        
        let trial = try! stroke.tangentAt(t: 0.5)   // Not normalized
        
        let target = Vector3D(i: 0.0, j: 2.0, k: 0.0)
        
        XCTAssert(trial == target)
        
        
        let normTarget = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        
        XCTAssertFalse(trial == normTarget)
        
        XCTAssertThrowsError(try stroke.tangentAt(t: -0.4))
        XCTAssertThrowsError(try stroke.tangentAt(t: 1.7))

    }
    
    func testLength()   {
        
        let alpha = Point3D(x: 2.5, y: 2.5, z: 2.5)
        let beta = Point3D(x: 4.5, y: 2.5, z: 2.5)
        
        let bar = try! LineSeg(end1: alpha, end2: beta)
        
        let target = 2.0
        
        XCTAssertEqual(bar.getLength(), target)
    }
    
    func testTransform()   {
        
        let hyar = Point3D(x: 5.0, y: 6.0, z: 3.5)
        let thar = Point3D(x: 4.0, y: 6.0, z: 3.5)
        
        let pristine = try! LineSeg(end1: hyar, end2: thar)
        
        let targetOne = Point3D(x: -6.0, y: 5.0, z: 3.5)
        let targetAnother = Point3D(x: -6.0, y: 4.0, z: 3.5)
        
        let pitched = try! LineSeg(end1: targetOne, end2: targetAnother)
        
        let swingZ = Transform(rotationAxis: Axis.z, angleRad: Double.pi / 2.0)
        let swung = try! pristine.transform(xirtam: swingZ) as! LineSeg
        
        XCTAssert(swung == pitched)
                
    }

    func testMirrorLineSeg()   {
        
        let hyar = Point3D(x: 5.0, y: 6.0, z: 3.5)
        let thar = Point3D(x: 4.0, y: 6.0, z: 3.5)
        
        let wand = try! LineSeg(end1: hyar, end2: thar)
        
        let nexus = Point3D(x: 0.0, y: 0.0, z: 0.0)
        
        let XYdir = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        let silver1 = try! Plane(spot: nexus, arrow: XYdir)
        
        let target1 = Point3D(x: 5.0, y: 6.0, z: -3.5)
        let target2 = Point3D(x: 4.0, y: 6.0, z: -3.5)
        
        let desired = try! LineSeg(end1: target1, end2: target2)

        let fairest = LineSeg.mirror(wire: wand, flat: silver1)
        
        XCTAssertEqual(fairest, desired)
        
    }

    func testReverse()   {
        
        let alpha = Point3D(x: 2.5, y: 2.5, z: 2.5)
        let beta = Point3D(x: 4.5, y: 4.5, z: 4.5)
        
        var stroke = try! LineSeg(end1: alpha, end2: beta)
        
        stroke.reverse()
        
        XCTAssertEqual(alpha, stroke.getOtherEnd())
        XCTAssertEqual(beta, stroke.getOneEnd())
    }
    
    func testResolveRelativeVec()   {
        
        let alpha = Point3D(x: 2.5, y: 2.5, z: 2.5)
        let beta = Point3D(x: 4.5, y: 2.5, z: 2.5)
        
        let stroke = try! LineSeg(end1: alpha, end2: beta)
        
        let pip = Point3D(x: 3.5, y: 3.0, z: 2.5)
        
        let offset = stroke.resolveRelativeVec(speck: pip)
        
        
        let targetA = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        let targetP = Vector3D(i: 0.0, j: 0.5, k: 0.0)
        
        XCTAssertEqual(offset.along, targetA)
        XCTAssertEqual(offset.perp, targetP)
        
    }
    
    func testResolveRelative()   {
        
        let alpha = Point3D(x: 2.5, y: 2.5, z: 2.5)
        let beta = Point3D(x: 4.5, y: 2.5, z: 2.5)
        
        let stroke = try! LineSeg(end1: alpha, end2: beta)
        
        let pip = Point3D(x: 3.5, y: 3.0, z: 2.5)
        
        let offset = stroke.resolveRelative(speck: pip)
        
        
        let targetA = 1.0
        let targetP = 0.5
        
        XCTAssertEqual(offset.along, targetA)
        XCTAssertEqual(offset.away, targetP)
        
    }
    
    func testIsCrossing()   {
        
        let alpha = Point3D(x: 2.5, y: 2.5, z: 2.5)
        let beta = Point3D(x: 2.5, y: 4.5, z: 2.5)
        
        let stroke = try! LineSeg(end1: alpha, end2: beta)
        
        let chopA = Point3D(x: 2.4, y: 2.8, z: 2.5)
        let chopB = Point3D(x: 2.6, y: 2.7, z: 2.5)
        
        let chop = try! LineSeg(end1: chopA, end2: chopB)
        
        let flag1 = stroke.isCrossing(chop: chop)
        
        XCTAssert(flag1)
        
    }
    
    func testClipTo()   {
        
        let alpha = Point3D(x: 2.5, y: 2.5, z: 2.5)
        let beta = Point3D(x: 4.5, y: 4.5, z: 2.5)
        
        let stroke = try! LineSeg(end1: alpha, end2: beta)
        
        let cliff = Point3D(x: 4.0, y: 4.0, z: 2.5)
        
        let shorter = stroke.clipTo(stub: cliff, keepNear: true)
        
        let target = 1.5 * sqrt(2.0)
        
        XCTAssertEqual(target, shorter.getLength(), accuracy: Point3D.Epsilon)
        
        let distal = stroke.clipTo(stub: cliff, keepNear: false)
        let target2 = 0.5 * sqrt(2.0)
        
        XCTAssertEqual(target2, distal.getLength(), accuracy: Point3D.Epsilon)
        
    }
    
    
    func testIntersectLine()   {
        
        let ptA = Point3D(x: 4.0, y: 2.0, z: 5.0)
        let ptB = Point3D(x: 2.0, y: 4.0, z: 5.0)
        
        let plateau = try! LineSeg(end1: ptA, end2: ptB)   // Known benign points
        
        var launcher = Point3D(x: 3.0, y: -1.0, z: 5.0)
        var azimuth = Vector3D(i: 0.0, j: -1.0, k: 0.0)
        
        var shot = try! Line(spot: launcher, arrow: azimuth)
        
        let target = Point3D(x: 3.0, y: 3.0, z: 5.0)
        
        XCTAssertNoThrow(try plateau.intersect(ray: shot))
        
        let crater = try! plateau.intersect(ray: shot)
        
        XCTAssert(crater.count == 1)
        let pip = Point3D(x: crater.first!.x, y: crater.first!.y, z: crater.first!.z)
        XCTAssertEqual(pip, target)
        
        
           // Case of being outside the range of the segment
        launcher = Point3D(x: 1.0, y: -1.0, z: 5.0)
        shot = try! Line(spot: launcher, arrow: azimuth)
        
        let crater2 = try! plateau.intersect(ray: shot)
   
        XCTAssert(crater2.isEmpty)
        

            // Also outside the range of the segment
        launcher = Point3D(x: 1.0, y: -3.0, z: 5.0)
        azimuth = Vector3D(i: -0.5, j: 0.866, k: 0.0)
        shot = try! Line(spot: launcher, arrow: azimuth)
        
        let crater3 = try! plateau.intersect(ray: shot)
        
        XCTAssert(crater3.isEmpty)
        
           // Parallel case
        let ptC = Point3D(x: 3.0, y: 2.0, z: 5.0)
        let ptD = Point3D(x: 1.0, y: 4.0, z: 5.0)
        
        var dir = Vector3D(from: ptC, towards: ptD, unit: true)
        
        let cliff = try! Line(spot: ptC, arrow: dir)
        
        XCTAssertThrowsError(try plateau.intersect(ray: cliff))
        
//        let crater4 = plateau.intersect(ray: cliff)

//        XCTAssert(crater4.isEmpty)
        
        
           // Coincident case
        let ptE = Point3D(x: 5.0, y: 1.0, z: 5.0)
        let ptF = Point3D(x: 1.0, y: 5.0, z: 5.0)
        
        dir = Vector3D(from: ptE, towards: ptF, unit: true)
        let cliff2 = try! Line(spot: ptE, arrow: dir)

        XCTAssertThrowsError(try plateau.intersect(ray: cliff2))
        
//        let crater5 = plateau.intersect(ray: cliff2)
        
//        XCTAssert(crater5.count == 2)
        
           // Intersect at one end
        let ptG = Point3D(x: -2.0, y: 2.0, z: 5.0)
        let thataway = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        let horizon = try! Line(spot: ptG, arrow: thataway)
        
        let crater6 = try! plateau.intersect(ray: horizon)
        
        XCTAssert(crater6.count == 1)
        
           // Intersect at other end
        let ptH = Point3D(x: -2.0, y: 4.0, z: 5.0)
        
        let horizon2 = try! Line(spot: ptH, arrow: thataway)
        
        let crater7 = try! plateau.intersect(ray: horizon2)
        
        XCTAssert(crater7.count == 1)
        
    }
    
    func testPerch()   {
        
        let ptA = Point3D(x: 5.0, y: 2.0, z: 2.0)
        let ptB = Point3D(x: 5.0, y: 4.0, z: 4.0)
        
        let contrail = try! LineSeg(end1: ptA, end2: ptB)
        
        let t1 = Point3D(x: 5.0, y: 5.0, z: 5.0)
        
        var sitRep = try! contrail.isCoincident(speck: t1)
        XCTAssertFalse(sitRep.flag)
        
        
        let t2 = Point3D(x: 5.0, y: 3.65, z: 3.65)
        
        sitRep = try! contrail.isCoincident(speck: t2)
        XCTAssert(sitRep.flag)

        let t3 = Point3D(x: 5.0, y: 2.5, z: 4.1)
        
        sitRep = try! contrail.isCoincident(speck: t3)
        XCTAssertFalse(sitRep.flag)
        
        
        let t4 = Point3D(x: 5.0, y: 0.5, z: 0.5)
        
        sitRep = try! contrail.isCoincident(speck: t4)
        XCTAssertFalse(sitRep.flag)
        
        sitRep = try! contrail.isCoincident(speck: ptA)
        XCTAssert(sitRep.flag)

        sitRep = try! contrail.isCoincident(speck: ptB)
        XCTAssert(sitRep.flag)

        XCTAssertNoThrow(try contrail.isCoincident(speck: ptB, accuracy: 0.0001))

        XCTAssertThrowsError(try contrail.isCoincident(speck: ptB, accuracy: -0.005))

    }
    
    
    func testCrown()   {
        
        let ptA = Point3D(x: 4.0, y: 2.0, z: 5.0)
        let ptB = Point3D(x: 2.0, y: 4.0, z: 5.0)
        
        let plateau = try! LineSeg(end1: ptA, end2: ptB)
        
        XCTAssert(plateau.findCrown(smallerT: 0.0, largerT: 1.0)  == 0.0)
        
    }
    
    func testApproximate()   {
        
        let ptA = Point3D(x: 4.0, y: 2.0, z: 5.0)
        let ptB = Point3D(x: 2.0, y: 4.0, z: 5.0)
        
        let dash = try! LineSeg(end1: ptA, end2: ptB)
        
        let milestones = try! dash.approximate(allowableCrown: 0.01)
        
        XCTAssertEqual(milestones.count, 2)
        
        XCTAssertEqual(milestones[0], ptA)
        XCTAssertEqual(milestones[1], ptB)
        
        XCTAssertThrowsError(try dash.approximate(allowableCrown: -0.5))
    }
    
    
    func testFindStep()   {
        
        let ptA = Point3D(x: 4.0, y: 2.0, z: 5.0)
        let ptB = Point3D(x: 2.0, y: 4.0, z: 5.0)
        
        let dash = try! LineSeg(end1: ptA, end2: ptB)
        
        let param = 0.6
        
        let inc = dash.findStep(allowableCrown: 0.010, currentT: param, increasing: true)
        XCTAssert(inc == 1.0)
        
        let dec = dash.findStep(allowableCrown: 0.010, currentT: param, increasing: false)
        XCTAssert(dec == 0.0)
        
    }
    
    func testGenBisect()   {
        
        let pipA = Point3D(x: 1.0, y: 5.0, z: 2.0)
        let pipB = Point3D(x: 4.6, y: 5.0, z: 2.0)
        
        let dir1 = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        let targetLoc = Point3D(x: 2.8, y: 5.0, z: 2.0)
        let targetDir = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        
        let targetLine = try! Line(spot: targetLoc, arrow: targetDir)
        
        let chop = try! LineSeg.genBisect(ptA: pipA, ptB: pipB, up: dir1)
        
        print(chop.getOrigin())
        print(chop.getDirection())
        
        XCTAssert(chop == targetLine)
        
        let dir2 = Vector3D(i: 1.0, j: 1.0, k: 0.0)
        
        do   {
            _ = try LineSeg.genBisect(ptA: pipA, ptB: pipB, up: dir2)
        } catch is NonUnitDirectionError {
            XCTAssert(true)
        } catch {
            XCTFail()
        }

        
        let dir3 = Vector3D(i: 0.0, j: 0.0, k: 0.0)
        
        do   {
            _ = try LineSeg.genBisect(ptA: pipA, ptB: pipB, up: dir3)
        } catch is ZeroVectorError {
            XCTAssert(true)
        } catch {
            XCTFail()
        }

        do   {
            _ = try LineSeg.genBisect(ptA: pipA, ptB: pipA, up: dir1)
        } catch is CoincidentPointsError {
            XCTAssert(true)
        } catch {
            XCTFail()
        }

    }
    
    func testIsClosedChain()   {
        
        let circleStart = Point3D(x: 2.5, y: 1.0, z: -0.8)
        
        let center = Point3D(x: 2.5, y: 2.5, z: -0.8)
        let axis = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        /// The Arc to hold points
        let cheerio = try! Arc(ctr: center, axis: axis, start: circleStart, sweep: Double.pi * 2.0)
        
        let ptA = cheerio.pointAtAngle(theta: 0.0)
        let ptB = cheerio.pointAtAngle(theta: 0.8)
        let ptC = cheerio.pointAtAngle(theta: 1.57)
        let ptD = cheerio.pointAtAngle(theta: 3.14)
        let ptE = cheerio.pointAtAngle(theta: 3.94)
        let ptF = cheerio.pointAtAngle(theta: 5.1)
        
        let barA = try! LineSeg(end1: ptA, end2: ptB)
        let barB = try! LineSeg(end1: ptB, end2: ptC)
        let barC = try! LineSeg(end1: ptC, end2: ptD)
        let barD = try! LineSeg(end1: ptD, end2: ptE)
        let barE = try! LineSeg(end1: ptE, end2: ptF)
        let barF = try! LineSeg(end1: ptF, end2: ptA)
        
        
        var bag = [barA, barC, barB, barE, barD]
        
        XCTAssertFalse(try! LineSeg.isClosedChain(rawSegs: bag))
        
        bag = [barA, barC, barB, barE, barD, barF]
        XCTAssert(try! LineSeg.isClosedChain(rawSegs: bag))
        
        bag = [barA, barD]
        XCTAssertThrowsError(try LineSeg.isClosedChain(rawSegs: bag))
        
    }
    
    
    
    func testOrderRing()   {
        
        let circleStart = Point3D(x: 2.5, y: 1.0, z: -0.8)
        
        let center = Point3D(x: 2.5, y: 2.5, z: -0.8)
        let axis = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        /// The Arc to hold points
        let cheerio = try! Arc(ctr: center, axis: axis, start: circleStart, sweep: Double.pi * 2.0)
        
        let ptA = cheerio.pointAtAngle(theta: 0.0)
        let ptB = cheerio.pointAtAngle(theta: 0.8)
        let ptC = cheerio.pointAtAngle(theta: 1.57)
        let ptD = cheerio.pointAtAngle(theta: 3.14)
        let ptE = cheerio.pointAtAngle(theta: 3.94)
        let ptF = cheerio.pointAtAngle(theta: 5.1)
        
        let barA = try! LineSeg(end1: ptA, end2: ptB)
        let barB = try! LineSeg(end1: ptB, end2: ptC)
        let barC = try! LineSeg(end1: ptC, end2: ptD)
        let barD = try! LineSeg(end1: ptD, end2: ptE)
        let barE = try! LineSeg(end1: ptE, end2: ptF)
        let barF = try! LineSeg(end1: ptF, end2: ptA)
        
        let target = [barA, barB, barC, barD, barE, barF]
        
        let bag = [barA, barC, barB, barE, barD, barF]
        
        let neat = try! LineSeg.orderRing(rawSegs: bag)
        
        XCTAssert(neat == target)
        
    }
    
    
    func testLengthSum()   {
        
        let ptA = Point3D(x: 2.5, y: 1.8, z: -3.0)
        let ptB = Point3D(x: 2.5, y: 0.8, z: -3.0)
        let ptC = Point3D(x: 3.5, y: 0.8, z: -3.0)
        let ptD = Point3D(x: 3.5, y: 1.8, z: -3.0)
        
        let eenie = try! LineSeg(end1: ptA, end2: ptB)
        let meenie = try! LineSeg(end1: ptB, end2: ptC)
        let minie = try! LineSeg(end1: ptC, end2: ptD)
        let moe = try! LineSeg(end1: ptD, end2: ptA)

        let wrap = [eenie, meenie, minie, moe]
        
        let fenceLength = LineSeg.sumLengths(sticks: wrap)
        
        XCTAssertEqual(fenceLength, 4.0)
        
        
    }
    
    func testEquals()   {
        
        let ptA = Point3D(x: 4.0, y: 2.0, z: 5.0)
        let ptB = Point3D(x: 2.0, y: 4.0, z: 5.0)
        
        let stalk = try! LineSeg(end1: ptA, end2: ptB)
        
        let ptA2 = Point3D(x: 4.0, y: 2.0, z: 5.0)
        let ptB2 = Point3D(x: 2.0, y: 4.0, z: 5.0)
        
        let bar = try! LineSeg(end1: ptA2, end2: ptB2)
        
        XCTAssertEqual(stalk, bar)
        
        let bat = try! LineSeg(end1: ptB2, end2: ptA2)

        XCTAssertNotEqual(stalk, bat)
    }
    
}
