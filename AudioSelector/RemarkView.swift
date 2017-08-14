//
//  RemarkView.swift
//  AudioSelector
//
//  Created by Semiotikus on 13.08.17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

import Cocoa

class RemarkView: LabelView {
    
    override func setup() {
        super.setup()
        self.font = NSFont.labelFont(ofSize: 9)
        wantsLayer = true
        self.boundsRotation = -45
    }
    
}
