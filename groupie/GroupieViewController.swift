//
//  GroupieViewController.swift
//  groupie
//
//  Created by Xinran on 4/15/16.
//  Copyright © 2016 DaisyDaisy. All rights reserved.
//

import UIKit

import FontAwesome_swift

class GroupieViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let sidebarIcon = UIImage.fontAwesomeIcon(name: .bars, textColor: UIColor.lightGray, size: CGSize(width: 24, height: 24))
     //   let sidebarIcon = UIImage(named:"MenuButton")!
        self.addLeftBarButtonWithImage(sidebarIcon)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: CustomSlideMenuController.NOTIFICATION_MENU_WILL_OPEN, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (self.navigationController!.viewControllers.count > 1) {
            let newViewControllers = [self.navigationController!.viewControllers.last]
            self.navigationController!.viewControllers = newViewControllers as! [UIViewController]
        }
        NotificationCenter.default.addObserver(self, selector: #selector(menuWillShow), name: CustomSlideMenuController.NOTIFICATION_MENU_WILL_OPEN, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
 //       self.navigationItem.setLeftBarButton(nil, animated: false)
 //       self.navigationItem.setLeftBarButtonItems(nil, animated: false)
    }
    
    func menuWillShow() {
        self.view.endEditing(true)
    }
}
