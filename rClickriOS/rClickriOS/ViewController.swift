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
    var panGesture: UIPanGestureRecognizer!
    var actionEnabled: String!
    
    @IBOutlet weak var snapshotImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
    actionEnabled = "None"
        ref.child(currentRoomNumber).child("interactive_settings").child("screenshot_url").observe(.value) { (snapshot) in
            if snapshot.exists() {
                DispatchQueue.global(qos: .background).async {
                    
                    if let snapshotURL = URL(string: snapshot.value as! String) {
                        URLSession.shared.dataTask(with: snapshotURL, completionHandler: { (data, response, error) in
                            
                            if error != nil && data != nil {
                                print("something went wrong with image")
                            } else {
                                DispatchQueue.main.async {
                                    self.snapshotImageView.image = UIImage(data: data!)
                                    print(self.snapshotImageView.image?.size)
                                }
                            }
                            
                            
                        }).resume()
                    }
                }
            }
        }
        
        
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func prevSlide(_ sender: UIButton) {
        self.ref.child(currentRoomNumber).childByAutoId().setValue(["timestamp" : Date.init().description, "action": "keyup", "completed": "false"])
    }
    
    @IBAction func nextSlide(_ sender: UIButton) {
        self.ref.child(currentRoomNumber).childByAutoId().setValue(["timestamp" : Date.init().description, "action": "keydown", "completed": "false"])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if snapshotImageView.frame.contains(touch.location(in: self.view))  {
                print(touch.location(in: snapshotImageView))
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if snapshotImageView.frame.contains(touch.location(in: self.view))  {
                print(touch.location(in: snapshotImageView))
            }
        }
    }
    
    
    
}

