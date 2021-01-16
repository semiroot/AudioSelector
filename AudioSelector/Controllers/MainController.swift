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
import CustomButton

class MainController: NSViewController {
    
    let facade = MainFacade()
    
    let inputContainer = NSView()
    var inputViews = [NSView]()
    
    let outputContainer = NSView()
    var outputViews = [NSView]()
    
    let systemContainer = NSView()
    var systemViews = [NSView]()
    
    let closeButton = CustomButton.closeButton()
    let passthroughSwitch = NSSwitch()
    let logView = NSTextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = Hub.requests.subscribe(
            onNext: { [weak self] request in
                self?.handleRequests(request)
            }
        )
        createLayout()
    }
    
    override func viewWillAppear() {
        subscribeToViewModel()
        facade.viewWillGetActive()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        logView.currentEditor()?.selectedRange = NSRange()
    }
    
    override func viewDidDisappear() {
        depopulate()
    }
    
    override var representedObject: Any? {
        didSet { populate() }
    }
    
    func createLayout() {
        closeButton.target = self
        closeButton.action = #selector(MainController.closeApp)
                
        passthroughSwitch.target = self
        passthroughSwitch.action = #selector(MainController.togglePassthrough)
        
        logView.focusRingType = .none
        
        /*
        facade.passthroughActive.asObservable().subscribe(
            onNext: { [weak self] value in
                self?.closeButton.state = value ? .on : .off
            }
        ).disposed(by: disposeBag)
        */
        
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(view).offset(2)
            make.top.equalTo(view).offset(10)
        }
        
        let labelIn = TitleView().withText("Input")
        view.addSubview(labelIn)
        labelIn.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(14)
            make.right.equalTo(view).offset(-10)
            make.top.equalTo(view).offset(20)
        }
        
        view.addSubview(inputContainer)
        inputContainer.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(view).offset(10)
            make.right.equalTo(view).offset(-10)
            make.top.equalTo(labelIn.snp.bottom)
        }
        
        let labelOut = TitleView().withText("Output")
        view.addSubview(labelOut)
        labelOut.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(14)
            make.right.equalTo(view).offset(-10)
            make.top.equalTo(inputContainer.snp.bottom).offset(10)
        }
        
        view.addSubview(outputContainer)
        outputContainer.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(view).offset(10)
            make.right.equalTo(view).offset(-10)
            make.top.equalTo(labelOut.snp.bottom)
        }

        let labelSystem = TitleView().withText("System")
        view.addSubview(labelSystem)
        labelSystem.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(14)
            make.right.equalTo(view).offset(-10)
            make.top.equalTo(outputContainer.snp.bottom).offset(10)
        }
        
        view.addSubview(systemContainer)
        systemContainer.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(view).offset(10)
            make.right.equalTo(view).offset(-10)
            make.top.equalTo(labelSystem.snp.bottom)
            make.bottom.equalTo(view).offset(-10)
        }
        
        /*
        
        view.addSubview(passthroughSwitch)
        passthroughSwitch.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(view).offset(10)
            make.top.equalTo(systemContainer.snp.bottom).offset(20)
            make.bottom.equalTo(view).offset(-10)
        }
         
        let labelPassthrough = LabelView()
        labelPassthrough.stringValue = "Pass input audio to to output device"
        view.addSubview(labelPassthrough)
        labelPassthrough.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(passthroughSwitch.snp.right).offset(10)
            make.centerY.equalTo(passthroughSwitch.snp.centerY)
        }
        */
                
        #if DEBUG
        /*
            buttonPassthrough.snp.removeConstraints()
            buttonPassthrough.snp.makeConstraints { (make) -> Void in
                make.left.equalTo(view).offset(10)
                make.top.equalTo(viewContainerSystem.snp.bottom).offset(20)
            }
        
            view.addSubview(logView)
            logView.snp.makeConstraints { (make) -> Void in
                make.height.equalTo(300)
                make.width.equalTo(1200)
                make.left.equalTo(view).offset(10)
                make.right.equalTo(view).offset(-10)
                make.bottom.equalTo(view).offset(-10)
                make.top.equalTo(buttonPassthrough).offset(40)
            }
        */
        #endif
    }
    
    func depopulate() {
        depopulateInput()
        depopulateOutput()
        depopulateSystem()
    }
    
    func depopulateInput() {
        inputViews.forEach { $0.removeFromSuperview() }
        inputViews.removeAll()
    }
    
    func depopulateOutput() {
        outputViews.forEach { $0.removeFromSuperview() }
        outputViews.removeAll()
    }
    
    func depopulateSystem() {
        systemViews.forEach { $0.removeFromSuperview() }
        systemViews.removeAll()
    }
    
    func populate() {
        populateInput()
        populateOutput()
        populateSystem()
    }
    
    func populateInput() {
        depopulateInput()
        
        var previousInputEdge = inputContainer.snp.top
        var previousInputItem : NSView?
        
        for deviceViewModel in facade.inputFacades {
            let inputControl = DeviceView().setup(deviceViewModel)
            inputViews.append(inputControl)
            inputContainer.addSubview(inputControl)
            inputControl.snp.makeConstraints { (make) -> Void in
                make.left.equalTo(inputContainer)
                make.right.equalTo(inputContainer)
                make.top.equalTo(previousInputEdge).offset(5)
            }
            previousInputItem = inputControl
            previousInputEdge = inputControl.snp.bottom
        }
        
        previousInputItem?.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(inputContainer)
        }
    }
    
    func populateOutput() {
        depopulateOutput()
        
        var previousOutputEdge = outputContainer.snp.top
        var previousOutputItem : NSView?
        
        for deviceViewModel in facade.outputFacades {
            let outputControl = DeviceView().setup(deviceViewModel)
            outputViews.append(outputControl)
            outputContainer.addSubview(outputControl)
            outputControl.snp.makeConstraints { (make) -> Void in
                make.left.equalTo(outputContainer)
                make.right.equalTo(outputContainer)
                make.top.equalTo(previousOutputEdge).offset(5)
            }
            previousOutputItem = outputControl
            previousOutputEdge = outputControl.snp.bottom
        }
        
        previousOutputItem?.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(outputContainer)
        }
    }
    
    func populateSystem() {
        depopulateSystem()
        
        var previousSystemEdge = systemContainer.snp.top
        var previousSystemItem : NSView?
        
        for deviceViewModel in facade.systemFacades {
            let systemControl = DeviceView().setup(deviceViewModel)
            systemViews.append(systemControl)
            systemContainer.addSubview(systemControl)
            systemControl.snp.makeConstraints { (make) -> Void in
                make.left.equalTo(systemContainer)
                make.right.equalTo(systemContainer)
                make.top.equalTo(previousSystemEdge).offset(5)
            }
            previousSystemItem = systemControl
            previousSystemEdge = systemControl.snp.bottom
        }
        
        previousSystemItem?.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(systemContainer)
        }
    }
    
    func handleRequests(_ request: Message) {
        switch request {
            case .populate:
                populate()
                break
            case .log(let content):
                logView.stringValue = "\(content)\n\(logView.stringValue)"
                logView.currentEditor()?.selectedRange = NSRange()
                break
            default: break
        }
    }
    
    func subscribeToViewModel() {
        
        _ = facade.passthroughActive.asObservable().subscribe(
            onNext: { [weak self] state in
                self?.passthroughSwitch.state = state ? .on : .off
            }
        )
        
    }
    
    @objc func togglePassthrough(_ sender: AnyObject) {
        Hub.request(.togglePassthrough)
    }
    
    @objc func closeApp(_ sender: AnyObject) {
        guard let delegate = NSApp.delegate as? AppDelegate else { return }
        delegate.closeApp()
    }
}
