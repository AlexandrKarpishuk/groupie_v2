//
//  CommentsInputView.swift
//  groupie
//
//  Created by Sania on 11/2/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit

class CommentInputView : UIView {
    
    var customHeight : CGFloat = 0 {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        get {
            let size = CGSize(width: UIViewNoIntrinsicMetric, height: self.customHeight)
            return size
        }
    }
    
}
