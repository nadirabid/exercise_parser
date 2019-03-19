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
            cellContent.layer.borderWidth = 8
            cellContent.sizeToFit()
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var frame = layoutAttributes.frame
        frame.size.height = ceil(size.height)
        layoutAttributes.frame = frame
        return layoutAttributes
    }
    
    @IBOutlet weak var textLabel: UILabel!
    override func layoutSubviews() {
        self.contentView.layer.borderColor = UIColor.blue.cgColor
        self.contentView.layer.borderWidth = 4
        
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 2
    }
}
