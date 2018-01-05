//
//  SidebarViewController.swift
//  groupie
//
//  Created by Xinran on 4/13/16.
//  Copyright © 2016 DaisyDaisy. All rights reserved.
//

import UIKit
import AVFoundation
import SDWebImage

class SidebarViewController: UIViewController {
    
    static let NOTIFICATION_NEED_SHOW_WORKOUTS = Notification.Name("MenuNeedShowWorkouts")
    
    var mainViewController: UIViewController?
    
    @IBOutlet var btnAvatar: RoundedButton!
    @IBOutlet var btnLogout: UIButton!
    @IBOutlet var btnWorkoutFeed: UIButton!
    @IBOutlet var btnSearchFriends: UIButton!
    @IBOutlet var btnInviteFriends: UIButton!
    @IBOutlet var btnSettings: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(onWorkoutFeedPressed), name: SidebarViewController.NOTIFICATION_NEED_SHOW_WORKOUTS, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onLogout), name: ServerManager.LOGGED_OUT_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onLogin), name: ServerManager.LOGGED_IN_NOTIFICATION, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.btnAvatar.clipsToBounds = true
        
        
        let normalImage = UIImage.fontAwesomeIcon(name: .signOut, textColor: UIColor.white, size: CGSize(width: 16, height: 16))
        self.btnLogout!.setImage(normalImage, for: .normal)
        
        if let info = ServerManager.shared.currentUser {
            var imageURL = URL(string: info.profile_picture_url)
            if (imageURL == nil) {
                imageURL = Bundle.main.url(forResource: "groupieAvatar.png", withExtension: nil)
            }
            self.btnAvatar?.sd_setBackgroundImage(with: imageURL, for: .normal, placeholderImage: UIImage(named:"UserPlaceholder"), options: .allowInvalidSSLCertificates, completed: nil)
        }
    }
    @objc func onLogout() {
        let imageURL = Bundle.main.url(forResource: "groupieAvatar.png", withExtension: nil)
        self.btnAvatar?.sd_setBackgroundImage(with: imageURL, for: .normal, placeholderImage: UIImage(named:"UserPlaceholder"), options: .allowInvalidSSLCertificates, completed: nil)
    }
    @objc func onLogin() {
        if let info = ServerManager.shared.currentUser {
            var imageURL = URL(string: info.profile_picture_url)
            if (imageURL == nil) {
                imageURL = Bundle.main.url(forResource: "groupieAvatar.png", withExtension: nil)
            }
            self.btnAvatar?.sd_setBackgroundImage(with: imageURL, for: .normal, placeholderImage: UIImage(named:"UserPlaceholder"), options: .allowInvalidSSLCertificates, completed: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.btnAvatar.layer.cornerRadius = self.btnAvatar.bounds.width * 0.49
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
 //       NotificationCenter.default.removeObserver(self)
    }
    
//    func changeViewController(menu: LeftMenu) {
//        switch menu {
//        case .Main:
//            self.slideMenuController()?.changeMainViewController(self.mainViewController, close: true)
//        case .Swift:
//            self.slideMenuController()?.changeMainViewController(self.swiftViewController, close: true)
//        case .Java:
//            self.slideMenuController()?.changeMainViewController(self.javaViewController, close: true)
//        case .Go:
//            self.slideMenuController()?.changeMainViewController(self.goViewController, close: true)
//        case .NonMenu:
//            self.slideMenuController()?.changeMainViewController(self.nonMenuViewController, close: true)
//        }
//    }
    
    @IBAction func onAvatarPressed() {
     /*   let profileVC = self.storyboard!.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        let user = ServerManager.shared.currentUser!
        profileVC.user = user
        WorkoutsManager.shared.GetUserWorkouts(user: user, onCompleted: { (workouts:[WorkoutInfo]) in
            profileVC.workouts = workouts
            
            DispatchQueue.main.async {
                (self.slideMenuController()?.mainViewController as! UINavigationController).pushViewController(profileVC, animated: true)
                self.slideMenuController()?.closeLeft()
            }
        })*/
   //     (self.slideMenuController()?.mainViewController as! UINavigationController).pushViewController(profileVC, animated: true)
        
        //   self.slideMenuController()?.changeMainViewController(profileVC, close: true)
        
    UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.gray,
                                                         NSFontAttributeName:UIFont.systemFont(ofSize: 15)], for: .normal)
    UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.black,
                                                         NSFontAttributeName:UIFont.systemFont(ofSize: 15)], for: .highlighted)
        UINavigationBar.appearance().isTranslucent = false
        
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        picker.delegate = self
        self.slideMenuController()?.present(picker, animated: true, completion: nil)
        
        self.slideMenuController()?.closeLeft()
    }
    
    @IBAction func onWorkoutFeedPressed() {
        if (((self.slideMenuController()?.mainViewController as? UINavigationController)?.topViewController as? HomeViewController) == nil) {
            let workoutVC = self.storyboard!.instantiateViewController(withIdentifier: "homeVC")
            (self.slideMenuController()?.mainViewController as! UINavigationController).pushViewController(workoutVC, animated: true)
        }
        self.slideMenuController()?.closeLeft()
    }
    
    @IBAction func onSearchFriendsPressed() {
        if (((self.slideMenuController()?.mainViewController as? UINavigationController)?.topViewController as? SearchFriendsVC) == nil) {
            let searchFriendVC = self.storyboard!.instantiateViewController(withIdentifier: "searchFriendsVC")
            (self.slideMenuController()?.mainViewController as! UINavigationController).pushViewController(searchFriendVC, animated: true)
        }
        self.slideMenuController()?.closeLeft()
    }
    
    @IBAction func onInviteFriendsPressed() {
        if (((self.slideMenuController()?.mainViewController as? UINavigationController)?.topViewController as? InviteFriendsVC) == nil) {
            let searchFriendVC = self.storyboard!.instantiateViewController(withIdentifier: "inviteFriendsVC") as! InviteFriendsVC
            searchFriendVC.canUseSearchFriends = false
            (self.slideMenuController()?.mainViewController as! UINavigationController).pushViewController(searchFriendVC, animated: true)
        }
        self.slideMenuController()?.closeLeft()
    }
    
    @IBAction func onSettingsPressed() {
        if (((self.slideMenuController()?.mainViewController as? UINavigationController)?.topViewController as? SettingsVC) == nil) {
            let settingsVC = self.storyboard!.instantiateViewController(withIdentifier: "SettingsVC")
            (self.slideMenuController()?.mainViewController as! UINavigationController).pushViewController(settingsVC, animated: true)
        }
        self.slideMenuController()?.closeLeft()
    }
    
    @IBAction func onLogoutPressed() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let loginViewController = mainStoryboard.instantiateViewController(withIdentifier: "loginNavVC") //as! LoginViewController
        //let loginViewController = mainStoryboard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        (self.slideMenuController()?.mainViewController as! UINavigationController).present(loginViewController, animated: true, completion: {
            if (((self.slideMenuController()?.mainViewController as? UINavigationController)?.topViewController as? HomeViewController) == nil) {
                let workoutVC = self.storyboard!.instantiateViewController(withIdentifier: "homeVC")
                var viewControllers = (self.slideMenuController()?.mainViewController as! UINavigationController).viewControllers
                viewControllers.removeLast()
                viewControllers.append(workoutVC)
                (self.slideMenuController()?.mainViewController as! UINavigationController).setViewControllers(viewControllers, animated: false)
            }
        })
        
        self.slideMenuController()?.closeLeft()
        
        ServerManager.shared.Logout()
    }
}

