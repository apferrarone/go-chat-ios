//
//  PokeballButton.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 1/9/17.
//  Copyright © 2017 Andrew Ferrarone. All rights reserved.
//

import UIKit

class PokeballButton: UIButton
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
        let createImage = UIImage(named: "CreateIconWhite")
        self.setImage(createImage, for: .normal)
    }
}
