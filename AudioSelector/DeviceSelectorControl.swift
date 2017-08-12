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


class DeviceSelectorControl: NSButton {
    
    enum SelectorTypes {
        case input
        case output
        case system
    }
    
    private var selectorType = SelectorTypes.output
    private var viewModel: DeviceViewModel?
    
    private let indicatorView = IndicatorView()
    
    private var disposeBag = DisposeBag()
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        unsubscribeFromViewModel()
    }
    
    deinit {
        unsubscribeFromViewModel()
    }
    
    public func setup(_ viewModel: DeviceViewModel, _ selectorType: DeviceSelectorControl.SelectorTypes) -> DeviceSelectorControl{
        self.viewModel = viewModel
        self.selectorType = selectorType
        
        swiftyConstraints()
            .attach(indicatorView).height(16).width(16).left().top().bottom().stackLeft()
            .attach(Label.create(viewModel.name)).height(20).left(5).top().right()
        
        subscribeToViewModel()
        
        self.isBordered = false
        self.title = ""
        
        return self
    }
    
    private func subscribeToViewModel() {
        guard let viewModel = viewModel else { return }
        
        self.target = self
        self.action = #selector(DeviceSelectorControl.selectDevice)
        self.sendAction(on: .leftMouseUp)
        
        var indicatorSource: Variable<Bool>?
        
        if selectorType == .input {
            indicatorSource = viewModel.isMainInput
        }
        if selectorType == .output {
            indicatorSource = viewModel.isMainOutput
        }
        if selectorType == .system {
            indicatorSource = viewModel.isSystemOutput
        }
        
        indicatorSource?.asObservable().subscribe(
            onNext: { [weak self] value in
                self?.indicatorView.isActive = value
            }
        ).addDisposableTo(disposeBag)
    }
    
    func selectDevice(_ sender: AnyObject) {
        guard let viewModel = viewModel else { return }
        
        if selectorType == .input {
            viewModel.setAsInputDevice()
        }
        if selectorType == .output {
            viewModel.setAsOutputDevice()
        }
        if selectorType == .system {
            viewModel.setAsSystemDevice()
        }
    }
    
    private func unsubscribeFromViewModel() {
        disposeBag = DisposeBag()
    }
}
