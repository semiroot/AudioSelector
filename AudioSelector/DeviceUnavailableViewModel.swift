//
//  DeviceViewModel.swift
//  AudioSelector
//
//  Created by Semiotikus on 12.08.17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

import Foundation
import RxSwift
import AMCoreAudio

class DeviceUnavailableViewModel {
    
    var interfaceActionRequests: Observable<InterfaceAction>
    var interfaceActionPublish = PublishSubject<InterfaceAction>()
    
    let isPresent = false
    
    let selectorType: SelectorTypes
    let name: String
    
    var isPreferredInput = Variable(false)
    var isPreferredOutput = Variable(false)
    var isPreferredSystem = Variable(false)
    
    init(_ type: SelectorTypes) {
        interfaceActionRequests = interfaceActionPublish
        self.selectorType = type
        
        let pref = Preferences.standard
        
        switch selectorType {
        case .input:
            self.name = pref.preferredInput
            break
        case .output:
            self.name = pref.preferredOutput
            break
        case .system:
            self.name = pref.preferredSystem
            break
        }
        
        update()
    }
    
    func update() {
        let pref = Preferences.standard

        let preferredInput = pref.preferredInput == name
        if isPreferredInput.value != preferredInput {
            isPreferredInput.value = preferredInput
        }

        let preferredOutput = pref.preferredOutput == name
        if isPreferredOutput.value != preferredOutput {
            isPreferredOutput.value = preferredOutput
        }

        let preferredSystem = pref.preferredSystem == name
        if isPreferredSystem.value != preferredSystem {
            isPreferredSystem.value = preferredSystem
        }
    }
    
    func setAsPreferredInput() {
        interfaceActionPublish.onNext(InterfaceAction.setAsPreferredInput)
    }
    
    func setAsPreferredOutput() {
        interfaceActionPublish.onNext(InterfaceAction.setAsPreferredOutput)
    }
    
    func setAsPreferredSystem() {
        interfaceActionPublish.onNext(InterfaceAction.setAsPreferredSystem)
    }
}
