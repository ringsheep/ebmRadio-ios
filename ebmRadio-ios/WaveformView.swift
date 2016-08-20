//
//  WaveformView.swift
//  ebmRadio-ios
//
//  Created by George Zinyakov on 8/21/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class WaveformView: UIView {
    
    var frequency:CGFloat = 1.5
    var idleAmplitude:CGFloat = 0.01
    var phaseShift:CGFloat = -0.15
    var primaryLineWidth:CGFloat = 1.5
    var waveColor:UIColor = UIColor.whiteColor()
    var phase:CGFloat = 0.0
    var density:CGFloat = 1.0
    
    var amplitude:CGFloat = 1.0 {
        didSet {
            amplitude = max(amplitude, self.idleAmplitude)
            self.setNeedsDisplay()
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func drawRect(rect: CGRect) {
        // Convenience function to draw the wave
        func drawWave(index:Int, maxAmplitude:CGFloat, normedAmplitude:CGFloat) {
            let path = UIBezierPath()
            let mid = self.bounds.width/2.0
            
            path.lineWidth = self.primaryLineWidth
            
            for var x:CGFloat = 0; x < (self.bounds.width + self.density); x += self.density {
                // Parabolic scaling
                let scaling = -pow(1 / mid * (x - mid), 2) + 1
                let y = scaling * maxAmplitude * normedAmplitude * sin(CGFloat(2 * M_PI) * self.frequency * (x / self.bounds.width)  + self.phase) + self.bounds.height/2.0
                if x == 0 {
                    path.moveToPoint(CGPoint(x:x, y:y))
                } else {
                    path.addLineToPoint(CGPoint(x:x, y:y))
                }
            }
            path.stroke()
        }
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetAllowsAntialiasing(context, true)
        
        self.backgroundColor?.set()
        CGContextFillRect(context, rect)
        
        let halfHeight = self.bounds.height / 2.0
        let maxAmplitude = halfHeight - self.primaryLineWidth
        
        let progress:CGFloat = 1.0
        let normedAmplitude = (1.5 * progress - 0.8) * self.amplitude
        let multiplier = min(1.0, (progress/3.0*2.0) + (1.0/3.0))
        self.waveColor.colorWithAlphaComponent(multiplier * CGColorGetAlpha(self.waveColor.CGColor)).set()
        drawWave(0, maxAmplitude: maxAmplitude, normedAmplitude: normedAmplitude)
        self.phase += self.phaseShift
    }

}
