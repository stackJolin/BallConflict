//
//  BallView.swift
//  BallConflict
//
//  Created by user on 15/7/2.
//  Copyright © 2015年 stackJolin. All rights reserved.
//

import UIKit

class BallView: UIView {
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.layer.backgroundColor = UIColor.redColor().CGColor
        self.layer.borderColor = UIColor.greenColor().CGColor
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.layer.borderWidth = 2
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
