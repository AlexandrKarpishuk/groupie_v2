//
//  WorkoutPublicVC.swift
//  groupie
//
//  Created by Sania on 6/21/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces
import MapKit



class WorkoutPublicVC : UIViewController {
    
   
    fileprivate var workouts = [WorkoutInfo]()
    fileprivate var p_needOpponentsSmallShowIndexes = Set<Int>()
    fileprivate var p_needMessageSmallShowIndexes = Set<Int>()
    fileprivate var selectedWorkout: WorkoutInfo?
    
    @IBOutlet weak var workoutTableView: UITableView?
    
    fileprivate var commentsCount = [0, 2, 1]
    fileprivate var cachedCell: WorkoutCell?
    
    fileprivate var p_isSubscribedForNotifications = false
    fileprivate var p_editVC: POST_EDIT_VC?
    
    fileprivate var placesClient = GMSPlacesClient()
    
    fileprivate var p_cellHeight = [Int: CGFloat]()
    fileprivate var p_needRecalcIndexes = Set<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
   //     self.workoutTableView?.rowHeight = UITableViewAutomaticDimension
    //    self.workoutTableView?.estimatedRowHeight = 180
        for index in 0..<6 {
            self.p_needRecalcIndexes.insert(index)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.prepareToShow()
        
        if (self.workouts.count == 0) {
            self.view.showActivity()
        }
    }
    
