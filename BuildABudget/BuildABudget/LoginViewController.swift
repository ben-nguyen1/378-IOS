//
//  ViewController.swift
//  BuildABudget
//
//  Created by Ben Nguyen on 10/6/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
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
        
        pass.text = nil
        pass.placeholder = "Password"
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
}

