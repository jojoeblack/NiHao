//
//  TestAllViewController.swift
//  NiHao01
//
//  Created by MacPro on 2018/4/18.
//  Copyright © 2018年 JoeMac01. All rights reserved.
//

import UIKit
import Alamofire
import FBSDKLoginKit
import FirebaseAuth
class TestAllViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    
    let quizTable:[String] = ["Food","Month","Travel","Custom","Snack"]
    let imgArray = [UIImage(named: "Quiz01.jpg"), UIImage(named: "Quiz02.jpeg"), UIImage(named: "Quiz03.jpg"),UIImage(named: "Quiz04.jpeg"),UIImage(named: "Quiz05.jpg")]
    var wordjsonarray = [WordStruct]()
  
    
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    var isSideMenuHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    @IBAction func connectWeb(_ sender: Any) {
        let myWebPage = self.storyboard?.instantiateViewController(withIdentifier: "navWeb") as! UINavigationController
        self.present(myWebPage, animated: true, completion: nil)
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
            print("error")
        }
    }
    /*導覽列*/

    /**************************collection view 實作*****************************/
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return quizTable.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuizCollectionViewCell", for: indexPath) as! QuizCollectionViewCell
        cell.quizImg.image = imgArray[indexPath.row]
        cell.quizLbl.text! = quizTable[indexPath.row]
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
    /**********************************************************************/
   
    func getwords(myArray:Array<Any>, myQuery:String, myTopic:String) {
        
        var myArray = [Vocabulary]()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let quizVC = mainStoryboard.instantiateViewController(withIdentifier: "QuizViewController") as! QuizViewController
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
            quizVC.ch = myArray[0].vocabularyCh
            quizVC.eng = myArray[0].vocabularyEng
            //wordsVC.img = foodArray[0].vocabularyImg
            quizVC.topicName = myTopic
            quizVC.topicArray = myArray
            self.navigationController?.pushViewController(quizVC, animated: true)
        }// end (response)
    }//end getword
}
