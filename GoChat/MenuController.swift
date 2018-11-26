//
//  MenuController.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 1/4/17.
//  Copyright © 2017 Andrew Ferrarone. All rights reserved.
//

import UIKit

class MenuController: UIViewController, UINavigationControllerDelegate
{
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var shareContainer: UIView!
    @IBOutlet weak var shareButton: BouncingButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    
    weak var newPostDelegate: NewPostControllerDelegate?
    
    private struct Menu {
        static let NEW_POST_NAVIGATION_IDENTIFIER = "NewPostNavigation"
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.shareButton.setTitleColor(UIColor.white, for: .normal)
        self.setupParticles()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        self.navigationController?.delegate = self
    }
    
    // MARK: Actions
    @IBAction func handleShare(_ sender: UIButton)
    {
        print("Share the App!")
    }
    
    //new post - not the best method name
    @IBAction func handleAdd(_ sender: UIButton)
    {
        if let newPostNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Menu.NEW_POST_NAVIGATION_IDENTIFIER) as? UINavigationController {
            let newPostController = newPostNavigationController.viewControllers.first as? NewPostController
            newPostController?.delegate = self.newPostDelegate
            
            //present the vc modally indpendent of the current nav stack and pop off the top (menuVC)
            self.navigationController?.present(newPostNavigationController, animated: true) {
                
                _ = self.navigationController?.popViewController(animated: false)
            }
        }
    }
    
    @IBAction func handleSettings(_ sender: UIButton)
    {
        print("Handle Settings")
    }
    
    @IBAction func menuTapped(_ sender: UIButton)
    {
        //set navController delegate then pop (delegate is necessary for custom transition)
        //first vc on stack is where we are popping back to (PostsController) + it provides the delegate method
        self.navigationController?.delegate = self.navigationController?.viewControllers[0] as! PostsController
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
// MARK: - Particle Emitter
    
    private func setupParticles()
    {
        self.view.layoutIfNeeded()
        self.shareContainer.layoutIfNeeded()
        
        let particleEmitter = CAEmitterLayer()
        particleEmitter.emitterPosition = self.shareButton.center
        particleEmitter.emitterSize = CGSize(width: 60.0, height: 30.0)
        particleEmitter.emitterMode = kCAEmitterLayerVolume
        particleEmitter.emitterShape = kCAEmitterLayerRectangle
        particleEmitter.emitterCells = [self.emitterCell()]
        
        self.shareContainer.layer.insertSublayer(particleEmitter, at: 0)
    }
    
    private func emitterCell() -> CAEmitterCell
    {
        let cell = CAEmitterCell()
        cell.birthRate = 3.0
        cell.lifetime = 7.0
        cell.lifetimeRange = 0.0
        cell.velocity = 250.0
        cell.velocityRange = 50.0
        cell.emissionRange = CGFloat.pi // half circle
        cell.spin = 2.0
        cell.spinRange = 3.0
        cell.scale = 0.5
        cell.scaleRange = 0.25
        cell.scaleSpeed = -0.05
        cell.yAcceleration = 200.0
        
        let image = UIImage(named: "Star")?.cgImage
        cell.contents = image
        
        return cell
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
