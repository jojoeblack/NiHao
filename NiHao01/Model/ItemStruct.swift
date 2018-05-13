//
//  ItemStruct.swift
//  NiHao01
//
//  Created by MacPro on 2018/4/7.
//  Copyright © 2018年 JoeMac01. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
//api上欄位轉變數
struct WordStruct: Decodable {
    let Ch: String
    let Eng: String
    let img: String
}

