//
//  Label.swift
//  AudioSelector
//
//  Created by Semiotikus on 12.08.17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

import Cocoa

class Label: NSTextField {

    class func create(_ text: String) -> Label {
        let label = Label()
        label.setup()
        label.stringValue = text
        return label
    }
    
    func setup() {
        self.isBezeled = false
        self.drawsBackground = false
        self.isEditable = false
        self.isSelectable = false
    }
}
