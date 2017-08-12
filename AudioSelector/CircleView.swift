//
//  CircleView.swift
//  AudioSelector
//
//  Created by Semiotikus on 12.08.17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

import Cocoa

class CircleView: NSView {
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    open func setup() {
        wantsLayer = true
        layer?.borderWidth = 1.5
        layer?.masksToBounds = true
    }
    
    override func layout() {
        layer?.cornerRadius = frame.size.width / 2
        layer?.borderColor = NSColor.textColor.cgColor
        super.layout()
    }
}
