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
    var favoriteInput = "" {
        didSet {
            if favoriteInput != "" {
                favoriteOutput = ""
                favoriteSystem = ""
            }
        }
    }
    var favoriteOutput = "" {
        didSet {
            if favoriteOutput != "" {
                favoriteInput = ""
                favoriteSystem = ""
            }
        }
    }
    var favoriteSystem = "" {
        didSet {
            if favoriteSystem != "" {
                favoriteInput = ""
                favoriteOutput = ""
            }
        }
    }
    
    private init() {
        let userDefaults = UserDefaults.standard
        preferredInput = userDefaults.string(forKey: "preferredInput") ?? ""
        preferredOutput = userDefaults.string(forKey: "preferredOutput") ?? ""
        preferredSystem = userDefaults.string(forKey: "preferredSystem") ?? ""
        favoriteInput = userDefaults.string(forKey: "favoriteInput") ?? ""
        favoriteOutput = userDefaults.string(forKey: "favoriteOutput") ?? ""
        favoriteSystem = userDefaults.string(forKey: "favoriteSystem") ?? ""
        Hub.log(
            "Preferences loading preferredInput=\(preferredInput) preferredOutput=\(preferredOutput) preferredSystem=\(preferredSystem) favoriteInput=\(favoriteInput) favoriteOutput=\(favoriteOutput) favoriteSystem=\(favoriteSystem)"
        )
    }
    
    func save() {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(preferredInput, forKey: "preferredInput")
        userDefaults.setValue(preferredOutput, forKey: "preferredOutput")
        userDefaults.setValue(preferredSystem, forKey: "preferredSystem")
        userDefaults.setValue(favoriteInput, forKey: "favoriteInput")
        userDefaults.setValue(favoriteOutput, forKey: "favoriteOutput")
        userDefaults.setValue(favoriteSystem, forKey: "favoriteSystem")
        Hub.log(
            "Preferences saving preferredInput=\(preferredInput) preferredOutput=\(preferredOutput) preferredSystem=\(preferredSystem) favoriteInput=\(favoriteInput) favoriteOutput=\(favoriteOutput) favoriteSystem=\(favoriteSystem)"
        )
    }
}
