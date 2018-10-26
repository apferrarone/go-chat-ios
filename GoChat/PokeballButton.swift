//
//  PokeballButton.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 1/9/17.
//  Copyright © 2017 Andrew Ferrarone. All rights reserved.
//

import UIKit

class PokeballButton: TeamColorButton
{
    override func image(forTeam team: Team?) -> UIImage? {
        #if DEBUG
            return UIImage(named: "CreateIconWhite")
        #endif
        switch team {
            case .some(.yellow): return UIImage(named: Constants.ImageNames.POKEBALL_YELLOW)
            case .some(.red): return UIImage(named: Constants.ImageNames.POKEBALL_RED)
            case .some(.blue): return UIImage(named: Constants.ImageNames.POKEBALL_BLUE)
            default: return UIImage(named: Constants.ImageNames.POKEBALL_GRAY)
        }
    }
}
