//
//  ViewController.swift
//  rClickrmacOS
//
//  Created by Numeric on 10/28/17.
//  Copyright © 2017 cocappathon. All rights reserved.
//

import Cocoa
import FirebaseCommunity
import Carbon.HIToolbox


class ViewController: NSViewController {
    var ref: DatabaseReference!
    var currentRoomNumber: String = "0000"
    
    func generateRoomNumber() {
//        let result = Int(arc4random_uniform(9999))
//        currentRoomNumber = "\(result)"
        currentRoomNumber = "2163"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseApp.configure()
        generateRoomNumber()
        ref = Database.database().reference()
//        self.ref.child(currentRoomNumber).childByAutoId().setValue(["timestamp" : Date.init().description, "action": "keydown", "completed": "false"])
        
        let childRef = ref.child(currentRoomNumber)
        
        let refHandle = childRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            for (randomToken, actionDictionary) in postDict {
                guard let action = actionDictionary["action"] as? String else {
                    break
                }
                print("we are this far now!")
                if (action == "keydown") {
                    print("pressing keydown")
                    DispatchQueue.main.async {
                        self.simulateKeyPress(0x7D)
                    }
                } else if (action == "keyup") {
                    print("pressing keyup")
                    DispatchQueue.main.async {
                        self.simulateKeyPress(0x7E)
                    }
                }
                childRef.child(randomToken).removeValue()
            }
        })
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func simulateKeyPress(_ keyCode: Int) {
        let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: true)
//        keyDownEvent?.flags = CGEventFlags.maskCommand
        keyDownEvent?.post(tap: CGEventTapLocation.cghidEventTap)
        
        let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: false)
//        keyUpEvent?.flags = CGEventFlags.maskCommand
        keyUpEvent?.post(tap: CGEventTapLocation.cghidEventTap)
    }


}

