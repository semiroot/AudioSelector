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

class DeviceViewModel {
    
    var interfaceActionRequests: Observable<InterfaceAction>
    var interfaceActionPublish = PublishSubject<InterfaceAction>()
    
    var isPresent = true
    
    var isInput = Variable(false)
    var isOutput = Variable(false)
    var isSystem = Variable(false)
    var isPreferredInput = Variable(false)
    var isPreferredOutput = Variable(false)
    var isPreferredSystem = Variable(false)
    
    var volumeIn = Variable<Float32>(0)
    var volumeOut = Variable<Float32>(0)
    var canChangeVolumeIn = Variable(false)
    var canChangeVolumeOut = Variable(false)
    var displayName = Variable("")
    
    var name: String {
        return device.name
    }
    
    var isInputDevice: Bool {
        return device.channels(direction: .recording) > 0
    }
    
    var isOutputDevice: Bool {
        return device.channels(direction: .playback) > 0
    }
    
    
    let device: AudioDevice
    
    init(_ device: AudioDevice) {
        interfaceActionRequests = interfaceActionPublish
        self.device = device
        update()
    }
    
    func update() {
        
        displayName.value = (device.isJackConnected(direction: .playback) ?? false) ? "\(device.name) (Headphones)" : device.name
        
        volumeIn.value = device.virtualMasterVolume(direction: .recording) ?? 0
        volumeOut.value = device.virtualMasterVolume(direction: .playback) ?? 0
        
        canChangeVolumeIn.value = device.canSetVirtualMasterVolume(direction: .recording)
        canChangeVolumeOut.value = device.canSetVirtualMasterVolume(direction: .playback)
        
        let input = AudioDevice.defaultInputDevice() == self.device
        if isInput.value != input {
            isInput.value = input
        }
        
        let output = AudioDevice.defaultOutputDevice() == self.device
        if isOutput.value != output {
            isOutput.value = output
        }
        
        let system = AudioDevice.defaultSystemOutputDevice() == self.device
        if isSystem.value != system {
            isSystem.value = system
        }
        
        let pref = Preferences.standard
        
        let preferredInput = pref.preferredInput == self.device.name
        if isPreferredInput.value != preferredInput {
            isPreferredInput.value = preferredInput
        }
        
        let preferredOutput = pref.preferredOutput == self.device.name
        if isPreferredOutput.value != preferredOutput {
            isPreferredOutput.value = preferredOutput
        }
        
        let preferredSystem = pref.preferredSystem == self.device.name
        if isPreferredSystem.value != preferredSystem {
            isPreferredSystem.value = preferredSystem
        }
    }
    
    func setAsInput() {
        interfaceActionPublish.onNext(InterfaceAction.setAsInput)
    }
    
    func setAsOutput() {
        interfaceActionPublish.onNext(InterfaceAction.setAsOutput)
    }
    
    func setAsSystem() {
        interfaceActionPublish.onNext(InterfaceAction.setAsSystem)
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
    
    func setVolumeIn(_ volume: Float32) {
        interfaceActionPublish.onNext(InterfaceAction.setVolumeIn(volume))
    }
    
    func setVolumeOut(_ volume: Float32) {
        interfaceActionPublish.onNext(InterfaceAction.setVolumeOut(volume))
    }
}
