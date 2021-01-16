//
//  SelectorPopover.swift
//  AudioSelector
//
//  Created by Semiotikus on 12.08.17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

import Cocoa

class PopoverWindow: NSPopover {
    
    fileprivate var globalMonitor: AnyObject?
    
    override func show(relativeTo positioningRect: NSRect, of positioningView: NSView, preferredEdge: NSRectEdge) {
        Hub.log("subscribeMonitor by show shown=\(self.isShown) monitor=\(self.globalMonitor != nil)")
        Hub.log("positioningRect=\(positioningRect) positioningView=\(positioningView) preferredEdge=\(preferredEdge)")
        super.show(relativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge)
        super.becomeFirstResponder()
        self.subscribeMonitor()
    }
    
    override func performClose(_ sender: Any?) {
        Hub.log("unsubscribeMonitor by performClose shown=\(self.isShown) monitor=\(self.globalMonitor != nil)")
        super.performClose(sender)
        self.unsubscribeMonitor()
    }
    
    deinit {
        Hub.log("unsubscribeMonitor by deinit shown=\(self.isShown) monitor=\(self.globalMonitor != nil)")
        self.unsubscribeMonitor()
    }
    
    fileprivate func subscribeMonitor() {
        self.globalMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [NSEvent.EventTypeMask.leftMouseDown, NSEvent.EventTypeMask.rightMouseDown],
            handler: self.handleMonitoredEvent
        ) as AnyObject?
    }
    
    fileprivate func unsubscribeMonitor() {
        if globalMonitor != nil {
            NSEvent.removeMonitor(globalMonitor!)
            globalMonitor = nil
        }
    }
    
    fileprivate func handleMonitoredEvent(_ event: NSEvent?) {
        Hub.log("handleMonitoredEvent with shown=\(self.isShown) monitor=\(self.globalMonitor != nil)")
        if self.isShown {
            self.performClose(self)
        }
    }
}
