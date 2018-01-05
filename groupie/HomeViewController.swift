//
//  HomeViewController.swift
//  groupie
//
//  Created by Xinran on 4/15/16.
//  Copyright © 2016 DaisyDaisy. All rights reserved.
//

import UIKit

import FontAwesome_swift
import PagingMenuController
import FBSDKCoreKit
import FBSDKLoginKit
import GooglePlaces



class HomeViewController: GroupieViewController{
    
    @IBOutlet weak var newWorkoutButton: UIButton!
    @IBOutlet weak var containerTopLayout: NSLayoutConstraint!
    @IBOutlet weak var postHeightLayout: NSLayoutConstraint!
    @IBOutlet weak var postView: POST_View!
    @IBOutlet weak var customMenuBackgroundHeightConstraint: NSLayoutConstraint!

    
    fileprivate var workouts = [Workout]()
    fileprivate let PAGE_MENU_ICON_SIZE: CGFloat = 20
    fileprivate let pagingBackColor = UIColor(red: 37/255, green: 44/255, blue: 49/255, alpha: 1)
    fileprivate var pagingOptions: PagingMenuOptions?
    fileprivate var pagingMenuController: PagingMenuController?
    fileprivate var oldPanPosition = CGPoint.zero
    
    
    fileprivate var plusButton: UIBarButtonItem?
    fileprivate var topButton: UIBarButtonItem?
    
    fileprivate static let MENU_HEIGHT: CGFloat = 44.0
    fileprivate var postViewHeight: CGFloat = 0.0
    
    fileprivate struct PagingMenuOptions: PagingMenuControllerCustomizable {
    //    private let viewController1 = ViewController1()
     //   private let viewController2 = ViewController2()
        
        fileprivate var componentType: ComponentType {
            return .all(menuOptions: MenuOptions(), pagingControllers: pagingControllers!)
        }
        
        fileprivate var lazyLoadingPage: LazyLoadingPage {
            return .three
        }
        
        fileprivate var pagingControllers: [UIViewController]?/* {
            return [/*viewController1, viewController2*/]
        }*/
        
/*        fileprivate var backgroundColor: UIColor {
            return .white
        }*/

        fileprivate struct MenuOptions: MenuViewCustomizable {
            var displayMode: MenuDisplayMode {
                return .segmentedControl
            }
            var itemsOptions: [MenuItemViewCustomizable] {
                return [MenuItem1(), MenuItem2(), MenuItem3()]
            }
            var backgroundColor: UIColor {
           //     return UIColor(red: 37/255, green: 44/255, blue: 49/255, alpha: 1)
                return .clear
            }
            var selectedBackgroundColor: UIColor {
           //     return UIColor(red: 37/255, green: 44/255, blue: 49/255, alpha: 1)
                return .clear
            }
            var focusMode: MenuFocusMode {
                return .none
            }
            var height: CGFloat {
                return MENU_HEIGHT
            }
        }
        
        fileprivate struct MenuItem1: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                let normalImage = UIImage.fontAwesomeIcon(name: .globe, textColor: UIColor.lightGray, size: CGSize(width: 20, height: 20))
                let selectedImage = UIImage.fontAwesomeIcon(name: .globe, textColor: UIColor.white, size: CGSize(width: 20, height: 20))
