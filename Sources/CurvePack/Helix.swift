//
//  Helix.swift
//  Rotini
//
//  Created by Paul on 4/23/23.
//

import Foundation

public struct Helix   {
    
    public var dia: Double
    
    public var pitch: Double
    
    public var wholeTurns: Int
    
    public var partialTurns: Double   //Radians
    
    public var center: Point3D
    
    public var axis: Vector3D
    
    public var startPt: Point3D
    
    /// Turn local points into global points
    public var toGlobal: Transform
    
    /// Turn global points into local
    public var fromGlobal: Transform
    

    ///Simplest constructor
    public init(dia: Double, pitch: Double, wholeTurns: Int, partialTurns: Double, center: Point3D, axis: Vector3D, startPt: Point3D) throws   {
        
        guard dia > 0.0 else { throw NegativeAccuracyError(acc: dia) }
        
        guard pitch > 0.0 else { throw NegativeAccuracyError(acc: pitch) }
        
        guard wholeTurns >= 0 else { throw NegativeAccuracyError(acc: Double(wholeTurns)) }
        
        guard partialTurns >= 0.0 else { throw NegativeAccuracyError(acc: partialTurns) }
        
        let wholePos = wholeTurns > 0
        let partPos = partialTurns > 0.0
        
        guard wholePos || partPos else { throw NegativeAccuracyError(acc: Double(wholeTurns)) }
        
        
        guard axis.isUnit() else { throw NonUnitDirectionError(dir: axis) }
        
        let startDir = Vector3D(from: center, towards: startPt)
        let components = Vector3D.resolve(split: startDir, ref: axis)
        
        var clocking = components.perp
        
        guard !clocking.isZero() else { throw ZeroVectorError(dir: clocking) }
        
        clocking.normalize()
        
        
        self.dia = dia
        self.pitch = pitch
        self.wholeTurns = wholeTurns
        self.partialTurns = partialTurns
        self.center = center
        self.axis = axis
        self.startPt = startPt

        let localCSYS = try! CoordinateSystem(origin: self.center, refDirection: clocking, normal: self.axis)
        
        self.toGlobal = try! Transform.genToGlobal(csys: localCSYS)
        
        self.fromGlobal = Transform.genFromGlobal(csys: localCSYS)
        
    }
    
    
    
    /// Fetch the location of the pivot point
    public func getCenter() -> Point3D   {
        return self.center
    }
    
    
    public func getAxisDir() -> Vector3D   {
        return self.axis
    }
    
    
    public func getDia() -> Double   {
        return self.dia
    }
    
    
    public func ptAtClocking(sweep: Double) -> Point3D   {
        
        let localX = cos(sweep) * self.dia / 2.0
        let localY = sin(sweep) * self.dia / 2.0
        let localZ = sweep / (2.0 * Double.pi) * self.pitch
        
        return Point3D(x: localX, y: localY, z: localZ)
    }
    
    
    public func pointAt(turnIndex: Int, sweep: Double) -> Point3D   {
        
        let clockedPt = ptAtClocking(sweep: sweep)
        
        let coilJump = Double(turnIndex) * self.pitch
        let jump = Transform(deltaX: 0.0, deltaY: 0.0, deltaZ: coilJump)
        
        let freshLocal = clockedPt.transform(xirtam: jump)
        
        return freshLocal
    }
    
    
    //TODO: Will need a transform function
    
    
    /// Create only enough points for line segments tthat will meet the crown limit.
    /// - Parameters:
    ///   - allowableCrown: Maximum deviation from the actual curve
    /// - Returns: Array of evenly spaced points in the local coordinate system
    /// - Throws:
    ///     - NegativeAccuracyError for an input less than zero
    /// - See: 'testApproximate' under ArcTests
    public func approximate(allowableCrown: Double) throws -> [Point3D]   {
        
        guard allowableCrown > 0.0 else { throw NegativeAccuracyError(acc: allowableCrown) }
        
        
        ///Where the curve starts - in local coordinates
        let localStart = Point3D(x: self.dia / 2.0, y: 0.0, z: 0.0)
        
        
        ///Intermediate result for breaking the curve up into segments
        let ratio = 1.0 - allowableCrown / (self.dia / 2.0)
        
        /// Step in angle that meets the allowable crown limit
        let maxSwing =  2.0 * abs(acos(ratio))
        

        /// Collection of points in the local CSYS
        var chainLocal = [Point3D]()
        
        if self.wholeTurns > 0   {
            
            ///Integer number of segments, where each segment will be less than maxSwing
            let wholeTurnSegs = ceil(2.0 * Double.pi / maxSwing)
            
            let angleIncrement = Double.pi * 2.0 / wholeTurnSegs
            
            ///Points to approximate a full turn
            var onceAround = [Point3D]()
            onceAround.append(localStart)
            
            let wholeTurnCount = Int(wholeTurnSegs)
            
            for g in 1..<wholeTurnCount   {   //No duplicate point at start.
                let freshAngle = Double(g) * angleIncrement
                let freshPt = ptAtClocking(sweep: freshAngle)
                onceAround.append(freshPt)
            }
            
            
            for g in 0..<self.wholeTurns   {
                let axisOffset = Double(g) * self.pitch
                let hop = Transform(deltaX: 0.0, deltaY: 0.0, deltaZ: axisOffset)
                
                let hopped = onceAround.map( { $0.transform(xirtam: hop) } )
                
                chainLocal.append(contentsOf: hopped)
            }
            
        }

        //TODO: This still leaves the case of a partialTurn that is less than maxSwing
        
        
        let axisOffset = Double(self.wholeTurns) * self.pitch
        let hop = Transform(deltaX: 0.0, deltaY: 0.0, deltaZ: axisOffset)
        
        if self.partialTurns > 0.0   {
            
            ///Local points for a partial turn
            var partAround = [Point3D]()
            
            if partialTurns < maxSwing   {
                
                let alpha = localStart.transform(xirtam: hop)   // End of whole turn
                partAround.append(alpha)
                
                let finalPt = ptAtClocking(sweep: partialTurns)
                partAround.append(finalPt)
                
            }  else  {
                
                let partialSegs = ceil(self.partialTurns / maxSwing)
                
                let angleIncrement = self.partialTurns / partialSegs
                
                /// The number of segments for the partial portion
                let partialSegsCount = Int(partialSegs)
                
                for g in 0...partialSegsCount   {
                    let freshAngle = Double(g) * angleIncrement
                    let freshPt = ptAtClocking(sweep: freshAngle)
                    partAround.append(freshPt)
                }
                
            }
            
            let hopped = partAround.map( { $0.transform(xirtam: hop) } )
            chainLocal.append(contentsOf: hopped)
            
        }  else  {
            let omega = localStart.transform(xirtam: hop)   // End point
            chainLocal.append(omega)
        }
        
        
        /// Points in the global CSYS
        let chainG = chainLocal.map( { $0.transform(xirtam: self.toGlobal) } )
        
        return chainG
    }
    
    
    public func length() -> Double   {
        
        var total = 0.0
        
        let allowC = self.dia / 100.0
        
        let steppingStones = try! self.approximate(allowableCrown: allowC)
        
        for g in 1..<steppingStones.count   {
            let barLength = Point3D.dist(pt1: steppingStones[g-1], pt2: steppingStones[g])
            total += barLength
        }
        
        return total
    }


}
