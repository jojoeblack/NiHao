//
//  MainPageViewController.swift
//  NiHao01
//
//  Created by MacPro on 2018/4/3.
//  Copyright © 2018年 JoeMac01. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FBSDKCoreKit
import FBSDKLoginKit
import AVFoundation
import Alamofire
import SwiftyJSON

class MainPageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, AVSpeechSynthesizerDelegate {

    
    
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    
    var synthesizer = AVSpeechSynthesizer()
    var totalUtterance: Int = 0
    var isSideMenuHidden = true
    var vocabularyBank:String = ""
    let imgArray = [UIImage(named: "food"), UIImage(named: "calendar"), UIImage(named: "travel"),UIImage(named: "dessert"),UIImage(named: "snack"),UIImage(named: "family")]
    let introductionArray = ["Food","Month","Travel","Custom","Snack","Family"]
    /*********************************JSON DATA VARIABLE************************************/
    
    
    var wordjsonarray = [WordStruct]()
    override func viewDidLoad() {
    /*********************************JSON DATA VARIABLE************************************/
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //initialize constant with o
        sideMenuConstraint.constant = -140
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let currentUser = Auth.auth().currentUser
        if currentUser == nil {
            self.showMessage(messageToDisplay: "could not read user details")
            return
        }

        //顯示歡迎詞
        
        //下載firebase用戶名
        var databaseReference : DatabaseReference!
        databaseReference = Database.database().reference()
        databaseReference.child("users").child((currentUser?.uid)!).child("userDetails").observeSingleEvent(of: DataEventType.value) { (snapshot) in
            //let userDetailsData = snapshot.value as? NSDictionary
            //let userName = userDetailsData?["userName"] as? String ?? " "
            
            //self.welcomeLabel.text = self.welcomeLabel.text! + " " + userName
        //說出歡迎詞
            
             /*if !self.synthesizer.isSpeaking {
               let speechUtterance = AVSpeechUtterance(string: "我不好,\(userName)")
               let voice = AVSpeechSynthesisVoice(language: "zh-TW")
               speechUtterance.voice = voice
               speechUtterance.rate = 0.5
                self.synthesizer.speak(speechUtterance)
            } */
        
        }//end closure snapshot
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    

    //導覽
    @IBAction func organizedBtn_Tapped(_ sender: Any) {
        if isSideMenuHidden {
            sideMenuConstraint.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        } else {
            sideMenuConstraint.constant = -200
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        isSideMenuHidden = !isSideMenuHidden
    }
    /****************************導覽列功能******************************/
    @IBAction func connectMywords_Tapped(_ sender: Any) {
        let mywordPage = self.storyboard?.instantiateViewController(withIdentifier: "navMywords") as! UINavigationController
        self.present(mywordPage, animated: true, completion: nil)
    }
    
    @IBAction func connectQuiz_Tapped(_ sender: Any) {
        let mytestPage = self.storyboard?.instantiateViewController(withIdentifier: "navTestAll") as! UINavigationController
        self.present(mytestPage, animated: true, completion: nil)
    }
    
    @IBAction func connectWeb(_ sender: Any) {
        let myWebPage = self.storyboard?.instantiateViewController(withIdentifier: "navWeb") as! UINavigationController
        self.present(myWebPage, animated: true, completion: nil)
    }
    
    
    
    /**************************End導覽列功能*****************************/
    
    public func showMessage(messageToDisplay: String){
        let alertController = UIAlertController(title: "Alert title", message: messageToDisplay, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default)
        {
            (ACTION:UIAlertAction!) in
            print("Ok button tapped")
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }//end showMessage
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionViewCell", for: indexPath) as! MainCollectionViewCell
        cell.topicImg.image = imgArray[indexPath.row]
        cell.topicLbl.text! = introductionArray[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        
        switch indexPath.row {
        case 0:
            let foodArray = [Vocabulary]()
            getwords(myArray: foodArray,myQuery: "Food",myTopic: "Food")
            
        case 1:
            let monthArray = [Vocabulary]()
            getwords(myArray: monthArray,myQuery: "Month",myTopic: "Month")
        case 2:
            let travelArray = [Vocabulary]()
            getwords(myArray: travelArray,myQuery: "Travel",myTopic: "Travel")
        case 3:
            let customArray = [Vocabulary]()
            getwords(myArray: customArray,myQuery: "Custom",myTopic: "Custom")
        case 4:
            let snackArray = [Vocabulary]()
            getwords(myArray: snackArray,myQuery: "Snacks",myTopic: "Snack")
        case 5:
            let familyArray = [Vocabulary]()
            getwords(myArray: familyArray,myQuery: "Family",myTopic: "Family")
        default:
            let foodArray = [Vocabulary]()
            getwords(myArray: foodArray,myQuery: "Food",myTopic: "Food")
        }//end switch
        
    }
/*********************************JSON FUNCTION************************************/
   
    func getwords(myArray:Array<Any>, myQuery:String, myTopic:String) {
        
        var myArray = [Vocabulary]()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let wordsVC = mainStoryboard.instantiateViewController(withIdentifier: "WordsViewController") as! WordsViewController
        let url = URL(string: "http://54.169.158.3:8080/WordServlet?def=\(myQuery)")
        Alamofire.request(url!).responseJSON { (response) in
            let result = response.data
            do {
                
                self.wordjsonarray = try JSONDecoder().decode([WordStruct].self, from: result!)
                for aaa in self.wordjsonarray {
                    let word = Vocabulary(wordCh: aaa.Ch, wordEng: aaa.Eng, wordImg: aaa.img)
                    myArray.append(word)
                }
                
            }//end do
            catch {
                print("Error:\(String(describing: response.result.error))")
            }//end catch
            //變數傳遞至另一頁面                                  
            wordsVC.ch = myArray[0].vocabularyCh
            wordsVC.eng = myArray[0].vocabularyEng
            //wordsVC.img = foodArray[0].vocabularyImg
            wordsVC.topicName = myTopic
            wordsVC.topicArray = myArray
            self.navigationController?.pushViewController(wordsVC, animated: true)
        }// end (response)
    }//end getword
    
    
}
