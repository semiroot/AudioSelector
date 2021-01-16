//
//  SliderCellView.swift
//  AudioSelector
//
//  Created by Hansmartin Geiser on 29.12.20.
//  Copyright © 2020 Hansmartin Geiser. All rights reserved.
//

import Cocoa


class SliderCellView: NSSliderCell {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
    }
    
    func sliderBackgroundColor() -> NSColor {
        let isLightMode  = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == nil;
        if (isLightMode) {
            if(isEnabled) {
                return NSColor(red: 1, green: 1, blue: 1, alpha: 0.3)
            } else {
                return NSColor(red: 1, green: 1, blue: 1, alpha: 0.2)
            }
            
        } else {
            if(isEnabled) {
                return NSColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            } else {
                return NSColor(red: 0, green: 0, blue: 0, alpha: 0.1)
            }
        }
    }
    
    func sliderForegrounddColor() -> NSColor {
        return NSColor(red: 1, green: 1, blue: 1, alpha: 0.8)
    }
    
    func sliderBorderColor() -> NSColor {
        let isLightMode  = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == nil;
        if (isLightMode) {
            if(isEnabled) {
                return NSColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            } else {
                return NSColor(red: 0, green: 0, blue: 0, alpha: 0.1)
            }
            
        } else {
            if(isEnabled) {
                return NSColor(red: 1, green: 1, blue: 1, alpha: 0.2)
            } else {
                return NSColor(red: 1, green: 1, blue: 1, alpha: 0.1)
            }
        }
    }
    
    override func drawBar(inside rect: NSRect, flipped: Bool) {
        
        let knobWidth = CGFloat(20)
        let barRadius = CGFloat(11)
        
        var leftWidth = CGFloat(floatValue) * (rect.width - knobWidth) + knobWidth
        if (leftWidth < knobWidth) { leftWidth = knobWidth }
        
        let leftRect = NSRect(x: 1, y: rect.origin.y - 8, width: CGFloat(leftWidth), height: knobWidth)
        let rightRect = NSRect(x: 1, y: rect.origin.y - 8, width: rect.width, height: knobWidth)
        let borderRect = NSRect(x: 0.5, y: rect.origin.y - 9, width: rect.width + 1, height: knobWidth + 2)
        
        // Draw Border Part
        let border = NSBezierPath(roundedRect: borderRect, xRadius: barRadius, yRadius: barRadius)
        sliderBorderColor().setFill()
        border.fill()
        
        // Draw Right Part
        let background = NSBezierPath(roundedRect: rightRect, xRadius: barRadius, yRadius: barRadius)
        sliderBackgroundColor().setFill()
        background.fill()
        
        if (leftWidth <= knobWidth) { return }
        // Draw Left Part
        let foreground = NSBezierPath(roundedRect: leftRect, xRadius: barRadius, yRadius: barRadius)
        sliderForegrounddColor().setFill()
        foreground.fill()
    }
}
