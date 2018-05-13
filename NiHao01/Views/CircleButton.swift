//
//  CircleButton.swift
//  NiHao01
//
//  Created by MacPro on 2018/4/8.
//  Copyright © 2018年 JoeMac01. All rights reserved.
//

import UIKit
@IBDesignable
class CircleButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 60.0{
        didSet{
            setupView()
        }
    }
    override func prepareForInterfaceBuilder() {
        setupView()
    }
    func setupView() {
        layer.cornerRadius = cornerRadius
    }
}
