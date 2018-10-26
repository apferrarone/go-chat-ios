//
//  TeamColorButton.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/8/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit

class TeamColorButton: BouncingButton
{
    override init(frame: CGRect)
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
        self.updateImage()
        self.listenForTeamChanges(true)
    }
    
    func handleTeamChange(notification: Notification)
    {
        self.updateImage()
    }
    
    fileprivate func listenForTeamChanges(_ shouldListen: Bool)
    {
        if shouldListen {
            NotificationCenter.default.addObserver(self, selector: #selector(handleTeamChange), name: Notification.Name(rawValue: Constants.Notifications.NOTIFICATION_TEAM_CHANGE), object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Constants.Notifications.NOTIFICATION_TEAM_CHANGE), object: nil)
        }
    }
    
    // override in subclass
    func image(forTeam team: Team?) -> UIImage?
    {
        return nil
    }
    
    fileprivate func updateImage()
    {
        let team = User.currentUser()?.teamMode == .team ? User.currentUser()?.team : nil
        self.setImage(self.image(forTeam: team), for: .normal)
    }
}
