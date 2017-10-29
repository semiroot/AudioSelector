//
//  RadioControl.swift
//  AudioSelector
//
//  Created by Semiotikus on 13.08.17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

import Cocoa

class RadioControl: CheckboxControl {
    
    override func setup() {
        self.setButtonType(NSButton.ButtonType.radio)
    }
}
