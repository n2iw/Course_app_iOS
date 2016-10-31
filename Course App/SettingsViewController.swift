//
//  SettingsViewController.swift
//  Course App
//
//  Created by Ming Ying on 8/31/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameField.text = Settings.getFirstName()
        lastNameField.text = Settings.getLastName()

        saveButton.enabled = false
    }

    @IBAction func saveNames(sender: UIButton) {
        if let first_name = firstNameField.text{
            if first_name != Settings.getFirstName() {
                Settings.setFirstName(first_name.capitalizedString)
                firstNameField.text = first_name.capitalizedString
            }
        }
        if let last_name = lastNameField.text {
            if last_name != Settings.getLastName() {
                Settings.setLastName(last_name.capitalizedString)
                lastNameField.text = last_name.capitalizedString
            }
        }
        saveButton.enabled = false
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
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
        if let f_name = firstNameField.text{
            let first_name = f_name.stringByTrimmingCharactersInSet(
                NSCharacterSet.whitespaceAndNewlineCharacterSet()
            ).capitalizedString
            firstNameField.text = first_name
            if first_name != Settings.getFirstName() {
                saveButton.enabled = true
            }
        }
        
        if let l_name = lastNameField.text {
            let last_name = l_name.stringByTrimmingCharactersInSet(
                NSCharacterSet.whitespaceAndNewlineCharacterSet()
            ).capitalizedString
            lastNameField.text = last_name
            if last_name != Settings.getLastName() {
                saveButton.enabled = true
            }
        }
    }
}
