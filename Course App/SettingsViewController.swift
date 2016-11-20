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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneField.text = Settings.getPhone()

        saveButton.enabled = false
    }

    @IBAction func savePhone(sender: UIButton) {
        if let phone = phoneField.text{
            if phone != Settings.getPhone() {
                Settings.setPhone(phone)
            }
        }
        saveButton.enabled = false
        phoneField.resignFirstResponder()
        self.tabBarController?.selectedIndex =  Settings.COURSES_TAB_INDEX
    }
    
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
