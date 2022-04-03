//
//  PointCrvTests.swift
//  
//
//  Created by Paul on 4/3/22.
//  Copyright © 2022 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest
@testable import CurvePack

class PointCrvTests: XCTestCase {

    func testFidelity() {

        let noob = PointCrv(x: 1.2, y: -0.75, z: 3.1, t: 0.4)
        
        XCTAssertEqual(1.2, noob.x)
        XCTAssertEqual(-0.75, noob.y)
        XCTAssertEqual(3.1, noob.z)
        XCTAssertEqual(0.4, noob.t)

    }

}
