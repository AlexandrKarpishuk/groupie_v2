//
//  LoginViewController.swift
//  groupie
//
//  Created by Xinran on 4/23/16.
//  Copyright © 2016 DaisyDaisy. All rights reserved.
//

import UIKit
import AVFoundation

import Alamofire
import FBSDKCoreKit
import FBSDKLoginKit



class LoginViewController: UIViewController{

    fileprivate let defaults = UserDefaults.standard
    
    fileprivate let fbPermissions = ["public_profile", "email", "user_friends"]
    
    @IBOutlet weak var fbLoginButton: RoundedButton?
    @IBOutlet weak var fbLogoutButton: UIButton?
    
    //@IBOutlet weak var videoView: LoginAnimationView!
    @IBOutlet var postTable: UITableView!
    var postTableAlphaOriginal: CGFloat = 0.5
    
    fileprivate var postsAll = [WorkoutInfo]()
    fileprivate var workouts = [WorkoutInfo]()
    fileprivate var cachedCell: WorkoutCell?
    fileprivate var avatarsAll = [UIImage]()
    fileprivate var avatars = [UIImage]()
    
    fileprivate var timer : Timer?
    fileprivate var isAnimated: Bool = false
    fileprivate var postIndex: Int = 0
    
    fileprivate var btnOriginalFontHeight: CGFloat = 0
    
 /*   fileprivate var videoPlayer: AVPlayer?
    fileprivate var videoItem: AVPlayerItem?
    fileprivate var videoLayer: AVPlayerLayer?
    fileprivate var videoNotifyToken: id_t?*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    //    self.postTable?.rowHeight = UITableViewAutomaticDimension
    //    self.postTable?.estimatedRowHeight = 160
        
        self.postTableAlphaOriginal = self.postTable.alpha
        self.btnOriginalFontHeight = self.fbLoginButton!.titleLabel!.font.pointSize

        self.postsAll.append(WorkoutInfo(info: ["organizer_name": "Caroline Geiger", "location_name": "Central Park", "attendees_names":["Anjali Southward", "Jeff Myers"], "description": "Whole team crushed a 5 mile run this morning! 🏅🏅🏅", "likesCount": 55]))
        self.postsAll.append(WorkoutInfo(info: ["organizer_name": "Anjali Southward", "location_name": "Lasker Pool", "attendees_names":[], "description": "Swimming Sat 8am. Who's coming?🏊‍♀️📋♀", "likesCount": 10]))
        self.postsAll.append(WorkoutInfo(info: ["organizer_name": "Jeff Myers", "location_name": "Prospect Park", "attendees_names":[], "description": "Anyone up for a few loops in the Park tomorrow?🚴", "likesCount": 70]))
        self.postsAll.append(WorkoutInfo(info: ["organizer_name": "Caroline Geiger", "location_name": "Rumble", "attendees_names":["Beth Gold", "Lindsay Carson"], "description": "Ready to punch stuff Sun morning. Come along!🥊", "likesCount": 2]))
        self.postsAll.append(WorkoutInfo(info: ["organizer_name": "Anjali Southward", "location_name": "Equinox West 92nd", "attendees_names":["Caroline Geiger"], "description": "Amazing Tabata class today!💪📋", "likesCount": 100]))
        
        self.avatarsAll.append(UIImage(named:"Avatar_Caroline")!)
        self.avatarsAll.append(UIImage(named:"Avatar_Anjali")!)
        self.avatarsAll.append(UIImage(named:"Avatar_Jeff")!)
        self.avatarsAll.append(UIImage(named:"Avatar_Caroline")!)
        self.avatarsAll.append(UIImage(named:"Avatar_Anjali")!)
        
        self.workouts.insert(self.postsAll[self.postsAll.count - 1 - self.workouts.count], at: 0)
        self.avatars.insert(self.avatarsAll[self.avatarsAll.count - 1 - self.avatars.count], at: 0)
        self.workouts.insert(self.postsAll[self.postsAll.count - 1 - self.workouts.count], at: 0)
        self.avatars.insert(self.avatarsAll[self.avatarsAll.count - 1 - self.avatars.count], at: 0)
        self.workouts.insert(self.postsAll[self.postsAll.count - 1 - self.workouts.count], at: 0)
        self.avatars.insert(self.avatarsAll[self.avatarsAll.count - 1 - self.avatars.count], at: 0)
        self.postIndex = self.postsAll.count - self.workouts.count - 1
        

        
        let imgView = UIImageView(image: UIImage(named:"Title"))
        self.navigationItem.titleView = imgView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.fbLoginButton!.cornerRadius = fbLoginButton!.bounds.height * 0.49
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 48/255, green: 55/255, blue: 61/255, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        
        let scale = self.view.bounds.width / 414.0
        self.fbLoginButton!.titleLabel!.font = self.fbLoginButton!.titleLabel!.font.withSize(self.btnOriginalFontHeight * scale)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
   /*     if (self.videoPlayer == nil) {
            let URL = Bundle.main.url(forResource: "LoginVideo.mp4", withExtension: nil)
            self.videoItem = AVPlayerItem(url: URL!)
            self.videoPlayer = AVPlayer(playerItem: self.videoItem)
            NotificationCenter.default.addObserver(self, selector: #selector(OnVideoFinish), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            self.videoLayer = AVPlayerLayer(player: self.videoPlayer)
            self.videoLayer?.frame = self.videoView.bounds
            self.videoView.layer.addSublayer(self.videoLayer!)
        }
        self.videoPlayer?.play()*/
        
