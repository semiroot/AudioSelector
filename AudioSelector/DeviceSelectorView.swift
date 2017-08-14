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
    
    enum SelectorTypes {
        case input
        case output
        case system
    }
    
    private var selectorType = SelectorTypes.output
    private var viewModel: DeviceViewModel?
    
    private let activeControl = RadioControl()
    private let defaultControl = RadioControl()
    
    private var disposeBag = DisposeBag()
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        unsubscribeFromViewModel()
    }
    
    deinit {
        unsubscribeFromViewModel()
    }
    
    public func setup(_ viewModel: DeviceViewModel, _ selectorType: DeviceSelectorView.SelectorTypes) -> DeviceSelectorView{
        self.viewModel = viewModel
        self.selectorType = selectorType
        
        swiftyConstraints()
            .attach(activeControl).height(16).width(16).left().top().bottom().stackLeft()
            .attach(defaultControl).height(16).width(16).left(10).top().bottom().stackLeft()
            .attach(LabelView().withText(viewModel.name)).height(20).left(10).top().right()
        
        subscribeToViewModel()
        
        return self
    }
    
    private func subscribeToViewModel() {
        guard let viewModel = viewModel else { return }
        
        activeControl.target = self
        activeControl.action = #selector(DeviceSelectorView.selectActive)
        activeControl.sendAction(on: .leftMouseUp)
        
        defaultControl.target = self
        defaultControl.action = #selector(DeviceSelectorView.selectDefault)
        defaultControl.sendAction(on: .leftMouseUp)
        
        var indicatorAction: Variable<Bool>?
        var indicatorDefault: Variable<Bool>?
        
        if selectorType == .input {
            indicatorAction = viewModel.isInput
            indicatorDefault = viewModel.isDefaultInput
        }
        if selectorType == .output {
            indicatorAction = viewModel.isOutput
            indicatorDefault = viewModel.isDefaultOutput
        }
        if selectorType == .system {
            indicatorAction = viewModel.isSystem
            indicatorDefault = viewModel.isDefaultSystem
        }
        
        indicatorAction?.asObservable().subscribe(
            onNext: { [weak self] value in
                self?.activeControl.isActive = value
            }
        ).addDisposableTo(disposeBag)
        
        indicatorDefault?.asObservable().subscribe(
            onNext: { [weak self] value in
                self?.defaultControl.isActive = value
            }
        ).addDisposableTo(disposeBag)
    }
    
    func selectActive(_ sender: AnyObject) {
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
    
    func selectDefault(_ sender: AnyObject) {
        guard let viewModel = viewModel else { return }
        
        if selectorType == .input {
            viewModel.setAsDefaultInput()
        }
        if selectorType == .output {
            viewModel.setAsDefaultOutput()
        }
        if selectorType == .system {
            viewModel.setAsDefaultSystem()
        }
    }
    
    private func unsubscribeFromViewModel() {
        disposeBag = DisposeBag()
    }
}
