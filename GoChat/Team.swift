//
//  Team.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/2/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit

enum Team: String
{
    case yellow = "yellow"
    case blue = "blue"
    case red = "red"
    
    var name: String {
        switch self {
        case .yellow: return "Instinct"
        case .blue: return "Mystic"
        case .red: return "Valor"
        }
    }
    
    var color: UIColor {
        switch self {
        case .yellow:
            #if DEBUG
                return UIColor(hex: Constants.ColorHexValues.CRYPTO_PINK)
            #endif
            return UIColor(hex:Constants.ColorHexValues.TEAM_INSTICT)
        case .blue: return UIColor(hex:Constants.ColorHexValues.TEAM_MYSTIC)
        case .red: return UIColor(hex:Constants.ColorHexValues.TEAM_VALOR)
        }
    }
    
    var image: UIImage? {
        switch self {
        case .yellow: return UIImage(named: Constants.ImageNames.TEAM_INSTINCT)
        case .blue: return UIImage(named: Constants.ImageNames.TEAM_MYSTIC)
        case .red: return UIImage(named: Constants.ImageNames.TEAM_VALOR)
        }
    }
    
    static func notifyTeamChanged()
    {
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.Notifications.NOTIFICATION_TEAM_CHANGE), object: User.currentUser())
    }
}
