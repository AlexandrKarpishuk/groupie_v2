//
//  UIViewExt.swift
//  groupie
//
//  Created by Sania on 8/12/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    fileprivate static let ACTIVITY_BACK_TAG = 887
    
    func showActivity(animated:Bool = true) {
        let blackView = UIView(frame:self.bounds)
        blackView.translatesAutoresizingMaskIntoConstraints = false
        blackView.tag = UIView.ACTIVITY_BACK_TAG
        self.addSubview(blackView)
        blackView.backgroundColor = UIColor.black
        blackView.alpha = (animated ? 0.0 : 0.75)
        var constraints = [NSLayoutConstraint]()
        let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[blackView]-0-|", options: NSLayoutFormatOptions(), metrics: [:], views: ["blackView" : blackView])
        constraints += horizontal
        let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[blackView]-0-|", options: NSLayoutFormatOptions(), metrics: [:], views: ["blackView" : blackView])
        constraints += vertical
        
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activity.translatesAutoresizingMaskIntoConstraints = false
        blackView.addSubview(activity)

        let centerY = NSLayoutConstraint(item: activity,
                                         attribute: NSLayoutAttribute.centerY,
                                         relatedBy: NSLayoutRelation.equal,
                                         toItem: blackView,
                                         attribute: NSLayoutAttribute.centerY,
                                         multiplier: 1,
                                         constant: 0)
   //     constraints += [centerY]
        
        let centerX = NSLayoutConstraint(item: activity,
                                         attribute: NSLayoutAttribute.centerX,
                                         relatedBy: NSLayoutRelation.equal,
                                         toItem: blackView,
                                         attribute: NSLayoutAttribute.centerX,
                                         multiplier: 1,
                                         constant: 0)
   //     constraints += [centerX]

        NSLayoutConstraint.activate(constraints)

        blackView.addConstraint(centerY)
        blackView.addConstraint(centerX)

        activity.startAnimating()
        
        if (animated) {
            UIView.animate(withDuration: 0.2,
                           animations: { 
                blackView.alpha = 0.75
            }, completion: { (Bool) in
                blackView.alpha = 0.75
            })
        }
    }
    
    func hideActivity(animated: Bool = true) {
        if (animated) {
            for subView in self.subviews {
                if (subView.tag == UIView.ACTIVITY_BACK_TAG) {
                    UIView.animate(withDuration: 0.3, animations: {
                        subView.alpha = 0
                    }, completion: { (Bool) in
                        subView.removeFromSuperview()
                        while (subView.subviews.count > 0) {
                            subView.subviews.last?.removeFromSuperview()
                        }
                        
                    })
                    return
                }
            }

        } else {
            for subView in self.subviews {
                if (subView.tag == UIView.ACTIVITY_BACK_TAG) {
                    subView.removeFromSuperview()
                    while (subView.subviews.count > 0) {
                        subView.subviews.last?.removeFromSuperview()
                    }
                    return
                }
            }
        }
    }

}

extension UILabel {
    
    func rectOf(for range: Range<String.Index>) -> CGRect?
    {
        guard let text  = self.attributedText else { return nil }
        
        let storge = NSTextStorage(attributedString: text)
        let layout = NSLayoutManager()
        let container = NSTextContainer()
        
        container.size = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        
        container.lineBreakMode = lineBreakMode
        container.lineFragmentPadding = 0.0
        container.maximumNumberOfLines = numberOfLines
        
        layout.addTextContainer(container)
        storge.addLayoutManager(layout)
        
        let loc = text.string.distance(from: text.string.startIndex, to: range.lowerBound)
        let len = text.string.distance(from: range.lowerBound, to: range.upperBound)
        let nsRange = NSMakeRange(loc, len)
        
        let pointer = UnsafeMutablePointer<NSRange>.allocate(capacity: 1)
        layout.characterRange(forGlyphRange: nsRange, actualGlyphRange: pointer)
        
        return layout.boundingRect(forGlyphRange: pointer.move(), in: container)
    }
    
    func rectOf(_ nsRange: NSRange) -> CGRect?
    {
        guard let text  = self.attributedText else { return nil }
        
        let storge = NSTextStorage(attributedString: text)
        let layout = NSLayoutManager()
        let container = NSTextContainer()
        
        container.size = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        
        container.lineBreakMode = self.lineBreakMode
        container.lineFragmentPadding = 0.0
        container.maximumNumberOfLines = numberOfLines
        
        layout.addTextContainer(container)
        storge.addLayoutManager(layout)
                
        let pointer = UnsafeMutablePointer<NSRange>.allocate(capacity: 1)
        layout.characterRange(forGlyphRange: nsRange, actualGlyphRange: pointer)
        
        return layout.boundingRect(forGlyphRange: pointer.move(), in: container)
    }
    
    func indexOfSymbolAtPoint(_ point:CGPoint) -> Int? {
        guard let text = self.attributedText else { return nil }
        let layout = NSLayoutManager()
        let container = NSTextContainer()
        let storge = NSTextStorage(attributedString: text)

        container.size = self.bounds.size
        
        container.lineBreakMode = self.lineBreakMode
      //  container.lineFragmentPadding = 0.0
        container.maximumNumberOfLines = 0
        
        layout.addTextContainer(container)
        storge.addLayoutManager(layout)
        
      /*  let textBoundingBox = layout.usedRect(for: container)
        let textContainerOffset = CGPoint(x: (self.bounds.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (self.bounds.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: point.x - textContainerOffset.x,
                                                     y: point.y - textContainerOffset.y)*/
        let indexOfCharacter = layout.characterIndex(for: point, in: container, fractionOfDistanceBetweenInsertionPoints: nil)
        let glyphRect = layout.boundingRect(forGlyphRange: NSRange(location:indexOfCharacter, length:1), in: container)
        if (glyphRect.contains(point)) {
            return indexOfCharacter
        }
        return nil
      //  return indexOfCharacter
    }
}

extension UITextView {
    func rectOf(_ nsRange: NSRange) -> CGRect?
    {
     //   guard let text  = self.attributedText else { return nil }
        
        let layout = self.layoutManager//NSLayoutManager()
        let container = self.textContainer
     //   let storge = self.textStorage// NSTextStorage(attributedString: self.attributedText)
        
     //   container.size = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        
     //   container.lineBreakMode = .byWordWrapping
     //   container.lineFragmentPadding = 0.0
     //   container.maximumNumberOfLines = 0
        
     //   layout.addTextContainer(container)
     //   storge.addLayoutManager(layout)
        
        let pointer = UnsafeMutablePointer<NSRange>.allocate(capacity: 1)
        layout.characterRange(forGlyphRange: nsRange, actualGlyphRange: pointer)
        
        return layout.boundingRect(forGlyphRange: pointer.move(), in: container)
    }
    
    func rectOfLastChar() -> CGRect {
        if (self.attributedText.length > 0) {
            return self.rectOf(NSMakeRange(self.attributedText.length - 1, 1))!
        }
        if (self.text.count > 0) {
            return self.rectOf(NSMakeRange(self.text.count - 1, 1))!
        }
        return CGRect.zero
    }
}
