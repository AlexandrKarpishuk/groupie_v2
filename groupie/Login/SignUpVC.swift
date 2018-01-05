//
//  SignUpVC.swift
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

class SignUpVC: UIViewController {
    
    @IBOutlet weak var btnFacebook: RoundedButton!
    @IBOutlet weak var btnSigUp: RoundedButton!
    @IBOutlet weak var fieldFirstName: UITextField!
    @IBOutlet weak var fieldLastName: UITextField!
    @IBOutlet weak var fieldEmail: UITextField!
    @IBOutlet weak var fieldPassword: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet var bottomSpace: NSLayoutConstraint!
  //  @IBOutlet var btnFacebookHeight: NSLayoutConstraint!
    
    fileprivate let defaults = UserDefaults.standard
    fileprivate let fbPermissions = ["public_profile", "email", "user_friends"]
    fileprivate var btnOriginalFontHeight: CGFloat = 0
    fileprivate var btnOriginalHeight: CGFloat = 0
    fileprivate var bottomScapeOriginal: CGFloat = 0
    fileprivate var p_activityCounter: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
  //      self.btnOriginalHeight = self.btnFacebookHeight.constant
        self.btnOriginalFontHeight = self.btnFacebook.titleLabel!.font.pointSize
        self.bottomScapeOriginal = self.bottomSpace.constant
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.btnFacebook.cornerRadius = self.btnFacebook.bounds.height * 0.49
        self.btnSigUp.cornerRadius = self.btnSigUp.bounds.height * 0.49
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        self.navigationController?.navigationBar.tintColor = .gray
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        var scale = self.view.bounds.width / 414.0
   //     self.btnFacebookHeight.constant = self.btnOriginalHeight * scale
        self.btnFacebook.titleLabel!.font = self.btnFacebook.titleLabel!.font.withSize(self.btnOriginalFontHeight * scale)
        self.btnSigUp.titleLabel!.font = self.btnSigUp.titleLabel!.font.withSize(self.btnOriginalFontHeight * scale)
        scale = self.view.bounds.height / 736.0
        self.bottomSpace.constant = self.bottomScapeOriginal * scale
        
        self.view.layoutSubviews()
        

        
    /*    let userView = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: self.fieldNick.bounds.height))
        userView.image = UIImage.fontAwesomeIcon(name: .user, textColor: UIColor.darkGray, size: CGSize(width: 20, height: 20))
        userView.contentMode = .center
        self.fieldNick.leftView = userView
        self.fieldNick.leftViewMode = .always
        
        let emailView = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: self.fieldNick.bounds.height))
        emailView.image = UIImage.fontAwesomeIcon(name: .envelope, textColor: UIColor.darkGray, size: CGSize(width: 20, height: 20))
        emailView.contentMode = .center
        self.fieldEmail.leftView = emailView
        self.fieldEmail.leftViewMode = .always
        
        let passView = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: self.fieldNick.bounds.height))
        passView.image = UIImage.fontAwesomeIcon(name: .key, textColor: UIColor.darkGray, size: CGSize(width: 20, height: 20))
        passView.contentMode = .center
        self.fieldPassword.leftView = passView
        self.fieldPassword.leftViewMode = .always*/
        
  //      #if DEBUG
//            self.fieldNick.text = "Sancho2"
//            self.fieldPassword.text = "1234567890"
//            self.fieldEmail.text = "sancho2@gmail.com"
  //      #endif


    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.fieldFirstName.resignFirstResponder()
        self.fieldLastName.resignFirstResponder()
        self.fieldEmail.resignFirstResponder()
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
                self.scrollView.contentOffset = CGPoint(x: 0, y: self.fieldFirstName.frame.origin.y - 8)
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
    
    fileprivate func isEmailValid(email: String?) -> Bool {
        if (email != nil && !email!.isEmpty) {
            let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailTest.evaluate(with: email!)
        }
        return false
    }
    
