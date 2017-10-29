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
    @IBOutlet weak var currentRoomNumberIndicator: NSTextField!
    
    @IBAction func takeScreenshot(_ sender: NSButton) {
        let screenshot = getCompressedJPEGScreenshot()
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let uuid = UUID().uuidString

        let screenshotImageRef = storageRef.child("images/\(uuid).jpg")
        
        let uploadTask = screenshotImageRef.putData(screenshot, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            let downloadURL = metadata.downloadURL
            if let downloadURLString = downloadURL()?.absoluteString {
                self.ref.child(self.currentRoomNumber).child("interactive_settings").setValue(["screenshot_url": downloadURLString])
            }
        }

//        do {
//            try jpegData.write(to: URL.init(fileURLWithPath: "/tmp/thumb.jpg"), options: .atomic)
//        } catch {
//            print("debug write failed")
//        }
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
        let result = Int(arc4random_uniform(9999))
        currentRoomNumber = "\(result)"
        currentRoomNumberIndicator.stringValue = currentRoomNumber.inserting(separator: " ", every: 1)
//        currentRoomNumber = "2163"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseApp.configure()
        generateRoomNumber()
        ref = Database.database().reference()
        self.ref.child(currentRoomNumber).child("interactive_settings").setValue(["screenshot_url":"http://google.com"])
        
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
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
//        if let fullScreenWindow = NSStoryboard.init(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "DotProjectionWindow")) as? DotProjectionWindowController {
//            fullScreenWindow.showWindow(nil)
//        }
        let test_panel = NSPanel.init(contentRect: NSMakeRect(300, 300, 500, 500), styleMask: NSWindow.StyleMask(rawValue: NSWindow.StyleMask.RawValue(UInt8(NSWindow.StyleMask.titled.rawValue) | UInt8(NSWindow.StyleMask.closable.rawValue))), backing: .buffered, defer: true)
        test_panel.isReleasedWhenClosed = true
        test_panel.hidesOnDeactivate = false
        test_panel.isFloatingPanel = true
        test_panel.styleMask = NSWindow.StyleMask(rawValue: NSWindow.StyleMask.RawValue(UInt8(NSWindow.StyleMask.borderless.rawValue) | UInt8(NSPanel.StyleMask.nonactivatingPanel.rawValue)))
        test_panel.level = NSWindow.Level(rawValue: NSWindow.Level.RawValue(kCGMainMenuWindowLevel - 1))
//        test_panel.collectionBehavior = UInt8(NSWindow.CollectionBehavior.canJoinAllSpaces.rawValue) | NSWindow.CollectionBehavior.fullScreenAuxiliary
//        test_panel.c
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

    func TakeScreensShots(folderName: String){
        
        var displayCount: UInt32 = 0;
        var result = CGGetActiveDisplayList(0, nil, &displayCount)
        if (result != CGError.success) {
            print("error: \(result)")
            return
        }
        let allocated = Int(displayCount)
        let activeDisplays = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: allocated)
        result = CGGetActiveDisplayList(displayCount, activeDisplays, &displayCount)
        
        if (result != CGError.success) {
            print("error: \(result)")
            return
        }
        
        for i in 1...displayCount {
            let unixTimestamp = CreateTimeStamp()
            let fileUrl = URL(fileURLWithPath: folderName + "\(unixTimestamp)" + "_" + "\(i)" + ".jpg", isDirectory: true)
            let screenShot:CGImage = CGDisplayCreateImage(activeDisplays[Int(i-1)])!
            let bitmapRep = NSBitmapImageRep(cgImage: screenShot)
            let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
            
            
            do {
                try jpegData.write(to: fileUrl, options: .atomic)
            }
            catch {print("error: \(error)")}
        }
    }
    
    func CreateTimeStamp() -> Int32
    {
        return Int32(Date().timeIntervalSince1970)
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


