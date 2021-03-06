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


class DeviceSelectorView: NSView {
    
    private var selectorType = SelectorTypes.output
    private var viewModel: DeviceViewModel?
    
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
    
    public func setup(_ viewModel: DeviceViewModel, _ selectorType: SelectorTypes) -> DeviceSelectorView{
        self.viewModel = viewModel
        self.selectorType = selectorType
        
        addSubview(activeControl)
        addSubview(preferredControl)
        addSubview(deviceLabel)
        addSubview(volumeControl)
        
        self.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(22)
        }
        
        activeControl.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(16)
            make.height.equalTo(16)
            make.left.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.centerY.equalTo(self)
        }
        
        preferredControl.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(16)
            make.width.equalTo(16)
            make.left.equalTo(activeControl.snp.right).offset(10)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.centerY.equalTo(self)

        }
        
        deviceLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(preferredControl.snp.right).offset(10)
            make.top.equalTo(self).offset(3)
            make.bottom.equalTo(self)
        }
        
        volumeControl.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(self)
            make.width.equalTo(200)
            make.height.equalTo(22)
            make.left.equalTo(deviceLabel.snp.right).offset(10)
            make.right.equalTo(self)
            make.top.equalTo(self)
        }
        
        subscribeToViewModel()
        
        return self
    }
    
    private func subscribeToViewModel() {
        guard let viewModel = viewModel else { return }
        
        activeControl.target = self
        activeControl.action = #selector(DeviceSelectorView.selectActive)
        activeControl.sendAction(on: NSEvent.EventTypeMask.leftMouseUp)
        activeControl.isEnabled = viewModel.isPresent
        
        preferredControl.target = self
        preferredControl.action = #selector(DeviceSelectorView.selectPreferred)
        preferredControl.sendAction(on: NSEvent.EventTypeMask.leftMouseUp)
        preferredControl.isEnabled = viewModel.isPresent
        
        volumeControl.target = self
        volumeControl.action = #selector(DeviceSelectorView.changeVolume(_:))
        volumeControl.isEnabled = viewModel.isPresent
        
        var indicatorAction: Variable<Bool>?
        var indicatorDefault: Variable<Bool>?
        var indicatorVolume: Variable<Float32>?
        var indicatorVolumeActive: Variable<Bool>?
        
        if selectorType == .input {
            indicatorAction = viewModel.isInput
            indicatorDefault = viewModel.isPreferredInput
            indicatorVolume = viewModel.volumeIn
            indicatorVolumeActive = viewModel.canChangeVolumeIn
        }
        if selectorType == .output {
            indicatorAction = viewModel.isOutput
            indicatorDefault = viewModel.isPreferredOutput
            indicatorVolume = viewModel.volumeOut
            indicatorVolumeActive = viewModel.canChangeVolumeOut
        }
        if selectorType == .system {
            indicatorAction = viewModel.isSystem
            indicatorDefault = viewModel.isPreferredSystem
            indicatorVolume = viewModel.volumeOut
            indicatorVolumeActive = viewModel.canChangeVolumeOut
        }
        
        indicatorAction?.asObservable().subscribe(
            onNext: { [weak self] value in
                self?.activeControl.isActive = value
            }
            ).disposed(by: disposeBag)
        
        indicatorDefault?.asObservable().subscribe(
            onNext: { [weak self] value in
                self?.preferredControl.isActive = value
            }
            ).disposed(by: disposeBag)
        
        indicatorVolume?.asObservable().subscribe(
            onNext: { [weak self] value in
                self?.volumeControl.floatValue = value as Float
            }
            ).disposed(by: disposeBag)
        
        indicatorVolumeActive?.asObservable().subscribe(
            onNext: { [weak self] value in
                self?.volumeControl.isEnabled = value
            }
            ).disposed(by: disposeBag)
        
        viewModel.displayName.asObservable().subscribe(
            onNext: {[weak self] value in
                self?.deviceLabel.stringValue = value
            }
            ).disposed(by: disposeBag)
    }
    
    @objc func selectActive(_ sender: AnyObject) {
        guard let viewModel = viewModel else { return }
        
        if selectorType == .input {
            viewModel.setAsInput()
        }
        if selectorType == .output {
            viewModel.setAsOutput()
        }
        if selectorType == .system {
            viewModel.setAsSystem()
        }
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
    
    @objc func changeVolume(_ sender: NSSlider) {
        guard let viewModel = viewModel else { return }
        
        if selectorType == .input {
            viewModel.setVolumeIn(sender.floatValue as Float32)
        }
        if selectorType == .output {
            viewModel.setVolumeOut(sender.floatValue as Float32)
        }
        if selectorType == .system {
            viewModel.setVolumeOut(sender.floatValue as Float32)
        }
    }
    
    private func unsubscribeFromViewModel() {
        disposeBag = DisposeBag()
    }
}
