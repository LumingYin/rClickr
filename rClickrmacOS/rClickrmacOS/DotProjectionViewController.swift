//
//  DotProjectionViewController.swift
//  rClickrmacOS
//
//  Created by Numeric on 10/29/17.
//  Copyright © 2017 cocappathon. All rights reserved.
//

import Cocoa

class DotProjectionViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        view.window?.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    func drawRedDotAt() {
        
    }
    
    func drawDimViewExcluding() {
        
    }
}
