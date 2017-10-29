//
//  ViewController.swift
//  rClickriOS
//
//  Created by Numeric on 10/28/17.
//  Copyright © 2017 cocappathon. All rights reserved.
//

import UIKit
import FirebaseCommunity

class ViewController: UIViewController {
    
    var ref: DatabaseReference!
    var currentRoomNumber: String = "0000"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func prevSlide(_ sender: UIButton) {
        self.ref.child(currentRoomNumber).childByAutoId().setValue(["timestamp" : Date.init().description, "action": "keydown", "completed": "false"])
    }
    
    @IBAction func nextSlide(_ sender: UIButton) {
        self.ref.child(currentRoomNumber).childByAutoId().setValue(["timestamp" : Date.init().description, "action": "keyup", "completed": "false"])
    }

    
}

