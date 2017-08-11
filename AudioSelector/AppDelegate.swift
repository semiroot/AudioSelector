//
//  AppDelegate.swift
//  AudioSelector
//
//  Created by Semiotikus on 11.08.17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system().statusItem(withLength: -2)
    let popover = NSPopover()
    var eventMonitor: EventMonitor?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named: "MenuIcon")
            button.action = #selector(AppDelegate.togglePopover(_:))
        }
        
        popover.contentViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "SelectorViewController") as! SelectorViewController
        
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [unowned self] event in
            if self.popover.isShown {
                self.hidePopover(event)
            }
        }
        eventMonitor?.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) { }
    
    func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            hidePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    func showPopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
        eventMonitor?.start()
    }
    
    func hidePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }


}

