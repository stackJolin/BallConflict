//
//  ViewController.swift
//  BallConflict
//
//  Created by user on 15/7/2.
//  Copyright © 2015年 stackJolin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.multipleTouchEnabled = true;
        let selfView:BallAnimation = BallAnimation(frame: self.view.bounds)
        self.view.addSubview(selfView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

