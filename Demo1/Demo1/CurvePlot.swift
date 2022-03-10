//
//  CurvePlot.swift
//  Demo1
//
//  Created by Paul on 3/7/22.
//

import Foundation
import CurvePack

var modelGeo = Peacock()

/// How much a flat approximation can deviate from a curve, or curved surface
var allowableCrown = 0.003

/// Show off the good results
public class Peacock   {
    
    /// Various PenCurves to be displayed
    var displaySegs = [PenCurve]()
    
    /// Brick that contains all drawn entities
    var extent = OrthoVol(minX: 0.0, maxX: 5.0, minY: 0.0, maxY: 5.0, minZ: -0.5, maxZ: 0.5)   // Dummy initial value
    
    init()   {
        
        let lowerLeft = Point3D(x: -1.0, y: -1.0, z: 0.5)
        let upCorner = Point3D(x: -1.0, y: 0.5, z: 0.5)
        
        let curb = try! LineSeg(end1: lowerLeft, end2: upCorner)
        displaySegs.append(curb)
        
        
        let upWave = Point3D(x: 0.0, y: 1.75, z: 0.5)
        let downWave = Point3D(x: 1.0, y: 2.25, z: 0.5)
        let beach = Point3D(x: 3.0, y: 4.5, z: 0.5)
        
        let wave = try! Cubic(alpha: upCorner, beta: upWave, betaFraction: 0.3, gamma: downWave, gammaFraction: 0.5, delta: beach)
        
        displaySegs.append(wave)
        
        
        let topRight = Point3D(x: 5.0, y: 4.5, z: 0.5)
        let plateau = try! LineSeg(end1: beach, end2: topRight)
        
        displaySegs.append(plateau)
        
        
        let peak = Point3D(x: 6.75, y: 3.75, z: 0.5)
        let mitt = Point3D(x: 5.25, y: 1.5, z: 0.5)
        
        let bulge = try! Quadratic(ptA: topRight, controlA: peak, ptB: mitt)
        displaySegs.append(bulge)
        
        
        let sqrt2 = sqrt(2.0)   // Useful for getting Arc coordinates correct
        
        let arc1 = Point3D(x: 2.75 + sqrt2 / 2.0, y: -1.0 + sqrt2 / 2.0, z: 0.5)
        
        let overhang = try! LineSeg(end1: mitt, end2: arc1)
        displaySegs.append(overhang)
        
        
        let arcCtr = Point3D(x: 2.75, y: -1.0, z: 0.5)
        let arc2 = Point3D(x: 1.75, y: -1.0, z: 0.5)
        
        let notch = try! Arc(center: arcCtr, end1: arc1, end2: arc2, useSmallAngle: true)
        displaySegs.append(notch)
        
        
        let heel = try! LineSeg(end1: arc2, end2: lowerLeft)
        displaySegs.append(heel)
        
        
        
        // Total up the volume used by the combination of curves.
        extent = displaySegs[0].getExtent()
        
        for xedni in 1..<displaySegs.count   {
            extent = extent + displaySegs[xedni].getExtent()
        }

    }
    
}
