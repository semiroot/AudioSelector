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
    
    private let device: AudioDevice
    
    init(_ device: AudioDevice) {
        self.device = device
        update()
    }
    
    func update() {
        let input = AudioDevice.defaultInputDevice() == self.device
        if isMainInput.value != input {
            isMainInput.value = input
        }
        
        let output = AudioDevice.defaultOutputDevice() == self.device
        if isMainOutput.value != output {
            isMainOutput.value = output
        }
        
        let system = AudioDevice.defaultSystemOutputDevice() == self.device
        if isSystemOutput.value != system {
            isSystemOutput.value = system
        }
    }
    
    var name: String {
        return device.name
    }
    
    var isInputDevice: Bool {
        return device.channels(direction: .recording) > 0
    }
    
    var isOutputDevice: Bool {
        return device.channels(direction: .playback) > 0
    }
    
    var isMainInput = Variable(false)
    var isMainOutput = Variable(false)
    var isSystemOutput = Variable(false)
    
    func setAsInputDevice() {
        self.device.setAsDefaultInputDevice()
    }
    
    func setAsOutputDevice() {
        self.device.setAsDefaultOutputDevice()
    }
    
    func setAsSystemDevice() {
        self.device.setAsDefaultSystemDevice()
    }
}
