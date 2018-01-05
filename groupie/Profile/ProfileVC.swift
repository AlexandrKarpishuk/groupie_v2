//
//  ProfileVC.swift
//  groupie
//
//  Created by Sania on 6/12/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import GooglePlaces
import MapKit

class ProfileVC: UIViewController {
    
    @IBOutlet weak var topBarHeightLayout: NSLayoutConstraint!
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var avatarName: UILabel!
    @IBOutlet weak var avatarWorkouts: UILabel!
    @IBOutlet weak var avatarBtnFollow: RoundedButton!
    @IBOutlet weak var profileTable: UITableView!
    
    fileprivate var cachedCell: WorkoutCell?
    fileprivate var placesClient = GMSPlacesClient()
    
    fileprivate var p_editVC: POST_EDIT_VC?
    
    fileprivate var p_cellHeight = [Int: CGFloat]()
    fileprivate var p_needRecalcIndexes = Set<Int>()

    
    var user:UserInfo?
    var workouts = [WorkoutInfo]()
    fileprivate var p_needOpponentsSmallShowIndexes = Set<Int>()
    fileprivate var p_needMessageSmallShowIndexes = Set<Int>()
    fileprivate var selectedWorkout: WorkoutInfo?
    fileprivate var originalFollowColor = UIColor()
    var plusImage = UIImage.fontAwesomeIcon(name: .plusCircle, textColor: UIColor.white, size: CGSize(width: 16, height: 16))
    var minusImage = UIImage.fontAwesomeIcon(name: .minusCircle, textColor: UIColor.white, size: CGSize(width: 16, height: 16))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topBarHeightLayout.constant = UIApplication.shared.statusBarFrame.height
        
   //     self.profileTable?.rowHeight = UITableViewAutomaticDimension
   //     self.profileTable?.estimatedRowHeight = 180
        
        self.originalFollowColor = self.avatarBtnFollow.backgroundColor!
        
