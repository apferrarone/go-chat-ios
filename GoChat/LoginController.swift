//
//  LoginController.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/2/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit

class LoginController: UIViewController, UITextFieldDelegate, KeyboardMover
{
    @IBOutlet weak var teamImageView: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet var checkButton: UIBarButtonItem!
    @IBOutlet weak var calloutLabel: UILabel!
    @IBOutlet weak var containerView: ShakyContainerView!
    @IBOutlet weak var containerViewBottomAnchor: NSLayoutConstraint!
    
    var spinner: UIActivityIndicatorView?
    var completionHandler: AuthenticationResultClosure?
    
    private struct Segues
    {
        static let USER_LOCATION = "userLocationSegue"
    }
    
    let user = User()

    var userIsNew = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.checkButton.isEnabled = false // enabled w/ valid login
        self.usernameField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginController.toggleCheckButton), name: Notification.Name.UITextFieldTextDidChange, object: nil)
        self.listenForKeyboardNotifications(shouldListen: true)
        self.updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        self.usernameField.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        self.listenForKeyboardNotifications(shouldListen: false)
    }
    
// MARK: - TextField
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let currentText = textField.text as NSString?
        let newText = currentText?.replacingCharacters(in: range, with: string)
        
        guard let count = newText?.count else { return true }
        
        if textField == self.usernameField {
            return count <= Constants.Authentication.CHARACTERS_MAX_USERNAME
        } else {
            return count <= Constants.Authentication.CHARACTERS_MAX_PASSWORD
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if self.checkButton.isEnabled {
            self.checkButtonTapped(self.checkButton)
            return true
        }
        return false
    }
    
    @objc fileprivate func toggleCheckButton()
    {
        if let usernameCount = self.usernameField.text?.count, let passwordCount = self.passwordTextField.text?.count {
            self.checkButton.isEnabled = usernameCount >= 2 && passwordCount >= 2
        }
    }
    
// MARK: - Actions
    
    @IBAction func checkButtonTapped(_ sender: UIBarButtonItem)
    {
        self.spinner(shouldShow: true)
        
        guard let username = self.usernameField.text?.trimmed(),
            let password = self.passwordTextField.text
            else { return }
        
        // sign up new user
        if self.userIsNew {
            self.verifyAndSignup(withUsername: username, password: password)
        }
        
        // login current user
        else {
            self.login(withUsername: username, password: password)
        }
    }
    
    func verifyAndSignup(withUsername username: String, password: String)
    {
        APIService().verify(username: username, password: password) { (usernameIsAvailable, error) in
            
            DispatchQueue.main.async {
                self.spinner(shouldShow: false)
                
                if usernameIsAvailable {
                    self.calloutLabel.text = " "
                    self.signupNewUser(withUsername: username, password: password)
                } else {
                    self.showCallout(withMessage: Constants.Authentication.USERNAME_TAKEN)
                    self.containerView.shake(duration: 0.05, repeatCount: 3)
                }
            }
        }
    }
    
    func signupNewUser(withUsername username: String, password: String)
    {
        self.spinner(shouldShow: true)
        self.user.username = username
        self.user.password = password
        
        self.user.signUp() { user, error in
            
            DispatchQueue.main.async {
                self.spinner(shouldShow: false)
                
                guard error == nil else {
                    self.showCallout(withMessage: Constants.Authentication.SIGNUP_ERROR_MESSAGE)
                    return
                }
                
                // Cheers! new user is signed up in the db so segue to next controller
                self.performSegue(withIdentifier: Segues.USER_LOCATION, sender: self)
            }
        }
    }
    
    func login(withUsername username: String, password: String)
    {
        self.spinner(shouldShow: true)
        self.user.username = username
        self.user.password = password
        
        self.user.login() { user, error in
            
            DispatchQueue.main.async {
                self.spinner(shouldShow: false)
                
                guard error == nil else {
                    self.showCallout(withMessage: Constants.Authentication.LOGIN_ERROR_MESSAGE)
                    self.containerView.shake(duration: 0.07, repeatCount: 2)
                    return
                }
                
                // Cheers! user is logged in
                self.completionHandler?(false)
            }
        }
    }
    
// MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == Segues.USER_LOCATION {
            if let locationController = segue.destination as? UserLocationController {
                locationController.user = self.user
                locationController.completionHandler = self.completionHandler
            }
        }
    }
    
// MARK: - Keyboard Mover
    
    func keyboardMoved(notification: Notification)
    {
        UIView.animateWithKeyboardNotification(notification: notification) { (keyboardHeight, keyboardWindowY) in
            
            self.containerViewBottomAnchor.constant = keyboardHeight
            self.view.layoutIfNeeded()
        }
    }
    
// MARK: - Helpers
    
    func updateUI()
    {
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: Constants.ColorHexValues.DARK_GRAY)
        self.view?.backgroundColor = UIColor(hex: Constants.ColorHexValues.DARK_GRAY)
        self.containerView?.backgroundColor = UIColor(hex: Constants.ColorHexValues.DARK_GRAY)
        self.teamImageView?.image = UIImage(named: Constants.ImageNames.POKEBALL_GRAY)
    }
    
    func showCallout(withMessage message: String?)
    {
        self.calloutLabel.text = message
        
        // move offscreen
        self.calloutLabel.transform = CGAffineTransform(translationX: (UIApplication.shared.keyWindow?.frame.width)!, y: 0.0)
        
        // animate back into position
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: .curveEaseOut, animations: {
            self.calloutLabel.transform = .identity
        }, completion: nil)
    }
    
    func spinner(shouldShow: Bool)
    {
        if shouldShow {
            self.spinner = self.navigationItem.showSpinner(shouldShow: true, onSide: .right)
        } else {
            self.spinner?.stopAnimating()
        self.navigationItem.rightBarButtonItem = self.checkButton
        }
    }
    
// MARK: - Status Bar Style
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
