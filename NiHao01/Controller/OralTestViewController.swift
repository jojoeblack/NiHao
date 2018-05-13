//
//  OralTestViewController.swift
//  NiHao01
//
//  Created by MacPro on 2018/4/8.
//  Copyright © 2018年 JoeMac01. All rights reserved.
//

import UIKit
import Speech
import AVFoundation

class OralTestViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var robotImg: UIImageView!
    @IBOutlet weak var answerLbl: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "zh-TW"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var synthesizer = AVSpeechSynthesizer()
    var totalUtterance: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //彈出視窗
        self.view.backgroundColor = UIColor.gray.withAlphaComponent(0.8)
        //顯示動畫
        robotImg.loadGif(name: "robot04")
        
        //下指令
         let pronounceWord:String = "好的,你唸一次"

        if !self.synthesizer.isSpeaking {
            let speechUtterance = AVSpeechUtterance(string: "\(pronounceWord)")
            let voice = AVSpeechSynthesisVoice(language: "zh-CN")
            speechUtterance.voice = voice
            speechUtterance.rate = 0.5
            self.synthesizer.speak(speechUtterance)
        }// end speaking
        
        playBtn.isEnabled = true
        
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.playBtn.isEnabled = isButtonEnabled
            }
        }
    }// end viewDidLoad

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playBtn_Tapped(_ sender: Any) {
        
            if  audioEngine.isRunning {
                audioEngine.stop()
                recognitionRequest?.endAudio()
                recognitionRequest = nil
                //synthesizer.continueSpeaking()
                playBtn.isEnabled = false
                playBtn.setTitle("Start Recording", for: .normal)
                
                
                    /*let speechUtterance = AVSpeechUtterance(string: "hi")
                    let voice = AVSpeechSynthesisVoice(language: "zh-CN")
                    speechUtterance.voice = voice
                    speechUtterance.rate = 0.5
                    self.synthesizer.speak(speechUtterance)*/
                
        } else {
                startRecording()
                playBtn.setTitle("Stop Recording", for: .normal)
        }
     

        
        
    }//END playBtn
    @IBAction func cancelBtn_Tapped(_ sender: Any) {
        self.view.removeFromSuperview()
    }//end close
    func authorizeSR() {
        SFSpeechRecognizer.requestAuthorization{ authStatus in
            
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.playBtn.isEnabled = true
                    
                case .denied:
                    self.playBtn.isEnabled = false
                    
                case .notDetermined:
                    self.playBtn.isEnabled = false
                case .restricted:
                    self.playBtn.setTitle("Speech recognition restricted on device", for: .disabled)
                }
            }
        }
            
    }//end authorizeSR
    func startRecording() {
        
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = true  //6
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil {
                
                self.answerLbl.text = result?.bestTranscription.formattedString  //9
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.playBtn.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        answerLbl.text = "YOUR ANS!"
        
    }//end startrecording
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            playBtn.isEnabled = true
        } else {
            playBtn.isEnabled = false
        }
    }


}
