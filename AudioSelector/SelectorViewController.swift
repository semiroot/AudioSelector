//
//  SelectorViewController.swift
//  AudioSelector
//
//  Created by Semiotikus on 11.08.17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa
import SnapKit
import AudioKit

class SelectorViewController: NSViewController {
    
    let viewContainerInput = NSView()
    let viewContainerOutput = NSView()
    let viewContainerSystem = NSView()
    let buttonClose = ButtonControl().withText("Quit")
    let checkboxPassthrough: CheckboxControl = CheckboxControl()
    let buttonPassthrough = Control().withText("Pass input to output")
    let logView = NSTextField()
    
    var disposableViews = [NSView]()
    var disposeBag = DisposeBag()
    
    let viewModel = SelectorViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLayout()
    }
    
    override func viewWillAppear() {
        subscribeToViewModel()
        viewModel.viewWillGetActive()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.logView.currentEditor()?.selectedRange = NSRange()
    }
    
    override func viewDidDisappear() {
        unsubscribeFromViewModel()
        unpopulateLayout()
        viewModel.viewDidGetInactive()
    }
    
    override var representedObject: Any? {
        didSet {
            populateLayout()
        }
    }
    
    func createLayout() {
        
        buttonClose.target = self
        buttonClose.action = #selector(SelectorViewController.doCloseApp)
        
        checkboxPassthrough.target = self
        checkboxPassthrough.action = #selector(SelectorViewController.togglePassthrough)
        
        buttonPassthrough.target = self
        buttonPassthrough.action = #selector(SelectorViewController.togglePassthrough)
        
        logView.focusRingType = .none
        
        viewModel.passthroughActive.asObservable().subscribe(
            onNext: { [weak self] value in
                self?.checkboxPassthrough.isActive = value
            }
        ).disposed(by: disposeBag)
        
        
        let labelActive = RemarkView().withText("  Active")
        self.view.addSubview(labelActive)
        labelActive.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(10)
            make.left.equalTo(self.view).offset(22)
            make.top.equalTo(self.view).offset(32)
        }
        
        let labelPreferred = RemarkView().withText("  Preferred")
        self.view.addSubview(labelPreferred)
        labelPreferred.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(10)
            make.left.equalTo(self.view).offset(52)
            make.top.equalTo(self.view).offset(32)
        }
        
        let labelIn = TitleView().withText("Input")
        self.view.addSubview(labelIn)
        labelIn.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(14)
            make.right.equalTo(self.view).offset(-20)
            make.top.equalTo(self.view).offset(30)
        }
        
        self.view.addSubview(viewContainerInput)
        viewContainerInput.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.view).offset(20)
            make.right.equalTo(self.view).offset(-20)
            make.top.equalTo(labelIn.snp.bottom)
        }
        
        let labelOut = TitleView().withText("Output")
        self.view.addSubview(labelOut)
        labelOut.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(14)
            make.right.equalTo(self.view).offset(-20)
            make.top.equalTo(viewContainerInput.snp.bottom).offset(25)
        }
        
        self.view.addSubview(viewContainerOutput)
        viewContainerOutput.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.view).offset(20)
            make.right.equalTo(self.view).offset(-20)
            make.top.equalTo(labelOut.snp.bottom)
        }

        let labelSystem = TitleView().withText("System")
        self.view.addSubview(labelSystem)
        labelSystem.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(14)
            make.right.equalTo(self.view).offset(-20)
            make.top.equalTo(viewContainerOutput.snp.bottom).offset(25)
        }
        
        self.view.addSubview(viewContainerSystem)
        viewContainerSystem.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.view).offset(20)
            make.right.equalTo(self.view).offset(-20)
            make.top.equalTo(labelSystem.snp.bottom)
        }
        
        self.view.addSubview(checkboxPassthrough)
        checkboxPassthrough.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(16)
            make.width.equalTo(16)
            make.left.equalTo(self.view).offset(20)
            make.top.equalTo(viewContainerSystem.snp.bottom).offset(20)
        }
        
        self.view.addSubview(buttonPassthrough)
        buttonPassthrough.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(16)
            make.left.equalTo(checkboxPassthrough.snp.right).offset(5)
            make.top.equalTo(checkboxPassthrough)
        }
        
        var preView: NSView = buttonPassthrough
        
        #if DEBUG
            self.view.addSubview(logView)
            preView = logView
            logView.snp.makeConstraints { (make) -> Void in
                make.height.equalTo(300)
                make.width.equalTo(600)
                make.left.equalTo(self.view).offset(20)
                make.right.equalTo(self.view).offset(-20)
                make.top.equalTo(buttonPassthrough.snp.bottom).offset(20)
            }
        #endif
        
        self.view.addSubview(buttonClose)
        buttonClose.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(self.view).offset(-20)
            make.top.equalTo(preView.snp.bottom).offset(20)
            make.bottom.equalTo(self.view).offset(-20)
        }
    }
    
    func populateLayout() {
        unpopulateLayout()
        
        var previousInputEdge = viewContainerInput.snp.top
        var previousInputItem : NSView?
        var previousOutputEdge = viewContainerOutput.snp.top
        var previousOutputItem : NSView?
        var previousSystemEdge = viewContainerSystem.snp.top
        var previousSystemItem : NSView?
        
        for deviceViewModel in viewModel.deviceViewModels.value {
            if deviceViewModel.isInputDevice {
                let inputControl = DeviceSelectorView().setup(deviceViewModel, .input)
                disposableViews.append(inputControl)
                viewContainerInput.addSubview(inputControl)
                inputControl.snp.makeConstraints { (make) -> Void in
                    make.left.equalTo(viewContainerInput)
                    make.right.equalTo(viewContainerInput)
                    make.top.equalTo(previousInputEdge).offset(5)
                }
                previousInputItem = inputControl
                previousInputEdge = inputControl.snp.bottom
            }
            if deviceViewModel.isOutputDevice {
                let outputControl = DeviceSelectorView().setup(deviceViewModel, .output)
                disposableViews.append(outputControl)
                viewContainerOutput.addSubview(outputControl)
                outputControl.snp.makeConstraints { (make) -> Void in
                    make.left.equalTo(viewContainerOutput)
                    make.right.equalTo(viewContainerOutput)
                    make.top.equalTo(previousOutputEdge).offset(5)
                }
                previousOutputItem = outputControl
                previousOutputEdge = outputControl.snp.bottom
                
                let systemControl = DeviceSelectorView().setup(deviceViewModel, .system)
                disposableViews.append(systemControl)
                viewContainerSystem.addSubview(systemControl)
                systemControl.snp.makeConstraints { (make) -> Void in
                    make.left.equalTo(viewContainerSystem)
                    make.right.equalTo(viewContainerSystem)
                    make.top.equalTo(previousSystemEdge).offset(5)
                }
                previousSystemItem = systemControl
                previousSystemEdge = systemControl.snp.bottom
            }
        }
        
        if let vm = viewModel.unavalablePreferredInputViewModel {
            let inputPreferred = DeviceUnavailableSelectorView().setup(vm, .input)
            disposableViews.append(inputPreferred)
            viewContainerInput.addSubview(inputPreferred)
            inputPreferred.snp.makeConstraints { (make) -> Void in
                make.left.equalTo(viewContainerInput)
                make.right.equalTo(viewContainerInput)
                make.top.equalTo(previousInputEdge).offset(5)
            }
            previousInputItem = inputPreferred
            previousInputEdge = inputPreferred.snp.bottom
        }
        
        if let vm = viewModel.unavalablePreferredOutputViewModel {
            let outputPreferred = DeviceUnavailableSelectorView().setup(vm, .output)
            disposableViews.append(outputPreferred)
            viewContainerOutput.addSubview(outputPreferred)
            outputPreferred.snp.makeConstraints { (make) -> Void in
                make.left.equalTo(viewContainerOutput)
                make.right.equalTo(viewContainerOutput)
                make.top.equalTo(previousOutputEdge).offset(5)
            }
            previousOutputItem = outputPreferred
            previousOutputEdge = outputPreferred.snp.bottom
        }
        
        if let vm = viewModel.unavalablePreferredSystemViewModel {
            let systemPreferred = DeviceUnavailableSelectorView().setup(vm, .system)
            disposableViews.append(systemPreferred)
            viewContainerSystem.addSubview(systemPreferred)
            systemPreferred.snp.makeConstraints { (make) -> Void in
                make.left.equalTo(viewContainerSystem)
                make.right.equalTo(viewContainerSystem)
                make.top.equalTo(previousSystemEdge).offset(5)
            }
            previousSystemItem = systemPreferred
            previousSystemEdge = systemPreferred.snp.bottom
        }
        
        
        previousInputItem?.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(viewContainerInput)
        }
        previousOutputItem?.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(viewContainerOutput)
        }
        previousSystemItem?.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(viewContainerSystem)
        }
    }
    
    func unpopulateLayout() {
        for view in disposableViews {
            view.removeFromSuperview()
        }
        disposableViews = [DeviceSelectorView]()
    }
    
    func subscribeToViewModel() {
        viewModel.deviceViewModels.asObservable().subscribe(
            onNext: { [weak self] _ in
                self?.populateLayout()
            }
        ).disposed(by: disposeBag)
        
        Logger.shared.entries.asObservable().subscribe(
            onNext: { [weak self] entries in
                self?.logView.stringValue = entries
                self?.logView.currentEditor()?.selectedRange = NSRange()
            }
        ).disposed(by: disposeBag)
        
        viewModel.passthroughActive.asObservable().subscribe(
            onNext: { [weak self] state in
                self?.checkboxPassthrough.isActive = state
            }
        ).disposed(by: disposeBag)
    }
    
    func unsubscribeFromViewModel() {
        disposeBag = DisposeBag()
    }
    
    @objc func togglePassthrough(_ sender: AnyObject) {
        viewModel.handlInterfaceAction(.togglePassthrough, nil)
    }
    
    @objc func doCloseApp(_ sender: AnyObject) {
        guard let delegate = NSApp.delegate as? AppDelegate else { return }
        delegate.closeApp()
    }
}
