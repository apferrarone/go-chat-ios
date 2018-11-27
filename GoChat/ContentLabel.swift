//
//  ContentLabel.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/11/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit

class ContentLabel: UILabel
{
    override func awakeFromNib()
    {
        self.setup()
    }
    
    func setup()
    {
        self.font = UIFont(name: "Avenir-Book", size: 15)
    }
}
