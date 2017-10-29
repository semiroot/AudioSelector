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

    let menuItem = NSStatusBar.system.statusItem(withLength: -2)
    let popover = SelectorPopover()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        if let button = menuItem.button {
            button.image = NSImage(named: NSImage.Name(rawValue: "MenuIcon"))
            button.action = #selector(AppDelegate.togglePopover(_:))
        }
        
        popover.contentViewController =
            NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
                .instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "SelectorViewController"))
            as! SelectorViewController
    }

    func applicationWillTerminate(_ aNotification: Notification) { }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else if let button = menuItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closeApp() {
        NSApp.terminate(self)
    }
}
