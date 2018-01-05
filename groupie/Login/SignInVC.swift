//
//  SignInVC.swift
//  groupie
//
//  Created by Sania on 6/22/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit
import FontAwesome_swift
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire

class SignInVC: UIViewController {
    
    @IBOutlet weak var btnFacebook: RoundedButton!
    @IBOutlet weak var btnSigIn: RoundedButton!
    @IBOutlet weak var btnForgot: UIButton!
    @IBOutlet weak var fieldNick: UITextField!
    @IBOutlet weak var fieldPassword: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    fileprivate let defaults = UserDefaults.standard
    fileprivate let fbPermissions = ["public_profile", "email", "user_friends"]
    fileprivate var btnOriginalFontHeight: CGFloat = 0
    fileprivate var p_activityCounter: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnOriginalFontHeight = self.btnFacebook.titleLabel!.font.pointSize
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.tintColor = .gray
        
        self.view.layoutSubviews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    /*    let userView = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: self.fieldNick.bounds.height))
        userView.image = UIImage.fontAwesomeIcon(name: .user, textColor: UIColor.darkGray, size: CGSize(width: 20, height: 20))
        userView.contentMode = .center
        self.fieldNick.leftView = userView
        self.fieldNick.leftViewMode = .always*/
        
   /*     let passView = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: self.fieldNick.bounds.height))
        passView.image = UIImage.fontAwesomeIcon(name: .key, textColor: UIColor.darkGray, size: CGSize(width: 20, height: 20))
        passView.contentMode = .center
        self.fieldPassword.leftView = passView
        self.fieldPassword.leftViewMode = .always*/
        
        let attrTitle = NSAttributedString(string: self.btnForgot.title(for: .normal)!, attributes: [NSUnderlineStyleAttributeName: NSNumber(value: Int32(NSUnderlineStyle.styleSingle.rawValue))])
        self.btnForgot.setAttributedTitle(attrTitle, for: .normal)
        
   //     self.fieldNick.text = "Sancho2"
   //     self.fieldPassword.text = "1234567890"
        
        let scale = self.view.bounds.width / 414.0
        //     self.btnFacebookHeight.constant = self.btnOriginalHeight * scale
        self.btnFacebook.titleLabel!.font = self.btnFacebook.titleLabel!.font.withSize(self.btnOriginalFontHeight * scale)
        self.btnSigIn.titleLabel!.font = self.btnSigIn.titleLabel!.font.withSize(self.btnOriginalFontHeight * scale)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        self.btnFacebook.cornerRadius = self.btnFacebook.bounds.height * 0.49
        self.btnSigIn.cornerRadius = self.btnSigIn.bounds.height * 0.49
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.fieldNick.resignFirstResponder()
        self.fieldPassword.resignFirstResponder()
        
