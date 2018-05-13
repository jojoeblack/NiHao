//
//  RobotInstruct.swift
//  NiHao01
//
//  Created by MacPro on 2018/4/21.
//  Copyright © 2018年 JoeMac01. All rights reserved.
//

import Foundation
class Robotinstruct {
    var instruction: String
    
    init() {
        let greetings = ["Give it a try","Go for it.","Go ahead","Why not?","It's worth a shot","What are you waiting for?","Just do it."]
        let reply = shuffleArray(arrayToBeShuffled: greetings)
        instruction = reply
        
    }
}
