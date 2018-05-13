//
//  WebViewController.swift
//  NiHao01
//
//  Created by MacPro on 2018/4/20.
//  Copyright © 2018年 JoeMac01. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import MARoundButton

class WebViewController: ViewController, UIWebViewDelegate {

    @IBOutlet weak var myWebView: UIWebView!
    @IBOutlet weak var myActivityView: UIActivityIndicatorView!
    
   
   
    
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    var isSideMenuHidden = true
    override func viewDidLoad() {
        let myURL: URL = URL(string: "http://54.169.158.3:8080/")!
        let myURLRequest: URLRequest = URLRequest(url: myURL)
        super.viewDidLoad()
        self.myWebView.delegate = self
        self.myActivityView.isHidden = true
        self.myActivityView.hidesWhenStopped = true
        self.myWebView.loadRequest(myURLRequest)
        
        //initialize constraint with 0
        sideMenuConstraint.constant = -140
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func organizedBtn_Tapped(_ sender: Any) {
        if isSideMenuHidden {
            sideMenuConstraint.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        } else {
            sideMenuConstraint.constant = -140
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        isSideMenuHidden = !isSideMenuHidden
    }
    /*導覽列*/
    @IBAction func topicBtn_Tapped(_ sender: Any) {
        let mytopicPage = self.storyboard?.instantiateViewController(withIdentifier: "navTopics") as! UINavigationController
        self.present(mytopicPage, animated: true, completion: nil)
    }
    @IBAction func quizBtn_Tapped(_ sender: Any) {
        let mytestPage = self.storyboard?.instantiateViewController(withIdentifier: "navTestAll") as! UINavigationController
        self.present(mytestPage, animated: true, completion: nil)
    }
    @IBAction func mywordBtn_Tapped(_ sender: Any) {
        let mywordPage = self.storyboard?.instantiateViewController(withIdentifier: "navMywords") as! UINavigationController
        self.present(mywordPage, animated: true, completion: nil)
    }
    
    @IBAction func logoutBtn_Tapped(_ sender: Any) {
        do {
            
            for userInfo in (Auth.auth().currentUser?.providerData)!{
                if userInfo.providerID == "facebook.com" {
                    FBSDKLoginManager().logOut()
                    break
                }
            }
            try Auth.auth().signOut()
            
            let signInPage = self.storyboard?.instantiateViewController(withIdentifier: "navSignin") as! UINavigationController
            
            let appDelegat = UIApplication.shared.delegate
            appDelegat?.window??.rootViewController = signInPage
        } catch {
            self.showMessage(messageToDisplay: "Could not signout at this moment")
        }
    }
    /*導覽列*/
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        myActivityView.isHidden = false
        myActivityView.startAnimating()
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        myActivityView.isHidden = true
        myActivityView.stopAnimating()
    }
    



}
