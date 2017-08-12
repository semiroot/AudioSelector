//
//  IndicatorView.swift
//  AudioSelector
//
//  Created by Semiotikus on 12.08.17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

import Cocoa
import SwiftyConstraints

class IndicatorView: CircleView {
    
    public var isActive: Bool {
        get {
            return !bulletView.isHidden
        }
        set {
            bulletView.isHidden = !newValue
        }
    }
    
    fileprivate let bulletView = CircleView()
    
    override func setup() {
        super.setup()
        
        bulletView.layer?.borderWidth = 0
        
        swiftyConstraints()
            .attach(bulletView)
            .widthOfSuperview(0.6, 0)
            .heightOfSuperview(0.6, 0)
            .center().middle()
        
        isActive = false
    }
    
    override func layout() {
        bulletView.layer?.backgroundColor = NSColor.textColor.cgColor
        super.layout()
    }
}
