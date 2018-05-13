//
//  AddViewController.swift
//  NiHao01
//
//  Created by MacPro on 2018/4/15.
//  Copyright © 2018年 JoeMac01. All rights reserved.
//

import UIKit
import Firebase
import Vision

class AddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var chTextField: UITextField!
    @IBOutlet weak var engTextField: UITextField!
    @IBOutlet weak var newImageView: UIImageView!
    
    
    var newword: Newword?
    let imagePicker = UIImagePickerController()
    let photoPicker = UIImagePickerController()
    var myNewWordFileName:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        photoPicker.delegate = self
        photoPicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
          newImageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIIMage")
            }
            
            detect(image: ciimage)
            
        }
        imagePicker.dismiss(animated: true, completion: nil)
        photoPicker.dismiss(animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneBtn_Tapped(_ sender: Any) {
        let mywordVC = self.storyboard?.instantiateViewController(withIdentifier: "navMywords") as! UINavigationController
        mywordVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        self.present(mywordVC, animated: true, completion: nil)
       
    }//end don
    
    @IBAction func chTextField_EndEdit(_ sender: Any) {
    }
    
    @IBAction func engTextField_EndEdit(_ sender: Any) {
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated : true,  completion: nil)
    }
    @IBAction func photoTapped(_ sender: Any) {
        photoPicker.sourceType = .photoLibrary
        present(photoPicker, animated : true,  completion: nil)
    }
    
    
    @IBAction func addBtn_Tapped(_ sender: Any) {
        if (self.chTextField.text?.count)! < 1 || (self.engTextField.text?.count)! < 1 {
            showMessage(titleTodDisplay: "Not working", messageToDisplay: "Nothing to Add")
            return
            
        } else {
            //新增單字時,同時上傳照片
            let optimizedImageData = UIImageJPEGRepresentation(newImageView.image!, 0.2)
            uploadProfileImage(imageData: optimizedImageData!)
            ///////////////////
            let currentUser = Auth.auth().currentUser
            if newword == nil {
                newword = Newword()
            }
            newword?.ch = self.chTextField.text
            newword?.eng = self.engTextField.text
            showMessage(titleTodDisplay: "Successful", messageToDisplay: "Add a new word to Word Pool")
            
            let ref =  Database.database().reference()
            let key = ref.child("users").child(currentUser!.uid).child("MyWords").childByAutoId().key
            let dictionaryNewword = ["id":key,
                                     "Chinese":newword!.ch!,
                                     "English":newword!.eng!]
            
            let childUpdates = ["users/\(currentUser!.uid)/MyWords/\(key)":dictionaryNewword]
            
            ref.updateChildValues(childUpdates, withCompletionBlock: { (error, ref) in
            
            self.chTextField.text = nil
            self.engTextField.text = nil
            self.newImageView.image = #imageLiteral(resourceName: "placeholder.png")
            })//end closure
            
            
        }
        
        
    }//end addItem_Tapped
    
    @IBAction func traslateBtn_Tapped(_ sender: Any) {
        translate()
    }
    @IBAction func cancel_Tapped(_ sender: Any) {
       
            self.chTextField.text = ""
            self.engTextField.text = ""
        
    }
    
    
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model fail to process image")
            }
            if let firstResult = results.first {
                let presentResult = firstResult.identifier.components(separatedBy: ",")
                self.engTextField.text = presentResult[0]
                self.translate()
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try! handler.perform([request])
        }
        
        
    }//end detect
    func translate() {
        let translator = ROGoogleTranslate()
        translator.apiKey = "// API Key" 
        
        var params = ROGoogleTranslateParams()
        params.source = "en"
        params.target = "zh-TW"
        params.text = engTextField.text ?? "The textfield is empty"
        
        translator.translate(params: params) { (result) in
            DispatchQueue.main.async {
                self.chTextField.text = "\(result)"
            }
        }
    }//end translate
    
    func showMessage(titleTodDisplay: String, messageToDisplay: String){
        let alertController = UIAlertController(title: titleTodDisplay, message: messageToDisplay, preferredStyle: .actionSheet)
        let OKAction = UIAlertAction(title: "OK", style: .default)
        {
            (ACTION:UIAlertAction!) in
            print("Ok button tapped")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {
            (ACTION) -> Void in
            return
        })
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }//end showMsg
    

    
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
        //上傳照片
        let photoFileName = "\(engTextField.text!).jpg"
        let storageReference = Storage.storage().reference()
        let currentUser = Auth.auth().currentUser
        let profileImageRef = storageReference.child("user").child(currentUser!.uid).child(photoFileName)
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
    
}
