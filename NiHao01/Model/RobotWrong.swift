//
//  RobotWrong.swift
//  NiHao01
//
//  Created by MacPro on 2018/4/21.
//  Copyright © 2018年 JoeMac01. All rights reserved.
//

import Foundation
class RobotWrong {
    var wrong: String
    
    init() {
        let greetings = ["Give it another try!","Don't give up.","Keep pushing.","Keep fighting!","Stay strong.","Come on! You can do it!"]
        let reply = shuffleArray(arrayToBeShuffled: greetings)
        wrong = reply
        
    }
}
