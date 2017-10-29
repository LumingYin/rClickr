//
//  RoomNumberViewController.swift
//  rClickriOS
//
//  Created by Mitchell Gant on 10/28/17.
//  Copyright © 2017 cocappathon. All rights reserved.
//

import UIKit
import FirebaseCommunity

class RoomNumberViewController: UIViewController, UITextFieldDelegate {

    
    var ref: DatabaseReference!
    @IBOutlet weak var roomNumberTextField: UITextField!
    var roomNumber: String?
    @IBOutlet weak var circleView: UILabel!
    
    @objc func numberChanged(sender: Any) {
        if let text = self.roomNumberTextField.text {
            if text.count == 0 {
                circleView.text = "○   ○   ○   ○"
            } else if text.count == 1 {
                circleView.text = "●   ○   ○   ○"
            } else if text.count == 2 {
                circleView.text = "●   ●   ○   ○"
            } else if text.count == 3 {
                circleView.text = "●   ●   ●   ○"
            } else {
                circleView.text = "●   ●   ●   ●"
                self.startSlidingBtnPressed(self)
            }
        }
//        print(self.roomNumberTextField.text)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.roomNumberTextField.becomeFirstResponder()
//        self.hideKeyboardWhenTappedAround()
        ref = Database.database().reference()
        self.roomNumberTextField.delegate = self
        self.roomNumberTextField.addTarget(self, action: #selector(numberChanged), for: .editingChanged)
        // Do any additional setup after loading the view.
//        let lineColor = UIColor(red:0.12, green:0.23, blue:0.35, alpha:1.0)
//        self.roomNumberTextField.setBottomLine(borderColor: lineColor)
        
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(string)
        return true
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.roomNumberTextField.text = ""
        self.circleView.text = "○   ○   ○   ○"
    }
    
    
    @IBAction func startSlidingBtnPressed(_ sender: Any) {
        if roomNumberTextField.text != "" {
            print(ref.child("\(roomNumberTextField.text)"))
            ref.child("\(roomNumberTextField.text!)").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    self.roomNumber = self.roomNumberTextField.text!
                    self.performSegue(withIdentifier: "toSlideBtns", sender: self)
                    
                } else {
                    self.presentWrongInputAlert(message: "The code you have entered is invalid. Please check the code on your Mac.")
                    self.roomNumberTextField.text = ""
                    self.circleView.text = "○   ○   ○   ○"
                }
            })
        } else {
            presentWrongInputAlert(message: "Please enter number into the field.")
        }
        
        
    }
    
    
    
}

extension UITextField {
    
    func setBottomLine(borderColor: UIColor) {
        
        self.borderStyle = UITextBorderStyle.none
        self.backgroundColor = UIColor.clear
        
        let borderLine = UIView()
        let height = 1.0
        borderLine.frame = CGRect(x: 0, y: Double(self.frame.height) - height, width: Double(self.frame.width), height: height)
        
        borderLine.backgroundColor = borderColor
        self.addSubview(borderLine)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
