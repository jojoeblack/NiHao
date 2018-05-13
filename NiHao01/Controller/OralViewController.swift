//
//  OralViewController.swift
//  NiHao01
//
//  Created by MacPro on 2018/4/10.
//  Copyright © 2018年 JoeMac01. All rights reserved.
//

import UIKit
import Speech
import AVFoundation


class OralViewController: UIViewController {

    @IBOutlet weak var robotImg: UIImageView!
    @IBOutlet weak var ansLbl: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    //correct ans
    var correctAns = ""
    //語音合成變數
    var synthesizer = AVSpeechSynthesizer()
    var totalUtterance: Int = 0
    //語音辨識變數
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier:"zh-TW"))
    var request : SFSpeechAudioBufferRecognitionRequest? = nil
    var recognitionTask : SFSpeechRecognitionTask?
    //機器人答話
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //彈出視窗
        self.view.backgroundColor = UIColor.clear.withAlphaComponent(0.8)
        //顯示動畫
        robotImg.loadGif(name: "robot04")
    
        //下指令
        let pronounceWord:String = Robotinstruct.init().instruction
        
        if !self.synthesizer.isSpeaking {
            let speechUtterance = AVSpeechUtterance(string: "\(pronounceWord)")
            let voice = AVSpeechSynthesisVoice(language: "en-UK")
            speechUtterance.voice = voice
            speechUtterance.rate = 0.5
            self.synthesizer.speak(speechUtterance)
            
            }//end synthesizer
        
        
        
        stopBtn.isEnabled = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playBtn_Tapped(_ sender: Any) {
        
        playBtn.isEnabled = false
        
        self.playBtn.backgroundColor = UIColor.gray
        self.stopBtn.backgroundColor = UIColor.green
        stopBtn.isEnabled = true
        perform(#selector(recognizeSpeech), with: nil, afterDelay: 0.5)
        
        
        
        
            
    }
    @IBAction func stopBtn_Tapped(_ sender: Any) {
        playBtn.isEnabled = true
        self.stopBtn.backgroundColor = UIColor.gray
        self.playBtn.backgroundColor = UIColor.red
        stopBtn.isEnabled = false
        stopRecording()
    }
    
    @IBAction func checkBtn_Tapped(_ sender: Any) {
        playBtn.setTitle("X", for: .normal)
        stopBtn.setTitle("V", for: .normal)
        
    
        //答對
        if ansLbl.text == correctAns {
            
            playBtn.backgroundColor = UIColor.gray
            stopBtn.backgroundColor = UIColor.green
            let pronounceWord:String = RobotCorrect.init().correct
            let speechUtterance = AVSpeechUtterance(string: "\(pronounceWord)")
            let voice = AVSpeechSynthesisVoice(language: "en-UK")
            speechUtterance.voice = voice
            speechUtterance.rate = 0.5
            self.synthesizer.speak(speechUtterance)
            
        }
            else {
            //答錯
            
            playBtn.backgroundColor = UIColor.red
            stopBtn.backgroundColor = UIColor.gray
            let pronounceWord:String = RobotWrong.init().wrong
            let speechUtterance = AVSpeechUtterance(string: "\(pronounceWord)")
            let voice = AVSpeechSynthesisVoice(language: "en-UK")
            speechUtterance.voice = voice
            speechUtterance.rate = 0.5
            self.synthesizer.speak(speechUtterance)
        }
        playBtn.isEnabled = false
        stopBtn.isEnabled = false
       
    }//end check button
    //返回
    @IBAction func cancelBtn_Tapped(_ sender: Any) {
        self.view.removeFromSuperview()
        
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
                let transcribedString = result.bestTranscription.formattedString
                self.ansLbl.text = transcribedString
            } else if let error = error {
                print(error)
            }
        })
    }//end recognizeSpeech
    func passToWordsVC() {
        //let wordsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WordsViewController") as! WordsViewController
            //wordsVC.scoreLbl.text = "5"
            
            //wordsVC.loadDottedProgressBar()
    }//end oral test
}
