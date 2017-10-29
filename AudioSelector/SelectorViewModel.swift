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

class SelectorViewModel {
    
    var devices = Variable([DeviceViewModel]())
    var passthroughActive = Variable(false)
    
    fileprivate var disposeBag = DisposeBag()
    
    fileprivate var resetScheduled = false
    fileprivate var inputDidChange = false
    fileprivate var inputDidChangeWhilePassthrough = false
    fileprivate var outputDidChange = false
    fileprivate var systemDidChange = false
    fileprivate var hardwareDidChange = false
    
    fileprivate var passthroughInput: AKMicrophone?
    
    init() {
        NotificationCenter.defaultCenter.subscribe(self, eventType: AudioHardwareEvent.self, dispatchQueue: DispatchQueue.main)
        NotificationCenter.defaultCenter.subscribe(self, eventType: AudioDeviceEvent.self, dispatchQueue: DispatchQueue.main)
        
        reloadViewModels()
    }
    
    deinit {
        NotificationCenter.defaultCenter.unsubscribe(self, eventType: AudioHardwareEvent.self)
        NotificationCenter.defaultCenter.unsubscribe(self, eventType: AudioDeviceEvent.self)
        
        Preferences.standard.save()
    }
    
    func viewWillGetActive() {
        reloadViewModels()
    }
    
    func viewDidGetInactive() {
    }
    
    func reloadViewModels() {
        self.disposeBag = DisposeBag()
        var list = [DeviceViewModel]()
        for device in AudioDevice.allDevices() {
            if device.name.contains("CADefaultDeviceAggregate") { continue }
            let dvm = DeviceViewModel(device)
            dvm.interfaceActionRequests.asObservable().subscribe(
                onNext: { [weak self] action in
                    self?.handlInterfaceAction(action, dvm)
                }
            ).disposed(by: disposeBag)
            list.append(dvm)
        }
        devices.value = list
    }
    
    func updateViewModels() {
        devices.value.forEach { $0.update() }
    }
    
    func updateViewModel(_ device : AudioDevice) {
        getViewModel(device)?.update()
    }
    
    fileprivate func getViewModel(_ forDevice: AudioDevice) -> DeviceViewModel? {
        if let vm = (devices.value.filter{ $0.device.uid == forDevice.uid }).first{
            return vm
        }
        if let vm = (devices.value.filter{ $0.device.name == forDevice.name }).first{
            return vm
        }
        return nil
    }
    
    func togglePassthrough() {
        if passthroughActive.value == true {
            stopPassthrough()
        } else {
            startPassthrough()
        }
    }
    
    func refreshPassthrough() {
        guard passthroughActive.value == true else { return }
        stopPassthrough()
        startPassthrough()
    }
    
    func startPassthrough() {
        passthroughActive.value = true
        passthroughInput = AKMicrophone() // microphone will point to what ever is the default input device
        AudioKit.output = passthroughInput
        AudioKit.start()
    }
    
    func stopPassthrough() {
        AudioKit.stop()
        AudioKit.output = nil
        AudioKit.disconnectAllInputs()
        passthroughInput?.stop()
        passthroughInput = nil
        passthroughActive.value = false
    }
    
    func scheduleChangeReset() {
        guard !resetScheduled else { return }
        resetScheduled = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
            Logger.shared.add("scheduleChangeReset running")
            self?.resetScheduled = false
            self?.inputDidChange = false
            self?.inputDidChangeWhilePassthrough = false
            self?.outputDidChange = false
            self?.systemDidChange = false
            self?.hardwareDidChange = false
        }
    }
    
    func handlInterfaceAction(_ action: InterfaceAction, _ target: DeviceViewModel) {
        Logger.shared.add("handlInterfaceAction \(target.device) \(action)")
        switch action {
        case .setAsInput:
            inputDidChangeWhilePassthrough = passthroughActive.value
            target.device.setAsDefaultInputDevice()
            break
        case .setAsOutput:
            target.device.setAsDefaultOutputDevice()
            break
        case .setAsSystem:
            target.device.setAsDefaultSystemDevice()
            break
        case .setAsDefaultInput:
            Preferences.standard.defaultInput = target.device.name
            Preferences.standard.save()
            break
        case .setAsDefaultOutput:
            Preferences.standard.defaultOutput = target.device.name
            Preferences.standard.save()
            break
        case .setAsDefaultSystem:
            Preferences.standard.defaultSystem = target.device.name
            Preferences.standard.save()
            break
        case .setVolumeIn(let volume):
            if target.device.canSetVirtualMasterVolume(direction: .recording) {
                target.device.setVirtualMasterVolume(volume, direction: .recording)
            }
            break
        case .setVolumeOut(let volume):
            if target.device.canSetVirtualMasterVolume(direction: .playback) {
                target.device.setVirtualMasterVolume(volume, direction: .playback)
            }
            break
        case .togglePassthrough:
            togglePassthrough()
            break;
        }
        updateViewModels()
    }
}

// MARK: - Implementation of AMCoreAudio EventSubscriber
extension SelectorViewModel: EventSubscriber {
    
    var hashValue: Int { get { return 707 as Int } }
    
    
    func eventReceiver(_ event: AMCoreAudio.Event) {
        
        Logger.shared.add(event)
        
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
            
            if updateDevice != nil {
                updateViewModel(updateDevice!)
            }
        }
        
        if let hardwareEvent = event as? AudioHardwareEvent {
            switch hardwareEvent {
            case .deviceListChanged(let added, let removed):
                // ignore virtual device created for passthrough
                if removed.count == 0 && added.count == 1 && (added.filter{ $0.name.contains("CADefaultDeviceAggregate")}).count == 1 { return }
                if added.count == 0 && removed.count == 1 && (removed.filter{ $0.name.contains("CADefaultDeviceAggregate")}).count == 1 { return }
                hardwareDidChange = true
            case .defaultInputDeviceChanged(_):
                inputDidChange = true
                if inputDidChangeWhilePassthrough {
                    refreshPassthrough()
                }
            case .defaultOutputDeviceChanged(_):
                outputDidChange = true
            case .defaultSystemOutputDeviceChanged(_):
                systemDidChange = true
            }
            reloadViewModels()
        }
        
        
        // check if we need to reset to our prefered settings
        guard hardwareDidChange else { return }
        scheduleChangeReset()
        
        Logger.shared.add("\(inputDidChangeWhilePassthrough) \(inputDidChange) \(outputDidChange) \(systemDidChange)")
        
        if inputDidChange && !inputDidChangeWhilePassthrough {
            if let vm = (devices.value.filter{ $0.device.name == Preferences.standard.defaultInput }).first, let device = AudioDevice.defaultInputDevice() {
                if vm.device.name != device.name {
                    vm.setAsInput()
                }
            }
        }
        if outputDidChange {
            if let vm = (devices.value.filter{ $0.device.name == Preferences.standard.defaultOutput }).first, let device = AudioDevice.defaultOutputDevice() {
                if vm.device.name != device.name {
                    vm.setAsOutput()
                }
            }
        }
        if systemDidChange {
            if let vm = (devices.value.filter{ $0.device.name == Preferences.standard.defaultSystem }).first, let device = AudioDevice.defaultSystemOutputDevice() {
                if vm.device.name != device.name {
                    vm.setAsSystem()
                }
            }
        }
    }
}
