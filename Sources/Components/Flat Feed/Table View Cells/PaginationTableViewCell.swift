//
//  PaginationTableViewCell.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 11/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

final class PaginationTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func reset() {
        activityIndicatorView.stopAnimating()
        DispatchQueue.main.async { self.activityIndicatorView.startAnimating() }
    }
}
