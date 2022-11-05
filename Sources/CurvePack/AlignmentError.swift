//
//  AlignmentError.swift
//  CurvePack
//
//  Created by Paul on 7/15/20.
//  Copyright © 2022 Paul Hollingshead. All rights reserved.
//

import Foundation

/// Exception for when the Loop can't be aligned
class AlignmentError: Error {
    
    
    var description: String {
        return "Curves could not be aligned!"
    }
    
}
