//
//  DotProjectionWindowController.swift
//  rClickrmacOS
//
//  Created by Numeric on 10/29/17.
//  Copyright © 2017 cocappathon. All rights reserved.
//

import Cocoa

class DotProjectionWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.isOpaque = false
        window?.backgroundColor = NSColor.clear

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

    
}

//class DotProjectionWindow: NSWindow {
//    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
//        super.init(contentRect: contentRect, styleMask: styleMask, backing: backingType, defer: flag)
//    }
//}

