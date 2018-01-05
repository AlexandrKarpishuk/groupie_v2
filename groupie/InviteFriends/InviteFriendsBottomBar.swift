//
//  InviteFriendsBottomBar.swift
//  groupie
//
//  Created by Sania on 11/10/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit

enum InviteFriendsState : Int {
    case title = 0
    case invite
}

class InviteFriendsBottomBar : UIView {
    
    fileprivate var p_state : InviteFriendsState = .title
    var state : InviteFriendsState {
        get {
            return self.p_state
        }
        set {
            self.setState(self.state, animated: true)
        }
    }
    
    var inviteHandler: (()->Void)?
    
    fileprivate var p_label : UILabel?
    fileprivate var p_button : UIButton?
    fileprivate var p_labelH : [NSLayoutConstraint]?
    fileprivate var p_labelV : [NSLayoutConstraint]?
    fileprivate var p_buttonH: [NSLayoutConstraint]?
    fileprivate var p_buttonV: [NSLayoutConstraint]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if (self.superview != nil) {
            self.buildView()
        } else {
            if (self.p_labelV != nil)  {self.removeConstraints(self.p_labelV!)}
            if (self.p_labelH != nil)  {self.removeConstraints(self.p_labelH!)}
            if (self.p_buttonV != nil) {self.removeConstraints(self.p_buttonV!)}
            if (self.p_buttonH != nil) {self.removeConstraints(self.p_buttonH!)}
            self.p_label?.removeFromSuperview()
            self.p_button?.removeFromSuperview()
            self.p_button?.removeTarget(self, action: #selector(onButtonTouchUpInside), for: .touchUpInside)
            self.p_label = nil
            self.p_button = nil
        }
    }
    
    func onButtonTouchUpInside() {
        self.inviteHandler?()
    }
    
    fileprivate func buildView() {
        if (self.p_label == nil) {
            self.p_label = UILabel(frame: self.bounds)
            self.p_label?.translatesAutoresizingMaskIntoConstraints = false
            self.p_label?.backgroundColor = UIColor(r:163, g:164, b:166)
            self.p_label?.textColor = .white
            self.p_label?.font = UIFont.systemFont(ofSize: 15)
            self.p_label?.text = "SELECT OR ADD A NEW USER"
            self.p_label?.textAlignment = .center
            self.addSubview(self.p_label!)
            
            self.p_button = UIButton(frame: self.bounds)
            self.p_button?.translatesAutoresizingMaskIntoConstraints = false
            self.p_button?.backgroundColor = UIColor(r:93, g:161, b:208)
            self.p_button?.setTitleColor(.white, for: .normal)
            let attrTitle = NSAttributedString(string: "INVITE", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSForegroundColorAttributeName: UIColor.white])
            self.p_button?.setAttributedTitle(attrTitle, for: .normal)
            self.p_button?.addTarget(self, action: #selector(onButtonTouchUpInside), for: .touchUpInside)
            self.addSubview(self.p_button!)
            
            // Label Constraints
            self.p_labelH = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[label]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["label": self.p_label!])
            self.p_labelV = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[label]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["label": self.p_label!])
            self.addConstraints(self.p_labelH!)
            self.addConstraints(self.p_labelV!)
            
            // Button Constraints
            self.p_buttonH = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[button]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["button": self.p_button!])
            self.p_buttonV = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[button]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["button": self.p_button!])
            self.addConstraints(self.p_buttonH!)
            self.addConstraints(self.p_buttonV!)
            
            self.setState(self.p_state, animated: false)
        }
    }
    
    func setState(_ newState: InviteFriendsState, animated: Bool = true) {
        self.p_state = newState
        if (animated) {
            switch (self.p_state) {
            case .invite:
            //    self.p_button?.isUserInteractionEnabled = true
                break
            case .title:
                self.p_button?.isUserInteractionEnabled = false
                break
            }
            UIView.animate(withDuration: 0.3, animations: {
                switch (self.p_state) {
                case .invite:
                    self.p_button?.alpha = 1
                    break
                case .title:
                    self.p_button?.alpha = 0
                    break
                }
            }) { (_:Bool) in
                switch (self.p_state) {
                case .invite:
                    self.p_button?.isUserInteractionEnabled = true
                    break
                case .title:
                  //  self.p_button?.isUserInteractionEnabled = false
                    break
                }
            }
        } else {
            switch (self.p_state) {
            case .invite:
                self.p_button?.alpha = 1
                self.p_button?.isUserInteractionEnabled = true
                break
            case .title:
                self.p_button?.alpha = 0
                self.p_button?.isUserInteractionEnabled = false
                break
            }
        }
    }
}
