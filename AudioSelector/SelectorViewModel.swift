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
    
    var deviceViewModels = Variable([DeviceViewModel]())
    var unavalablePreferredInputViewModel: DeviceUnavailableViewModel?
    var unavalablePreferredOutputViewModel: DeviceUnavailableViewModel?
    var unavalablePreferredSystemViewModel: DeviceUnavailableViewModel?
    
    var passthroughActive = Variable(false)
    
    fileprivate var disposeBag = DisposeBag()
    
    fileprivate var resetScheduled = false
    fileprivate var inputDidChange = false
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
        
        // generate new device view model list
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
        
        // generate new device unavailable view model items
        let pref = Preferences.standard
        
        unavalablePreferredInputViewModel = nil
        unavalablePreferredOutputViewModel = nil
        unavalablePreferredSystemViewModel = nil
        
        if pref.preferredInput != "" && (self.deviceViewModels.value.filter{ $0.name == pref.preferredInput }).count == 0 {
            let vm = DeviceUnavailableViewModel(SelectorTypes.input)
            vm.interfaceActionRequests.asObservable().subscribe(
                onNext: { [weak self] action in
                    self?.handlInterfaceAction(action, vm)
                }
            ).disposed(by: disposeBag)
            unavalablePreferredInputViewModel = vm
        }
        if pref.preferredOutput != "" && (self.deviceViewModels.value.filter{ $0.name == pref.preferredOutput }).count == 0 {
            let vm = DeviceUnavailableViewModel(SelectorTypes.output)
            vm.interfaceActionRequests.asObservable().subscribe(
                onNext: { [weak self] action in
                    self?.handlInterfaceAction(action, vm)
                }
            ).disposed(by: disposeBag)
            unavalablePreferredOutputViewModel = vm
        }
        if pref.preferredSystem != "" && (self.deviceViewModels.value.filter{ $0.name == pref.preferredSystem }).count == 0 {
            let vm = DeviceUnavailableViewModel(SelectorTypes.system)
            vm.interfaceActionRequests.asObservable().subscribe(
                onNext: { [weak self] action in
                    self?.handlInterfaceAction(action, vm)
                }
            ).disposed(by: disposeBag)
            unavalablePreferredSystemViewModel = vm
        }
        
        deviceViewModels.value = list
    }
    
    func updateViewModels() {
        unavalablePreferredInputViewModel?.update()
        unavalablePreferredOutputViewModel?.update()
        unavalablePreferredSystemViewModel?.update()
        deviceViewModels.value.forEach { $0.update() }
    }
    
    func updateViewModel(_ device : AudioDevice) {
        getViewModel(device)?.update()
    }
    
    private func getViewModel(_ forDevice: AudioDevice) -> DeviceViewModel? {
        if let vm = (deviceViewModels.value.filter{ $0.device.uid == forDevice.uid }).first{
            return vm
        }
        if let vm = (deviceViewModels.value.filter{ $0.device.name == forDevice.name }).first{
            return vm
        }
        return nil
    }
    
    func scheduleChangeReset() {
        guard !resetScheduled else { return }
        resetScheduled = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
            Logger.shared.add("scheduleChangeReset running")
            self?.resetScheduled = false
            self?.inputDidChange = false
            self?.outputDidChange = false
            self?.systemDidChange = false
            self?.hardwareDidChange = false
        }
    }
    
    func handlInterfaceAction(_ action: InterfaceAction, _ target: AnyObject?) {
        Logger.shared.add("handlInterfaceAction \(String(describing: target)) \(action)")
        switch action {
        case .setAsInput:
            guard let target = target as? DeviceViewModel else { return }
            target.device.setAsDefaultInputDevice()
            stopPassthrough()
            break
        case .setAsOutput:
            guard let target = target as? DeviceViewModel else { return }
            target.device.setAsDefaultOutputDevice()
            stopPassthrough()
            break
        case .setAsSystem:
            guard let target = target as? DeviceViewModel else { return }
            target.device.setAsDefaultSystemDevice()
            break
        case .setAsPreferredInput:
            var name: String?
            if let target = target as? DeviceViewModel {  name = target.device.name }
            if let target = target as? DeviceUnavailableViewModel { name = target.name }
            guard let inputName = name else { return }
            Preferences.standard.preferredInput = inputName
            Preferences.standard.save()
            break
        case .setAsPreferredOutput:
            var name: String?
            if let target = target as? DeviceViewModel {  name = target.device.name }
            if let target = target as? DeviceUnavailableViewModel { name = target.name }
            guard let outputName = name else { return }
            Preferences.standard.preferredOutput = outputName
            Preferences.standard.save()
            break
        case .setAsPreferredSystem:
            var name: String?
            if let target = target as? DeviceViewModel {  name = target.device.name }
            if let target = target as? DeviceUnavailableViewModel { name = target.name }
            guard let systemName = name else { return }
            Preferences.standard.preferredSystem = systemName
            Preferences.standard.save()
            break
        case .setVolumeIn(let volume):
            guard let target = target as? DeviceViewModel else { return }
            if target.device.canSetVirtualMasterVolume(direction: .recording) {
                target.device.setVirtualMasterVolume(volume, direction: .recording)
            }
            break
        case .setVolumeOut(let volume):
            guard let target = target as? DeviceViewModel else { return }
            if target.device.canSetVirtualMasterVolume(direction: .playback) {
                target.device.setVirtualMasterVolume(volume, direction: .playback)
            }
            break
        case .togglePassthrough:
            togglePassthrough()
            break
        }
        updateViewModels()
    }
}

