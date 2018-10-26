//
//  ViewControllers.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/3/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit

extension UIViewController
{
    
    //add this var to UIViewController
    var contentViewController: UIViewController {
        if let navCon = self as? UINavigationController {
            return navCon.visibleViewController ?? self
        } else {
            return self
        }
    }
}
