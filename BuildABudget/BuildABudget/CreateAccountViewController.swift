//
//  CreateAccountViewController.swift
//  BuildABudget
//
//  Created by Ben Nguyen on 10/6/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var create: UIButton!
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var pass: UITextField!
    
    var alertErrorController:UIAlertController? = nil
    var accountSuccessController:UIAlertController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        create.layer.cornerRadius = 5
        
        // add placeholder text for all text fields
        firstName.text = nil
        firstName.placeholder = "First Name"
        firstName.delegate = self
        
        lastName.text = nil
        lastName.placeholder = "Last Name"
        lastName.delegate = self
        
        email.text = nil
        email.placeholder = "Email Address"
        email.delegate = self
        
        pass.text = nil
        pass.placeholder = "Password"
        pass.delegate = self
        pass.isSecureTextEntry = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func createBtn(_ sender: Any) {
        if UserDefaults.standard.object(forKey: "userName") != nil {
            self.alertErrorController = UIAlertController(title: "Alert", message: "An account on this device already exist.", preferredStyle: UIAlertControllerStyle.alert)
            
            let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (action:UIAlertAction) in
            }
            self.alertErrorController!.addAction(OKAction)
            
            self.present(self.alertErrorController!, animated: true, completion:nil)
        } else {
            print("New Account")
            if (firstName.text!.isEmpty || lastName.text!.isEmpty || email.text!.isEmpty || pass.text!.isEmpty) {
                self.alertErrorController = UIAlertController(title: "Alert", message: "All fields must be entered", preferredStyle: UIAlertControllerStyle.alert)
                
                let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    (action:UIAlertAction) in
                }
                self.alertErrorController!.addAction(OKAction)
                
                self.present(self.alertErrorController!, animated: true, completion:nil)
            } else {
                // add info to UserDefaults
                Account.setFirstName(firstName.text!)
                Account.setLasttName(lastName.text!)
                Account.setUserName(email.text!)
                Account.setPass(pass.text!)
                
                self.accountSuccessController = UIAlertController(title: "Alert", message: "Your account has been made!", preferredStyle: UIAlertControllerStyle.alert)
                
                let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    (action:UIAlertAction) in
                    
                    // after creating an account, go back to login screen
                    // TODO:
                    // in the future, this will be the tutorial screen
                    let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
                    self.navigationController?.pushViewController(secondViewController, animated: true)
                }
                self.accountSuccessController!.addAction(OKAction)
                self.present(self.accountSuccessController!, animated: true, completion:nil)
            }
            

        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // This method is called when the user touches the Return key on the
    // keyboard. The 'textField' passed in is a pointer to the textField
    // the cursor was in at the time they touched the Return key on the
    // keyboard.
    //
    // From the Apple documentation: Asks the delegate if the text field
    // should process the pressing of the return button.
    //
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 'First Responder' is the same as 'input focus'.
        // We are removing input focus from the text field.
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user touches on the main view (outside the UITextField).
    //
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
