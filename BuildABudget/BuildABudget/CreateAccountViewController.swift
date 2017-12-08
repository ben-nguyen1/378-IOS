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
    //below commented code is for future use with setting up initial account balance - not part of initial project proposal
    //@IBOutlet weak var initialAccountBalance: UITextField!
    
    var alertErrorController:UIAlertController? = nil
    var accountSuccessController:UIAlertController? = nil
    let budgetAgent = MyBudget.agent
    
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
        
        //below commented code is for future use with setting up initial account balance - not part of initial project proposal
        //initialAccountBalance.text = nil
        //initialAccountBalance.placeholder = "Initial Account Balance"
        //initialAccountBalance.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            if (firstName.text!.isEmpty || lastName.text!.isEmpty || email.text!.isEmpty || pass.text!.isEmpty ) {
            //below commented code is for future use with setting up initial account balance - not part of initial project proposal, if using below line of code then comment out the one line of code above
            //if (firstName.text!.isEmpty || lastName.text!.isEmpty || email.text!.isEmpty || pass.text!.isEmpty || initialAccountBalance.text!.isEmpty) {
                self.alertErrorController = UIAlertController(title: "Alert", message: "All fields must be entered", preferredStyle: UIAlertControllerStyle.alert)
                
                let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    (action:UIAlertAction) in
                }
                self.alertErrorController!.addAction(OKAction)
                
                self.present(self.alertErrorController!, animated: true, completion:nil)
            //below commented code is for future use with setting up initial account balance - not part of initial project proposal
            //} else if isValidAmount(inputAmount: initialAccountBalance.text!) == false {
            //    print("TEST: isValidAmount = false")
            //    self.alertErrorController = UIAlertController(title: "Alert", message: "Amount must be between 0.00 and 100000000.00", preferredStyle: UIAlertControllerStyle.alert)
            //    let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action:UIAlertAction) in }
            //    self.alertErrorController!.addAction(OKAction)
            //    self.present(self.alertErrorController!, animated: true, completion:nil)
            } else {
                // add info to UserDefaults
                Account.setFirstName(firstName.text!)
                Account.setLasttName(lastName.text!)
                Account.setUserName(email.text!)
                Account.setPass(pass.text!)
                Account.setCurrency("$")
                //self.createInitialBudgetObject() //for use with setting up initial amount
                
                self.accountSuccessController = UIAlertController(title: "Alert", message: "Your account has been made!", preferredStyle: UIAlertControllerStyle.alert)
                
                let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    (action:UIAlertAction) in
                    
                    // after creating an account, go to tutorial screen
                    let storyboard = UIStoryboard(name: "Tutorial", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "tutorialPageVC") as! TutorialPageViewController
                    self.present(vc, animated: true, completion: nil)
                }
                self.accountSuccessController!.addAction(OKAction)
                self.present(self.accountSuccessController!, animated: true, completion:nil)
            }
            

        }
    }
    
    //this function is for future code involving setting up an initial account balance as reported by user
    //func isValidAmount( inputAmount: String) -> Bool{
    //    let budgetVCAgent = BudgetViewController.bc
    //    let answer = budgetVCAgent.isValidAmount(inputMoneyString: inputAmount)
    //    print("isValidAmount = \(answer)")
    //    return answer
    //}
    
    //this function is for future code involving setting up an initial account balance as reported by user
    //func createInitialBudgetObject(){
    //    let access = AccessService.access
    //    let newBudgetObject = MyBudget(description: "Budget",
    //                                   startDate:   Date(),
    //                                   endDate:     Date() )
    //    newBudgetObject.accountBalance = (self.initialAccountBalance.text! as NSString).doubleValue
    //}
    
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
