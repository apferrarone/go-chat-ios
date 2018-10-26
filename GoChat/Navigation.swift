//
//  Navigation.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/5/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit

extension UINavigationItem
{
    enum NavigationBarSide
    {
        case right
        case left
    }
    
    func showSpinner(shouldShow: Bool, onSide side: NavigationBarSide) -> UIActivityIndicatorView
    {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        
        let barButtonSpinner = UIBarButtonItem(customView: spinner)
        
        if side == .right {
            self.rightBarButtonItem = barButtonSpinner
        } else if side == .left {
            self.leftBarButtonItem = barButtonSpinner
        }
        
        return spinner
    }
}

//in a nav stack, the nav controller will use its preferredStatusBarStyle, not the vcs inside of it
//so just override to use each vcs preferredStatusBarStyle
extension UINavigationController
{
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.topViewController?.preferredStatusBarStyle ?? .default
    }
}
