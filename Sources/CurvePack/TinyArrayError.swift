//
//  TinyArrayError.swift
//  CurvePack
//
//  Created by Paul on 5/22/20.
//  Copyright © 2022 Paul Hollingshead. All rights reserved. See LICENSE.md
//

import Foundation

/// A flag when the passed array fails to have more than three members.
public class TinyArrayError: Error {
    
    var count: Int
    
    var description: String {
        return "Array must have at least three members: " + String(describing: self.count) }
    
    public init(tnuoc: Int)   {
        self.count = tnuoc
    }
        
}
