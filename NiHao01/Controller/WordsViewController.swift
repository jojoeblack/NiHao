//
//  WordsViewController.swift
//  NiHao01
//
//  Created by MacPro on 2018/4/5.
//  Copyright © 2018年 JoeMac01. All rights reserved.
//

import UIKit
import AVFoundation
import Speech
import DottedProgressBar

class WordsViewController: UIViewController {

    @IBOutlet weak var imgImg: UIImageView!
    @IBOutlet weak var lblCh: UILabel!
    @IBOutlet weak var lblEng: UILabel!

    
    var ch = ""
    var eng = ""
    //var img = ""
    var topicName = ""
    var counter:Int = 1
    var topicArray = [Vocabulary]()
    var synthesizer = AVSpeechSynthesizer()
    var totalUtterance: Int = 0
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblCh.text = ch
        lblEng.text = eng
        DispatchQueue.main.async {
            if let imgURL = URL(string: self.topicArray[0].vocabularyImg) {
                do{
                    let imageData = try Data(contentsOf: imgURL)
                    self.imgImg.image = UIImage(data: imageData)}
                catch let err {
                    print("Error: \(err.localizedDescription)")
                }
                
            }
        }//end DispatchQueue
        
        loadDottedProgressBar(dotOrd: counter)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func pronounceBtn_Tapped(_ sender: Any) {
        guard let pronounceWord:String = lblCh.text
            else{
             return
        }
        //if !self.synthesizer.isSpeaking {
        //DispatchQueue.main.async {
            let speechUtterance = AVSpeechUtterance(string: "\(pronounceWord)")
            let voice = AVSpeechSynthesisVoice(language: "zh-CN")
            speechUtterance.voice = voice
            speechUtterance.rate = 0.5
            self.synthesizer.speak(speechUtterance)
        //}
        
        //}
    }
    @IBAction func nextBtn_Tapped(_ sender: Any) {
 
            if counter < topicArray.count {
                lblCh.text = topicArray[counter].vocabularyCh
                lblEng.text = topicArray[counter].vocabularyEng
                
                if let imgURL = URL(string: self.topicArray[counter].vocabularyImg) {
                    do{
                        let imageData = try Data(contentsOf: imgURL)
                        self.imgImg.image = UIImage(data: imageData)}
                    catch let err {
                        print("Error: \(err.localizedDescription)")
                    }
                    
                }
                
                
                //計算最後一個字
                if counter <= topicArray.count - 2 {
                    counter = counter + 1
                } else {
                    counter = topicArray.count
                    
                }
                loadDottedProgressBar(dotOrd: counter)
            } else {
                counter = topicArray.count
            }
           
            return

    }// end next btn
    
    @IBAction func oralTestBtn_Tapped(_ sender: Any) {
        let oraltestVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OralViewController") as! OralViewController
        
        self.addChildViewController(oraltestVC)
        //self.present(oraltestVC, animated: false, completion: nil)

        oraltestVC.view.frame = self.view.frame
        self.view.addSubview(oraltestVC.view)
        oraltestVC.didMove(toParentViewController: self)
        oraltestVC.correctAns = lblCh.text!
    }//end oral test
    
    func loadDottedProgressBar(dotOrd : Int){
        let arrayNum = topicArray.count
        
        let progressBar = DottedProgressBar()
        progressBar.progressAppearance = DottedProgressBar.DottedProgressAppearance(
            dotRadius: 5.0,
            dotsColor: UIColor.blue.withAlphaComponent(0.2),
            dotsProgressColor: UIColor.red,
            backColor: UIColor.clear
            
        )
        view.addSubview(progressBar)
        progressBar.frame = CGRect(x: 100, y: 650, width: 200, height: 20)
        
        progressBar.setNumberOfDots(arrayNum, animated: true)
        progressBar.setProgress(dotOrd, animated: true)
        
    }
    
}
