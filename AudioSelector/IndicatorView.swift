//
//  IndicatorView.swift
//  AudioSelector
//
//  Created by Semiotikus on 12.08.17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

import Cocoa
import SnapKit

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
        
        addSubview(bulletView)
        bulletView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(self).multipliedBy(0.6)
            make.height.equalTo(self).multipliedBy(0.6)
            make.center.equalTo(self)
        }
        
        isActive = false
    }
    
    override func layout() {
        bulletView.layer?.backgroundColor = NSColor.textColor.cgColor
        super.layout()
    }
}
