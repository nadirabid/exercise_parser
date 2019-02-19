//
//  WorkoutActivityCollectionViewCell.swift
//  mobile
//
//  Created by Nadir Muzaffar on 2/17/19.
//  Copyright © 2019 Nadir Muzaffar. All rights reserved.
//

import UIKit

class WorkoutActivityCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cellContent: UIView! {
        didSet {
            cellContent.layer.borderColor = UIColor.red.cgColor
            cellContent.layer.borderWidth = 4
        }
    }
    
    @IBOutlet weak var textLabel: UILabel!
    override func layoutSubviews() {
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 2
    }
}
