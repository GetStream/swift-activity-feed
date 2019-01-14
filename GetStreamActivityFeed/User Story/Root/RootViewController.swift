//
//  ViewController.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 14/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    var presenter: RootPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let presenter = presenter {
            DispatchQueue.main.async(execute: presenter.setup)
        }
    }
}
