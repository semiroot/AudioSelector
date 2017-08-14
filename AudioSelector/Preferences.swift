//
//  Preferences.swift
//  AudioSelector
//
//  Created by Semiotikus on 13.08.17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

import Foundation

class Preferences  {
    static let standard = Preferences()
    
    var defaultInput = ""
    var defaultOutput = ""
    var defaultSystem = ""
    
    private init() {
        let userDefaults = UserDefaults.standard
        defaultInput = userDefaults.string(forKey: "defaultInput") ?? ""
        defaultOutput = userDefaults.string(forKey: "defaultOutput") ?? ""
        defaultSystem = userDefaults.string(forKey: "defaultSystem") ?? ""
        Swift.print("Preferences loading defaultInput=\(defaultInput) defaultOutput=\(defaultOutput) defaultSystem=\(defaultSystem)")
    }
    
    func save() {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(defaultInput, forKey: "defaultInput")
        userDefaults.setValue(defaultOutput, forKey: "defaultOutput")
        userDefaults.setValue(defaultSystem, forKey: "defaultSystem")
        Swift.print("Preferences saving defaultInput=\(defaultInput) defaultOutput=\(defaultOutput) defaultSystem=\(defaultSystem)")
    }
}