        for index in 0..<6 {
            self.p_needRecalcIndexes.insert(index)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.p_needMessageSmallShowIndexes = Set<Int>()
        self.p_needOpponentsSmallShowIndexes = Set<Int>()
        
        self.navigationController?.navigationBar.tintColor = .gray
        
        self.avatarView.clipsToBounds = true
        self.avatarView.layer.cornerRadius = self.avatarView.bounds.height * 0.49
        self.avatarBtnFollow.clipsToBounds = true
        self.avatarBtnFollow.cornerRadius = self.avatarBtnFollow.bounds.height * 0.49
        
        if (user != nil && ServerManager.shared.currentUser != nil) {
            self.avatarBtnFollow.isHidden = (user!.id == ServerManager.shared.currentUser!.id)
            let following = FriendsManager.shared.following
            if (following.contains(where: { (userTest:UserInfo) -> Bool in
                return userTest.id == user!.id
            })) {
                self.avatarBtnFollow.setImage(self.minusImage, for: .normal)
                self.avatarBtnFollow.setTitle("Following", for: .normal)
                self.avatarBtnFollow.backgroundColor = UIColor(colorLiteralRed: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
            } else {
                self.avatarBtnFollow.setImage(self.plusImage, for: .normal)
                self.avatarBtnFollow.setTitle("Follow", for: .normal)
                self.avatarBtnFollow.backgroundColor = self.originalFollowColor
            }
            
            let imageURL = URL(string: user!.profile_picture_url)
            self.avatarView.sd_setImage(with: imageURL,
                                        placeholderImage: UIImage(named: "UserPlaceholder"),
                                        options: SDWebImageOptions.allowInvalidSSLCertificates,
                                        completed: nil)
        }
 /*       NotificationCenter.default.addObserver(self, selector: #selector(updateWorkoutComments), name:WorkoutsManager.WORKOUT_COMMENTS_UPDATED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateWorkoutLikes), name:WorkoutsManager.WORKOUT_LIKES_UPDATED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onWorkoutsUpdated), name:WorkoutsManager.WORKOUTS_DID_UPDATED, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDB_Readed), name:WorkoutsManager.WORKOUT_DB_READED, object: nil)*/
        
        self.showAvatar()
    }
    
    fileprivate func showAvatar() {
        if (user != nil) {
            self.avatarName.text = self.userFullName(user!)
        } else {
            self.avatarName.text = ""
        }
        self.avatarWorkouts.text = "\(self.workouts.count)"
    }
    
    fileprivate func userFullName(_ user: UserInfo) -> String {
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
        return userFullName
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
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
    
    @IBAction func onFollowPressed() {
        if (user != nil) {
            let following = FriendsManager.shared.following
            if (following.contains(where: { (userTest:UserInfo) -> Bool in
                return userTest.id == user!.id
            })) {
                FriendsManager.shared.UnFollow(user: user!, onSuccess: { [weak self] (Bool) in
                    self?.avatarBtnFollow.setImage(self?.plusImage, for: .normal)
                    self?.avatarBtnFollow.setTitle("Follow", for: .normal)
                    self?.avatarBtnFollow.backgroundColor = self?.originalFollowColor
                }, onFail:  { [weak self] (message:String?) in
                    self?.avatarBtnFollow.setImage(self?.minusImage, for: .normal)
                    self?.avatarBtnFollow.setTitle("Following", for: .normal)
                    self?.avatarBtnFollow.backgroundColor = UIColor(colorLiteralRed: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
                })
            } else {
                FriendsManager.shared.Follow(user: user!, onSuccess: { [weak self] (Bool) in
                    self?.avatarBtnFollow.setImage(self?.minusImage, for: .normal)
                    self?.avatarBtnFollow.setTitle("Following", for: .normal)
                    self?.avatarBtnFollow.backgroundColor = UIColor(colorLiteralRed: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
                }, onFail:  { [weak self] (message:String?) in
                    self?.avatarBtnFollow.setImage(self?.plusImage, for: .normal)
                    self?.avatarBtnFollow.setTitle("Follow", for: .normal)
                    self?.avatarBtnFollow.backgroundColor = self?.originalFollowColor
                })
            }

        }
    }
}


extension ProfileVC : UITableViewDataSource {

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
        
        cell.writer = info.organizer_name
        cell.location = info.location_name
        cell.opponents = info.attendees_names
        cell.message = info.descr
        cell.likes = info.likes
        if (info.init_time != nil) {
            cell.date = "\(Date().agoFromDate(date: info.init_time!)) ago"
        } else {
            cell.date = ""
        }
        cell.commentsCount = info.comments.filter({ (commentInfo:CommentInfo) -> Bool in
            return commentInfo.is_active
        }).count
        cell.onComments = { [weak self] (workout: WorkoutInfo?) in
            if (workout != nil) {
                self?.selectedWorkout = workout
                self?.performSegue(withIdentifier: "Comments", sender: nil)
            }
        }
        
        if (self.user != nil) {
            var imageURL = URL(string: self.user!.profile_picture_url)
            if (imageURL == nil) {
                imageURL = Bundle.main.url(forResource: "groupieAvatar.png", withExtension: nil)
            }
            cell.btnAvatar?.sd_setBackgroundImage(with: imageURL, for: .normal, placeholderImage: UIImage(named:"UserPlaceholder"), options: .allowInvalidSSLCertificates, completed: nil)
        } else {
            let imageURL = Bundle.main.url(forResource: "groupieAvatar.png", withExtension: nil)
            cell.btnAvatar?.sd_setBackgroundImage(with: imageURL, for: .normal, placeholderImage: UIImage(named:"UserPlaceholder"), options: .allowInvalidSSLCertificates, completed: nil)
        }
        
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
                                                  handler: { (action: UIAlertAction) in
                    }))
                    self?.present(alert, animated: true, completion: nil)
                })
            }
        }
        cell.onLeave = { [weak self, weak tableView] (workout: WorkoutInfo?) in
            if (workout != nil) {
                WorkoutsManager.shared.Leave(workout: workout!, onSuccess: { [weak tableView] (WorkoutInfo) in
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
                                                  handler: { (action: UIAlertAction) in
                    }))
                    self?.present(alert, animated: true, completion: nil)
                })
            }
        }
        cell.onLike = { [weak self, weak cell] (workout: WorkoutInfo?) in
            if (workout != nil) {
                if (LikesManager.shared.isLiked(workout: workout)) {
                    LikesManager.shared.dislike(workout: workout!, onSuccess: { (workout:WorkoutInfo, Int64) in
                        DispatchQueue.main.async {
                            let visibleCells = self?.profileTable?.indexPathsForVisibleRows
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
                            let visibleCells = self?.profileTable?.indexPathsForVisibleRows
                            if (visibleCells!.contains(indexPath)) {
                                cell?.likes = workout.likes
                                cell?.isLiked = LikesManager.shared.isLiked(workout: workout)
                            }
                        }
                        
                    }, onFail: { (_:String?) in
                        
                    })
                }
            }
        }
        cell.onEdit = { [weak self, weak tableView] (workout: WorkoutInfo?) in
            let editStoryboard = UIStoryboard(name: "EditPost", bundle: nil)
            self?.p_editVC = editStoryboard.instantiateInitialViewController() as? POST_EDIT_VC
            self?.p_editVC?.workout = workout
            self?.p_editVC?.show(parentVC: (self!.slideMenuController()!.mainViewController! as! UINavigationController).topViewController!)
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
     /*   cell.onUserTapped = { (userNick: String?) in
            if (userNick != nil) {
                self.view.showActivity()
                
                ServerManager.shared.GetUserInfo(userNick: userNick!, onSuccess: { (user:UserInfo) in
                    
                    let profileVC = self.storyboard!.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                    profileVC.user = user
                    WorkoutsManager.shared.GetUserWorkouts(user: user, onCompleted: { (workouts:[WorkoutInfo]) in
                        profileVC.workouts = workouts
                        
                        DispatchQueue.main.async {
                            (self.slideMenuController()?.mainViewController as! UINavigationController).pushViewController(profileVC, animated: true)
                            
                            self.view.hideActivity()
                        }
                    })
                    
                }, onFail: { (message:String?) in
                    NSLog("\(message)")
                    self.view.hideActivity()
                })
            }
        }*/
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
                    if let indexPath = strongSelf.profileTable.indexPath(for: sender) {
                        strongSelf.p_needRecalcIndexes.insert(indexPath.row)
                        //   strongSelf.workoutTableView?.reloadRows(at: [indexPath], with: .none)
                        strongSelf.profileTable.beginUpdates()
                        strongSelf.profileTable.endUpdates()
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (!tableView.indexPathsForVisibleRows!.contains(indexPath)) {
            (cell as! WorkoutCell).autosizeOpponents = false
            (cell as! WorkoutCell).autosizeMessage = false
        }
        
  //      (cell as? WorkoutCell)?.btnAvatar?.sd_cancelCurrentImageLoad()
    }
    
    func parseFriends(text:String? = nil, users:[UserInfo]? = nil) -> [Any] { // Can be String or UserInfo
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
    
}

extension ProfileVC : UITableViewDelegate {
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
    }
}
