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
import SwiftyConstraints
import AudioKit

class SelectorViewController: NSViewController {
    
    let viewContainerInput = NSView()
    let viewContainerOutput = NSView()
    let viewContainerSystem = NSView()
    let buttonClose = ButtonControl().withText("Quit")
    let checkboxPassthrough: CheckboxControl = CheckboxControl()
    let buttonPassthrough = Control().withText("Pass input to output")
    let logView = NSTextField()
    
    var disposableViews = [DeviceSelectorView]()
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
        let constraints = self.view.swiftyConstraints()
        
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
        
        constraints
            .attach(RemarkView().withText("Active"))
                .height(10).left(25).top(30)
            .attach(RemarkView().withText("Prefered"))
                .height(10).left(55).top(30)
            
            .attach(TitleView().withText("Main in"))
                .height(14).right(20).top(30).stackTop()
            .attach(viewContainerInput)
                .left(20).top().right(20).stackTop()
            
            .attach(TitleView().withText("Main out"))
                .right(20).top(5).stackTop()
            .attach(viewContainerOutput)
                .left(20).top().right(20).stackTop()
            
            .attach(TitleView().withText("System out"))
                .height(14).right(20).top(5).stackTop()
            .attach(viewContainerSystem)
                .left(20).top().right(20).stackTop()
            
            .attach(checkboxPassthrough)
                .height(16).width(16).left(20).top(20).stackLeft()
            .attach(buttonPassthrough)
                .height(16).left(5).top(20).stackTop().resetStackLeft()
            
            .attach(logView)
                .height(300).width(600).left(20).right(20).top(20).stackTop()
            
            .attach(buttonClose)
                .top(20).right(20).bottom(20)
        
        
    }
    
    func populateLayout() {
        unpopulateLayout()
        
        let inputConstraints = viewContainerInput.swiftyConstraints()
        let outputConstraints = viewContainerOutput.swiftyConstraints()
        let systemConstraints = viewContainerSystem.swiftyConstraints()
        
        for deviceViewModel in viewModel.deviceViewModels.value {
            if deviceViewModel.isInputDevice {
                let inputControl = DeviceSelectorView().setup(deviceViewModel, .input)
                disposableViews.append(inputControl)
                inputConstraints.attach(inputControl).left().right().top(5).stackTop()
            }
            if deviceViewModel.isOutputDevice {
                let outputControl = DeviceSelectorView().setup(deviceViewModel, .output)
                disposableViews.append(outputControl)
                outputConstraints.attach(outputControl).left().right().top(5).stackTop()
                
                let systemControl = DeviceSelectorView().setup(deviceViewModel, .system)
                disposableViews.append(systemControl)
                systemConstraints.attach(systemControl).left().right().top(5).stackTop()
            }
        }
        inputConstraints.bottom()
        outputConstraints.bottom()
        systemConstraints.bottom()
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
