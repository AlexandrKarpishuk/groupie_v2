//
//  IAAPushNoteView.m
//  TLV Airport
//
//  Created by Aviel Gross on 1/29/14.
//  Copyright (c) 2014 NGSoft. All rights reserved.
//

import Foundation
import UIKit

protocol AGPushNoteViewDelegate : NSObjectProtocol {
    func pushNoteDidAppear()
    func pushNoteWillDisappear()
}

class AGPushNoteView : UIToolbar {

    fileprivate static let CLOSE_PUSH_SEC: TimeInterval = 5
    fileprivate static let SHOW_ANIM_DUR: TimeInterval = 0.5
    fileprivate static let HIDE_ANIM_DUR: TimeInterval = 0.35

    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var containerView: UIView!
    
    fileprivate var closeTimer: Timer?
    fileprivate var currentMessage: String?
    fileprivate var pendingPushArr = [String]()
    
    var messageTapActionBlock:((_ message: String?)->Void)?

    //Singleton instance
    fileprivate static var p_sharedPushView: AGPushNoteView?
    static var shared: AGPushNoteView! {
        get {
            if (AGPushNoteView.p_sharedPushView == nil) {
                let nibArr = Bundle.main.loadNibNamed("AGPushNoteView", owner: nil, options: nil)
                for currentObject in nibArr! {
                    if (currentObject is AGPushNoteView)
                    {
                        AGPushNoteView.p_sharedPushView = currentObject as? AGPushNoteView
                        break;
                    }
                }
                AGPushNoteView.p_sharedPushView!.setUpUI()
            }
            return AGPushNoteView.p_sharedPushView
        }
    }


    fileprivate var p_delegate: AGPushNoteViewDelegate?
    static var delegate: AGPushNoteViewDelegate?  {
        get {
            return AGPushNoteView.shared.p_delegate
        }
        set {
            AGPushNoteView.shared.p_delegate = newValue
        }
    }


    override init(frame withFrame: CGRect) {
        super.init(frame: withFrame)
        
        var newFrame = withFrame
        newFrame.size.width = UIApplication.shared.keyWindow!.bounds.width
        self.frame = newFrame
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }

    func setUpUI() {
        let f = self.frame
        let width = UIApplication.shared.keyWindow!.bounds.size.width
        let height: CGFloat = 54
        self.frame = CGRect(x:f.origin.x, y:-height, width:width, height:height)
    
        let cvF = self.containerView.frame
        self.containerView.frame = CGRect(x:cvF.origin.x,
                                          y:cvF.origin.y,
                                          width:self.frame.size.width,
                                          height:cvF.size.height)
    

        self.barTintColor = nil
        self.isTranslucent = true
        self.barStyle = .black

        
    
        self.layer.zPosition = 100000
        self.backgroundColor = UIColor.clear
        self.isMultipleTouchEnabled = false
        self.isExclusiveTouch = true
    
        let msgTap = UITapGestureRecognizer(target:self, action:#selector(messageTapAction))
        self.messageLabel.isUserInteractionEnabled = true
        self.messageLabel.addGestureRecognizer(msgTap)
    
    //:::[For debugging]:::
    //            self.containerView.backgroundColor = [UIColor yellowColor];
    //            self.closeButton.backgroundColor = [UIColor redColor];
    //            self.messageLabel.backgroundColor = [UIColor greenColor];

        UIApplication.shared.delegate!.window!?.addSubview(AGPushNoteView.shared)
    }

    static func awake() {
        if (AGPushNoteView.shared.frame.origin.y == 0) {
            UIApplication.shared.delegate!.window!?.addSubview(AGPushNoteView.shared)
        }
    }

    static func showWithNotificationMessage(message : String) {
        AGPushNoteView.showWithNotificationMessage(message, completed:{
            //Nothing.
        })
    }

    static func showWithNotificationMessage(_ message: String?, completed:(()->Void)?) {
    
        AGPushNoteView.shared.currentMessage = message

        if (message != nil) {
            let APP = UIApplication.shared.delegate
            
            AGPushNoteView.shared.pendingPushArr.append(message!)
            
            AGPushNoteView.shared.messageLabel.text = message
            UIApplication.shared.delegate!.window!?.windowLevel = UIWindowLevelStatusBar
            
            let f = AGPushNoteView.shared.frame
            AGPushNoteView.shared.frame = CGRect(x:f.origin.x,
                                                 y:-f.size.height,
                                                 width:f.size.width,
                                                 height:f.size.height)
            UIApplication.shared.delegate!.window!?.addSubview(AGPushNoteView.shared)
            
            //Show
            UIView.animate(withDuration: AGPushNoteView.SHOW_ANIM_DUR, animations: {
                let f = AGPushNoteView.shared.frame
                AGPushNoteView.shared.frame = CGRect(x:f.origin.x,
                                                     y:0,
                                                     width:f.size.width,
                                                     height:f.size.height)
            }, completion: { (complete:Bool) in
                if (completed != nil) {
                    completed!()
                }
                AGPushNoteView.delegate?.pushNoteDidAppear()
            })
            
            //Start timer (Currently not used to make sure user see & read the push...)
            AGPushNoteView.shared.closeTimer = Timer.scheduledTimer(timeInterval:AGPushNoteView.CLOSE_PUSH_SEC, target: AGPushNoteView.self, selector:#selector(close), userInfo: nil, repeats: false)
        }
    }
    static func closeWitCompletion(completed:(()->Void)?) {
        AGPushNoteView.delegate?.pushNoteWillDisappear()

    
        AGPushNoteView.shared.closeTimer?.invalidate()
    
        UIView.animate(withDuration: AGPushNoteView.HIDE_ANIM_DUR, animations: {
            let f = AGPushNoteView.shared.frame
            AGPushNoteView.shared.frame = CGRect(x:f.origin.x,
                                                 y:-f.size.height,
                                                 width:f.size.width,
                                                 height:f.size.height)
        }, completion: { (complete:Bool) in
            AGPushNoteView.shared.handlePendingPushJumpWitCompletion(completed)
        })
    }

    static func close() {
        AGPushNoteView.closeWitCompletion(completed: nil)
    }

    func handlePendingPushJumpWitCompletion(_ completed:(()->Void)?) {
        let lastObj = self.pendingPushArr.last //Get myself
        if (lastObj != nil) {
            self.pendingPushArr.removeLast() //Remove me from arr
            if let messagePendingPush = self.pendingPushArr.last { //Maybe get pending push //If got something - remove from arr, - than show it.
                self.pendingPushArr.removeLast()
                AGPushNoteView.showWithNotificationMessage(messagePendingPush, completed:completed)
            } else {
                UIApplication.shared.delegate!.window!?.windowLevel = UIWindowLevelNormal
            }
        }
    }

    static func setMessageAction(action:((_ message: String?)->Void)?) {
        AGPushNoteView.shared.messageTapActionBlock = action
    }

    func messageTapAction() {
        if (self.messageTapActionBlock != nil) {
            self.messageTapActionBlock!(self.currentMessage)
            AGPushNoteView.close()
        }
    }

    @IBAction func closeActionItem(_ sender: UIBarButtonItem) {
        AGPushNoteView.close()
    }
}
