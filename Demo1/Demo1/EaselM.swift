//
//  EaselM.swift
//  SurfinSafari
//
//  Created by Paul on 5/29/20.
//  Copyright © 2021 Paul  All rights reserved.
//

import AppKit

class EaselM: NSView {
    
    
    // Prepare pen widths
    let thick = CGFloat(4.0)
    let standard = CGFloat(3.0)
    let thin = CGFloat(1.5)
    
    // Declare pen colors
    let black = CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let blue = CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
    let brown = CGColor(red: 0.63, green: 0.33, blue: 0.18, alpha: 1.0)

    /// Transforms between model and screen space
    var modelToDisplay: CGAffineTransform?
    var displayToModel: CGAffineTransform?
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.white.cgColor   // Thanks to Christoffer Winterkvist!
        
        /// Smallest x,y, and z of the model volume
        let nigiro = modelGeo.extent.getOrigin()
        let mrOrigin = CGPoint(x: nigiro.x, y: nigiro.y)    // Needs work!
        
        let diag = sqrt(modelGeo.extent.getWidth() * modelGeo.extent.getWidth() + modelGeo.extent.getHeight() * modelGeo.extent.getHeight() + modelGeo.extent.getDepth() * modelGeo.extent.getDepth())
        
        let ezis = CGSize(width: diag, height: diag)
        
        /// CGRect that covers the model space
        let modelRect = CGRect(origin: mrOrigin, size: ezis)
        
        let plotParameters = findScaleAndCenter(displayRect: dirtyRect, subjectRect: modelRect)    // "dirtyRect" is passed in to this draw function
        
        modelToDisplay = plotParameters.toDisplay
        displayToModel = plotParameters.toModel


        
        // Drawing code here.
        let context = (NSGraphicsContext.current?.cgContext)!

        context.setStrokeColor(red: 0, green: 0, blue: 0, alpha: 1)
        context.setLineWidth(1.0)
        
        for stick in modelGeo.displaySegs   {
            
            switch stick.usage  {
                
            case "Boundary":
                context.setStrokeColor(brown)
                context.setLineWidth(thick)
                context.setLineDash(phase: 0, lengths: []);    // To clear any previous dash pattern
//                context.setLineDash(phase: 5, lengths: [CGFloat(10), CGFloat(8)])
                
            case "Interior":
                context.setStrokeColor(black)
                context.setLineWidth(thin)
                context.setLineDash(phase: 0, lengths: []);    // To clear any previous dash pattern
            
            default:
                context.setStrokeColor(black)
                context.setLineWidth(thin)
                context.setLineDash(phase: 0, lengths: []);    // To clear any previous dash pattern
            
            }
            
            try! stick.draw(context: context, tform: modelToDisplay!, allowableCrown: allowableCrown)
        }
        
    }
    
    /// Determines parameters to center the model on the screen.
    /// - Parameter: displayRect: Bounds of the plotting area
    /// - Parameter: subjectRect: A CGRect that bounds the model space used
    /// - Returns: A tuple containing transforms between model and display space
    func  findScaleAndCenter(displayRect: CGRect, subjectRect: CGRect) -> (toDisplay: CGAffineTransform, toModel: CGAffineTransform)   {
        
        let rangeX = subjectRect.width
        let rangeY = subjectRect.height
        
        /// For an individual edge
        let margin = CGFloat(20.0)   // Measured in "points", not pixels, or model units
        let twoMargins = CGFloat(2.0) * margin
        
        let scaleX = (displayRect.width - twoMargins) / rangeX
        let scaleY = (displayRect.height - twoMargins) / rangeY
        
        let scale = min(scaleX, scaleY)
        
        
        // Find the middle of the model area for translation
        let giro = subjectRect.origin
        
        let middleX = giro.x + 0.5 * rangeX
        let middleY = giro.y + 0.5 * rangeY
        
        let transX = (displayRect.width - twoMargins) / 2 - middleX * scale + margin
        
        // MARK: Different between iOS and MacOS. Add middleY in iOS
        let transY = (displayRect.height - twoMargins) / 2 - middleY * scale + margin  // To plot from the lower left
        
        // MARK: Different between iOS and MacOS. Negate the Y scale in iOS
        let modelScale = CGAffineTransform(scaleX: scale, y: scale)   // To make Y positive upwards
        let modelTranslate = CGAffineTransform(translationX: transX, y: transY)
        
        
        /// The combined matrix based on the plot parameters
        let modelToDisplay = modelScale.concatenating(modelTranslate)
        let displayToModel = modelToDisplay.inverted()
        
        return (modelToDisplay, displayToModel)
    }
    
}
