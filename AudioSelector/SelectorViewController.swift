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
    
    var disposableViews = [DeviceSelectorControl]()
    var disposeBag = DisposeBag()
    
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
        for view in disposableViews {
            view.sizeToFit()
        }
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
        
        constraints
            .attach(Label.create("Input devices:"))
                .height(20).left(20).top(20).right(20).stackTop()
            .attach(viewContainerInput)
                .left(20).top().right(20).stackTop()
            .attach(Label.create("Output devices:"))
                .height(20).left(20).top(20).right(20).stackTop()
            .attach(viewContainerOutput)
                .left(20).top().right(20).stackTop()
            .attach(Label.create("System output devices:"))
                .height(20).left(20).top(20).right(20).stackTop()
            .attach(viewContainerSystem)
                .left(20).top().right(20).stackTop().bottom(20)
        
    }
    
    func populateLayout() {
        unpopulateLayout()
        
        let inputConstraints = viewContainerInput.swiftyConstraints()
        let outputConstraints = viewContainerOutput.swiftyConstraints()
        let systemConstraints = viewContainerSystem.swiftyConstraints()
        
        for deviceViewModel in viewModel.devices.value {
            if deviceViewModel.isInputDevice {
                let inputControl = DeviceSelectorControl().setup(deviceViewModel, .input)
                disposableViews.append(inputControl)
                inputConstraints.attach(inputControl).left().right().top(5).stackTop()
            }
            if deviceViewModel.isOutputDevice {
                let outputControl = DeviceSelectorControl().setup(deviceViewModel, .output)
                disposableViews.append(outputControl)
                outputConstraints.attach(outputControl).left().right().top(5).stackTop()
                
                let systemControl = DeviceSelectorControl().setup(deviceViewModel, .system)
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
        disposableViews = [DeviceSelectorControl]()
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
}
