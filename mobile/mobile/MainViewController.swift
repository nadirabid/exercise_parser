//
//  ViewController.swift
//  mobile
//
//  Created by Nadir Muzaffar on 12/29/18.
//  Copyright © 2018 Nadir Muzaffar. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var items = ["one"]
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityWorkoutCell", for: indexPath)
        
        if let workoutTableViewCell = cell as? WorkoutTableViewCell {
            workoutTableViewCell.workoutName.text = items[indexPath.row]
        }
        
        return cell
    }
}
