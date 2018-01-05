//
//  WorkoutListViewController.swift
//  groupie
//
//  Created by Xinran on 4/23/16.
//  Copyright © 2016 DaisyDaisy. All rights reserved.
//

import UIKit


class WorkoutListViewController: UIViewController{
    
    @IBOutlet weak var workoutListTableView: UITableView?
    
    deinit {
        NSLog("Deinit worklistviewcontroller")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        workoutListTableView?.dataSource = self
        workoutListTableView?.delegate = self
        workoutListTableView?.estimatedRowHeight = 400
        workoutListTableView?.rowHeight = UITableViewAutomaticDimension
        
        NotificationCenter.default.addObserver(self, selector:#selector(updateWorkouts), name: NSNotification.Name(rawValue: Constants.Notifications.WorkoutsUpdated), object: nil)
    }
    
    @objc fileprivate func updateWorkouts(){
        workoutListTableView?.reloadData()
    }
    
}

extension WorkoutListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 210
    }
    
}

extension WorkoutListViewController: UITableViewDataSource {
   
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
      //  return DataManager.sharedInstance.workouts.count
        return 3
    }
    
    func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
  /*      let cell = self.workoutListTableView?.dequeueReusableCell(withIdentifier: Constants.Cells.WorkoutListCell) as! WorkoutListCell
        
        let workout = DataManager.sharedInstance.workouts[indexPath.row]
        
        cell.nameLabel?.text = workout.name*/
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! WorkoutCell
        
        
        cell.opponents = ["Jeff Myers", "Equinox SoHo", "Chelsea Young", "Ben White", "Robie Wiliams"]
        cell.message = "We're going for a long distance run, anyone wanna join?"
        cell.date = "Posted 9m ago"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