  /*      self.videoView.onAnimationCompleted = {
            self.videoView.startAnimation()
        }
        self.videoView.startAnimation()*/
        
        self.startAnimation()
    }
    
 /*   func OnVideoFinish() {
        self.videoPlayer?.seek(to: kCMTimeZero)
        self.videoPlayer?.play()
    }*/
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    
        self.isAnimated = false
        
        self.timer?.invalidate()
        self.timer = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
/*        if (self.videoPlayer != nil) {
            NotificationCenter.default.removeObserver(self)
            self.videoPlayer?.pause()
            self.videoPlayer?.replaceCurrentItem(with: nil)
            self.videoPlayer = nil
        }
        if (self.videoLayer != nil) {
            self.videoLayer?.removeFromSuperlayer()
            self.videoLayer = nil
        }
        if (self.videoItem != nil) {
            self.videoItem = nil
        }*/
        

    }
    
    func startAnimation() {
        self.isAnimated = true
        
        if (self.timer == nil) {
            self.timer = Timer.scheduledTimer(timeInterval: 5.0,
                                              target: self,
                                              selector: #selector(onTimer),
                                              userInfo: nil,
                                              repeats: true)
        }
        self.onTimer()
    }
    
    func onTimer() {
        UIView.animate(withDuration: 1.0) {
            self.postTable.beginUpdates()
            if (self.workouts.count >= self.postsAll.count) {
                self.workouts.removeLast()
                self.avatars.removeLast()
                self.postTable.deleteRows(at: [IndexPath(row:self.workouts.count, section:0)], with: UITableViewRowAnimation.none)
            }
            self.workouts.insert(self.postsAll[self.postIndex], at: 0)
            self.avatars.insert(self.avatarsAll[self.postIndex], at: 0)
            
            self.postIndex -= 1
            if (self.postIndex < 0) {
                self.postIndex += self.postsAll.count
            }
            
            self.postTable.insertRows(at: [IndexPath(row:0, section:0)], with: UITableViewRowAnimation.top)
            
            self.postTable.endUpdates()
        }


        /* else {
            UIView.animate(withDuration: 0.6, animations: { 
                self.postTable.alpha = 0
            }, completion: { (Bool) in
                self.workouts.removeAll()
                self.avatars.removeAll()
                self.postTable.reloadData()
                self.postTable.alpha = self.postTableAlphaOriginal
            })
        }*/
        
        if (!self.isAnimated) {
            self.timer!.invalidate()
            self.timer = nil
        }
    }
    
    @IBAction func loginButtonClicked(_ sender: AnyObject?){
        let successBlock = { (json: AnyObject) -> () in
            NSLog("Successfully logged in fb user")
            let id = json["id"]
            let email = json["email"]
            let token = json["token"]
            self.defaults.set(id, forKey: "id")
            self.defaults.set(email, forKey: "email")
            self.defaults.set(token, forKey: "token")
            
            self.dismiss(animated: true, completion: nil)
        }
        let failureBlock = { (error: Error?) -> () in
            NSLog("Failed to login fb user with error \(error)")
        }
        loginToFacebookWithSuccess(successBlock, andFailure: failureBlock)
    }
    
    @IBAction func logoutButtonClicked(_ sender: AnyObject?){
        FBSDKLoginManager().logOut()
        self.defaults.removeObject(forKey: "id")
        self.defaults.removeObject(forKey: "email")
        self.defaults.removeObject(forKey: "token")
    }
    
    @IBAction func onSignInPressed(_ sender:UIButton?) {
        let signInVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC")
        NSLog("VC: \(self.navigationController)")
        self.navigationController?.pushViewController(signInVC!, animated: true)
    }
    
    fileprivate func loginToFacebookWithSuccess(_ successBlock: @escaping (AnyObject) -> (), andFailure failureBlock: @escaping (Error?) -> ()){
        
        if FBSDKAccessToken.current() != nil {
            if Constants.loginDebug {
                FBSDKLoginManager().logOut()
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        //(FBSDKLoginManagerLoginResult?, Error?)
        FBSDKLoginManager().logIn(withReadPermissions: fbPermissions, from: self, handler: { (result: FBSDKLoginManagerLoginResult?, error: Error?) -> Void in
            
            if (error != nil) {
                NSLog("Error logging in. \(error)")
                FBSDKLoginManager().logOut()
                failureBlock(error)
                return
            } else if (result == nil || result!.isCancelled) {
                FBSDKLoginManager().logOut()
                failureBlock(nil)
                return
            }
            
            if !self.hasPermissions(result?.grantedPermissions as! Set<NSObject>) {
                //The user did not grant all permissions requested
                //Discover which permissions are granted
                //and if you can live without the declined ones
                failureBlock(nil)
            }
            
            
            let fbToken = result!.token.tokenString
            let fbUserID = result!.token.userID
            
            self.loginUserWithToken(fbToken!, successBlock: successBlock, andFailure: failureBlock)
        } as! FBSDKLoginManagerRequestTokenHandler)
    }
    
    fileprivate func loginUserWithToken(_ token: String, successBlock: @escaping (AnyObject) -> (), andFailure failureBlock: (NSError?) -> ()){
    //    Alamofire.request(.GET, Constants.API.FbAuth, parameters: ["access_token": token])
        Alamofire.request(Constants.API.FbAuth, method: HTTPMethod.get, parameters: ["access_token": token], encoding: JSONEncoding.default)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let resp = response.result.value {
                        successBlock(resp as AnyObject)
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    fileprivate func hasPermissions(_ grantedPermissions: Set<NSObject>) -> Bool {
        // check if all permissions were granted
        var allPermsGranted = true
        let grantedPermissions = grantedPermissions.map( {"\($0)"} )
        for permission in self.fbPermissions {
            if !grantedPermissions.contains(permission){
                allPermsGranted = false
                break
            }
        }
        
        return allPermsGranted
    }
}

extension LoginViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let info = self.workouts[indexPath.row]
        if (self.cachedCell == nil) {
            self.cachedCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? WorkoutCell
        }
        let autosizeOpponents = true
        let autosizeMessage = true
        let height = self.cachedCell!.fullHeight(writer: info.organizer_name, location: info.location_name, opponents: info.attendees_names, message: info.descr, commentsCount: 0, autosizeOpponents: autosizeOpponents, autosizeMessage: autosizeMessage, workout: info)
        return height
    }
}

extension LoginViewController: UITableViewDataSource {
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        //  return DataManager.sharedInstance.workouts.count
        return self.workouts.count
    }
    
    func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        /*      let cell = self.workoutListTableView?.dequeueReusableCell(withIdentifier: Constants.Cells.WorkoutListCell) as! WorkoutListCell
         
         let workout = DataManager.sharedInstance.workouts[indexPath.row]
         
         cell.nameLabel?.text = workout.name*/
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! WorkoutCell
        
        
        // cell.opponents = ["Jeff Myers", "Chelsea Young", "Equinox SoHo", "Ben White", "Robie Wiliams"]
        // cell.message = "We're going for a long distance run, anyone wanna join?"
        // cell.date = "Posted 9m ago"
        // cell.commentsCount = self.commentsCount[indexPath.row]
        
        let info = self.workouts[indexPath.row]
        cell.workoutInfo = info
        
        cell.writer = info.organizer_name
        cell.location = info.location_name
        cell.opponents = info.attendees_names
        cell.message = info.descr
        cell.likes = info.likes
        cell.isLiked = true
        cell.setButtonType(.join)
        if (info.init_time != nil) {
            cell.date = "\(Date().agoFromDate(date: info.init_time!)) ago"
        } else {
            cell.date = ""
        }
        cell.commentsCount = info.comments.filter({ (commentInfo:CommentInfo) -> Bool in
            return commentInfo.is_active
        }).count
        cell.btnAvatar?.setBackgroundImage(self.avatars[indexPath.row], for: .normal)
        cell.btnAvatar?.isUserInteractionEnabled = false
  /*      cell.onComments = { (workout: WorkoutInfo?) in
            if (workout != nil) {
                self.selectedWorkout = workout
                self.performSegue(withIdentifier: "Comments", sender: nil)
            }
        }
        cell.onJoin = { (workout: WorkoutInfo?) in
            if (workout != nil) {
                WorkoutsManager.shared.Join(workout: workout!, onSuccess: { (WorkoutInfo) in
                    self.needUpdateWorkouts()
                }, onFail: { (message:String?) in
                    
                })
            }
        }*/
        
        return cell
    }
    
}
