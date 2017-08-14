//
//  Label.swift
//  AudioSelector
//
//  Created by Semiotikus on 12.08.17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

import Cocoa

class LabelView: NSTextField {
    
    func withText(_ text: String) -> NSTextField {
        self.stringValue = text
        return self
    }

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
    
    func setup() {
        self.isBezeled = false
        self.drawsBackground = false
        self.isEditable = false
        self.isSelectable = false
        self.font = NSFont.labelFont(ofSize: 12)
    }
}
