//
//  PaginationTableViewCell.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 11/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

public final class PaginationTableViewCell: BaseTableViewCell {
    
    @IBOutlet public weak var activityIndicatorView: UIActivityIndicatorView!
    
    public override func reset() {
        activityIndicatorView.stopAnimating()
        DispatchQueue.main.async { self.activityIndicatorView.startAnimating() }
    }
}
