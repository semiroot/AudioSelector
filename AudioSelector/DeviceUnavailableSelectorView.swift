//
//  DeviceView.swift
//  AudioSelector
//
//  Created by Semiotikus on 12.08.17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

import Cocoa
import SwiftyConstraints
import RxSwift
import AMCoreAudio


class DeviceUnavailableSelectorView: NSView {
    
    private var selectorType = SelectorTypes.output
    private var viewModel: DeviceUnavailableViewModel?
    
    private let activeControl = RadioControl()
    private let preferredControl = RadioControl()
    private let volumeControl = NSSlider()
    private let deviceLabel = LabelView()
    
    private var disposeBag = DisposeBag()
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        unsubscribeFromViewModel()
    }
    
    deinit {
        unsubscribeFromViewModel()
    }
    
    public func setup(_ viewModel: DeviceUnavailableViewModel, _ selectorType: SelectorTypes) -> DeviceUnavailableSelectorView{
        self.viewModel = viewModel
        self.selectorType = viewModel.selectorType
        
        activeControl.isEnabled = false
        activeControl.isActive = false
        volumeControl.isEnabled = false
        volumeControl.floatValue = 0
        preferredControl.isEnabled = true
        preferredControl.isActive = true
        deviceLabel.stringValue = viewModel.name
        deviceLabel.layer?.opacity = 0.5
        
        swiftyConstraints()
            .attach(activeControl).height(16).width(16).left().top().bottom().stackLeft()
            .attach(preferredControl).height(16).width(16).left(10).top().bottom().stackLeft()
            .attach(deviceLabel).height(20).left(10).top().stackLeft()
            .attach(volumeControl).middle().width(120).left(20).top().right()
        
        subscribeToViewModel()
        
        return self
    }
    
    private func subscribeToViewModel() {
        guard let viewModel = viewModel else { return }
        
        preferredControl.target = self
        preferredControl.action = #selector(DeviceSelectorView.selectPreferred)
        preferredControl.sendAction(on: NSEvent.EventTypeMask.leftMouseUp)
        
        var indicatorDefault: Variable<Bool>?
        
        if selectorType == .input {
            indicatorDefault = viewModel.isPreferredInput
        }
        if selectorType == .output {
            indicatorDefault = viewModel.isPreferredOutput
        }
        if selectorType == .system {
            indicatorDefault = viewModel.isPreferredSystem
        }
        
        indicatorDefault?.asObservable().subscribe(
            onNext: { [weak self] value in
                self?.preferredControl.isActive = value
            }
        ).disposed(by: disposeBag)
    }
    
    @objc func selectPreferred(_ sender: AnyObject) {
        guard let viewModel = viewModel else { return }
        
        if selectorType == .input {
            viewModel.setAsPreferredInput()
        }
        if selectorType == .output {
            viewModel.setAsPreferredOutput()
        }
        if selectorType == .system {
            viewModel.setAsPreferredSystem()
        }
    }
    
    private func unsubscribeFromViewModel() {
        disposeBag = DisposeBag()
    }
}
