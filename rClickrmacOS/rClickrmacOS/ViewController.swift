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
    var redDotController: RedDotController!
    
    @IBOutlet weak var currentRoomNumberIndicator: NSTextField!
    
    func uploadScreenshot() {
        let screenshot = getCompressedJPEGScreenshot()
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let uuid = UUID().uuidString
        
        let screenshotImageRef = storageRef.child("images/\(uuid).jpg")
        
        _ = screenshotImageRef.putData(screenshot, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                return
            }
            let downloadURL = metadata.downloadURL
            if let downloadURLString = downloadURL()?.absoluteString {
                self.ref.child(self.currentRoomNumber).child("interactive_settings").setValue(["screenshot_url": downloadURLString])
            }
        }
    }

    
    func showRedDotAt(dict: Dictionary<String, Float>) {
        let center = NotificationCenter.default
        center.post(name: NSNotification.Name(rawValue: "shouldMoveRedDot"), object: nil, userInfo: dict)
    }
    
    func getCompressedJPEGScreenshot() -> Data {
        let displayID = CGMainDisplayID()
        let imageRef = CGDisplayCreateImage(displayID)
        let size: NSSize = NSMakeSize(300, 200)
        let nsImage = NSImage.init(cgImage: imageRef!, size: NSZeroSize)
        let resizedImage = nsImage.resizeWhileMaintainingAspectRatioToSize(size: size)
        let cgImage = resizedImage?.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage!)
        let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
        return jpegData
    }
    
    func generateRoomNumber() {
        let result = Int(arc4random_uniform(9000) + 1000)
        currentRoomNumber = "\(result)"
        currentRoomNumberIndicator.stringValue = currentRoomNumber.inserting(separator: " ", every: 1)
    }
    
    override func viewDidAppear() {
        self.view.window?.titlebarAppearsTransparent = true
        self.view.window?.titleVisibility = .hidden
        self.view.window?.styleMask.insert(.fullSizeContentView)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseApp.configure()
        generateRoomNumber()
        ref = Database.database().reference()
        self.ref.child(currentRoomNumber).child("interactive_settings").setValue(["screenshot_url":"http://google.com"])
        
        let childRef = ref.child(currentRoomNumber)
        
        self.redDotController = RedDotController.init()
        self.redDotController.configurateEverything()

        
        _ = childRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            

            for (randomToken, actionDictionary) in postDict {
                if (actionDictionary["wants_new_image"] as? Bool) != nil && (actionDictionary["wants_new_image"] as? Bool) == true {
                    childRef.child(randomToken).child("wants_new_image").setValue(false)
                    self.uploadScreenshot()
                } else {
                    if let coordinates = actionDictionary["highlight_coordinates"] as? Dictionary<String, Float> {
                        self.showRedDotAt(dict: coordinates)
                    }
                    guard let action = actionDictionary["action"] as? String else {
                        break
                    }
                    print("Detected action. Attempting to perform action!")
                    if (action == "keydown") {
                        print("Pressing keydown.")
                        DispatchQueue.main.async {
                            self.simulateKeyPress(0x7D)
                            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (timer) in
                                self.uploadScreenshot()
                            })
                        }
                    } else if (action == "keyup") {
                        print("Pressing keyup.")
                        DispatchQueue.main.async {
                            self.simulateKeyPress(0x7E)
                            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (timer) in
                                self.uploadScreenshot()
                            })
                        }
                    } else if (action == "volumeup") {
                        print("Pressing volup.")
                        DispatchQueue.main.async {
                            self.redDotController.increaseVolume()
                        }
                    } else if (action == "volumedown") {
                        print("Pressing voldown.")
                        DispatchQueue.main.async {
                            self.redDotController.decreaseVolume()
                        }
                    } else if (action == "space") {
                        print("Pressing space.")
                        DispatchQueue.main.async {
                            self.simulateKeyPress(0x31)
                        }
                    } else if (action == "blank") {
                        print("Switching between blackout/no blackout.")
                        self.redDotController.blackoutSwitch()
                    }
                    childRef.child(randomToken).removeValue()
                }
            }
        })
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
    }

    func simulateKeyPress(_ keyCode: Int) {
        let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: true)
        keyDownEvent?.post(tap: CGEventTapLocation.cghidEventTap)
        
        let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: false)
        keyUpEvent?.post(tap: CGEventTapLocation.cghidEventTap)
    }
}

extension String {
    var pairs: [String] {
        var result: [String] = []
        let characters = Array(self.characters)
        stride(from: 0, to: characters.count, by: 2).forEach {
            result.append(String(characters[$0..<min($0+2, characters.count)]))
        }
        return result
    }
    mutating func insert(separator: String, every n: Int) {
        self = inserting(separator: separator, every: n)
    }
    func inserting(separator: String, every n: Int) -> String {
        var result: String = ""
        let characters = Array(self.characters)
        stride(from: 0, to: characters.count, by: n).forEach {
            result += String(characters[$0..<min($0+n, characters.count)])
            if $0+n < characters.count {
                result += separator
            }
        }
        return result
    }
}


