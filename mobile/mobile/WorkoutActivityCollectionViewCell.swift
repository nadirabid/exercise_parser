//
//  WorkoutActivityCollectionViewCell.swift
//  mobile
//
//  Created by Nadir Muzaffar on 2/17/19.
//  Copyright © 2019 Nadir Muzaffar. All rights reserved.
//

import UIKit

class WorkoutActivityCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var cellContent: UIView!
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        layoutAttributes.frame.size.height = ceil(size.height)

        return layoutAttributes
    }
    
    override func layoutSubviews() {
        super.layoutSubviews() // DONT FUCKING FORGET TO CALL THIS
        
        cellContent.layer.cornerRadius = 6.0
        cellContent.layer.shadowColor! = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.08).cgColor
        cellContent.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        cellContent.layer.shadowRadius = 20
        cellContent.layer.shadowOpacity = 1.0
        
        let size = layer.preferredFrameSize()
        textLabel?.preferredMaxLayoutWidth = size.width
    }
}
