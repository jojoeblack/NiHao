//
//  RobotCorrect.swift
//  NiHao01
//
//  Created by MacPro on 2018/4/21.
//  Copyright © 2018年 JoeMac01. All rights reserved.
//

import Foundation
class RobotCorrect {
    var correct: String
    
    init() {
        let greetings = ["Well done","Great","Very Nice","Fantastic","Fabulous","Good answer","Brilliant","Wonderful","Impressive","There you go!","Keep it up.","I'm so proud of you!"]
        let reply = shuffleArray(arrayToBeShuffled: greetings)
        correct = reply
        
    }
}
