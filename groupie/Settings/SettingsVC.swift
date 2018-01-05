//
//  SettingsVC.swift
//  groupie
//
//  Created by Sania on 8/13/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import MessageUI

class SettingsVC : GroupieViewController {

    enum SettingsCells : Int {
        case Avatar = 0
        case UserName = 1
        case Notifications = 2
        case MakeMyPostsPublic = 3
        case TermsOfService = 4
        case PrivacyPolicy = 5
        case SendFeedback = 6
        case SEND_TEST_NOTIFICATION = 7
    }
    
    @IBOutlet var table: UITableView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Settings"
        self.navigationController?.navigationBar.topItem?.title = "Settings"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 18)]
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    

}

extension SettingsVC : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "Cell \(indexPath.row)"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        switch (indexPath.row) {
            
        case SettingsCells.Avatar.rawValue:
            if let avatarCell = cell as? SettingCellImage {
                avatarCell.iImage.clipsToBounds = true
                avatarCell.iImage.layer.cornerRadius = avatarCell.iImage.bounds.height * 0.49
                
                if let info = ServerManager.shared.currentUser {
                    var imageURL = URL(string: info.profile_picture_url)
                    if (imageURL == nil) {
                        imageURL = Bundle.main.url(forResource: "groupieAvatar.png", withExtension: nil)
                    }
                    avatarCell.iImage.sd_setImage(with: imageURL,  placeholderImage: UIImage(named:"UserPlaceholder"), options: .allowInvalidSSLCertificates, completed: nil)
                } else {
                    let imageURL = Bundle.main.url(forResource: "groupieAvatar.png", withExtension: nil)

                    avatarCell.iImage.sd_setImage(with: imageURL,  placeholderImage: UIImage(named:"UserPlaceholder"), options: .allowInvalidSSLCertificates, completed: nil)
                }
            }
            break
            
        case SettingsCells.UserName.rawValue:
            
            if let nameCell = cell as? SettingCellTextField {
                nameCell.field.text = ServerManager.shared.currentUser?.username
                nameCell.onEnterPressed = { [weak self, weak nameCell] (newName: String?) in
                    if (newName != nil && !newName!.isEmpty) {
                        if (nameCell?.field.text != ServerManager.shared.currentUser?.username) {
                            ServerManager.shared.SetMeName(newName!, onSuccess: { (UserInfo) in
                                
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
                    } else {
                        let alert = UIAlertController(title: "Attention",
                                                      message: "Please enter name",
                                                      preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK",
                                                      style: UIAlertActionStyle.cancel,
                                                      handler: { [weak nameCell] (action: UIAlertAction) in
                            nameCell?.field.becomeFirstResponder()
                        }))
                        self?.present(alert, animated: true, completion: nil)
                    }
                }
            }
            break
            
        case SettingsCells.Notifications.rawValue:
            let isAllow = ServerManager.shared.currentUser!.allow_notifications
            (cell as! SettingCellSwitch).swOnOff.isOn = isAllow
            (cell as! SettingCellSwitch).onSwitchChanged = { [unowned self] (val:Bool) in
                if (val) {
                    ServerManager.shared.OnNotifications(onSuccess: { (user: UserInfo) in
                        ServerManager.shared.currentUser!.allow_notifications = user.allow_notifications
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
                } else {
                    ServerManager.shared.OffNotifications(onSuccess: { (user: UserInfo) in
                        ServerManager.shared.currentUser!.allow_notifications = user.allow_notifications
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
            break
            
        case SettingsCells.MakeMyPostsPublic.rawValue:
            var isPublic = true
            if let savedIsPublic = KeyChain.GetPassword("SERVICE", account: "MAKE_MY_POSTS_PUBLIC") {
                isPublic = (savedIsPublic == "true")
            }
            (cell as! SettingCellSwitch).swOnOff.isOn = isPublic
            (cell as! SettingCellSwitch).onSwitchChanged = { (val:Bool) in
                KeyChain.SetPassword("SERVICE", account: "MAKE_MY_POSTS_PUBLIC", password: "\(val)")
            }
            break
            
        case SettingsCells.TermsOfService.rawValue:
            (cell as! SettingsCellButtonUnderline).onButtonPressed = {
                UIApplication.shared.openURL(URL(string:"http://groupiefit.com/terms/")!)
            }
            break
            
        case SettingsCells.PrivacyPolicy.rawValue:
            (cell as! SettingsCellButtonUnderline).onButtonPressed = {
                UIApplication.shared.openURL(URL(string:"http://groupiefit.com/privacy/")!)
            }
            break
            
        case SettingsCells.SendFeedback.rawValue:
            (cell as! SettingsCellButtonUnderline).onButtonPressed = { [weak self] in
                if let strongSelf = self {
                    var isSuccess = false
                    if (MFMailComposeViewController.canSendMail()) {
                        let mailVC = MFMailComposeViewController()
                        if (mailVC != nil) {
                            mailVC.setSubject("Groupie feedback")
                            mailVC.setToRecipients(["groupiefit@gmail.com"])
                            mailVC.mailComposeDelegate = strongSelf
                            mailVC.setMessageBody("", isHTML: true)
                            strongSelf.present(mailVC, animated: true, completion: nil)
                            isSuccess = true
                        }
                    }
                    if (!isSuccess) {
                        let mailRecipient = "groupiefit@gmail.com"
                        let mailSubject = "Groupie feedback"
                        let mailBody = ""
                        
                        let mailTo = "mailto:\(mailRecipient)?subject=\(mailSubject)&body=\(mailBody)"
                        
                        guard let escapedMailTo = mailTo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                            NSLog("Invalid mail to format")
                            return
                        }
                        
                        guard let url = URL(string: escapedMailTo) else {
                            NSLog("Invalid mail to format: \(escapedMailTo)")
                            return
                        }
                        
                        if (UIApplication.shared.canOpenURL(url)) {
                            UIApplication.shared.openURL(url)
                        } else {
                            let alert = UIAlertController(title: "Attention",
                                                          message: "Fail to send email. Please setup email on device",
                                                          preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK",
                                                          style: UIAlertActionStyle.cancel,
                                                          handler: { (action: UIAlertAction) in
                            }))
                            strongSelf.present(alert, animated: true, completion: {
                            })
                        }
                    }
                }
            }
            break
            
        case SettingsCells.SEND_TEST_NOTIFICATION.rawValue:
            (cell as! SettingsCellButtonUnderline).onButtonPressed = {
                ServerManager.shared.SendTestNotification(onSuccess: { 
                    
                }, onFail: { (_:String?) in
                    
                })
            }
            break
            
        default:
            break
        }
        
        return cell
    }
}

extension SettingsVC : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch (indexPath.row) {
            
        case SettingsCells.Avatar.rawValue:
            return 140
            
        default:
            break
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.row) {
            
        case SettingsCells.Avatar.rawValue:
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.gray,
                                                             NSFontAttributeName:UIFont.systemFont(ofSize: 15)], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.black,
                                                             NSFontAttributeName:UIFont.systemFont(ofSize: 15)], for: .highlighted)
            UINavigationBar.appearance().isTranslucent = false
        
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.allowsEditing = false
            picker.delegate = self
            //self.navigationController?.show(picker, sender: true)
            self.slideMenuController()?.present(picker, animated: true, completion: nil)

            break
            
        default:
            break
        }

    }
    
}


