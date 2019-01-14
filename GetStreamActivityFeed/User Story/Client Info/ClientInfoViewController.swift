//
//  ClientInfoViewController.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 14/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

final class ClientInfoViewController: UIViewController, BundledNibLoadable {
    
    @IBOutlet weak var infoLabel: UILabel!
    
    var info: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let info = info {
            infoLabel.text = info
        }
    }
}
