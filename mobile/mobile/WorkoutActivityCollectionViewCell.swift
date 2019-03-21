//
//  WorkoutActivityCollectionViewCell.swift
//  mobile
//
//  Created by Nadir Muzaffar on 2/17/19.
//  Copyright © 2019 Nadir Muzaffar. All rights reserved.
//

import UIKit

class WorkoutActivityCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var textLabel: UILabel! {
        didSet {
            textLabel.preferredMaxLayoutWidth = 5 // setting this makes text label wrap
        }
    }
    @IBOutlet weak var cellContent: UIView! {
        didSet {
            cellContent.layer.borderColor = UIColor.red.cgColor
            cellContent.layer.borderWidth = 8
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        layoutAttributes.frame.size.height = ceil(size.height)

        return layoutAttributes
    }
    
    override func layoutSubviews() {
        super.layoutSubviews() // DONT FUCKING FORGET TO CALL THIS
        self.contentView.layer.borderColor = UIColor.blue.cgColor
        self.contentView.layer.borderWidth = 4
        
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 2
    }
}