    fileprivate func validateInput() -> Bool {
        if (self.fieldFirstName.text == nil || self.fieldFirstName.text!.isEmpty) {
            let alert = UIAlertController(title: "Attention",
                                          message: "Please enter first name",
                                          preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: UIAlertActionStyle.cancel,
                                          handler: { (action: UIAlertAction) in
                                            self.fieldFirstName.becomeFirstResponder()
            }))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        if (self.fieldLastName.text == nil || self.fieldLastName.text!.isEmpty) {
            let alert = UIAlertController(title: "Attention",
                                          message: "Please enter last name",
                                          preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: UIAlertActionStyle.cancel,
                                          handler: { (action: UIAlertAction) in
                                            self.fieldLastName.becomeFirstResponder()
            }))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        if (self.fieldEmail.text == nil || self.fieldEmail.text!.isEmpty || !self.isEmailValid(email: self.fieldEmail.text)) {
            let alert = UIAlertController(title: "Attention",
                                          message: "Please enter email",
                                          preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: UIAlertActionStyle.cancel,
                                          handler: { (action: UIAlertAction) in
                                            self.fieldEmail.becomeFirstResponder()
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
    
    @IBAction func onSignUpPressed() {
        self.fieldFirstName.resignFirstResponder()
        self.fieldLastName.resignFirstResponder()
        self.fieldEmail.resignFirstResponder()
        self.fieldPassword.resignFirstResponder()
        
        if (self.validateInput()) {
            //self.navigationController!.dismiss(animated: true, completion: nil)
        
            self.showActivity()
            
            ServerManager.shared.SignUp(username: self.fieldFirstName.text! + self.fieldLastName.text!,
                                        firstName: self.fieldFirstName!.text!,
                                        lastName: self.fieldLastName!.text!,
                                        password: self.fieldPassword.text!,
                                        email: self.fieldEmail.text!,
                                        onSuccess: { (user: UserInfo) in
                self.hideActivity()
                self.onSignedUp(user)
            }, onFail: { (message: String?) in
                self.hideActivity()
                self.showError(message)
            })
        }
    }
    
    @IBAction func onFacebookPressed() {
        self.fieldFirstName.resignFirstResponder()
        self.fieldLastName.resignFirstResponder()
        self.fieldEmail.resignFirstResponder()
        self.fieldPassword.resignFirstResponder()
        
        
        var needLoginFromWeb = true
        if let currentToken = FBSDKAccessToken.current() {
            if let token = currentToken.tokenString {
                needLoginFromWeb = false

                self.showActivity()
                
                self.signInWithFacebookToken(token, success: { (user:UserInfo) in
                    NSLog("Signed In with current token")
                    self.hideActivity()
                    self.onSignedUp(user)
                }, fail: { (message:String?) in
                    self.signupUserWithToken(token, successBlock: { (user:UserInfo) in
                        NSLog("Signed Up with current token")
                        self.hideActivity()
                        self.onSignedUp(user)
                    }, andFailure: { (message:String?) in
                        self.hideActivity()
                        self.showError(message)
                    })
                })
            }
        }
        if (needLoginFromWeb) {
            
            self.showActivity()

            loginToFacebookWithSuccess({ (user:UserInfo) in
                self.hideActivity()
                self.onSignedUp(user)
            }, andFailure:  { (message:String?) in
                self.hideActivity()
                self.showError(message)
            })
        }
    }
    
    fileprivate func loginToFacebookWithSuccess(_ successBlock: @escaping (UserInfo) -> (), andFailure failureBlock: @escaping (String?) -> ()){
        
        if FBSDKAccessToken.current() != nil {
            if Constants.loginDebug {
                FBSDKLoginManager().logOut()
            } else {
             //   self.dismiss(animated: true, completion: nil)
            }
        }
        //(FBSDKLoginManagerLoginResult?, Error?)
        FBSDKLoginManager().logIn(withReadPermissions: fbPermissions, from: self, handler: { (result: FBSDKLoginManagerLoginResult?, error: Error?) -> Void in
            
            if (error != nil) {
                NSLog("Error logging in. \(error)")
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
 //           let fbUserID = result!.token.userID
            
            self.signupUserWithToken(fbToken!, successBlock: successBlock, andFailure: failureBlock)
            } )
    }
    
    fileprivate func onSignedUp(_ user: UserInfo) {
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
    
    fileprivate func signInWithFacebookToken(_ token:String, success: ((_ user:UserInfo)->Void)?, fail: ((_ message: String?)->Void)?) {
        ServerManager.shared.SignInWithFacebook(access_token: token, onSuccess: { (user:UserInfo) in
            if (success != nil) {
                success!(user)
            }
        }, onFail: { (message:String?) in
            if (fail != nil) {
                fail!(message)
            }
        })
    }
    
    fileprivate func signupUserWithToken(_ token: String, successBlock: @escaping (UserInfo) -> (), andFailure failureBlock: @escaping (String?) -> ()){
        //    Alamofire.request(.GET, Constants.API.FbAuth, parameters: ["access_token": token])
    /*    Alamofire.request(Constants.API.FbAuth, method: HTTPMethod.get, parameters: ["access_token": token], encoding: JSONEncoding.default)
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
        let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email,name,first_name,last_name"], httpMethod: "GET")
        req?.start(completionHandler: { (connection: FBSDKGraphRequestConnection?, result: Any?, error: Error?) in
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

extension SignUpVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.fieldFirstName) {
            self.fieldFirstName.resignFirstResponder()
            self.fieldLastName.becomeFirstResponder()
        } else if (textField == self.fieldFirstName) {
            self.fieldLastName.resignFirstResponder()
            self.fieldEmail.becomeFirstResponder()
        } else if (textField == self.fieldEmail) {
            self.fieldEmail.resignFirstResponder()
            self.fieldPassword.becomeFirstResponder()
        } else {            
            self.onSignUpPressed()
        }
        return true
    }
    
}
