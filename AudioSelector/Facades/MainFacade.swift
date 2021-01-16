//
//  SelectorViewModel.swift
//  AudioSelector
//
//  Created by Semiotikus on 12.08.17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

import Foundation
import RxSwift
import AMCoreAudio
import AudioKit

class MainFacade {
    
    var inputFacades = [DeviceFacade]()
    var outputFacades = [DeviceFacade]()
    var systemFacades = [DeviceFacade]()
        
    fileprivate var disposeBag = DisposeBag()
    
    fileprivate var resetScheduled = false
    fileprivate var inputDidChange = false
    fileprivate var outputDidChange = false
    fileprivate var systemDidChange = false
    fileprivate var hardwareDidChange = false
    
    
    init() {
        NotificationCenter.defaultCenter.subscribe(self, eventType: AudioHardwareEvent.self, dispatchQueue: DispatchQueue.main)
        NotificationCenter.defaultCenter.subscribe(self, eventType: AudioDeviceEvent.self, dispatchQueue: DispatchQueue.main)
        
        _ = Hub.requests.observeOn(MainScheduler.asyncInstance).subscribe(
            onNext: { [weak self] request in
                self?.handleInterfaceRequest(request)
            }
        )
        
        createFacades()
    }
    
    deinit {
        NotificationCenter.defaultCenter.unsubscribe(self, eventType: AudioHardwareEvent.self)
        NotificationCenter.defaultCenter.unsubscribe(self, eventType: AudioDeviceEvent.self)
        disposeBag = DisposeBag()
    }
    
    func viewWillGetActive() { createFacades() }
    
    func createFacades() {
        inputFacades.removeAll()
        outputFacades.removeAll()
        systemFacades.removeAll()
        
        for device in AudioDevice.allDevices() {
            if device.name.contains("CADefaultDeviceAggregate") { continue }
            
            if device.channels(direction: .recording) > 0 {
                inputFacades.append(DeviceFacade(type: .input, device: device))
            }
            
            if device.channels(direction: .playback) > 0 {
                outputFacades.append(DeviceFacade(type: .output, device: device))
                systemFacades.append(DeviceFacade(type: .system, device: device))
            }
        }
        
        let pref = Preferences.standard
        
        if pref.preferredInput != "" && (inputFacades.filter{ $0.name == pref.preferredInput }).count == 0 {
            inputFacades.append(DeviceFacade(type: .input, deviceName: pref.preferredInput))
        }
        if pref.preferredOutput != "" && (outputFacades.filter{ $0.name == pref.preferredOutput }).count == 0 {
            outputFacades.append(DeviceFacade(type: .output, deviceName: pref.preferredOutput))
        }
        if pref.preferredSystem != "" && (systemFacades.filter{ $0.name == pref.preferredSystem }).count == 0 {
            systemFacades.append(DeviceFacade(type: .system, deviceName: pref.preferredSystem))
        }
        
        if pref.favoriteInput != "" && (inputFacades.filter{ $0.name == pref.favoriteInput }).count == 0 {
            inputFacades.append(DeviceFacade(type: .input, deviceName: pref.favoriteInput))
        }
        if pref.favoriteOutput != "" && (outputFacades.filter{ $0.name == pref.favoriteOutput }).count == 0 {
            outputFacades.append(DeviceFacade(type: .output, deviceName: pref.favoriteOutput))
        }
        if pref.favoriteSystem != "" && (systemFacades.filter{ $0.name == pref.favoriteSystem }).count == 0 {
            systemFacades.append(DeviceFacade(type: .system, deviceName: pref.favoriteSystem))
        }
        
        Hub.request(.populate)
    }
    
