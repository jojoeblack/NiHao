//
//  RobotGreeting.swift
//  NiHao01
//
//  Created by MacPro on 2018/4/21.
//  Copyright © 2018年 JoeMac01. All rights reserved.
//

import Foundation
class RobotGreeting {
    var greeting: String
    
    init() {
        let greetings = ["How are you doing?","How’s it going?","What’s up?","What’s new?","What’s going on?","How’s everything ?","How are things?","How’s life?","How’s your day?","How’s your day going?","Good to see you","Pleased to meet you","How have you been?"]
        let sayHi = shuffleArray(arrayToBeShuffled: greetings)
        greeting = sayHi
        
    }
}

func shuffleArray(arrayToBeShuffled array1:[String]) -> String{
    var oldArray = array1
    var newArray = [String]()
    var randomNum:Int
    for _ in array1 {
        randomNum = Int(arc4random_uniform(UInt32(oldArray.count)))
        newArray.append(oldArray[randomNum])
        oldArray.remove(at: randomNum)
    }
    return newArray[0]
}