extension SettingsVC : UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.clear,
                                                         NSFontAttributeName:UIFont.systemFont(ofSize: 0.1)], for: .normal)
    UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.clear,
                                                         NSFontAttributeName:UIFont.systemFont(ofSize: 0.1)], for: .highlighted)
        UINavigationBar.appearance().isTranslucent = true
        picker.dismiss(animated: true, completion: nil)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let cell = self.table.cellForRow(at: IndexPath(row: SettingsCells.Avatar.rawValue, section: 0)) as! SettingCellImage
        cell.iImage.showActivity(animated: true)
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
                ServerManager.shared.SetAvatarImage(jpegData: jpegData!, onSuccess: { [weak cell] (user:UserInfo) in
                    let imageURL = URL(string: user.profile_picture_url)
                    SDWebImageManager.shared().imageCache?.removeImage(forKey: user.profile_picture_url, fromDisk: true, withCompletion: {
                        DispatchQueue.main.async {
                            cell?.iImage.sd_setImage(with: imageURL,  placeholderImage: UIImage(named:"UserPlaceholder"), options: .allowInvalidSSLCertificates, completed: { (_, _, _, _) in
                                cell?.iImage.hideActivity()
                            })
                        }
                    })
                    
                    
                }, onFail: { [weak cell] (message:String?) in
                    NSLog("\(message)")
                    cell?.iImage.hideActivity()
                })
            } else {
                cell.iImage.hideActivity()
            }
        }
    UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.clear,
                                                         NSFontAttributeName:UIFont.systemFont(ofSize: 0.1)], for: .normal)
    UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.clear,
                                                         NSFontAttributeName:UIFont.systemFont(ofSize: 0.1)], for: .highlighted)
        UINavigationBar.appearance().isTranslucent = true
        picker.dismiss(animated: true, completion: nil)
  //      self.navigationController?.navigationBar.tintColor = .white
    }
}


extension SettingsVC : UINavigationControllerDelegate {
    
}

extension SettingsVC /* Keyboard */ {
    
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
                            self.table.contentInset.bottom = endFrame.height
                            self.table.scrollIndicatorInsets.bottom = endFrame.height
                            
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
                            self.table.contentInset.bottom = 0
                            self.table.scrollIndicatorInsets.bottom = 0
                            self.view.layoutSubviews()
            }, completion: { (Bool) in
                
            })
        }
    }
    
    
}

extension SettingsVC : MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}


