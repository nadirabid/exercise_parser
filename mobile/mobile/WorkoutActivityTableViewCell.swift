//
//  WorkoutActivityTableViewCell.swift
//  mobile
//
//  Created by Nadir Muzaffar on 1/28/19.
//  Copyright © 2019 Nadir Muzaffar. All rights reserved.
//

import UIKit

@IBDesignable
class WorkoutActivityTableViewCell: UITableViewCell {
    @IBInspectable var cornerRadius: CGFloat = 2
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 3
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.5
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var cardView: UIView! {
        didSet {
//            cardView.layer.cornerRadius = cornerRadius
//            let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
//            
//            cardView.layer.masksToBounds = false
//            cardView.layer.shadowColor = shadowColor?.cgColor
//            cardView.layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
//            cardView.layer.shadowOpacity = shadowOpacity
//            cardView.layer.shadowPath = shadowPath.cgPath
            
            cardView.layer.backgroundColor = UIColor.white.cgColor
        }
    }
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        
        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
}
