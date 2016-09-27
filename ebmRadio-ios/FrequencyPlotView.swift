//
//  FrequencyPlotView.swift
//  ebmRadio-ios
//
//  Created by George Zinyakov on 9/7/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation
import UIKit

class FrequencyPlotView: UIView, FSFrequencyDomainAnalyzerDelegate {
    
    let maxLevelCount = 64
    var levels:UnsafeMutablePointer<Float>!
    var count:Int = 0
    var drawing = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupCustomInitialisation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupCustomInitialisation()
    }
    
    private func setupCustomInitialisation() {
        levels = UnsafeMutablePointer<Float>.alloc(maxLevelCount)
        self.backgroundColor = UIColor.clearColor()
    }
    
    func frequenceAnalyzer(analyzer: FSFrequencyDomainAnalyzer!, levelsAvailable levels: UnsafeMutablePointer<Float>, count: UInt) {
        if drawing {
            return
        }
        
        self.count = min(maxLevelCount, Int(count))
        
        memcpy(self.levels, levels, sizeof(Float) * self.count);
        
        self.setNeedsDisplay()
    }
    
    private func reset() {
        self.count = 0
        self.setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        guard self.count != 0 else {
            return
        }
        
        for index in 0...self.count {
            if (self.levels[index] < 0 || self.levels[index] > 1) {
                print("Invalid level: \(self.levels[index])")
                return
            }
        }
        
        self.drawing = true
        let height = CGRectGetHeight(self.bounds)
        let levelWidth = CGRectGetWidth(self.bounds) / CGFloat(self.count)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context!, 2)
        CGContextSetStrokeColorWithColor(context!, UIColor.lightGrayColor().CGColor)
        let yp = height - (CGFloat(self.levels[0]) * height)
        CGContextMoveToPoint(context!, 0, yp)
        
        for index in 1...self.count {
            let x = levelWidth * CGFloat(index)
            var y = height - (CGFloat(self.levels[index]) * height)
            CGContextAddLineToPoint(context!, x, y)
        }
        CGContextStrokePath(context!)
        drawing = false
    }
}
