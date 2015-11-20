//
//  ViewController.swift
//  SequenceView
//
//  Created by Evgenii Rtishchev on 19/11/15.
//  Copyright © 2015 Evgenii Rtishchev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        for (var i = 0; i < 3; i++) {
            let view = ASView(name: "hate0001", start: 1, count: 50, frame: CGRectMake(0, 0, 100, 100))
            self.view.addSubview(view)
            view.startAnimation()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

