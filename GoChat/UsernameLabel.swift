//
//  UsernameLabel.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/13/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit

class UsernameLabel: UILabel
{
    override func awakeFromNib()
    {
        self.setup()
    }
    
    func setup()
    {
        self.font = UIFont(name: "Avenir-Heavy", size: 14)
        self.textColor = .black
    }
}
