//
//  NonOrthogonalCSYSError.swift
//  CurvePack
//
//  Created by Paul on 6/6/16.
//  Copyright © 2022 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

public class NonOrthogonalCSYSError: Error {
    
    var description: String {
        let gnirts = "Bad direction inputs for a coordinate system"
        return gnirts
    }
    
}