    func prepareToShow() {
        self.readFromCache()
        self.workoutTableView?.reloadData()
        if (ServerManager.shared.isLoggedIn) {
            self.updateWorkoutsFromServer()
        } else {
            if (!self.p_isSubscribedForNotifications) {
                NotificationCenter.default.addObserver(self, selector: #selector(needUpdateWorkouts), name: ServerManager.LOGGED_IN_NOTIFICATION, object: nil)
            }
        }
        if (!self.p_isSubscribedForNotifications) {
            NotificationCenter.default.addObserver(self, selector: #selector(didPost), name: WorkoutsManager.WORKOUT_DID_POST_NOTIFICATION, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(updateWorkoutComments), name:WorkoutsManager.WORKOUT_COMMENTS_UPDATED, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(updateWorkoutLikes), name:WorkoutsManager.WORKOUT_LIKES_UPDATED, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(updateWorkoutLikes), name: LikesManager.ON_LIKED_NOTIFICATION, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(onWorkoutsUpdated), name:WorkoutsManager.WORKOUTS_DID_UPDATED, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(onDB_Readed), name:WorkoutsManager.WORKOUT_DB_READED, object: nil)
            
            self.p_isSubscribedForNotifications = true
        }
    }
    
    func onDB_Readed() {
        DispatchQueue.main.async { [weak self] in
            self?.readFromCache()
            if (self?.workouts.count != 0) {
                self?.view.hideActivity()
            }
            for index in 0..<6 {
                self?.p_needRecalcIndexes.insert(index)
            }
            self?.workoutTableView?.reloadData()
        }
    }
    
    override func PagingWillMove() {
        super.PagingWillMove()
        
        self.prepareToShow()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (self.p_isSubscribedForNotifications) {
            NotificationCenter.default.removeObserver(self)
            
            self.p_isSubscribedForNotifications = false
        }
        
        self.view.hideActivity()
    }
    
    func readFromCache() {
        self.workouts = WorkoutsManager.shared.workoutsPublic.sorted(by: { (info1:WorkoutInfo, info2:WorkoutInfo) -> Bool in
            return info1.init_time_original > info2.init_time_original
        })
        self.p_needMessageSmallShowIndexes = Set<Int>()
        self.p_needOpponentsSmallShowIndexes = Set<Int>()
    }
    
    func didPost() {
        DispatchQueue.main.async { [weak self] in
            let oldPostsCount = self?.workouts.count
            
            self?.readFromCache()
            
            if (self != nil && oldPostsCount != nil && self!.workouts.count - oldPostsCount! == 1) {
                self?.workoutTableView?.beginUpdates()
                
                
                self?.workoutTableView?.insertRows(at: [IndexPath(row:0, section:0)], with: UITableViewRowAnimation.top)
                
                if let strongSelf = self {
                    var newHeights = [Int: CGFloat]()
                    for (key, height) in strongSelf.p_cellHeight {
                        newHeights[key + 1] = height
                    }
                    strongSelf.p_cellHeight = newHeights
                }
                self?.workoutTableView?.endUpdates()
            } else {
                for index in 0..<6 {
                    self?.p_needRecalcIndexes.insert(index)
                }
                self?.workoutTableView?.reloadData()
            }
        }
        self.updateWorkoutsFromServer()
    }
    
    func needUpdateWorkouts() {
        self.readFromCache()
        DispatchQueue.main.async { [weak self] in
            if let strongSelf = self {
                if let visibleCellsIndexPath = strongSelf.workoutTableView!.indexPathsForVisibleRows {
                    for indexPath in visibleCellsIndexPath {
                        strongSelf.p_needRecalcIndexes.insert(indexPath.row)
                    }
                }
            }
            self?.workoutTableView?.reloadData()
        }
        self.updateWorkoutsFromServer()
    }
    
    fileprivate func updateWorkoutsFromServer() {
        if (ServerManager.shared.isLoggedIn) {
            WorkoutsManager.shared.UpdateWorkoutsPublic()
        }
    }
    
    func onWorkoutsUpdated(_ notify: Notification) {
        if (!Thread.isMainThread) {
            DispatchQueue.main.async {
                self.onWorkoutsUpdated(notify)
            }
            return
        }
        
        
        if (self.workouts.count == 0) {
            self.readFromCache()
            
            DispatchQueue.main.async { [weak self] in
                self?.workoutTableView?.reloadData()
                self?.view.hideActivity()
            }
        } else {            
    //        let unchanged:[WorkoutInfo] = notify.userInfo![WorkoutsManager.INFO_UNCHANGED]!  as! [WorkoutInfo]
            var updated = notify.userInfo![WorkoutsManager.INFO_UPDATED]! as! [WorkoutInfo]
            var new:[WorkoutInfo] = notify.userInfo![WorkoutsManager.INFO_NEW]! as! [WorkoutInfo]
    //        let unused:[WorkoutInfo] = notify.userInfo![WorkoutsManager.INFO_UNUSED]! as! [WorkoutInfo]
            
            updated = updated.filter({ (info:WorkoutInfo) -> Bool in
                return info.isPublic && info.is_active
            })
            new = new.filter({ (info:WorkoutInfo) -> Bool in
                return info.isPublic && info.is_active
            })

            
            let paths = self.workoutTableView?.indexPathsForVisibleRows
            var toUpdatePaths = [IndexPath]()
            for indexPath in paths! {
                let info = self.workouts[indexPath.row]
                for updatedInfo in updated {
                    if (updatedInfo.id == info.id) {
                        toUpdatePaths.append(indexPath)
                        self.p_needRecalcIndexes.insert(indexPath.row)
                        break
                    }
                }
                info.updateComments(completed: nil, fail: nil)
                info.updateLikes(completed: nil, fail: nil)
            }
            var toInsertPaths = [IndexPath]()
            let sortedNew = new.sorted(by: { (info1:WorkoutInfo, info2:WorkoutInfo) -> Bool in
                return info1.init_time_original > info2.init_time_original
            })
            for index in 0..<sortedNew.count {
                toInsertPaths.append(IndexPath(row: index, section: 0))

                var newHeights = [Int: CGFloat]()
                for (key, height) in self.p_cellHeight {
                    newHeights[key + 1] = height
                }
                self.p_cellHeight = newHeights
                self.p_needRecalcIndexes.insert(index)
            }
            
            if (toUpdatePaths.count > 0 || toInsertPaths.count > 0) {
                DispatchQueue.main.async { [weak self] in
                    self?.workoutTableView?.beginUpdates()
                    self?.workouts.insert(contentsOf: sortedNew, at: 0)
                    for i in 0..<sortedNew.count {
                        toInsertPaths.append(IndexPath(row: i, section: 0))
                    }
                    if let strongSelf = self {
                        for i in 0..<strongSelf.workouts.count {
                            strongSelf.p_needRecalcIndexes.insert(i)
                        }
                    }

                    self?.workoutTableView?.reloadRows(at: toUpdatePaths, with: .fade)
                    self?.workoutTableView?.insertRows(at: toInsertPaths, with: .top)
                    
                    self?.workoutTableView?.endUpdates()
                }
            }

            /*self.workouts = newWorkouts.sorted(by: { (info1:WorkoutInfo, info2:WorkoutInfo) -> Bool in
                return info1.init_time_original > info2.init_time_original
            })
            
            DispatchQueue.main.async {
                self.workoutTableView?.reloadData()
            }*/
        }
    }
    
    func updateWorkoutComments(_ notify: Notification) {
        if let updatedWorkout = notify.object as? WorkoutInfo {
            DispatchQueue.main.async { [weak self] in
                let paths = self?.workoutTableView?.indexPathsForVisibleRows
                var toUpdatePaths = [IndexPath]()
                for indexPath in paths! {
                    let info = self?.workouts[indexPath.row]
                    if (info != nil && updatedWorkout.id == info!.id) {
                        toUpdatePaths.append(indexPath)
                        let cell = self?.workoutTableView?.cellForRow(at: indexPath) as! WorkoutCell
                        cell.commentsCount = updatedWorkout.comments.filter({ (commentInfo:CommentInfo) -> Bool in
                                return commentInfo.is_active
                        }).count
                    }
                }
                
                if (toUpdatePaths.count > 0) {
                    //       self?.workoutTableView?.beginUpdates()
                    
                    /*   if (updatedWorkout.comments.count == 1) {
                     self?.workoutTableView?.reloadRows(at: toUpdatePaths, with: .fade)
                     } else {*/
                     self?.workoutTableView?.reloadRows(at: toUpdatePaths, with: .none)
                     /*}*/
                    
                    //       self?.workoutTableView?.endUpdates()
                }
            }
        }
    }
    
    func updateWorkoutLikes(_ notify: Notification) {
        if let updatedWorkout = notify.object as? WorkoutInfo {
            let paths = self.workoutTableView?.indexPathsForVisibleRows
            for indexPath in paths! {
                let info = self.workouts[indexPath.row]
                if (updatedWorkout.id == info.id) {
                    DispatchQueue.main.async { [weak self] in
                        let cell = self?.workoutTableView?.cellForRow(at: indexPath) as? WorkoutCell
                        if (cell != nil) {
                            cell?.likes = updatedWorkout.likes
                            cell?.isLiked = LikesManager.shared.isLiked(workout: updatedWorkout)
                        }
                    }
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                let paths = self?.workoutTableView?.indexPathsForVisibleRows
                for indexPath in paths! {
                    let cell = self?.workoutTableView?.cellForRow(at: indexPath) as? WorkoutCell
                    if (cell != nil) {
                        if let updatedWorkout = self?.workouts[indexPath.row] {
                            cell?.likes = updatedWorkout.likes
                            cell?.isLiked = LikesManager.shared.isLiked(workout: updatedWorkout)
                        }
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if (self.selectedWorkout != nil) {
            let destVC = segue.destination
            if let commentsVC = destVC as? CommentsVC {
                commentsVC.workout = self.selectedWorkout
            }
        }
    }
}

extension WorkoutPublicVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (self.p_needRecalcIndexes.contains(indexPath.row)) {
            let info = self.workouts[indexPath.row]
            if (self.cachedCell == nil) {
                self.cachedCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? WorkoutCell
            }
            let autosizeOpponents = !self.p_needOpponentsSmallShowIndexes.contains(indexPath.row)
            let autosizeMessage = !self.p_needMessageSmallShowIndexes.contains(indexPath.row)
            let height = self.cachedCell!.fullHeight(writer: info.organizer_name, location: info.location_name, opponents: info.attendees_names, message: info.descr, commentsCount: info.comments.filter({ (commentInfo:CommentInfo) -> Bool in
                    return commentInfo.is_active
            }).count, autosizeOpponents: autosizeOpponents, autosizeMessage: autosizeMessage, workout: info)
            self.p_needRecalcIndexes.remove(indexPath.row)
            self.p_cellHeight[indexPath.row] = height
            return height
        } else {
            if (self.p_cellHeight[indexPath.row] != nil) {
                return self.p_cellHeight[indexPath.row]!
            } else {
                return 180
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.p_needRecalcIndexes.insert(indexPath.row + 1)
        self.p_needRecalcIndexes.insert(indexPath.row - 1)
        
        let info = self.workouts[indexPath.row]
        info.updateLikes(completed: nil, fail: nil)
        info.updateComments(completed: nil, fail: nil)
    }
}

extension WorkoutPublicVC: UITableViewDataSource {
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        //  return DataManager.sharedInstance.workouts.count
        return self.workouts.count
    }
    
    func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        /*      let cell = self.workoutListTableView?.dequeueReusableCell(withIdentifier: Constants.Cells.WorkoutListCell) as! WorkoutListCell
         
         let workout = DataManager.sharedInstance.workouts[indexPath.row]
         
         cell.nameLabel?.text = workout.name*/
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! WorkoutCell

        
        let info = self.workouts[indexPath.row]
        cell.workoutInfo = info
        
//        cell.autosizeOpponents = false
//        cell.autosizeMessage = false
        cell.writer = info.organizer_name
        cell.location = info.location_name
        cell.opponents = info.attendees_names
        cell.message = info.descr
        cell.likes = info.likes
        cell.isLiked = LikesManager.shared.isLiked(workout: info)

        if (info.init_time != nil) {
            cell.date = "\(Date().agoFromDate(date: info.init_time!)) ago"
        } else {
            cell.date = ""
        }
        cell.commentsCount = info.comments.filter({ (commentInfo:CommentInfo) -> Bool in
            return commentInfo.is_active
        }).count
        
        if (self.p_needOpponentsSmallShowIndexes.contains(indexPath.row)) {
            cell.autosizeOpponents = false
        } else {
            cell.autosizeOpponents = true
        }
        if (self.p_needMessageSmallShowIndexes.contains(indexPath.row)) {
            cell.autosizeMessage = false
        } else {
            cell.autosizeMessage = true
        }
        
        cell.onComments = { [weak self] (workout: WorkoutInfo?) in
            if (workout != nil) {
                self?.selectedWorkout = workout
                self?.performSegue(withIdentifier: "Comments", sender: nil)
            }
        }
        
        var imageURL = URL(string: info.organizer_image)
        if (imageURL == nil) {
            imageURL = Bundle.main.url(forResource: "groupieAvatar.png", withExtension: nil)
        }
        cell.btnAvatar?.sd_setBackgroundImage(with: imageURL, for: .normal, placeholderImage: UIImage(named:"UserPlaceholder"), options: .allowInvalidSSLCertificates, completed: nil)
        
        var currentUserName = ""
        if (ServerManager.shared.currentUser?.username != nil) {
            currentUserName = ServerManager.shared.currentUser!.username
        }
        if (info.organizer_name == currentUserName) {
            cell.setButtonType(.edit)
        } else if (info.attendees_names.contains(currentUserName)) {
            cell.setButtonType(.leave)
        } else {
            cell.setButtonType(.join)
        }
        cell.onJoin = { [weak self, weak tableView] (workout: WorkoutInfo?) in
            if (workout != nil) {
                WorkoutsManager.shared.Join(workout: workout!, onSuccess: { [weak tableView] (WorkoutInfo) in
                    DispatchQueue.main.async {
                        tableView?.beginUpdates()
                        
                        tableView?.reloadRows(at: [indexPath], with: .fade)
                        
                        tableView?.endUpdates()
                    }
                }, onFail: { [weak self] (message:String?) in
                    let alert = UIAlertController(title: "Attention",
                                                  message: message,
                                                  preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK",
                                                  style: UIAlertActionStyle.cancel,
                                                  handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                })
            }
        }
        cell.onLeave = { [weak self, weak tableView] (workout: WorkoutInfo?) in
            if (workout != nil) {
                WorkoutsManager.shared.Leave(workout: workout!, onSuccess: { [weak tableView] (WorkoutInfo) in
                    DispatchQueue.main.async { [weak tableView] in
                        tableView?.beginUpdates()
                        
                        tableView?.reloadRows(at: [indexPath], with: .fade)
                        
                        tableView?.endUpdates()
                    }
                }, onFail: { [weak self] (message:String?) in
                    let alert = UIAlertController(title: "Attention",
                                                  message: message,
                                                  preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK",
                                                  style: UIAlertActionStyle.cancel,
                                                  handler: { (action: UIAlertAction) in
                    }))
                    self?.present(alert, animated: true, completion: nil)
                })
            }
        }
        cell.onEdit = { [weak self, weak tableView] (workout: WorkoutInfo?) in
            let editStoryboard = UIStoryboard(name: "EditPost", bundle: nil)
            self?.p_editVC = editStoryboard.instantiateInitialViewController() as? POST_EDIT_VC
            self?.p_editVC?.workout = workout
            if (workout != nil) {
                self?.view.showActivity(animated: true)
                DispatchQueue.global().async {
                    let group = DispatchGroup()
                    var users = [UserInfo]()
                    for username in workout!.attendees_names {
                        group.enter()
                        UsersManager.shared.getUser(userName: username, completed: { (user:UserInfo) in
                            users.append(user)
                            group.leave()
                        }, fail: {
                            group.leave()
                        })
                    }
                    group.wait(wallTimeout: DispatchWallTime.now() + 30.0)
                    DispatchQueue.main.async {
                        self?.p_editVC?.loadViewIfNeeded()
                        self?.p_editVC?.withWhomUsers = users
                        self?.p_editVC?.showWithWhomUsers()
                        self?.view.hideActivity()
                        self?.p_editVC?.show(parentVC: (self!.slideMenuController()!.mainViewController! as! UINavigationController).topViewController!)
                    }
                }
            }
            self?.p_editVC?.onCloseHandler = {
                self!.p_editVC = nil
                DispatchQueue.main.async {
                    tableView?.beginUpdates()
                    
                    tableView?.reloadRows(at: [indexPath], with: .fade)
                    
                    tableView?.endUpdates()
                }
            }
            self?.p_editVC?.onDeleteHandler = { (workout: WorkoutInfo) in
                DispatchQueue.main.async {
                    tableView?.beginUpdates()
                    self?.workouts.remove(at: indexPath.row)
                    tableView?.deleteRows(at: [indexPath], with: .fade)
                    
                    tableView?.endUpdates()
                }
            }
            self?.p_editVC?.onInviteHandler = {
                let inviteFriendVC = self?.storyboard!.instantiateViewController(withIdentifier: "inviteFriendsVC") as? InviteFriendsVC
                
                if (inviteFriendVC != nil) {
                    inviteFriendVC!.canShowFriends = true
                    if let friends = self?.p_editVC?.withWhomUsers {
                        inviteFriendVC!.selectedUsers = friends
                  /*      var newUsers = [String]()
                        for item in friends {
                            if (item is String) {
                                //newUsers.append(item as! String)
                            }
                        }
                        inviteFriendVC!.newContacts = newUsers*/
                    }
                    inviteFriendVC!.onInviteHandler = { [weak self] (selected: [UserInfo]) in
                        
                        if (selected.count > 0 && selected is [UserInfo]) {
                            self?.p_editVC?.withWhomUsers = selected as! [UserInfo]
                            self?.p_editVC?.showWithWhomUsers()
                        } else {
                            self?.p_editVC?.withWhomUsers = [UserInfo]()
                            self?.p_editVC?.showWithWhomUsers()
                        }
                        inviteFriendVC?.navigationController?.popViewController(animated: true)
                        
                    }
                    inviteFriendVC!.onBackHandler = {
                        inviteFriendVC?.navigationController?.popViewController(animated: true)
                    }
                    (self?.slideMenuController()?.mainViewController as? UINavigationController)?.pushViewController(inviteFriendVC!, animated: true)
                }
            }
        }
        cell.onLike = { [weak self, weak cell] (workout: WorkoutInfo?) in
            if (workout != nil) {
                if (LikesManager.shared.isLiked(workout: workout)) {
                    LikesManager.shared.dislike(workout: workout!, onSuccess: { [weak self, weak cell] (workout:WorkoutInfo, Int64) in
                        DispatchQueue.main.async {
                            let visibleCells = self?.workoutTableView?.indexPathsForVisibleRows

                            if (visibleCells != nil && visibleCells!.contains(indexPath)) {
                                cell?.likes = workout.likes
                                cell?.isLiked = LikesManager.shared.isLiked(workout: workout)
                            }
                        }
                        
                    }, onFail: { (_:String?) in
                        
                    })
                } else {
                    LikesManager.shared.like(workout: workout!, onSuccess: { [weak self, weak cell] (workout:WorkoutInfo, Int64) in
                        DispatchQueue.main.async {
                            let visibleCells = self?.workoutTableView?.indexPathsForVisibleRows

                            if (visibleCells != nil && visibleCells!.contains(indexPath)) {
                                cell?.likes = workout.likes
                                cell?.isLiked = LikesManager.shared.isLiked(workout: workout)
                            }
                        }
                        
                    }, onFail: { (_:String?) in
                        
                    })
                }
            }
        }
        cell.onAvatar = { [weak self](workout: WorkoutInfo?) in
            if (workout?.organizer_name != nil) {
                self?.view.showActivity()
                
                UsersManager.shared.getUser(userName: workout!.organizer_name, completed: { [weak self] (user:UserInfo) in
                    WorkoutsManager.shared.GetUserWorkouts(user: user, onCompleted: { [weak self] (workouts:[WorkoutInfo]) in
                        
                        DispatchQueue.main.async {
                            if let profileVC = self?.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
                                profileVC.workouts = workouts
                                profileVC.user = user
                                (self?.slideMenuController()?.mainViewController as? UINavigationController)?.pushViewController(profileVC, animated: true)
                            }
                            
                            self?.view.hideActivity()
                        }
                    })
                    }, fail: { [weak self] in
                        self?.view.hideActivity()
                })
            }
        }
        cell.onUserTapped = { [weak self] (userNick: String?) in
            if (userNick != nil) {
                self?.view.showActivity()
                
                UsersManager.shared.getUser(userName: userNick!, completed: { [weak self] (user:UserInfo) in
                    WorkoutsManager.shared.GetUserWorkouts(user: user, onCompleted: { [weak self] (workouts:[WorkoutInfo]) in
                        DispatchQueue.main.async {
                            if let profileVC = self?.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
                                profileVC.workouts = workouts
                                profileVC.user = user
                                (self?.slideMenuController()?.mainViewController as? UINavigationController)?.pushViewController(profileVC, animated: true)
                            }
                            
                            self?.view.hideActivity()
                        }
                    })
                    }, fail: { [weak self] in
                    self?.view.hideActivity()
                })
            }
        }
        
        cell.onWhere = { [weak tableView] (sender: WorkoutCell, workout: WorkoutInfo?) in
            sender.autosizeOpponents = !sender.autosizeOpponents
            if (sender.autosizeOpponents) {
                self.p_needOpponentsSmallShowIndexes.remove(indexPath.row)
            } else {
                self.p_needOpponentsSmallShowIndexes.insert(indexPath.row)
            }
            tableView?.reloadData()
        }
        
        cell.onBody = { [weak tableView] (sender: WorkoutCell, workout: WorkoutInfo?) in
            sender.autosizeMessage = !sender.autosizeMessage
            if (sender.autosizeMessage) {
                self.p_needMessageSmallShowIndexes.remove(indexPath.row)
            } else {
                self.p_needMessageSmallShowIndexes.insert(indexPath.row)
            }
            tableView?.reloadData()
        }
        
        cell.onURLTapped = { (url) in
            if (url != nil && UIApplication.shared.canOpenURL(url!)) {
                UIApplication.shared.openURL(url!)
            }
        }
        
        cell.onAddressTapped = { [weak self] (address: String?) in
            if let strongSelf = self {
                if (address != nil) {
                    let filter = GMSAutocompleteFilter()
                    filter.type = .noFilter//.establishment
                    strongSelf.placesClient.autocompleteQuery(address!, bounds: nil, filter: filter, callback: { (complete:[GMSAutocompletePrediction]?, error:Error?) in
                        //<#T##GMSCoordinateBounds?#>
                        if (error != nil) {
                            NSLog("Places Error: \(error!)")
                        } else if let retainedComlete = complete {
                            DispatchQueue.global().async {
                                if retainedComlete.count > 0 {
                                    let place = retainedComlete.first!
                                    strongSelf.placesClient.lookUpPlaceID(place.placeID!, callback: { (res:GMSPlace?, error:Error?) in
                                        NSLog("Request: '\(address!)'\nName: '\(res!.name)' Address: '\(res!.formattedAddress!)'")
                                        if (res != nil && error == nil) {
                                            // Open address
                                            let coordinates = res!.coordinate
                                            let regionDistance:CLLocationDistance = 10000
                                            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
                                            let options = [
                                                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                                                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
                                            ]
                                            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                                            let mapItem = MKMapItem(placemark: placemark)
                                            mapItem.name = res!.name
                                            mapItem.openInMaps(launchOptions: options)
                                        }
                                    })
                                }
                            }
                        }
                    })
                }
            }
        }
        
        cell.onNeedResize = { [weak self] (sender: WorkoutCell) in
            if let strongSelf = self {
                DispatchQueue.main.async {
                    if let indexPath = strongSelf.workoutTableView?.indexPath(for: sender) {
                        strongSelf.p_needRecalcIndexes.insert(indexPath.row)
                     //   strongSelf.workoutTableView?.reloadRows(at: [indexPath], with: .none)
                        strongSelf.workoutTableView?.beginUpdates()
                        strongSelf.workoutTableView?.endUpdates()
                    }
                }
            }
        }
        
        return cell
    }
    
    func parseFriends(text:String? = nil, users: [UserInfo]? = nil) -> [Any] { // Can be String or UserInfo
        var tmpFriends = FriendsManager.shared.followers
        tmpFriends.append(contentsOf: FriendsManager.shared.following)
        
        var result = [Any]()
        if (users != nil && users!.count > 0) {
            for user in users! {
                result.append(user)
            }
        }
        if (text != nil && !text!.isEmpty) {
            let components = text!.components(separatedBy: ", ")
            if (components.count > 0) {
                for item in components {
                    let newText = item.trimmingCharacters(in: CharacterSet(charactersIn: " "))
                    if (!newText.isEmpty) {
                        var isUserFounded = false
                        for user in tmpFriends {
                            var userFullName = ""
                            if (!user.first_name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty || !user.last_name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty) {
                                userFullName = user.first_name
                                if (!user.last_name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty) {
                                    if (!userFullName.isEmpty) {
                                        userFullName += " "
                                    }
                                    userFullName += user.last_name
                                }
                            } else if (!user.display_name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty) {
                                userFullName = user.display_name
                            } else {
                                userFullName = user.username
                            }
                            if (userFullName == newText) {
                                result.append(user)
                                isUserFounded = true
                                break
                            }
                        }
                        
                        if (!isUserFounded) {
                            result.append(newText)
                        }
                    }
                }
            }
        }
        return result
    }
    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (!tableView.indexPathsForVisibleRows!.contains(indexPath)) {
            (cell as! WorkoutCell).autosizeOpponents = false
            (cell as! WorkoutCell).autosizeMessage = false
        }
    }
}
