//
//  CheckboxControl.swift
//  AudioSelector
//
//  Created by Semiotikus on 20.08.17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

import Cocoa

class CheckboxControl: Control {
    
    override func setup() {
        self.setButtonType(NSButton.ButtonType.switch)
    }
    
    public var isActive: Bool {
        get {
            return self.integerValue == 1
        }
        set {
            self.integerValue = newValue ? 1 : 0
        }
    }
}
