//
//  HelixTests.swift
//  RotiniTests
//
//  Created by Paul on 4/23/23.
//

import XCTest
import CurvePack

final class HelixTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFidelity()  {
        
        let universe = Point3D(x: 0.0, y: 0.0, z: 2.0)
        let arrow = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        let genesis = Point3D(x: 1.0, y: 0.0, z: 2.0)
        
        let rotorTip = try! Helix(dia: 2.00, pitch: 0.50, wholeTurns: 2, partialTurns: 0.0, center: universe, axis: arrow, startPt: genesis)
        
        XCTAssertEqual(2.00, rotorTip.getDia())
        XCTAssertEqual(0.50, rotorTip.pitch)
        XCTAssertEqual(2, rotorTip.wholeTurns)
        XCTAssertEqual(0.0, rotorTip.partialTurns)

        let ctrTarget = Point3D(x: 0.0, y: 0.0, z: 2.0)
        XCTAssertEqual(ctrTarget, rotorTip.getCenter())
        
        let dirTarget = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        XCTAssertEqual(dirTarget, rotorTip.getAxisDir())

        let startTarget = Point3D(x: 1.0, y: 0.0, z: 2.0)
        XCTAssertEqual(startTarget, rotorTip.startPt)
        
        let run = rotorTip.length()
    }

    func testGuard()   {
        
        let universe = Point3D(x: 0.0, y: 0.0, z: 2.0)
        let arrow = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        let genesis = Point3D(x: 1.0, y: 0.0, z: 2.0)
        
        do   {
                        
            let badGyrate = try Helix(dia: -2.00, pitch: 0.50, wholeTurns: 2, partialTurns: 0.0, center: universe, axis: arrow, startPt: genesis)
            
        } catch is NegativeAccuracyError   {
            
            XCTAssert(true)
            
        }   catch {
            XCTAssert(false, "Code should never have gotten here")
        }
        
        do   {
                        
            let badGyrate = try Helix(dia: 2.00, pitch: -0.50, wholeTurns: 2, partialTurns: 0.0, center: universe, axis: arrow, startPt: genesis)
            
        } catch is NegativeAccuracyError   {
            
            XCTAssert(true)
            
        }   catch {
            XCTAssert(false, "Code should never have gotten here")
        }
        
        do   {
                        
            let badGyrate = try Helix(dia: 2.00, pitch: 0.50, wholeTurns: -13, partialTurns: 0.0, center: universe, axis: arrow, startPt: genesis)
            
        } catch is NegativeAccuracyError   {
            
            XCTAssert(true)
            
        }   catch {
            XCTAssert(false, "Code should never have gotten here")
        }
        
        do   {
                        
            let badGyrate = try Helix(dia: 2.00, pitch: 0.50, wholeTurns: 3, partialTurns: -0.6, center: universe, axis: arrow, startPt: genesis)
            
        } catch is NegativeAccuracyError   {
            
            XCTAssert(true)
            
        }   catch {
            XCTAssert(false, "Code should never have gotten here")
        }
        
        let badArrow = Vector3D(i: 0.0, j: 1.0, k: 1.0)

        do   {
                        
            let badGyrate = try Helix(dia: 2.00, pitch: 0.50, wholeTurns: 3, partialTurns: 0.6, center: universe, axis: badArrow, startPt: genesis)
            
        } catch is NonUnitDirectionError   {
            
            XCTAssert(true)
            
        }   catch {
            XCTAssert(false, "Code should never have gotten here")
        }
        
    }
    
    
    func testLength()  {
        
        let universe = Point3D(x: 0.0, y: 0.0, z: 2.0)
        let arrow = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        let genesis = Point3D(x: 1.0, y: 0.0, z: 2.0)
        
        let rotorTip = try! Helix(dia: 2.00, pitch: 0.50, wholeTurns: 2, partialTurns: 0.0, center: universe, axis: arrow, startPt: genesis)
        
        let run = rotorTip.length()
        
        XCTAssertEqual(run, 12.525, accuracy: 0.01)
    }


}
