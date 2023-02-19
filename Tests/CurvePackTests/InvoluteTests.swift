//
//  InvoluteTests.swift
//  
//
//  Created by Paul Hollingshead on 2/19/23.
//

import XCTest
import CurvePack

final class InvoluteTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func testFidelity()   {
        
        let sample = Involute(baseRadius: 2.0)
        
        XCTAssertEqual(2.0, sample.getBaseRadius())
        
    }
    
    func testAngleForRadius()   {
        
        let sample = Involute(baseRadius: 2.0)
        
        let theta25 = try! sample.angleForRadius(targetR: 2.5, epsilon: 0.001)
        
        //This only tests repeatability.
        XCTAssertEqual(0.75, theta25, accuracy: 0.0001)
        
        
        XCTAssertThrowsError(try sample.angleForRadius(targetR: 1.75, epsilon: 0.001))

    }

}
