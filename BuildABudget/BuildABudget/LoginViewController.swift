//
//  ViewController.swift
//  BuildABudget
//
//  Created by Ben Nguyen on 10/6/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var register: UIButton!
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var pass: UITextField!
    
    var alertErrorController:UIAlertController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        login.layer.cornerRadius = 5
        register.layer.cornerRadius = 5
        
        email.text = nil
        email.placeholder = "Email Address"
        email.delegate = self;
        
        pass.text = nil
        pass.placeholder = "Password"
        pass.delegate = self;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        if Account.userName() == email.text! && Account.pass() == pass.text! {
            performSegue(withIdentifier: "loginToTab", sender: self)
            print("Login sucessful")
        } else {
            self.alertErrorController = UIAlertController(title: "Alert", message: "Email or Password does not match", preferredStyle: UIAlertControllerStyle.alert)
            
            let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){
                (action:UIAlertAction) in
            }
            self.alertErrorController!.addAction(OKAction)
            
            self.present(self.alertErrorController!, animated: true, completion:nil)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginToTab"{
            var vc = segue.destination as! TabBarViewController
            vc.selectedIndex = 2
            //Data has to be a variable name in your RandomViewController
        }
    }
    
    @IBAction func goCreateBtn(_ sender: Any) {
    }
    
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

