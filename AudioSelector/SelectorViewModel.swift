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
    
    init() {
        updateDeviceList()
        
        NotificationCenter.defaultCenter.subscribe(self, eventType: AudioHardwareEvent.self, dispatchQueue: DispatchQueue.main)
        NotificationCenter.defaultCenter.subscribe(self, eventType: AudioDeviceEvent.self, dispatchQueue: DispatchQueue.main)
        NotificationCenter.defaultCenter.subscribe(self, eventType: AudioStreamEvent.self, dispatchQueue: DispatchQueue.main)
    }
    
    deinit {
        NotificationCenter.defaultCenter.unsubscribe(self, eventType: AudioHardwareEvent.self)
        NotificationCenter.defaultCenter.unsubscribe(self, eventType: AudioDeviceEvent.self)
        NotificationCenter.defaultCenter.unsubscribe(self, eventType: AudioStreamEvent.self)
    }
    
    var hashValue: Int { get { return 0 as Int } }
    
    func eventReceiver(_ event: AMCoreAudio.Event) {
        
        Swift.print(event)
        
        switch event {
//        case let event as AudioDeviceEvent:
//            switch event {
//            case .isRunningDidChange( _):
//                updateDevicesInList()
//            case .isRunningSomewhereDidChange(_):
//                updateDevicesInList()
//            default:
//                break
//            }
        case let event as AudioHardwareEvent:
            switch event {
            case .deviceListChanged(_, _):
                self.updateDeviceList()
            case .defaultInputDeviceChanged(_):
                updateDevicesInList()
            case .defaultOutputDeviceChanged(_):
                updateDevicesInList()
            case .defaultSystemOutputDeviceChanged(_):
                updateDevicesInList()
            }
        default:
            break
        }
    }

    func updateDeviceList() {
        var list = [DeviceViewModel]()
        for device in AudioDevice.allDevices() {
            list.append(DeviceViewModel(device))
        }
        devices.value = list
    }
    
    func updateDevicesInList() {
        for viewModel in devices.value {
            viewModel.update()
        }
    }
}


