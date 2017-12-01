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
    
    var preferredInput = ""
    var preferredOutput = ""
    var preferredSystem = ""
    
    private init() {
        let userDefaults = UserDefaults.standard
        preferredInput = userDefaults.string(forKey: "preferredInput") ?? ""
        preferredOutput = userDefaults.string(forKey: "preferredOutput") ?? ""
        preferredSystem = userDefaults.string(forKey: "preferredSystem") ?? ""
        Logger.shared.add("Preferences loading preferredInput=\(preferredInput) preferredOutput=\(preferredOutput) preferredSystem=\(preferredSystem)")
    }
    
    func save() {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(preferredInput, forKey: "preferredInput")
        userDefaults.setValue(preferredOutput, forKey: "preferredOutput")
        userDefaults.setValue(preferredSystem, forKey: "preferredSystem")
        Logger.shared.add("Preferences saving preferredInput=\(preferredInput) preferredOutput=\(preferredOutput) preferredSystem=\(preferredSystem)")
    }
}
