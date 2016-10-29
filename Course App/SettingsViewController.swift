//
//  SettingsViewController.swift
//  Course App
//
//  Created by Ming Ying on 8/31/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    let FIRST_NAME = "firstName"
    let LAST_NAME = "lastName"

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    private var firstName: String?;
    private var lastName: String?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstName = defaults.stringForKey(FIRST_NAME)
        lastName = defaults.stringForKey(LAST_NAME)
        firstNameField.text = firstName
        lastNameField.text = lastName

        saveButton.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveNames(sender: UIButton) {
        if let first_name = firstNameField.text{
            if first_name != self.firstName {
                firstName = first_name.capitalizedString
                defaults.setObject( firstName, forKey: FIRST_NAME)
                firstNameField.text = firstName
            }
        }
        if let last_name = lastNameField.text {
            if last_name != self.lastName {
                lastName = last_name.capitalizedString
                defaults.setObject( lastName, forKey: LAST_NAME)
                lastNameField.text = lastName
            }
        }
        defaults.synchronize()
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
        if let first_name = firstNameField.text{
            if first_name != self.firstName {
                saveButton.enabled = true
            }
        }
        
        if let last_name = lastNameField.text {
            if last_name != self.lastName {
                saveButton.enabled = true
            }
        }
    }

}
