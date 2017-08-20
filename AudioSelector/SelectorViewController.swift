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

class SelectorViewController: NSViewController {
    
    let viewModel = SelectorViewModel()
    
    var viewContainerInput = NSView()
    var viewContainerOutput = NSView()
    var viewContainerSystem = NSView()
    
    var disposableViews = [DeviceSelectorView]()
    var disposeBag = DisposeBag()
    
    var buttonClose = NSButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLayout()
    }
    
    override func viewWillAppear() {
        populateLayout()
        subscribeToViewModel()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    override func viewDidDisappear() {
        unsubscribeFromViewModel()
        unpopulateLayout()
    }
    
    override var representedObject: Any? {
        didSet {
            populateLayout()
        }
    }
    
    func createLayout() {
        let constraints = self.view.swiftyConstraints()
        
        buttonClose.bezelStyle = NSRoundedBezelStyle
        buttonClose.title = "Quit"
        buttonClose.target = self
        buttonClose.action = #selector(SelectorViewController.doCloseApp)
        
        constraints
            .attach(RemarkView().withText("Active"))
                .height(10).left(25).top(30)
            .attach(RemarkView().withText("Default"))
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
            
            .attach(buttonClose)
                .top(20).right(20).bottom(20)
        
    }
    
    func populateLayout() {
        unpopulateLayout()
        
        let inputConstraints = viewContainerInput.swiftyConstraints()
        let outputConstraints = viewContainerOutput.swiftyConstraints()
        let systemConstraints = viewContainerSystem.swiftyConstraints()
        
        for deviceViewModel in viewModel.devices.value {
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
        viewModel.devices.asObservable().subscribe(
            onNext: { [weak self] _ in
                self?.populateLayout()
            }
        ).addDisposableTo(disposeBag)
    }
    
    func unsubscribeFromViewModel() {
        disposeBag = DisposeBag()
    }
    
    func doCloseApp(_ sender: AnyObject) {
        guard let delegate = NSApp.delegate as? AppDelegate else { return }
        delegate.closeApp()
    }
}
