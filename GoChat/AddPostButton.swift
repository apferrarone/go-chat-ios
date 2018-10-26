//
//  AddPostButton.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 1/11/17.
//  Copyright © 2017 Andrew Ferrarone. All rights reserved.
//

import UIKit

class AddPostButton: TeamColorButton
{
    override func image(forTeam team: Team?) -> UIImage?
    {
        switch team {
        case .some(.yellow): return UIImage(named: Constants.ImageNames.ADD_YELLOW)
        case .some(.red): return UIImage(named: Constants.ImageNames.ADD_RED)
        case .some(.blue): return UIImage(named: Constants.ImageNames.ADD_BLUE)
        default: return UIImage(named: Constants.ImageNames.ADD_GRAY)
        }
    }
}