        NotificationCenter.default.removeObserver(self)
    }

    
    func onKeyboardWillShow(_ notify: Notification?) {
        if (notify?.userInfo != nil) {
            let duration = notify!.userInfo![UIKeyboardAnimationDurationUserInfoKey]  as! TimeInterval
            let endFrame = self.view.convert(notify!.userInfo![UIKeyboardFrameEndUserInfoKey] as! CGRect, from: nil)
            let options = UIViewAnimationOptions(rawValue:
                (notify!.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue << 16)
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: options,
                           animations: {
                            self.scrollView.contentInset.bottom = endFrame.height
                            self.scrollView.scrollIndicatorInsets.bottom = endFrame.height
                            self.scrollView.contentOffset = CGPoint(x: 0, y: self.fieldNick.frame.origin.y - 8)
                            self.view.layoutSubviews()
            }, completion: { (Bool) in
                
            })
        }
    }
    
    func onKeyboardWillHide(_ notify: Notification?) {
        if (notify?.userInfo != nil) {
            let duration = notify!.userInfo![UIKeyboardAnimationDurationUserInfoKey]  as! TimeInterval
            let options = UIViewAnimationOptions(rawValue:
                (notify!.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue << 16)
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: options,
                           animations: {
                            self.scrollView.contentInset.bottom = 0
                            self.scrollView.scrollIndicatorInsets.bottom = 0
                            self.view.layoutSubviews()
            }, completion: { (Bool) in
                
            })
        }
    }
    
    fileprivate func validateInput() -> Bool {
        if (self.fieldNick.text == nil || self.fieldNick.text!.isEmpty) {
            let alert = UIAlertController(title: "Attention",
                                          message: "Please enter name",
                                          preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: UIAlertActionStyle.cancel,
                                          handler: { (action: UIAlertAction) in
                self.fieldNick.becomeFirstResponder()
            }))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        if (self.fieldPassword.text == nil || self.fieldPassword.text!.isEmpty) {
            let alert = UIAlertController(title: "Attention",
                                          message: "Please enter password",
                                          preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: UIAlertActionStyle.cancel,
                                          handler: { (action: UIAlertAction) in
                self.fieldPassword.becomeFirstResponder()
            }))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    @IBAction func onSignInPressed() {
        self.fieldNick.resignFirstResponder()
        self.fieldPassword.resignFirstResponder()
        
        if (self.validateInput()) {
            self.showActivity()
            ServerManager.shared.SignIn(username: self.fieldNick.text!,
                                        password: self.fieldPassword.text!,
                                        onSuccess: { (user:UserInfo) in
                self.hideActivity()
                self.onSignedIn(user)
            }, onFail: { (message: String?) in
                self.hideActivity()
                self.showError("Invalid username or password")
            })
        }
    }
    
    @IBAction func onFacebookPressed() {
        self.fieldNick.resignFirstResponder()
        self.fieldPassword.resignFirstResponder()
        
        var needLoginFromWeb = true
        if let currentToken = FBSDKAccessToken.current() {
            if let token = currentToken.tokenString {
                needLoginFromWeb = false
                self.showActivity()
                self.signInWithFacebookToken(token, success: { (user:UserInfo) in
                    NSLog("Signed In with current token")
                    self.hideActivity()
                    self.onSignedIn(user)
                }, fail: { (message:String?) in
                    self.signUpWithFacebookToken(token, success: { (user:UserInfo) in
                        NSLog("Signed Up with current token")
                        self.hideActivity()
                        self.onSignedIn(user)
                    }, fail: { (message:String?) in
                        self.hideActivity()
                        self.showError("Can't SignIn with Facebook")
                    })
                })
            }
        }
        if (needLoginFromWeb) {
            self.showActivity()
            loginToFacebookWithSuccess({ (user:UserInfo) in
                NSLog("Signed In with new token")
                self.hideActivity()
                self.onSignedIn(user)
            }, andFailure: { (message:String?) in
                self.hideActivity()
                self.showError("Can't SignIn with Facebook")
            })
        }
    }
    
    fileprivate func onSignedIn(_ user: UserInfo) {
       /* let alert = UIAlertController(title: "Success",
                                      message: "\(user.username) signed in",
            preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: UIAlertActionStyle.cancel,
                                      handler: { (action: UIAlertAction) in
                                        self.navigationController!.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)*/
        self.navigationController!.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func showError(_ message:String?) {
        NSLog("Failed to login fb user with error \(String(describing: message))")
        if (message != nil) {
            let alert = UIAlertController(title: "Attention!",
                                          message: message!,
                                          preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: UIAlertActionStyle.cancel,
                                          handler: { (action: UIAlertAction) in
                                            
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Attention!",
                                          message: "Server Error",
                                          preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: UIAlertActionStyle.cancel,
                                          handler: { (action: UIAlertAction) in
                                            
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func showActivity() {
        if (self.p_activityCounter == 0) {
            self.p_activityCounter += 1
            
            // show
            self.view.showActivity()
        } else {
            self.p_activityCounter += 1
        }
    }
    
    fileprivate func hideActivity() {
        if (self.p_activityCounter > 0) {
            self.p_activityCounter -= 1
            if (self.p_activityCounter == 0) {
                
                // hide
                self.view.hideActivity()
            }
        }
    }
    
    
    fileprivate func loginToFacebookWithSuccess(_ successBlock: @escaping (UserInfo) -> (), andFailure failureBlock: @escaping (String?) -> ()){
        
        if FBSDKAccessToken.current() != nil {
            if Constants.loginDebug {
                FBSDKLoginManager().logOut()
            } else {
         //       self.dismiss(animated: true, completion: nil)
                
            }
        }
        //(FBSDKLoginManagerLoginResult?, Error?)
        FBSDKLoginManager().logIn(withReadPermissions: fbPermissions, from: self, handler: { (result: FBSDKLoginManagerLoginResult?, error: Error?) -> Void in
            
            if (error != nil) {
                NSLog("Error logging in. \(String(describing: error))")
                FBSDKLoginManager().logOut()
                failureBlock(error?.localizedDescription)
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
//            let fbUserID = result!.token.userID
            
            self.loginUserWithToken(fbToken!, successBlock: successBlock, andFailure: failureBlock)
            } )
    }
    
    fileprivate func signInWithFacebookToken(_ token:String, success: ((_ user:UserInfo)->Void)?, fail: ((_ message: String?)->Void)?) {
        ServerManager.shared.SignInWithFacebook(access_token: token, onSuccess: { (user:UserInfo) in
            
   /*         let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "invitable_friends, taggable_friends, friends"], httpMethod: "GET")
            req?.start(completionHandler: { (_:FBSDKGraphRequestConnection?, result:Any?, error:Error?) in
                if (error == nil && result != nil) {
                    if let resultDict = result as? [String: Any] {
                        NSLog("\(resultDict)")
                    }
                } else {
                    NSLog("\(error)")
                }
            })*/
            if (success != nil) {
                success!(user)
            }
        }, onFail: { (message:String?) in
            if (fail != nil) {
                fail!(message)
            }
        })
    }
    
    fileprivate func signUpWithFacebookToken(_ token:String, success: ((_ user:UserInfo)->Void)?, fail: ((_ message: String?)->Void)?) {
        let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "public_profile,first_name,last_name"], httpMethod: "GET")
        req?.start(completionHandler: { (_:FBSDKGraphRequestConnection?, result: Any?, error: Error?) in
            if (error == nil && result != nil) {
                if let resultDict = result as? [String: Any] {
                    if (resultDict["name"] != nil && resultDict["email"] != nil) {
                        let firstName = resultDict["first_name"] ?? ""
                        let lastName = resultDict["last_name"] ?? ""
                        ServerManager.shared.SignUpWithFacebook(username: resultDict["name"] as! String,
                                                                firstName: firstName as! String,
                                                                lastName: lastName as! String,
                                                                access_token: token,
                                                                email: resultDict["email"] as! String,
                                                                phone_number: "",
                                                                onSuccess: { (user: UserInfo) in
                                                                    success?(user)
                        }, onFail: { (message: String?) in
                            fail?(message)
                        })
                    } else {
                        fail?("Error while recieving Facebook user data")
                    }
                } else {
                    fail?("Error while recieving Facebook user data")
                }
            } else {
                fail?("Error while recieving Facebook user data")
            }
        })
    }
    
    fileprivate func loginUserWithToken(_ token: String, successBlock: @escaping (UserInfo) -> (), andFailure failureBlock: @escaping (String?) -> ()){
        //    Alamofire.request(.GET, Constants.API.FbAuth, parameters: ["access_token": token])
      /*  Alamofire.request(Constants.API.FbAuth, method: HTTPMethod.get, parameters: ["access_token": token], encoding: JSONEncoding.default)
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
        }*/
        ServerManager.shared.SignInWithFacebook(access_token: token,
                                                onSuccess: { (user:UserInfo) in
            successBlock(user)
        }, onFail: { (message: String?) in
            let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email,name,first_name,last_name"], httpMethod: "GET")
            req?.start(completionHandler: { (_: FBSDKGraphRequestConnection?, result: Any?, error: Error?) in
                if (error == nil && result != nil) {
                    if let resultDict = result as? [String: Any] {
                        if (resultDict["name"] != nil && resultDict["email"] != nil) {
                            let firstName = resultDict["first_name"] ?? ""
                            let lastName = resultDict["last_name"] ?? ""
                            ServerManager.shared.SignUpWithFacebook(username: resultDict["name"] as! String,
                                                                    firstName: firstName as! String,
                                                                    lastName: lastName as! String,
                                                                    access_token: token,
                                                                    email: resultDict["email"] as! String,
                                                                    phone_number: "",
                                                                    onSuccess: { (user: UserInfo) in
                                                                        successBlock(user)
                            }, onFail: { (message: String?) in
                                failureBlock(message)
                            })
                        } else {
                            failureBlock("Error while recieving Facebook user data")
                        }
                    } else {
                        failureBlock("Error while recieving Facebook user data")
                    }
                } else {
                    failureBlock("Error while recieving Facebook user data")
                }
            })
        //    failureBlock(message)
        })
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

extension SignInVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.fieldNick) {
            self.fieldNick.resignFirstResponder()
            self.fieldPassword.becomeFirstResponder()
        } else {
            self.onSignInPressed()
        }
        return true
    }
    
}
