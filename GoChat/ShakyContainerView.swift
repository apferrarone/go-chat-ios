//
//  ShakyContainerView.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/6/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit

class ShakyContainerView: UIView
{
    func shake(duration: CFTimeInterval, repeatCount: Float)
    {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = duration
        animation.repeatCount = repeatCount
        animation.autoreverses = true
        animation.fromValue = [self.center.x - 20, self.center.y]
        animation.toValue = [self.center.x + 20, self.center.y]
        self.layer.add(animation, forKey: "position")
    }
}
