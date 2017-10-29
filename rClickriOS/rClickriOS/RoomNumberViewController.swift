//
//  RoomNumberViewController.swift
//  rClickriOS
//
//  Created by Mitchell Gant on 10/28/17.
//  Copyright © 2017 cocappathon. All rights reserved.
//

import UIKit
import FirebaseCommunity

class RoomNumberViewController: UIViewController, UITextFieldDelegate{

    
    var ref: DatabaseReference!
    @IBOutlet weak var roomNumberTextField: UITextField!
    var roomNumber: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        // Do any additional setup after loading the view.
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ViewController {
            destination.currentRoomNumber = roomNumber!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func presentWrongInputAlert(message: String) {
        let alert = UIAlertController(title: "Wrong Input", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func startSlidingBtnPressed(_ sender: Any) {
        if roomNumberTextField.text != "" {
            print(ref.child("\(roomNumberTextField.text)"))
            ref.child("\(roomNumberTextField.text!)").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    self.roomNumber = self.roomNumberTextField.text!
                    self.performSegue(withIdentifier: "toSlideBtns", sender: self)
                    
                } else {
                    self.presentWrongInputAlert(message: "Your room number does not exist.")
                }
            })
        } else {
            presentWrongInputAlert(message: "Please enter number into the field.")
        }
        
        
    }
    
}
