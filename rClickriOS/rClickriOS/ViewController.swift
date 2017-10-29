//
//  ViewController.swift
//  rClickriOS
//
//  Created by Numeric on 10/28/17.
//  Copyright © 2017 cocappathon. All rights reserved.
//

import UIKit
import FirebaseCommunity
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    var ref: DatabaseReference!
    var currentRoomNumber: String = "0000"
    var panGesture: UIPanGestureRecognizer!
    var actionEnabled: String!
    var audioEnabled = false
    
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var snapshotImageView: UIImageView!
 
    // MARK: Speech Recognition setup
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @IBAction func toggleMicInputPressed(_ sender: Any) {
        if !audioEnabled {
            try? startRecording()
            audioEnabled = true
        } else {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        var swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeUp))
        swipeUp.direction = .up
        volumeView.addGestureRecognizer(swipeUp)
        
        var swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeDown))
        swipeDown.direction = .down
        volumeView.addGestureRecognizer(swipeDown)
    actionEnabled = "None"
        ref.child(currentRoomNumber).child("interactive_settings").child("screenshot_url").observe(.value) { (snapshot) in
            if snapshot.exists() {
                DispatchQueue.global(qos: .background).async {
                    
                    if let snapshotURL = URL(string: snapshot.value as! String) {
                        URLSession.shared.dataTask(with: snapshotURL, completionHandler: { (data, response, error) in
                            
                            if error != nil && data == nil {
                                print("something went wrong with image")
                            } else {
                                DispatchQueue.main.async {
                                    if let uiimage = UIImage(data: data!) as? UIImage {
                                        self.snapshotImageView.image = uiimage
                                        print(self.snapshotImageView.image?.size)
                                    }
                                }
                            }
                            
                            
                        }).resume()
                    }
                }
            }
        }
        
    }
    

    override func viewDidAppear(_ animated: Bool) {
        ref.child(currentRoomNumber).child("interactive_settings").child("wants_new_image").setValue(true)
        
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    print("We're authorized ... starting to record")
                case .denied:
                    print("User denied access to speech recognition")
                case .restricted:
                    print("Speech recognition restricted on this device")
                case .notDetermined:
                    print("Speech recognition not yet authorized")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func prevSlide(_ sender: UIButton?) {
        self.ref.child(currentRoomNumber).childByAutoId().setValue(["timestamp" : Date.init().description, "action": "keyup", "completed": "false"])
    }
    
    @IBAction func nextSlide(_ sender: UIButton?) {
        self.ref.child(currentRoomNumber).childByAutoId().setValue(["timestamp" : Date.init().description, "action": "keydown", "completed": "false"])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if snapshotImageView.frame.contains(touch.location(in: self.view))  && actionEnabled == "pointer" {
                var x = touch.location(in: snapshotImageView).x / snapshotImageView.frame.width
                var y = 1 - (touch.location(in: snapshotImageView).y / snapshotImageView.frame.height)
                print("x:\(x), y:\(y)")
                ref.child(currentRoomNumber).child("interactive_settings").child("highlight_coordinates").updateChildValues(["x" : x, "y" : y])
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            if snapshotImageView.frame.contains(touch.location(in: self.view)) &&  actionEnabled == "pointer" {
                var x = touch.location(in: snapshotImageView).x / snapshotImageView.frame.width
                var y = 1 - (touch.location(in: snapshotImageView).y / snapshotImageView.frame.height)
                print("x:\(x), y:\(y)")
                ref.child(currentRoomNumber).child("interactive_settings").child("highlight_coordinates").updateChildValues(["x" : x, "y" : y])
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if actionEnabled == "pointer" {
            ref.child(currentRoomNumber).child("interactive_settings").child("highlight_coordinates").updateChildValues(["x" : -1, "y" : -1])
        }
        
    }
    
    @IBAction func pointerBtnPressed(_ sender: Any) {
        if actionEnabled != "pointer" {
            actionEnabled = "pointer"
        } else {
            actionEnabled = "None"
        }
    }
    
    
    @IBAction func playPauseBtnPressed(_ sender: Any) {
        
        self.ref.child(currentRoomNumber).childByAutoId().setValue(["timestamp" : Date.init().description, "action": "space", "completed": "false"])
    }
    
    @IBAction func blankBtnPressed(_ sender: Any) {
        self.ref.child(currentRoomNumber).childByAutoId().setValue(["timestamp" : Date.init().description, "action": "blank", "completed": "false"])
    }
    
    @IBAction func forceRefreshImage(_ sender: Any) {
        ref.child(currentRoomNumber).child("interactive_settings").child("wants_new_image").setValue(true)
    }
    
    @objc func swipeUp() {
        self.ref.child(currentRoomNumber).childByAutoId().setValue(["timestamp" : Date.init().description, "action": "volumeup", "completed": "false"])
    }
    
    @objc func swipeDown() {
        self.ref.child(currentRoomNumber).childByAutoId().setValue(["timestamp" : Date.init().description, "action": "volumedown", "completed": "false"])
    }
    
    
    // MARK: Speech Recognition
    private func startRecording() throws {
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode as? AVAudioInputNode else { fatalError("Audio engine has no input node") }
        
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                let segments = result.bestTranscription.segments
                print("segments: \(segments)")
                let array = Array(result.bestTranscription.formattedString.components(separatedBy: " ").reversed())
                var wordSet = Set<String>()
                for i in array {
                    wordSet.insert(i)
                }
                if wordSet.contains("next") || wordSet.contains("previous") || wordSet.contains("Next") || wordSet.contains("Previous")||wordSet.contains("last") || wordSet.contains("Last"){
                    if wordSet.contains("next") || wordSet.contains("Next") {
                        self.nextSlide(nil)
                        print("next")
                    }
                    if wordSet.contains("previous")  || wordSet.contains("Previous") || wordSet.contains("last") || wordSet.contains("Last"){
                        self.prevSlide(nil)
                        print("prev")
                    }
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    
                    try? self.startRecording()
                } else {
                    print("nothing found")
                }
                isFinal = result.isFinal
            }
            

        }
        
        
    }
}

