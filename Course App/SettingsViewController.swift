//
//  SettingsViewController.swift
//  Course App
//
//  Created by Ming Ying on 8/31/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var promptLabel: UILabel!
    
    //MARK: View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneField.text = Settings.getPhone()
        let userName = Settings.getUserName()
        if userName != nil && userName != "" {
            self.promptLabel.text = "Name: \(userName!)"
            self.promptLabel.textColor = UIColor.blueColor()
            self.phoneField.textColor = UIColor.blueColor()
        }

        saveButton.enabled = false
    }

    // MARK: Actions
    
    @IBAction func savePhone(sender: UIButton) {
        if let phone = phoneField.text{
            if phone != Settings.getPhone() {
                Settings.setPhone(phone,
                    succeed: { userName in
                        dispatch_async(dispatch_get_main_queue()) {
                            self.promptLabel.text = "Name: \(userName)"
                            self.promptLabel.textColor = UIColor.blueColor()
                            self.phoneField.textColor = UIColor.blueColor()
                        }
                    },
                    fail: {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.promptLabel.text = "Phone number not registered!"
                            self.promptLabel.textColor = UIColor.redColor()
                            self.phoneField.textColor = UIColor.redColor()
                        }
                })
            }
        }
        saveButton.enabled = false
        phoneField.resignFirstResponder()
    }
    
    //MARK: TextFiel delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        saveButton.enabled = false
        if let temp = phoneField.text{
            let phone = temp.stringByTrimmingCharactersInSet(
                NSCharacterSet.whitespaceAndNewlineCharacterSet()
            )
            phoneField.text = phone
            if phone != Settings.getPhone() {
                saveButton.enabled = true
            }
        }
    }
}
