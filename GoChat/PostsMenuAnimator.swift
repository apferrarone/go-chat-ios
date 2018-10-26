//
//  PostsMenuAnimator.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 1/4/17.
//  Copyright © 2017 Andrew Ferrarone. All rights reserved.
//

import UIKit


class PostsMenuAnimator: NSObject, UIViewControllerAnimatedTransitioning
{
    var isPushAnimation = false
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        if self.isPushAnimation {
            self.animateToMenu(withContext: transitionContext)
        } else {
            self.animateFromMenu(withContext: transitionContext)
        }
    }
    
    // MARK: animations
    
    private func animateToMenu(withContext context: UIViewControllerContextTransitioning)
    {
        let postsController = context.viewController(forKey: .from) as! PostsController
        let menuController = context.viewController(forKey: .to) as! MenuController
        let container = context.containerView
        
        // get an image (sort of a snap shot) of the current postsController w/ no content:
        postsController.tableView.alpha = 0.0 //set table view transparent so we are left w/ background
        let backgroundSnapshot = postsController.backgroundContainer.rasterizedImageSnapshot()
        postsController.tableView.alpha = 1.0 //set table view back now that we have snapshot
        
        // setup menuController
        menuController.backgroundImageView.image = backgroundSnapshot
        menuController.view.sendSubview(toBack: menuController.backgroundImageView)
        
        //get final frame for toVc so that when setting up all the rect conversions are correct:
        //add it to the container of the animated transision where the animation takes place
        let centerFrame = context.finalFrame(for: menuController)
        menuController.view.setNeedsLayout()
        menuController.view.layoutIfNeeded()
        menuController.view.frame = centerFrame
        container.addSubview(menuController.view)
        
        //setup addButton
        // we want animation to look like add button is animating from the pokeball menu button
        // so its initial frame needs to be the frame of the pokeball menu button
        let addButtonSnapshot = UIImageView(image: menuController.addButton.image(for: .normal)!)
        let initialAddButtonFrame = menuController.view.convert(menuController.menuButton.frame, from: menuController.menuButton.superview)
        let finalAddButtonFrame = menuController.view.convert(menuController.addButton.frame, from: menuController.addButton.superview)
        container.insertSubview(addButtonSnapshot, at: container.subviews.count)
        addButtonSnapshot.frame = initialAddButtonFrame
        
        //perform the animated transition:
        menuController.addButton.isHidden = true
        menuController.view.alpha = 0.0
        
        //maybe just put this animation w/ the next one
        UIView.animate(withDuration: self.transitionDuration(using: context), animations: { 
            
            menuController.view.alpha = 1.0
            
        }) { isFinished in
            
            let wasCancelled = context.transitionWasCancelled
            context.completeTransition(!wasCancelled)
        }
        
        UIView.animate(withDuration: self.transitionDuration(using: context), delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: { 
            
            addButtonSnapshot.frame = finalAddButtonFrame
            
        }) { isFinished in
            
            //cleanup here
            addButtonSnapshot.removeFromSuperview()
            menuController.addButton.isHidden = false
        }
    }
    
    private func animateFromMenu(withContext context: UIViewControllerContextTransitioning)
    {
        let postsController = context.viewController(forKey: .to) as! PostsController
        let menuController = context.viewController(forKey: .from) as! MenuController
        let container = context.containerView
        
        //add the postController view hierarchy to the container and animate away menuController
        container.insertSubview(postsController.view, at: 0)
        
        //for this one we are animating the add button back to the center of the pokeball menu button
        
        let addButtonSnapshot = UIImageView(image: menuController.addButton.image(for: .normal)!)
        let addButtonFrame = container.convert(menuController.addButton.frame, from: menuController.addButton.superview)
        
        var menuButtonFrame = container.convert(menuController.menuButton.frame, from: menuController.menuButton.superview)
        menuButtonFrame.origin = CGPoint(x: menuButtonFrame.origin.x + menuButtonFrame.size.width / 2, y: menuButtonFrame.origin.y + menuButtonFrame.size.height / 2)
        menuButtonFrame.size = CGSize(width: 0.0, height: 0.0)
        
        addButtonSnapshot.frame = addButtonFrame
        container.addSubview(addButtonSnapshot)
        menuController.addButton.isHidden = true
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            
            menuController.view.alpha = 0.0
            addButtonSnapshot.frame = menuButtonFrame
            
        }) { isFinished in
           
            let wasCancelled = context.transitionWasCancelled
            context.completeTransition(!wasCancelled)
            addButtonSnapshot.removeFromSuperview() //final cleanup
        }
    }
}
