//
//  ViewController.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 14/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    
    var presenter: RootPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.setup()
    }
}
