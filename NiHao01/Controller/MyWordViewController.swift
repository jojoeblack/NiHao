//
//  MyWordViewController.swift
//  NiHao01
//
//  Created by MacPro on 2018/4/14.
//  Copyright © 2018年 JoeMac01. All rights reserved.
//

import UIKit
import MobileCoreServices
import FirebaseStorage
import FirebaseAuth
import FirebaseStorageUI
import Firebase
import Speech
import FBSDKLoginKit

class MyWordViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var userprofileimageView: UIImageView!
    @IBOutlet weak var newwordTableView: UITableView!
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    
    
    
    
    var wordList = [Newword]()
    var synthesizer = AVSpeechSynthesizer()
    var totalUtterance: Int = 0
    var isSideMenuHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newwordTableView.delegate = self
        newwordTableView.dataSource = self
        sideMenuConstraint.constant = -140
        
        
    }//End viewDidLoad
    
    override func viewWillAppear(_ animated: Bool) {
        //load avatar
        let storageReference = Storage.storage().reference()
        let currentUser = Auth.auth().currentUser
        
        let profileImageRef = storageReference.child("user").child(currentUser!.uid).child("profileImage.jpg")
        profileImageRef.getData(maxSize: 2 * 2048 * 2048) { (data, error) in
            if let error = error {
                print("error \(error)")
            } else {
                if let imageData = data {
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)
                        self.userprofileimageView.image = image
                    }
                }
            }
        }//end data,error closure
        
        
        
       loadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func setProfileimage_Tapped(_ sender: Any) {
        let profileImagePicker = UIImagePickerController()
        profileImagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        profileImagePicker.mediaTypes = [kUTTypeImage as String]
        profileImagePicker.delegate = self
        present(profileImagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func refresh_Tapped(_ sender: Any) {
        viewWillAppear(true)
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
    
    @IBAction func topicBtn_Tapped(_ sender: Any) {
        let mytopicPage = self.storyboard?.instantiateViewController(withIdentifier: "navTopics") as! UINavigationController
        self.present(mytopicPage, animated: true, completion: nil)

    }
    @IBAction func quizBtn_Tapped(_ sender: Any) {
        let mytestPage = self.storyboard?.instantiateViewController(withIdentifier: "navTestAll") as! UINavigationController
        self.present(mytestPage, animated: true, completion: nil)

    }
    @IBAction func aboutBtn_Tapped(_ sender: Any) {
        let myWebPage = self.storyboard?.instantiateViewController(withIdentifier: "navWeb") as! UINavigationController
        self.present(myWebPage, animated: true, completion: nil)

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
            print("Could not signout at this moment")
        }

    }
    
    
   
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //把圖存在物件
        if let profileImage = info[UIImagePickerControllerOriginalImage] as? UIImage, let optimizedImageData = UIImageJPEGRepresentation(profileImage, 0.6) {
            uploadProfileImage(imageData: optimizedImageData)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func uploadProfileImage(imageData: Data) {
        //上傳指標
        let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        activityIndicator.startAnimating()
        activityIndicator.center = self.view.center
        activityIndicator.color = UIColor.red
        self.view.addSubview(activityIndicator)
        
        let storageReference = Storage.storage().reference()
        let currentUser = Auth.auth().currentUser
        let profileImageRef = storageReference.child("user").child(currentUser!.uid).child("profileImage.jpg")
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        profileImageRef.putData(imageData, metadata: uploadMetaData) { (uploadedImageMeta, error) in
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            if error != nil {
                print("Error\(String(describing: error?.localizedDescription))")
                return
            } else {
                print("Meta data of uploaded imagae \(String(describing: uploadMetaData))")
            }
        }//end closure
    }//end uploadProfileImage
    
    /*********** tableview datasource *************/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.wordList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = newwordTableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath as IndexPath) as! MyWordTableViewCell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red:0.48, green:0.75, blue:0.83, alpha:0.6)
        cell.selectedBackgroundView = backgroundView
        cell.textLabel?.text = wordList[indexPath.row].ch! + ":" + wordList[indexPath.row].eng!
        
        //load mywordphoto
        let currentUser = Auth.auth().currentUser
        let storageReference = Storage.storage().reference()
        let myWordPhotoRef = storageReference.child("user").child(currentUser!.uid).child("\(wordList[indexPath.row].eng!).jpg")
        myWordPhotoRef.getData(maxSize: 2 * 2048 * 2048) { (data, error) in
            if let error = error {
                print("error \(error)")
            } else {
                if let imageData = data {
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)
                        cell.imageView?.image = image
                    }
                }
            }
        }//end data,error closure
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        let chPronounce = wordList[indexPath.row].ch
        if  chPronounce != nil {
            let speechUtterance = AVSpeechUtterance(string: "\(chPronounce ?? "nothing")")
        let voice = AVSpeechSynthesisVoice(language: "zh-CN")
        speechUtterance.voice = voice
        speechUtterance.rate = 0.5
        self.synthesizer.speak(speechUtterance)
        } else {
            print ("Select nothing")
        }
        
    }//end didselectrow
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let storageReference = Storage.storage().reference()
        let ref = Database.database().reference()
        let currentUser = Auth.auth().currentUser
        let word = wordList[indexPath.row]
        let id = word.id
        let eng = word.eng
        ////刪除資料
        if editingStyle == .delete {
            ref.child("users").child(currentUser!.uid).child("MyWords").child(id!).setValue(nil)
            //print(id!)
            wordList.remove(at: indexPath.item)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            storageReference.child("user").child(currentUser!.uid).child("\(eng!).jpg").delete(completion: nil)
            
        }
        
    }
    func loadData() {
        self.wordList.removeAll()
        let currentUser = Auth.auth().currentUser
        let ref = Database.database().reference()
        ref.child("users").child(currentUser!.uid).child("MyWords").observeSingleEvent(of: .value, with: { (snapshot) in
            if let mywordDict = snapshot.value as? [String:AnyObject] {
                for (_,mywordElement) in mywordDict {
                    print(mywordElement);
                    let newword = Newword()
                    newword.id = mywordElement["id"] as? String
                    newword.ch = mywordElement["Chinese"] as? String
                    newword.eng = mywordElement["English"] as? String
                    
                    self.wordList.append(newword)
                    
        
                }
            }
            self.newwordTableView.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }//end loadData
    


    
    
}