    func scheduleChangeReset() {
        guard !resetScheduled else { return }
        resetScheduled = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
            Hub.log("scheduleChangeReset running")
            self?.resetScheduled = false
            self?.inputDidChange = false
            self?.outputDidChange = false
            self?.systemDidChange = false
            self?.hardwareDidChange = false
        }
    }
    
    func handleInterfaceRequest(_ request: Message) {        
        switch request {
            case .updateFacades:
                inputFacades.forEach { $0.update() }
                outputFacades.forEach { $0.update() }
                systemFacades.forEach { $0.update() }
                break
            case .updateInputFacades:
                inputFacades.forEach { $0.update() }
                break
            case .updateOutputFacades:
                outputFacades.forEach { $0.update() }
                break
            case .updateSystemFacades:
                systemFacades.forEach { $0.update() }
                break
            case .updateFacade(let device):
                inputFacades.forEach { if $0.device == device { $0.update() }}
                outputFacades.forEach { if $0.device == device { $0.update() }}
                systemFacades.forEach { if $0.device == device { $0.update() }}
                break
            case .startPassthrough:
                //startPassthrough()
                break
            case .stopPassthrough:
                //stopPassthrough()
                break
            case .togglePassthrough:
                //togglePassthrough()
                break
            default: break
        }
    }
    
    // MARK: - Audio pass through handling
    
    let audioEngine = AudioEngine()
    var inputNode: AudioEngine.InputNode? = nil
    var passthroughActive = Variable(false)
    
    func togglePassthrough() {
        Hub.log("togglePassthrough")
        if passthroughActive.value == true {
            stopPassthrough()
        } else {
            startPassthrough()
        }
    }
    
    private func refreshPassthrough() {
        Hub.log("refreshPassthrough")
        stopPassthrough()
        startPassthrough()
    }
    
    private func startPassthrough() {
        Hub.log("startPassthrough")
        //guard passthroughActive.value == true else { return }
        inputNode = AudioEngine.InputNode()
        audioEngine.output = inputNode
        inputNode?.start()
        //AudioKit.output = passthroughInput
        
        if (try? audioEngine.start()) != nil {
            Hub.log("passthrough active")
            passthroughActive.value = true
        } else {
            Hub.log("passthrough inactive")
            passthroughActive.value = false
        }
        
 
    }
    
    private func stopPassthrough() {
        Hub.log("stopPassthrough")
        guard passthroughActive.value == false else { return }
        inputNode?.stop()
        inputNode = nil
        audioEngine.stop()
        audioEngine.output = nil
        passthroughActive.value = false
        /*AudioKit.output = nil
        AudioKit.disconnectAllInputs()
        passthroughInput?.stop()
        passthroughInput = nil
        passthroughActive.value = false*/

    }
}

// MARK: - Implementation of AMCoreAudio EventSubscriber
extension MainFacade: EventSubscriber {
    
    var hashValue: Int { get { return 707 as Int } }
    
    func eventReceiver(_ event: AMCoreAudio.Event) {
        
        Hub.log(String(describing: event))
        
        if let devicEvent = event as? AudioDeviceEvent {
            var updateDevice: AudioDevice?
            
            switch devicEvent {
            case .isJackConnectedDidChange(let device):
                updateDevice = device
            case .volumeDidChange(let device, _, _):
                updateDevice = device
            case .listDidChange(let device):
                updateDevice = device
            case .nameDidChange(let device):
                updateDevice = device
            case .isRunningDidChange(let device):
                updateDevice = device
            case .isRunningSomewhereDidChange(let device):
                updateDevice = device
            default: break
            }
            
            if let updateDevice = updateDevice {
                Hub.request(.updateFacade(updateDevice))
            }
        }
        
        if let hardwareEvent = event as? AudioHardwareEvent {
            switch hardwareEvent {
            case .deviceListChanged(let added, let removed):
                // ignore virtual device created for passthrough
                if removed.count == 0 && added.count == 1 && (added.filter{ $0.name.contains("CADefaultDeviceAggregate")}).count == 1 { return }
                if added.count == 0 && removed.count == 1 && (removed.filter{ $0.name.contains("CADefaultDeviceAggregate")}).count == 1 { return }
                createFacades()
                hardwareDidChange = true
                return
            case .defaultInputDeviceChanged(_):
                inputDidChange = true
                break
            case .defaultOutputDeviceChanged(_):
                outputDidChange = true
                break
            case .defaultSystemOutputDeviceChanged(_):
                systemDidChange = true
                break
            }
            stopPassthrough()
        }
        
        Hub.log("\(hardwareDidChange) \(inputDidChange) \(outputDidChange) \(systemDidChange)")
        
        // check if we need to reset to our preferred settings
        guard hardwareDidChange else { return }
        scheduleChangeReset()
        
        if inputDidChange {
            if let facade = (inputFacades.filter{ $0.name == Preferences.standard.preferredInput }).first, let device = AudioDevice.defaultInputDevice() {
                if facade.name != device.name { facade.setActive() }
            }
        }
        if outputDidChange {
            if let facade = (outputFacades.filter{ $0.name == Preferences.standard.preferredOutput }).first, let device = AudioDevice.defaultOutputDevice() {
                if facade.name != device.name { facade.setActive() }
            }
        }
        if systemDidChange {
            if let facade = (systemFacades.filter{ $0.name == Preferences.standard.preferredSystem }).first, let device = AudioDevice.defaultSystemOutputDevice() {
                if facade.name != device.name { facade.setActive() }
            }
        }
    }
}
