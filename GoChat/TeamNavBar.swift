//
//  TeamNavBar.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/12/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit

enum NavBarSide
{
    case left
    case right
}

// if you subclass UINavigationBar, the nav controller must be initialized with init(navigationBarClass:toolbarClass:)
class TeamNavBar: UINavigationBar
{
    let DARK_GRAY = UIColor(hex: Constants.ColorHexValues.DARK_GRAY)
    
    // returns the UISwtich from the topLevel Navigation Item
    // so the visible Nav Bar switch, checking for it on the left side first
    var topTeamSwitch: UISwitch? {
        get {
            if let button = self.topItem?.leftBarButtonItem?.customView as? UISwitch {
                return button
            } else if let button = self.topItem?.rightBarButtonItem?.customView as? UISwitch {
                return button
            }
            return nil
        }
    }
    
    var allTeamSwitches: [UISwitch] {
        get {
            var switches = [UISwitch]()
            if let items = self.items {
                for item in items {
                    if let button = self.switchFromItem(item) {
                        switches.append(button)
                    }
                }
            }
            return switches
        }
    }
    
    required override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup()
    {
        self.barTintColor = DARK_GRAY
        self.updateBasedOnTeamColor()
        self.listenForColorChanges(true)
    }
    
    deinit {
        self.listenForColorChanges(false)
    }
    
    // Utilities
    
    fileprivate func switchFromItem(_ item: UINavigationItem) -> UISwitch?
    {
        var buttonSwitch = item.leftBarButtonItem?.customView as? UISwitch
        if buttonSwitch == nil {
            buttonSwitch = item.rightBarButtonItem?.customView as? UISwitch
        }
        return buttonSwitch
    }
    
    fileprivate func listenForColorChanges(_ shouldListen: Bool)
    {
        if shouldListen {
            NotificationCenter.default.addObserver(self, selector: #selector(colorsChanged), name: Notification.Name(rawValue: Constants.Notifications.NOTIFICATION_TEAM_CHANGE), object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Constants.Notifications.NOTIFICATION_TEAM_CHANGE), object: nil)
        }
    }
    
    func colorsChanged(notification: Notification)
    {
        self.updateBasedOnTeamColor()
    }
    
    fileprivate func updateBasedOnTeamColor()
    {
        self.isTranslucent = false
        self.isOpaque = true
        
        if let user = User.currentUser() {
            let color = user.currentColor()
            let otherColor = color == DARK_GRAY ? user.team?.color : DARK_GRAY
            
            self.barTintColor = color
            
            UIView.animate(withDuration: 0.23) {
                
                for button in self.allTeamSwitches {
                    button.isOn = user.teamMode == .team
                    button.tintColor = self.DARK_GRAY
                    button.onTintColor = otherColor
                    button.backgroundColor = otherColor
                    button.layer.cornerRadius = 16
                }
            }
        }
        
        #if DEBUG
        for button in self.allTeamSwitches {
            button.onTintColor = UIColor(hex: Constants.ColorHexValues.CRYPTO_PINK)
        }
        #endif
    }
}

/**
 * Extension UINavBar
 */
extension UINavigationItem
{
    func showSpinner(onSide side: NavBarSide)
    {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        
        let barButtonSpinner = UIBarButtonItem(customView: spinner)
        
        switch side {
        case .right: self.rightBarButtonItem = barButtonSpinner
        case .left: self.leftBarButtonItem = barButtonSpinner
        }
    }
}
