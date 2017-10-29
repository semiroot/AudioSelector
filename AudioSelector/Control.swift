//
//  CheckboxControl.swift
//  AudioSelector
//
//  Created by Semiotikus on 20.08.17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

import Cocoa

class Control: NSButton {
    
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
        self.isBordered = false
    }
    
    func withText(_ text: String) -> NSButton {
        self.title = text
        return self
    }
}
