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
import CustomButton


class DeviceView: NSView {
    
    private var viewModel: DeviceFacade?
    
    private var disposeBag = DisposeBag()
    
    private let preferredControl = CustomButton.createPinButton()
    private let favoriteControl = CustomButton.createFavoriteButton()
    private let volumeControl = NSSlider()
    private let deviceButton = CustomButton.createDeviceButton()
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        unsubscribeFromViewModel()
    }
    
    deinit {
        unsubscribeFromViewModel()
    }
    
    public func setup(_ viewModel: DeviceFacade) -> DeviceView{
        self.viewModel = viewModel
        
        volumeControl.cell = SliderCellView()
        
        addSubview(deviceButton)
        addSubview(preferredControl)
        addSubview(favoriteControl)
        addSubview(volumeControl)
        
        self.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(22)
        }
        
        deviceButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self)
            make.height.equalTo(22)
            make.width.greaterThanOrEqualTo(100)
            make.centerY.equalTo(self)
        }
        
        preferredControl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(deviceButton.snp.left).offset(1)
            make.height.equalTo(20)
            make.width.equalTo(20)
            make.centerY.equalTo(self)
        }
        
        favoriteControl.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(deviceButton.snp.right).offset(-1)
            make.height.equalTo(20)
            make.width.equalTo(20)
            make.centerY.equalTo(self)
        }
        
        volumeControl.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(self)
            make.width.equalTo(150)
            make.left.equalTo(favoriteControl.snp.right).offset(10)
            make.right.equalTo(self)
        }
        
        subscribeToViewModel()
        
        return self
    }
    
    private func subscribeToViewModel() {
        guard let viewModel = viewModel else { return }
        
        deviceButton.target = viewModel
        deviceButton.action = #selector(DeviceFacade.setActive)
        deviceButton.sendAction(on: NSEvent.EventTypeMask.leftMouseUp)
        deviceButton.isEnabled = viewModel.isPresent
        deviceButton.state = viewModel.isActive.value ? .on : .off
        
        favoriteControl.target = viewModel
        favoriteControl.action = #selector(DeviceFacade.setFavorite)
        favoriteControl.sendAction(on: NSEvent.EventTypeMask.leftMouseUp)
        
        preferredControl.target = viewModel
        preferredControl.action = #selector(DeviceFacade.setPreferred)
        preferredControl.sendAction(on: NSEvent.EventTypeMask.leftMouseUp)
        preferredControl.isEnabled = viewModel.isPresent
        
        volumeControl.target = viewModel
        volumeControl.action = #selector(DeviceFacade.setVolume(_:))
        volumeControl.isEnabled = viewModel.isPresent
        
        
        var indicatorVolume: Variable<Float32>?
        var indicatorVolumeActive: Variable<Bool>?
        
        if viewModel.type == .input {
            indicatorVolume = viewModel.volumeIn
            indicatorVolumeActive = viewModel.canChangeVolumeIn
        }
        if viewModel.type == .output {
            indicatorVolume = viewModel.volumeOut
            indicatorVolumeActive = viewModel.canChangeVolumeOut
        }
        if viewModel.type == .system {
            indicatorVolume = viewModel.volumeOut
            indicatorVolumeActive = viewModel.canChangeVolumeOut
        }
        
        viewModel.isActive.asObservable().subscribe(
            onNext: { [weak self] value in
                self?.deviceButton.state = value ? .on : .off
            }
        ).disposed(by: disposeBag)
        
        viewModel.isPreferred.asObservable().subscribe(
            onNext: { [weak self] value in
                self?.preferredControl.state = value ? .on : .off
            }
        ).disposed(by: disposeBag)
    
        viewModel.isFavorite.asObservable().subscribe(
            onNext: { [weak self] value in
                self?.favoriteControl.state = value ? .on : .off
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
                self?.deviceButton.title = value
            }
        ).disposed(by: disposeBag)
    }
    
    private func unsubscribeFromViewModel() {
        disposeBag = DisposeBag()
    }
}