extension SidebarViewController : UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.clear,
                                                         NSFontAttributeName:UIFont.systemFont(ofSize: 0.1)], for: .normal)
    UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.clear,
                                                         NSFontAttributeName:UIFont.systemFont(ofSize: 0.1)], for: .highlighted)
        UINavigationBar.appearance().isTranslucent = true
        
        self.slideMenuController()?.leftViewController?.view.layoutSubviews()

        picker.dismiss(animated: true, completion: {
            self.slideMenuController()?.openLeft()
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.btnAvatar.showActivity(animated: true)
        DispatchQueue.global().async {
            let image = info[UIImagePickerControllerOriginalImage] as? UIImage
            if (image != nil) {
                let maxBounds: CGFloat = 600
                var newSize = CGSize()
                if (image!.size.width > image!.size.height) {
                    newSize.height = maxBounds
                    newSize.width = maxBounds * image!.size.width / image!.size.height
                } else {
                    newSize.width = maxBounds
                    newSize.height = maxBounds * image!.size.height / image!.size.width
                }
                let scaledImage = image?.resize(to: newSize)
                let jpegData = UIImageJPEGRepresentation(scaledImage!, 0.8)
                ServerManager.shared.SetAvatarImage(jpegData: jpegData!, onSuccess: { (user:UserInfo) in
                    let imageURL = URL(string: user.profile_picture_url)
                    SDWebImageManager.shared().imageCache?.removeImage(forKey: user.profile_picture_url, fromDisk: true, withCompletion: {
                        DispatchQueue.main.async {
                            self.btnAvatar.sd_setBackgroundImage(with: imageURL, for: .normal, placeholderImage: UIImage(named:"UserPlaceholder"), options: .allowInvalidSSLCertificates, completed: { (_, _, _, _) in
                                self.btnAvatar.hideActivity()
                            })
                        }
                    })

                    
                }, onFail: { (message:String?) in
                    NSLog("\(message)")
                    self.btnAvatar.hideActivity()
                })
            } else {
                self.btnAvatar.hideActivity()
            }
        }
        
    UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.clear,
                                                         NSFontAttributeName:UIFont.systemFont(ofSize: 0.1)], for: .normal)
    UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.clear,
                                                             NSFontAttributeName:UIFont.systemFont(ofSize: 0.1)], for: .highlighted)
        UINavigationBar.appearance().isTranslucent = true
        
        self.slideMenuController()?.leftViewController?.view.layoutSubviews()
        
        
        
        picker.dismiss(animated: true, completion: {
            self.slideMenuController()?.openLeft()
        })

    }
}

extension SidebarViewController : UINavigationControllerDelegate {
    
}
