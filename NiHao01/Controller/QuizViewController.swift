//
//  QuizViewController.swift
//  NiHao01
//
//  Created by MacPro on 2018/4/19.
//  Copyright © 2018年 JoeMac01. All rights reserved.
//

import UIKit
import AVFoundation
import Speech
import MARoundButton

class QuizViewController: ViewController {
    var ch = ""
    var eng = ""
    var topicName = ""
    var counter:Int = 0
    var topicArray = [Vocabulary]()
    
    var score:Int = 0
    var userAnswer:String = ""
    
    //語音辨識變數
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier:"zh-TW"))
    var request : SFSpeechAudioBufferRecognitionRequest? = nil
    var recognitionTask : SFSpeechRecognitionTask?
    
    @IBOutlet weak var quizImg: UIImageView!
    @IBOutlet weak var recordBtn: MARoundButton!
    @IBOutlet weak var stopBtn: MARoundButton!
    @IBOutlet weak var checkBtn: MARoundButton!
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var questionCounterLbl: UILabel!
    @IBOutlet weak var useranswerLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
            if let imgURL = URL(string: self.topicArray[0].vocabularyImg) {
                do{
                    let imageData = try Data(contentsOf: imgURL)
                    self.quizImg.image = UIImage(data: imageData)}
                catch let err {
                    print("Error: \(err.localizedDescription)")
                }
                
            }
        }//end DispatchQueue
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func recordBtn_Tapped(_ sender: Any) {
        recordBtn.isEnabled = false
        
        self.recordBtn.backgroundColor = UIColor.gray
        self.stopBtn.backgroundColor = UIColor.green
        stopBtn.isEnabled = true
        perform(#selector(recognizeSpeech), with: nil, afterDelay: 0.5)
    }
    
    @IBAction func stopBtn_Tapped(_ sender: Any) {
        recordBtn.isEnabled = true
        
        self.stopBtn.backgroundColor = UIColor.gray
        self.recordBtn.backgroundColor = UIColor.red
        stopBtn.isEnabled = false
        stopRecording()
        useranswerLbl.text = userAnswer
    }
    @IBAction func checkBtn_Tapped(_ sender: Any) {
        
        if userAnswer == ch {
            if  counter + 1 <= topicArray.count {
              score += 1
            }
        }
        
        
        updateUI()
        
            //計算最後一個字
            if counter <= topicArray.count - 1 {
                counter = counter + 1
            }
            else {
                counter = topicArray.count
            }
            if counter < topicArray.count {
                ch = topicArray[counter].vocabularyCh
                if let imgURL = URL(string: self.topicArray[counter].vocabularyImg) {
                    do{
                        let imageData = try Data(contentsOf: imgURL)
                        self.quizImg.image = UIImage(data: imageData)}
                    catch let err {
                        print("Error: \(err.localizedDescription)")
                    }
                    
                }
              
            }//end if
            useranswerLbl.text = "Your ANS"
            return
            
        
        
    }
    
    func updateUI() {
        scoreLbl.text = "Score: \(score)"
        if counter < topicArray.count {
          questionCounterLbl.text = "\(counter+1)/ \(topicArray.count)"
        } else {
          questionCounterLbl.text = "\(counter)/ \(topicArray.count)"
        }
        
        progressView.frame.size.width = (view.frame.size.width / CGFloat(topicArray.count)) * CGFloat(counter+1)
        
        
    }
    func stopRecording() {
        audioEngine.stop()
        request?.endAudio()
        recognitionTask?.cancel()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    @objc func recognizeSpeech() {
        let node = audioEngine.inputNode
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = request else {
            fatalError ("Can not create a recognition request")
        }
        recognitionRequest.shouldReportPartialResults = true
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request?.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            return print (error)
            
        }
        guard let recognizeMe = SFSpeechRecognizer() else {
            return
        }
        if !recognizeMe.isAvailable {
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request!, resultHandler: { result, error in
            if let result = result {
            self.userAnswer = result.bestTranscription.formattedString
            } else if let error = error {
                print(error)
            }
        })
    }//end recognizeSpeech
    
 

}
