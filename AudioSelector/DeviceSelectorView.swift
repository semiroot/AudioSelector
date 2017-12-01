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
