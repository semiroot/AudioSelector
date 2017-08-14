//
//  SelectorPopover.swift
//  AudioSelector
//
//  Created by Semiotikus on 12.08.17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

import Cocoa

class SelectorPopover: NSPopover {
    
    fileprivate var globalMonitor: AnyObject?
    
    override func show(relativeTo positioningRect: NSRect, of positioningView: NSView, preferredEdge: NSRectEdge) {
        Swift.print("subscribeMonitor by show shown=\(self.isShown) monitor=\(self.globalMonitor != nil)")
        Swift.print("positioningRect=\(positioningRect) positioningView=\(positioningView) preferredEdge=\(preferredEdge)")
        super.show(relativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge)
        self.subscribeMonitor()
    }
    
    override func performClose(_ sender: Any?) {
        Swift.print("unsubscribeMonitor by performClose shown=\(self.isShown) monitor=\(self.globalMonitor != nil)")
        super.performClose(sender)
        self.unsubscribeMonitor()
    }
    
    deinit {
        Swift.print("unsubscribeMonitor by deinit shown=\(self.isShown) monitor=\(self.globalMonitor != nil)")
        self.unsubscribeMonitor()
    }
    
    fileprivate func subscribeMonitor() {
        self.globalMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown],
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
        Swift.print("handleMonitoredEvent with shown=\(self.isShown) monitor=\(self.globalMonitor != nil)")
        if self.isShown {
            self.performClose(self)
        }
    }
}
