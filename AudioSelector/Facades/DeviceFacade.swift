//
//  DeviceViewModel.swift
//  AudioSelector
//
//  Created by Semiotikus on 12.08.17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

import Cocoa
import RxSwift
import AMCoreAudio

class DeviceFacade {
        
    var isPresent: Bool
    
    var isActive = Variable(false)
    var isPreferred = Variable(false)
    var isFavorite = Variable(false)
    
    var volumeIn = Variable<Float32>(0)
    var volumeOut = Variable<Float32>(0)
    var canChangeVolumeIn = Variable(false)
    var canChangeVolumeOut = Variable(false)
    
    var displayName = Variable("")
    var name: String { return device?.name ?? deviceName ?? "" }
    
    var type: Channel
    var device: AudioDevice?
    
    var isInputDevice: Bool { type == .input }
    var isOutputDevice: Bool { type == .output }
    var isSystemDevice: Bool { type == .system }
    
    private var deviceName: String?
    
    init(type: Channel, device: AudioDevice) {
        self.type = type
        self.device = device
        isPresent = true
        update()
    }
    
    init(type: Channel, deviceName: String) {
        self.type = type
        self.deviceName = deviceName
        isPresent = false
        update()
    }
    
    func update() {
        displayName.value = (device?.isJackConnected(direction: .playback) ?? false) ? "\(name) (Headphones)" : name
        
        volumeIn.value = device?.virtualMasterVolume(direction: .recording) ?? 0
        volumeOut.value = device?.virtualMasterVolume(direction: .playback) ?? 0
        
        canChangeVolumeIn.value = device?.canSetVirtualMasterVolume(direction: .recording) ?? false
        canChangeVolumeOut.value = device?.canSetVirtualMasterVolume(direction: .playback) ?? false
        
        isActive.value = false
        isActive.value = isInputDevice && device != nil && AudioDevice.defaultInputDevice() == device ? true : isActive.value
        isActive.value = isOutputDevice && device != nil && AudioDevice.defaultOutputDevice() == device ? true : isActive.value
        isActive.value = isSystemDevice && device != nil && AudioDevice.defaultSystemOutputDevice() == device ? true : isActive.value
        
        let pref = Preferences.standard
        isPreferred.value = false
        isPreferred.value = isInputDevice && pref.preferredInput == name ? true : isPreferred.value
        isPreferred.value = isOutputDevice && pref.preferredOutput == name ? true : isPreferred.value
        isPreferred.value = isSystemDevice && pref.preferredSystem == name ? true : isPreferred.value
        isFavorite.value = false
        isFavorite.value = isInputDevice && pref.favoriteInput == name ? true : isFavorite.value
        isFavorite.value = isOutputDevice && pref.favoriteOutput == name ? true : isFavorite.value
        isFavorite.value = isSystemDevice && pref.favoriteSystem == name ? true : isFavorite.value
        
        if isFavorite.value {
            Hub.request(.updateAppIcon(isActive.value))
        }
        
        //Logger.shared.add("Updated \(displayName.value) active=\(isActive.value) type=\(type)")
    }
    
    @objc func setActive() {
        guard let device = device else { return }
        
        if type == .input {
            device.setAsDefaultInputDevice()
            Hub.request(.updateInputFacades)
        }
        if type == .output {
            device.setAsDefaultOutputDevice()
            Hub.request(.updateOutputFacades)
        }
        if type == .system {
            device.setAsDefaultSystemDevice()
            Hub.request(.updateSystemFacades)
        }
        
        Hub.request(.stopPassthrough)
    }
    
    @objc func setPreferred() {
        if type == .input { Preferences.standard.preferredInput = name }
        if type == .output { Preferences.standard.preferredOutput = name }
        if type == .system { Preferences.standard.preferredSystem = name }
        
        Preferences.standard.save()
            
        if type == .input { Hub.request(.updateInputFacades) }
        if type == .output { Hub.request(.updateOutputFacades) }
        if type == .system { Hub.request(.updateSystemFacades) }
    }
    
    @objc func setFavorite() {
        if type == .input { Preferences.standard.favoriteInput = name }
        if type == .output { Preferences.standard.favoriteOutput = name }
        if type == .system { Preferences.standard.favoriteSystem = name }
        
        Preferences.standard.save()
        
        Hub.request(.updateFacades)
    }
    
    @objc func setVolume(_ control: NSControl) {
        guard let device = device else { return }
        
        if canChangeVolumeIn.value && type == .input {
            device.setVirtualMasterVolume(control.floatValue as Float32, direction: .recording)
        }
        if canChangeVolumeOut.value && (type == .output || type == .system) {
            device.setVirtualMasterVolume(control.floatValue as Float32, direction: .playback)
        }
        
        update()
    }
}
