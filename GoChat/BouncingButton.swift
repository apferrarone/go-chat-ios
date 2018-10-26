//
//  BouncingButton.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/2/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit

class BouncingButton: UIButton
{
    override var isHighlighted : Bool {
        didSet {
            isHighlighted ? self.touchDown() : self.touchUp()
        }
    }
}
