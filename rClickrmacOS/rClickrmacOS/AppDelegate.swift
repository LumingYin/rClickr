//
//  AppDelegate.swift
//  rClickrmacOS
//
//  Created by Numeric on 10/28/17.
//  Copyright © 2017 cocappathon. All rights reserved.
//

import Cocoa
import FirebaseCommunity


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        FirebaseApp.configure()

        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

