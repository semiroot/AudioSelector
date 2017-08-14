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

class SelectorViewModel: EventSubscriber {
    
    var devices = Variable([DeviceViewModel]())
    
    fileprivate var disposeBag = DisposeBag()
    
    fileprivate var resetScheduled = false
    fileprivate var inputDidChange = false
    fileprivate var outputDidChange = false
    fileprivate var systemDidChange = false
    fileprivate var hardwareDidChange = false
    
    init() {
        NotificationCenter.defaultCenter.subscribe(self, eventType: AudioHardwareEvent.self, dispatchQueue: DispatchQueue.main)
        NotificationCenter.defaultCenter.subscribe(self, eventType: AudioDeviceEvent.self, dispatchQueue: DispatchQueue.main)
        NotificationCenter.defaultCenter.subscribe(self, eventType: AudioStreamEvent.self, dispatchQueue: DispatchQueue.main)
        
        updateDeviceList()
    }
    
    deinit {
        NotificationCenter.defaultCenter.unsubscribe(self, eventType: AudioHardwareEvent.self)
        NotificationCenter.defaultCenter.unsubscribe(self, eventType: AudioDeviceEvent.self)
        NotificationCenter.defaultCenter.unsubscribe(self, eventType: AudioStreamEvent.self)
        
        Preferences.standard.save()
    }
    
    var hashValue: Int { get { return 0 as Int } }
    
    func eventReceiver(_ event: AMCoreAudio.Event) {
        
        Swift.print(event)
        
        switch event {
        case let event as AudioHardwareEvent:
            switch event {
            case .deviceListChanged(_, _):
                hardwareDidChange = true
                updateDeviceList()
            case .defaultInputDeviceChanged(_):
                inputDidChange = true
                updateDevicesInList()
            case .defaultOutputDeviceChanged(_):
                outputDidChange = true
                updateDevicesInList()
            case .defaultSystemOutputDeviceChanged(_):
                systemDidChange = true
                updateDevicesInList()
            }
            
            scheduleChangeReset()
            
            guard hardwareDidChange else { return }
            
            if inputDidChange {
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
            
            if inputDidChange && outputDidChange && systemDidChange {
                updateDevicesInList()
            }
            
        default:
            break
        }
    }

    func updateDeviceList() {
        self.disposeBag = DisposeBag()
        var list = [DeviceViewModel]()
        for device in AudioDevice.allDevices() {
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
    
    func updateDevicesInList() {
        for viewModel in devices.value {
            viewModel.update()
        }
    }
    
    func scheduleChangeReset() {
        guard !resetScheduled else { return }
        resetScheduled = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
            Swift.print("scheduleChangeReset running")
            self?.resetScheduled = false
            self?.inputDidChange = false
            self?.outputDidChange = false
            self?.systemDidChange = false
            self?.hardwareDidChange = false
        }
    }
    
    func handlInterfaceAction(_ action: InterfaceAction, _ target: DeviceViewModel) {
        Swift.print("handlInterfaceAction \(target.device) \(action)")
        switch action {
        case .setAsInput:
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
        default:
            break
        }
        updateDevicesInList()
    }
}


