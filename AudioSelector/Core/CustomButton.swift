//
//  CustomButton.swift
//  AudioSelector
//
//  Created by Hansmartin Geiser on 02.01.21.
//  Copyright © 2021 Hansmartin Geiser. All rights reserved.
//

import Cocoa
import CustomButton


extension CustomButton {
    
    static func createDeviceButton() -> CustomButton {
        let button = CustomButton()
        
        button.title = ""
        button.titleMargin = 35
        button.titleColorLight = .black
        button.titleColorLightActive = .white
        button.titleColorDark = .white
        button.titleColorDarkActive = .black
        
        button.cornerRadius = 11//-4
        button.borderWidth = 1
        button.borderColorLight = NSColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        button.borderColorDark = NSColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        
        button.backgroundColorLight = NSColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        button.backgroundColorLightActive = NSColor(red: 0, green: 0, blue: 0, alpha: 0.9)
        button.backgroundColorDark = NSColor(red: 1, green: 1, blue: 1, alpha: 0.15)
        button.backgroundColorDarkActive = NSColor(red: 1, green: 1, blue: 1, alpha: 0.9)
        
        button.backgroundColorActive = .controlAccentColor
        
        button.contentPosition = .left
        button.animateState = false
        
        
        return button
    }
    
    
    static func createDeviceButtonInactive() -> CustomButton {
        let button = CustomButton()
        
        button.title = ""
        button.titleMargin = 35
        button.titleColorLight = NSColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        button.titleColorDark = NSColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        
        button.cornerRadius = 11
        button.borderWidth = 1
        button.borderColorLight = NSColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        button.borderColorDark = NSColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        
        button.backgroundColorLight = NSColor(red: 0, green: 0, blue: 0, alpha: 0.15)
        button.backgroundColorDark = NSColor(red: 1, green: 1, blue: 1, alpha: 0.15)
        
        button.contentPosition = .left
        button.animateState = false
        
        return button
    }
    
    static func createFavoriteButton() -> CustomButton {
        let button = CustomButton()
        
        button.title = ""
        button.titleMargin = 0
        button.titleColorLight = .black
        button.titleColorLightActive = .white
        button.titleColorDark = .white
        button.titleColorDarkActive = .black
        
        button.icon = NSImage(named: NSImage.Name("Favorite"))
                
        button.backgroundColor = .clear
        button.backgroundColorActive = .controlAccentColor
        
        button.cornerRadius = 10
        button.borderWidth = 0
        
        button.contentPosition = .center
        button.animateState = false
        
        return button
    }
    
    static func createPinButton() -> CustomButton {
        let button = CustomButton()
        
        button.title = ""
        button.titleMargin = 0
        button.titleColorLight = .black
        button.titleColorLightActive = .white
        button.titleColorDark = .white
        button.titleColorDarkActive = .black
        
        button.icon = NSImage(named: NSImage.Name("Pin"))
        
        button.backgroundColor = .clear
        button.backgroundColorActive = .controlAccentColor
                
        button.cornerRadius = 10
        button.borderWidth = 0
        
        button.contentPosition = .center
        button.animateState = false
        
        return button
    }
    
    static func closeButton() -> CustomButton {
        let button = CustomButton()
        
        button.title = ""
        button.titleColorLight = .black
        button.titleColorLightActive = .white
        button.titleColorDark = .white
        button.titleColorDarkActive = .black
        
        button.icon = NSImage(named: NSImage.Name("Cross"))
        
        button.cornerRadius = 0
        button.borderWidth = 0
        
        button.contentPosition = .left
        button.animateState = false
        
        return button
    }
}
