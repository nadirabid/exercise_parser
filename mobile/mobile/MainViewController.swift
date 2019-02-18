//
//  ViewController.swift
//  mobile
//
//  Created by Nadir Muzaffar on 12/29/18.
//  Copyright © 2018 Nadir Muzaffar. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var items = ["one", "two", "three"]
    
    let columnLayout = ColumnFlowLayout(
        cellsPerRow: 1,
        minimumInteritemSpacing: 10,
        minimumLineSpacing: 10,
        sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.collectionViewLayout = columnLayout
        collectionView?.contentInsetAdjustmentBehavior = .always
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WorkoutActivityCollectionViewCell", for: indexPath)
        
        if let workoutCollectionViewCell = cell as? WorkoutActivityCollectionViewCell {
            workoutCollectionViewCell.label.text = items[indexPath.row]
        }
        
        return cell
    }
}
