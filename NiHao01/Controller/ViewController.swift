//
//  ViewController.swift
//  NiHao01
//
//  Created by MacPro on 2018/4/1.
//  Copyright © 2018年 JoeMac01. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatpasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func signupBtn(_ sender: Any) {
        guard let userName = nameTextField.text, !userName.isEmpty else
        {
            self.showMessage(messageToDisplay: "Name is required!")
            return;}
        guard let userEmailAddress = emailTextField.text, !userEmailAddress.isEmpty else
        {
            self.showMessage(messageToDisplay: "Email is required!")
            return;}
        guard let userPassword = passwordTextField.text, !userPassword.isEmpty else
        {
            self.showMessage(messageToDisplay: "PassWord is required!")
            return;}
        guard let userRepeatPassword = repeatpasswordTextField.text, !userRepeatPassword.isEmpty else
        {
            self.showMessage(messageToDisplay: "Repeat PassWord is required!")
            return;}
        if userPassword != userRepeatPassword{
            self.showMessage(messageToDisplay: "User provided passwords do not match")
            return
        }
        Auth.auth().createUser(withEmail: userEmailAddress, password: userPassword) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                self.showMessage(messageToDisplay: error.localizedDescription)
                return
            }
            if let user = user {
                var databaseReference: DatabaseReference!
                databaseReference = Database.database().reference()
                
                let userDetailes:[String:String]=["userName":userName]
                databaseReference.child("users").child(user.uid).setValue(["userDetails":userDetailes])
            }
        }
            self.signupMessage(messageToDisplay: "You are now a member")
        return
        
    }
    
    
    
    
    @IBAction func cancelBtn(_ sender: Any) {
        let mainPage = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.present(mainPage, animated: true, completion: nil)

    }
    public func showMessage(messageToDisplay: String){
        let alertController = UIAlertController(title: "Alert!", message: messageToDisplay, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default)
        {
            (ACTION:UIAlertAction!) in
            print("Ok button tapped")
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    public func signupMessage(messageToDisplay: String){
        let alertController = UIAlertController(title: "Welcome", message: messageToDisplay, preferredStyle: .actionSheet)
        let OKAction = UIAlertAction(title: "OK", style: .default)
        {
            (ACTION:UIAlertAction!) in
            print("Ok button tapped")
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    

}

