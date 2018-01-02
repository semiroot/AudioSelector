//
//  DeviceView.swift
//  AudioSelector
//
//  Created by Semiotikus on 12.08.17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

import Cocoa
import SnapKit
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
        
        addSubview(activeControl)
        addSubview(preferredControl)
        addSubview(deviceLabel)
        addSubview(volumeControl)
        
        activeControl.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(16)
            make.height.equalTo(16)
            make.left.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
        }
        
        preferredControl.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(16)
            make.width.equalTo(16)
            make.left.equalTo(activeControl.snp.right).offset(10)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
        }
        
        deviceLabel.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(20)
            make.left.equalTo(preferredControl.snp.right).offset(10)
            make.top.equalTo(self)
        }
        
        volumeControl.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(self)
            make.width.equalTo(120)
            make.left.equalTo(deviceLabel.snp.right).offset(10)
            make.right.equalTo(self)
            make.top.equalTo(self)
        }
        
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
