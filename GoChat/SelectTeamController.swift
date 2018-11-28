//
//  SelectTeamController.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/2/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit

class SelectTeamController: UIViewController
{
    @IBOutlet weak var checkButton: UIBarButtonItem!
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet var teamImageViews: [BouncingButton]!
    
    var userIsNew = false
    var completionHandler: AuthenticationResultClosure?
    
    private struct Segues
    {
        static let LOGIN = "loginSegue"
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.checkButton.isEnabled = false // enabled once user selects team
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        let color = UIColor(hex: Constants.ColorHexValues.DARK_GRAY)
        self.navigationController?.navigationBar.barTintColor = color
        self.view.backgroundColor = color
        
        self.teamLabel.text = Constants.Authentication.CHOOSE_TEAM_MESSAGE
        self.teamImageViews.forEach { $0.alpha = 0.0 }

    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        self.animateTeamImageViews()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: Constants.ColorHexValues.DARK_GRAY)
    }
    
// MARK: - Actions:
    
    @IBAction func yellowInstinctSelected(_ sender: UIButton) { self.checkButton.isEnabled = true }
    @IBAction func blueMysticSelected(_ sender: UIButton) { self.checkButton.isEnabled = true }
    @IBAction func redValorSelected(_ sender: UIButton) { self.checkButton.isEnabled = true }
    
    @IBAction func handleCheckMarkTapped(_ sender: UIBarButtonItem)
    {
        self.userIsNew = true
        self.performSegue(withIdentifier: Segues.LOGIN, sender: self)
    }
    
    @IBAction func handleLoginTapped(_ sender: UIButton)
    {
        self.userIsNew = false
        self.performSegue(withIdentifier: Segues.LOGIN, sender: self)
    }
    
// MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == Segues.LOGIN {
            if let loginController = segue.destination.contentViewController as? LoginController {
                loginController.userIsNew = self.userIsNew
                loginController.completionHandler = self.completionHandler
            }
        }
    }
    
// MARK: - Helpers
    
    fileprivate func animateTeamImageViews()
    {
        self.teamImageViews.forEach { $0.alpha = 0.0 }
        
        UIView.animate(withDuration: 1.0, delay: 0.5, options: .curveLinear, animations: {
            self.teamImageViews.forEach { $0.alpha = 1.0 }
        }, completion: nil)
    }
    
// MARK: - Status Bar Style
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