// MARK: - Audio pass through handling
extension SelectorViewModel {
    func togglePassthrough() {
        if passthroughActive.value == true {
            stopPassthrough()
        } else {
            startPassthrough()
        }
    }
    
    private func refreshPassthrough() {
        guard passthroughActive.value == true else { return }
        stopPassthrough()
        startPassthrough()
    }
    
    private func startPassthrough() {
        passthroughActive.value = true
        passthroughInput = AKMicrophone() // microphone will point to what ever is the default input device
        AudioKit.output = passthroughInput
        AudioKit.start()
    }
    
    private func stopPassthrough() {
        AudioKit.stop()
        AudioKit.output = nil
        AudioKit.disconnectAllInputs()
        passthroughInput?.stop()
        passthroughInput = nil
        passthroughActive.value = false
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
            
            if let updateDevice = updateDevice {
                updateViewModel(updateDevice)
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
            case .defaultOutputDeviceChanged(_):
                outputDidChange = true
            case .defaultSystemOutputDeviceChanged(_):
                systemDidChange = true
            }
            reloadViewModels()
        }
        
        Logger.shared.add("\(hardwareDidChange) \(inputDidChange) \(outputDidChange) \(systemDidChange)")
        
        // check if we need to reset to our preferred settings
        guard hardwareDidChange else { return }
        scheduleChangeReset()
        
        stopPassthrough()
        
        if inputDidChange {
            if let vm = (deviceViewModels.value.filter{ $0.device.name == Preferences.standard.preferredInput }).first, let device = AudioDevice.defaultInputDevice() {
                if vm.device.name != device.name {
                    vm.setAsInput()
                }
            }
        }
        if outputDidChange {
            if let vm = (deviceViewModels.value.filter{ $0.device.name == Preferences.standard.preferredOutput }).first, let device = AudioDevice.defaultOutputDevice() {
                if vm.device.name != device.name {
                    vm.setAsOutput()
                }
            }
        }
        if systemDidChange {
            if let vm = (deviceViewModels.value.filter{ $0.device.name == Preferences.standard.preferredSystem }).first, let device = AudioDevice.defaultSystemOutputDevice() {
                if vm.device.name != device.name {
                    vm.setAsSystem()
                }
            }
        }
    }
}
