//
//  RoundButton.swift
//  groupie
//
//  Created by Sania on 6/7/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation

import UIKit

class RoundedButton : AutosizeButton {
    
    private var p_borderColor : UIColor? = nil
    var borderColor : UIColor? {
        get {
            return self.p_borderColor
        }
        
        set {
            self.p_borderColor = newValue
            
            if self.superview != nil {
                self.applyBorderColor()
            }
        }
    }
    var borderWidth : CGFloat = 1.0
    var cornerRadius : CGFloat = 3.0 {
        didSet {
            self.applyStyle()
        }
    }
    private var p_indicator : UIImageView?
    private var p_savedTitle : String?
    private var p_isLoading : Bool = false
    
    
    //MARK: - Dealloc
    deinit {
        if self.p_indicator != nil {
            self.p_indicator!.removeFromSuperview()
        }
    }
    
    //MARK: -
    override func willMove(toSuperview newSuperview: UIView?) {
        
        super.willMove(toSuperview: newSuperview)
        if (newSuperview != nil) {
            self.applyStyle()
        }
    }
    
    func applyStyle() {
        self.applyBorderColor()
        
        self.layer.cornerRadius = self.cornerRadius
    }
    
    func showLoader() {
        if self.p_isLoading == false {
            if self.p_indicator == nil {
                let indicatorSize = min(self.frame.size.width, self.frame.size.height) * 0.75
                self.p_indicator = UIImageView(frame: CGRect(x: 0, y: 0, width: indicatorSize, height: indicatorSize))
                self.p_indicator!.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
                self.p_indicator?.image = UIImage(named: "Loader")
                self.addSubview(self.p_indicator!)
            }
            
            self.p_isLoading = true
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.titleLabel?.alpha = 0
                self.p_indicator?.alpha = 1
            }, completion: { (Bool) -> Void in
                self.titleLabel?.isHidden = true
                self.p_savedTitle = self.title(for: .normal)
                self.setTitle(nil, for: .normal)
            })
            
            self.startIndicator()
            
            self.isUserInteractionEnabled = false
        }
    }
    
    func hideLoader() {
        if self.p_isLoading == true {
            self.setTitle(self.p_savedTitle, for: .normal)
            self.titleLabel?.alpha = 0
            self.titleLabel?.isHidden = false
            self.p_isLoading = false
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.titleLabel?.alpha = 1
                self.p_indicator?.alpha = 0
                self.titleLabel?.isHidden = false
            }, completion: { (Bool) -> Void in
                self.isUserInteractionEnabled = true
                self.titleLabel?.isHidden = false
            })
        }
    }
    
    private func startIndicator () {
        UIView.animate(withDuration: 0.5, delay:0, options:UIViewAnimationOptions.curveLinear, animations: { () -> Void in
            self.p_indicator!.transform = self.p_indicator!.transform.rotated(by: CGFloat(Double.pi))
        }) { (Bool) -> Void in
            if self.p_isLoading == true {
                self.startIndicator()
            }
        }
    }
    
    private func applyBorderColor() {
        if self.borderColor != nil {
            self.layer.borderColor = self.borderColor?.cgColor
            self.layer.borderWidth = self.borderWidth
        } else {
            self.layer.borderColor = self.borderColor?.cgColor
            self.layer.borderWidth = 0.0
        }
    }
    
}
