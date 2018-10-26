//
//  Views.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/8/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit

extension UIView
{
    func touchUp()
    {
        self.animate(touchDown: false, completion: nil)
    }
    
    func touchDown()
    {
        self.animate(touchDown: true, completion: nil)
    }
    
    func animate(touchDown: Bool, completion: (()->Void)?)
    {
        let damping : CGFloat = (touchDown) ? 1 : 0.34
        let velocity : CGFloat = (touchDown) ? 0.5 : 0.8
        let duration : Double = (touchDown) ? 0.24 : 0.42
        let options : UIViewAnimationOptions = [.curveEaseOut, .beginFromCurrentState]
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: options, animations: {
            self.layer.transform = (touchDown) ? CATransform3DMakeScale(0.92, 0.92, 1) : CATransform3DIdentity
        }) { (done) in
            if done { completion?() }
        }
    }
    
    func roundCorners()
    {
        self.layer.cornerRadius = 12.0
    }
    
    // remember: shadows are drawn based on the alpha channel of your layer pixel by pixel
    // so if you have a transparent view or a complex shape this is great: just set the shadow opacity
    // but if your shadow is simple like a rect or circle, then draw the path since you dont need
    // the gpu to check the alpha channel of every pixel
    // but if shadow paths are not an option then you can improve performance by carefully choosing views 
    // for offscreen rendering use layer.rasterize but profile to make sure this is good b/c it can be worse
    func drawShadow(withOffset offset: CGFloat)
    {
        self.layer.shadowOffset = CGSize(width: 0.0, height: offset)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 1.5
        self.layer.shadowOpacity = 0.40
        self.layer.shouldRasterize = true
        
        //scale matters so you dont render a non retina layer on a retina device
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    /**
     * Go back and test all the fps with the drawing shadow and moving arouns the shouldRasterize lines
     */
    
    func drawShadow()
    {
        self.drawShadow(withOffset: 0.5)
    }
    
    // shadowPath is very fast but does not resize even with autolayout
    // dont set the path in vc, just subclass view and in layoutSubviews redraw the shadowPath
    func rasterizeShadow()
    {
        self.layer.shadowPath = UIBezierPath(roundedRect: self.layer.bounds, cornerRadius: self.layer.cornerRadius).cgPath
    }
    
    // gets a snapshot for use w/ animated vc transitions
    // so that for transitions, a third party object - animator will draw views and animate them
    // each vc is not concerned with the transition and the incoming vc, so use snapshots and animate those
    // and leave each vc untouched
    func rasterizedImageSnapshot() -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshot!
    }
}
