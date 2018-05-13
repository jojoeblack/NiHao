//
//  SignInViewController.swift
//  NiHao01
//
//  Created by MacPro on 2018/4/1.
//  Copyright © 2018年 JoeMac01. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import Firebase
import FirebaseDatabase
import FBSDKCoreKit
import FBSDKLoginKit
import AVFoundation

class SignInViewController: UIViewController, FBSDKLoginButtonDelegate{
    
    
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    var synthesizer = AVSpeechSynthesizer()
    var totalUtterance: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        facebookLoginButton.delegate = self
        facebookLoginButton.readPermissions = ["email"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func SignInButtonTapped(_ sender: Any) {
        guard let userEmail = userEmailTextField.text,
            !userEmail.isEmpty else {
            self.showMessage(messageToDisplay: "User email is required")
            return
        }
        guard let userPassword = userPasswordTextField.text,
            !userEmail.isEmpty else {
                self.showMessage(messageToDisplay: "User password is required")
                return
        }
        Auth.auth().signIn(withEmail: userEmail, password: userPassword) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                self.showMessage(messageToDisplay: error.localizedDescription)
                return
            }
            if user != nil{
                //下載firebase用戶名
                var databaseReference : DatabaseReference!
                databaseReference = Database.database().reference()
                databaseReference.child("users").child((user?.uid)!).child("userDetails").observeSingleEvent(of: DataEventType.value) { (snapshot) in
                    let userDetailsData = snapshot.value as? NSDictionary
                    let userName = userDetailsData?["userName"] as? String ?? " "
                    
                    //self.welcomeLabel.text = self.welcomeLabel.text! + " " + userName
                    //說出歡迎詞
                    
                    if !self.synthesizer.isSpeaking {
                        let speechUtterance = AVSpeechUtterance(string: "Hi,\(userName),Welcom to Nihou Chinese,\(RobotGreeting.init().greeting)")
                        let voice = AVSpeechSynthesisVoice(language: "en-UK")
                        speechUtterance.voice = voice
                        speechUtterance.rate = 0.5
                        self.synthesizer.speak(speechUtterance)
                    }
                    
                }//end closure snapshot

                let mainPage = self.storyboard?.instantiateViewController(withIdentifier: "navTopics") as! UINavigationController
                self.present(mainPage, animated: true, completion: nil)
            }
        }//end Auth
        

    }//end SignIn Button
    
   
    public func showMessage(messageToDisplay: String){
        let alertController = UIAlertController(title: "Alert title", message: messageToDisplay, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default)
        {
            (ACTION:UIAlertAction!) in
            
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    //FB log in
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print("Error took place \(error.localizedDescription)")
            return
        }
        print("Successful")
        if FBSDKAccessToken.current() == nil{
            return
        }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("Could not sign in with Facebook because of: \(error.localizedDescription)")
                self.showMessage(messageToDisplay: error.localizedDescription)
                FBSDKLoginManager().logOut()
                return
            }
            //user is sgigned in
            print("Successfully signed! User id = \(String(describing: user?.uid))")
            print("User email = \(String(describing: user?.email))")
            
            var userDetails: [String: String] = [:]
            if let userFullname = user?.displayName{
                
                let userNameDetails = userFullname.components(separatedBy: .whitespaces)
                if userNameDetails.count >= 2 {
                    userDetails["userName"] = userNameDetails[0] + userNameDetails[1]
                }
                
            }
            //Store in database
            var databaseReference: DatabaseReference!
            databaseReference = Database.database().reference()
            
            //讀取user
            databaseReference.child("users").child((user?.uid)!).child("userDetails").observeSingleEvent(of: DataEventType.value) { (snapshot) in
                let userDetailsData = snapshot.value as? NSDictionary
                let userName = userDetailsData?["userName"] as? String ?? " "
                //說出歡迎詞
                
                if !self.synthesizer.isSpeaking {
                    let speechUtterance = AVSpeechUtterance(string: "Hi,\(userName),Welcom to Nihou Chinese,\(RobotGreeting.init().greeting) ")
                    let voice = AVSpeechSynthesisVoice(language: "en-UK")
                    speechUtterance.voice = voice
                    speechUtterance.rate = 0.5
                    self.synthesizer.speak(speechUtterance)
                }
            }
            //連到主頁
            let mainPage = self.storyboard?.instantiateViewController(withIdentifier: "navTopics") as! UINavigationController
            let appDelegate = UIApplication.shared.delegate
            appDelegate?.window??.rootViewController = mainPage
            return

            
        }
        
    }
    
    @IBAction func emailTextField_EndEdit(_ sender: Any) {
    }
    
    @IBAction func passWordTextField_EndEdit(_ sender: Any) {
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User signed out")
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //開始輸入的狀態
        var shift: CGFloat = 0.0 //位移值
        if textField.tag == 1 {
            shift = 60.0
        }else if textField.tag == 2 {
            
        }
        self.view.center = CGPoint(x: self.view.center.x, y: self.view.center.y - shift)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        var shift: CGFloat = 0.0 //位移值
        if textField.tag == 1 {
            shift = 60.0
        }else if textField.tag == 2 {
            
        }
        self.view.center = CGPoint(x: self.view.center.x, y: self.view.center.y + shift)
    }

}