//                let normalImage = UIImage(named: "WorkoutPublic")!
//                let selectedImage = UIImage(named: "WorkoutPublicHL")!
                return .image(image: normalImage, selectedImage: selectedImage)
            }
        }
        fileprivate struct MenuItem2: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                let normalImage = UIImage.fontAwesomeIcon(name: .users, textColor: UIColor.lightGray, size: CGSize(width: 20, height: 20))
                let selectedImage = UIImage.fontAwesomeIcon(name: .users, textColor: UIColor.white, size: CGSize(width: 20, height: 20))
              //  let normalImage = UIImage(named: "WorkoutFriends")!
              //  let selectedImage = UIImage(named: "WorkoutFriendsHL")!
                return .image(image: normalImage, selectedImage: selectedImage)
                
                // .text(title: MenuItemText(text: String.fontAwesomeIcon(name: FontAwesome.listUL)))
            }
        }
        fileprivate struct MenuItem3: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                //    let normalImage = UIImage.fontAwesomeIcon(name: .listUL, textColor: UIColor.black, size: CGSize(width: 20, height: 20))
                let normalImage = UIImage.fontAwesomeIcon(name: .user, textColor: UIColor.lightGray, size: CGSize(width: 20, height: 20))
                let selectedImage = UIImage.fontAwesomeIcon(name: .user, textColor: UIColor.white, size: CGSize(width: 20, height: 20))
         //       let normalImage = UIImage(named: "WorkoutPersonal")!
         //       let selectedImage = UIImage(named: "WorkoutPersonalHL")!
                return .image(image: normalImage, selectedImage: selectedImage)
                
                // .text(title: MenuItemText(text: String.fontAwesomeIcon(name: FontAwesome.listUL)))
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let publicVC = Constants.Storyboards.Main.instantiateViewController(withIdentifier: "workoutPublicVC") as! WorkoutPublicVC
        let friendsVC = Constants.Storyboards.Main.instantiateViewController(withIdentifier: "workoutFriendsVC") as! WorkoutFriendsVC
        let personalVC = Constants.Storyboards.Main.instantiateViewController(withIdentifier: "workoutPersonalVC") as! WorkoutPersonalVC

        
        
        
        self.pagingOptions = PagingMenuOptions()
        self.pagingOptions!.pagingControllers = [publicVC, friendsVC, personalVC]
        
  /*      options.menuHeight = 50
        options.menuDisplayMode = .SegmentedControl
        options.font = UIFont.fontAwesomeOfSize(PAGE_MENU_ICON_SIZE)
        options.selectedFont = UIFont.fontAwesomeOfSize(PAGE_MENU_ICON_SIZE)
        options.textColor = UIColor(red: 92/255, green: 97/255, blue: 101/255, alpha: 1)
        options.selectedTextColor = UIColor.whiteColor()
        options.backgroundColor = pagingBackColor
        options.selectedBackgroundColor = pagingBackColor*/
        
        self.pagingMenuController = self.childViewControllers.first as! PagingMenuController
        self.pagingMenuController?.delegate = self
        self.pagingMenuController?.setup(/*viewControllers: viewControllers, options:*/ self.pagingOptions!)
        
    //    self.navigationController?.navigationBar.barTintColor = .clear//UIColor(red: 48/255, green: 56/255, blue: 62/255, alpha: 1)
     //   self.navigationController?.navigationBar.backgroundColor = .clear
     //   self.navigationController?.navigationBar.shadowImage = nil//UIImage()
     //   self.navigationController?.navigationBar.isTranslucent = false
        self.title = "Workout Feed"
        self.navigationController?.navigationBar.topItem?.title = "Workout Feed"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 18)]

        self.customMenuBackgroundHeightConstraint.constant = HomeViewController.MENU_HEIGHT
        
        let plusIcon = UIImage(named: "PlusButton")!
        self.plusButton = UIBarButtonItem(image: plusIcon, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.onPlusPressed))
        self.plusButton!.tintColor = .white
        
        let topIcon = UIImage(named: "ToTopButton")!
        self.topButton = UIBarButtonItem(image: topIcon, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.onToTopPressed))
        self.topButton!.tintColor = .white
        
        var isPublic = true
        if let savedIsPublic = KeyChain.GetPassword("SERVICE", account: "MAKE_MY_POSTS_PUBLIC") {
            isPublic = (savedIsPublic == "true")
        }
        
        self.postViewHeight = self.postView.bounds.height
        self.postView.onPostHandler = { [weak self] in
            if let strongSelf = self {
                if (strongSelf.postView.whereField.text == nil || strongSelf.postView.whereField.text!.isEmpty) {
                    // alert
                    let alert = UIAlertController(title: "Attention",
                                                  message: "Please Enter \"Where?\"",
                                                  preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK",
                                                  style: UIAlertActionStyle.cancel,
                                                  handler: { (action: UIAlertAction) in
                    }))
                    strongSelf.present(alert, animated: true, completion: {
                        strongSelf.postView.whereField.becomeFirstResponder()
                    })
                } else if (strongSelf.postView.detailsField.text == nil || strongSelf.postView.detailsField.text!.isEmpty) {
                    // alert
                    let alert = UIAlertController(title: "Attention",
                                                  message: "Please Enter Details",
                                                  preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK",
                                                  style: UIAlertActionStyle.cancel,
                                                  handler: { (action: UIAlertAction) in
                    }))
                    strongSelf.present(alert, animated: true, completion: {
                        strongSelf.postView.whereField.becomeFirstResponder()
                    })
                } else {
                    WorkoutsManager.shared.PostWorkout(name: (self?.postView.whereField.text)!,
                                                       descr: (self?.postView.detailsField.text)!,
                                                       type: "Run",  //Run, Bike, Strength, Dance, Combat, Yoga, Other
                                                        isPublic: isPublic,
                                                        onSuccess: { [weak self] (workout: WorkoutInfo) in
                                                            if let text = self?.postView.whereField.text {
                                                                WorkoutsManager.shared.SetWorkoutLocation(location: text, isGooglePlace: self?.postView.isGooglePlace ?? false, workout: workout, onSuccess: { [weak self] (WorkoutInfo) in
                                                                    
                                                                    let result = self?.parseFriends(users: self?.postView.withWhomUsers)
                                                                    
                                                                    if (result != nil && result!.count > 0) {
                                                                        var attendies = [String]()
                                                                        for item in result! {
                                                                            if (item is String) {
                                                                                attendies.append(item as! String)
                                                                            } else if (item is UserInfo) {
                                                                                attendies.append((item as! UserInfo).username)
                                                                            }
                                                                        }
                                                                        FriendsManager.shared.InviteFriendsToWorkout(workout: workout, friends: attendies, onSuccess: { (Bool) in
                                                                            NotificationCenter.default.post(name: WorkoutsManager.WORKOUT_DID_POST_NOTIFICATION, object: nil)
                                                                        }, onFail: { (String) in
                                                                            NotificationCenter.default.post(name: WorkoutsManager.WORKOUT_DID_POST_NOTIFICATION, object: nil)
                                                                        })
                                                                        self?.postView.whereField.text = nil
                                                                        
                                                                        self?.postView.withWhomUsers = [UserInfo]()
                                                                        self?.postView.showWithWhomUsers()
                                                                        self?.postView.detailsField.text = nil
                                                                    } else {
                                                                        NotificationCenter.default.post(name: WorkoutsManager.WORKOUT_DID_POST_NOTIFICATION, object: nil)
                                                                    }
                                                                }, onFail: nil)
                                                            }
                        }, onFail:  { [weak self] (message: String?) in
                            let alert = UIAlertController(title: "Attention",
                                                          message: message,
                                                          preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK",
                                                          style: UIAlertActionStyle.cancel,
                                                          handler: { (action: UIAlertAction) in
                            }))
                            self?.present(alert, animated: true, completion: nil)
                        })
                    self?.hidePOST(animated: true)
                }
            }
        }
        self.postView.onAvatarHandler = { [weak self] in
            let inviteFriendVC = self?.storyboard!.instantiateViewController(withIdentifier: "inviteFriendsVC") as? InviteFriendsVC
            
            if (inviteFriendVC != nil) {
                self?.view.endEditing(true)
                inviteFriendVC!.canShowFriends = true
                inviteFriendVC!.canUseSearchFriends = true
                if let friends = self?.parseFriends(users: self?.postView.withWhomUsers) {
                    inviteFriendVC!.selectedUsers = friends
                    var newUsers = [String]()
                    for item in friends {
                        if (item is String) {
                            newUsers.append(item as! String)
                        }
                    }
                    inviteFriendVC!.newContacts = newUsers
                }
                inviteFriendVC!.onInviteHandler = { [weak self] (selected: [UserInfo]) in
                    
                    if (selected.count > 0 && selected is [UserInfo]) {
                        self?.postView.withWhomUsers = selected as! [UserInfo]
                        self?.postView.showWithWhomUsers()
                    } else {
                        self?.postView.withWhomUsers = [UserInfo]()
                        self?.postView.showWithWhomUsers()
                    }
                    inviteFriendVC?.navigationController?.popViewController(animated: true)

                }
                inviteFriendVC!.onBackHandler = {
                    inviteFriendVC?.navigationController?.popViewController(animated: true)
                    //(self?.slideMenuController()?.mainViewController as? UINavigationController)?.popViewController(animated: true)
                }
                (self?.slideMenuController()?.mainViewController as? UINavigationController)?.pushViewController(inviteFriendVC!, animated: true)
            }
        }
        
        
        self.hidePOST(animated: false)
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
                        //    result.append(newText)
                        }
                    }
                }
            }
        }
        return result
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    /*    if FBSDKAccessToken.current() == nil {
            showLoginView()
            return
        }*/
        if (ServerManager.shared.isLoggedIn == false) {
            ServerManager.shared.Autologin(onSuccess: { (_) in
                if (ServerManager.shared.isLoggedIn) {
                    ContactsManager.shared.RequestRights()
                } else {
                    self.showLoginView()
                }
//                DataManager.sharedInstance.fetchWorkouts(nil)
//                WorkoutsManager.shared.UpdateWorkoutsPublic()
            }, onFail: { (_) in
                self.showLoginView()
            })
            return
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(onLogout), name: ServerManager.LOGGED_OUT_NOTIFICATION, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func onLogout() {
        self.pagingMenuController?.move(toPage: 0, animated: false)
    }
    
    fileprivate func showLoginView(){
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let loginViewController = mainStoryboard.instantiateViewController(withIdentifier: "loginNavVC") //as! LoginViewController
        //let loginViewController = mainStoryboard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        ServerManager.shared.Logout()
        self.navigationController?.present(loginViewController, animated: true, completion: nil)
    }
    
    fileprivate func loadData(){
        
    }
    public func onPlusPressed() {
        self.showPOST(animated: true)
    }

    public func onToTopPressed() {
        self.hidePOST(animated: true)
    }

    fileprivate func showPOST(animated: Bool) {
        navigationItem.setRightBarButton(self.topButton, animated: animated)
        
        self.postView.isHidden = false
        self.postView.willShow()
        
        if (animated) {
            let fullDuration:CGFloat = 0.33
            if (self.postHeightLayout.constant < HomeViewController.MENU_HEIGHT) {
                let firstPartDuration:TimeInterval = TimeInterval(fullDuration / self.postViewHeight * (HomeViewController.MENU_HEIGHT - self.postHeightLayout.constant))
                UIView.animate(withDuration: firstPartDuration, delay: 0.0, options: [.layoutSubviews, .curveEaseIn], animations: { [weak self]() -> Void in
                    if let strongSelf = self {
                        strongSelf.postHeightLayout.constant = HomeViewController.MENU_HEIGHT
                        strongSelf.view.layoutIfNeeded()
                    }
                }) { [weak self](completed:Bool) -> Void in
                    if let strongSelf = self {
                        if (!completed) {
                            strongSelf.showPOST(animated: false)
                        } else {
                            let secondPartDuration:TimeInterval = TimeInterval(fullDuration / strongSelf.postViewHeight * (strongSelf.postViewHeight - HomeViewController.MENU_HEIGHT))
                            UIView.animate(withDuration: secondPartDuration, delay: 0.0, options: [.layoutSubviews, .curveEaseOut], animations: { [weak self]() -> Void in
                                if let strongSelf = self {
                                    strongSelf.postHeightLayout.constant = strongSelf.postViewHeight
                                    strongSelf.containerTopLayout.constant = (strongSelf.postViewHeight - HomeViewController.MENU_HEIGHT)
                                    strongSelf.view.layoutIfNeeded()
                                }
                            }) { [weak self](completed:Bool) -> Void in
                                if (!completed) {
                                    if let strongSelf = self {
                                        strongSelf.showPOST(animated: false)
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                let secondPartDuration:TimeInterval = TimeInterval(fullDuration / self.postViewHeight * (self.postViewHeight - self.postHeightLayout.constant))
                UIView.animate(withDuration: secondPartDuration, delay: 0.0, options: [.layoutSubviews, .curveEaseOut], animations: { [weak self]() -> Void in
                    if let strongSelf = self {
                        strongSelf.postHeightLayout.constant = strongSelf.postViewHeight
                        strongSelf.containerTopLayout.constant = (strongSelf.postViewHeight - HomeViewController.MENU_HEIGHT)
                        strongSelf.view.layoutIfNeeded()
                    }
                }) { [weak self](completed:Bool) -> Void in
                    if (!completed) {
                        if let strongSelf = self {
                            strongSelf.showPOST(animated: false)
                        }
                    }
                }
            }
        } else {
            self.postHeightLayout.constant = self.postViewHeight
            self.containerTopLayout.constant = (self.postViewHeight - HomeViewController.MENU_HEIGHT)
        }
    }

    fileprivate func hidePOST(animated: Bool) {
        navigationItem.setRightBarButton(self.plusButton, animated: animated)
        
        if (animated)
        {
            let fullDuration:CGFloat = 0.33
            if (self.postHeightLayout.constant > HomeViewController.MENU_HEIGHT) {
                let firstPartDuration:TimeInterval = TimeInterval(fullDuration / self.postViewHeight * (self.postHeightLayout.constant - HomeViewController.MENU_HEIGHT))
                UIView.animate(withDuration: firstPartDuration, delay: 0.0, options: [.layoutSubviews, .curveEaseIn], animations: { [weak self]() -> Void in
                    if let strongSelf = self {
                        strongSelf.postHeightLayout.constant = HomeViewController.MENU_HEIGHT
                        strongSelf.containerTopLayout.constant = 0
                        strongSelf.view.layoutIfNeeded()
                    }
                }) { [weak self](completed:Bool) -> Void in
                    if let strongSelf = self {
                        if (!completed) {
                            strongSelf.showPOST(animated: false)
                        } else {
                            let secondPartDuration:TimeInterval = TimeInterval(fullDuration / strongSelf.postViewHeight * HomeViewController.MENU_HEIGHT)
                            UIView.animate(withDuration: secondPartDuration, delay: 0.0, options: [.layoutSubviews, .curveEaseOut], animations: { [weak self]() -> Void in
                                if let strongSelf = self {
                                    strongSelf.postHeightLayout.constant = 0
                                    strongSelf.view.layoutIfNeeded()
                                }
                            }) { [weak self](completed:Bool) -> Void in
                                if (!completed) {
                                    if let strongSelf = self {
                                        strongSelf.showPOST(animated: false)
                                    }
                                }
                                self?.postView.isHidden = true
                            }
                        }
                    }
                }
            } else {
                let secondPartDuration:TimeInterval = TimeInterval(fullDuration / self.postViewHeight * self.postHeightLayout.constant)
                UIView.animate(withDuration: secondPartDuration, delay: 0.0, options: [.layoutSubviews, .curveEaseOut], animations: { [weak self]() -> Void in
                    if let strongSelf = self {
                        strongSelf.postHeightLayout.constant = 0
                        strongSelf.view.layoutIfNeeded()
                    }
                }) { [weak self](completed:Bool) -> Void in
                    if (!completed) {
                        if let strongSelf = self {
                            strongSelf.showPOST(animated: false)
                        }
                    }
                    self?.postView.isHidden = true
                }
            }
        } else {
            self.postHeightLayout.constant = 0
            self.containerTopLayout.constant = 0
            self.postView.isHidden = true
        }
        self.postView.whereField.resignFirstResponder()
        self.postView.withWhomField.resignFirstResponder()
        self.postView.detailsField.resignFirstResponder()
        self.postView.willHide()
    }
    
    @IBAction func panGesture(recognizer:UIPanGestureRecognizer) {
        recognizer.maximumNumberOfTouches = 1
        switch (recognizer.state) {
        case .began:
            self.oldPanPosition = recognizer.location(in: self.view)
            break
            
        case .changed:
            let curPos = recognizer.location(in: self.view)
            var deltaY = curPos.y - self.oldPanPosition.y
            
            var newPostHeight = self.postHeightLayout.constant + deltaY
            if (newPostHeight > self.postViewHeight) {
                newPostHeight = self.postViewHeight
            }
            if (newPostHeight < 0) {
                newPostHeight = 0
            }
            if (newPostHeight < HomeViewController.MENU_HEIGHT) {
                deltaY = -self.containerTopLayout.constant
            }
            if (self.postHeightLayout.constant < self.postViewHeight) {
                self.postView.hideAutoWindows()
            }
            self.postHeightLayout.constant = newPostHeight
            
            var newTopHeight = self.containerTopLayout.constant + deltaY
            if (newTopHeight > self.postViewHeight - HomeViewController.MENU_HEIGHT) {
                newTopHeight = self.postViewHeight - HomeViewController.MENU_HEIGHT
            }
            if (newTopHeight <= 0) {
                newTopHeight = 0
            }
            self.containerTopLayout.constant = newTopHeight
            
            self.view.layoutIfNeeded()
            
            self.oldPanPosition = curPos
            
            break
            
        case .ended:
            let velocity = recognizer.velocity(in: self.view)
            if (velocity.y < 0) {
                self.hidePOST(animated: true)
            } else {
                self.showPOST(animated: true)
            }
            break
            
        case .cancelled:
            break
            
        default:
            break
        }
        
    }
}

extension UIViewController {
    func PagingWillMove() {
        
    }
}

extension HomeViewController: PagingMenuControllerDelegate{
    func willMove(toMenu menuController: UIViewController, fromMenu previousMenuController: UIViewController) {
        menuController.PagingWillMove()
    }
    
    func didMove(toMenu menuController: UIViewController, fromMenu previousMenuController: UIViewController) {
    }
}

extension HomeViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !self.postView.frame.contains(gestureRecognizer.location(in: self.postView.superview)) && !self.postView.isHidden
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension HomeViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

