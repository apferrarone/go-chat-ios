//
//  SettingsController.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 1/17/17.
//  Copyright © 2017 Andrew Ferrarone. All rights reserved.
//

import UIKit
import MessageUI

private let SEGUE_MY_STUFF = "myStuff"

private enum Section: Int
{
    case myStuff = 0
    case feedback = 1
    case logout = 2
}

class SettingsController: UITableViewController, MFMailComposeViewControllerDelegate
{
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.usernameLabel.text = User.currentUser()?.username
        self.usernameLabel.textColor = User.currentUser()?.team?.color
    }
    
    // MARK: TableView
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch indexPath.section {
        case Section.myStuff.rawValue:
            let mode = indexPath.row == 0 ? MyPostsControllerMode.myPosts : MyPostsControllerMode.myCommentedPosts
            self.performSegue(withIdentifier: SEGUE_MY_STUFF, sender: mode)
        case Section.feedback.rawValue:
            self.sendFeedback()
        case Section.logout.rawValue:
            self.logoutCurrentUser()
        default:
            break
        }
        
        self.tableView.deselect()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == SEGUE_MY_STUFF {
            if let mode = sender as? MyPostsControllerMode {
                let myPostsController = segue.destination.contentViewController as! MyPostsController
                myPostsController.mode = mode
            }
        }
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    private func sendFeedback()
    {
        let mailComposerController = MFMailComposeViewController()
        
        //be careful not to set delegate, must be mailComposeDelegate
        mailComposerController.mailComposeDelegate = self
        
        mailComposerController.setToRecipients([Constants.Settings.EMAIL_FEEDBACK])
        mailComposerController.setSubject("Feedback")
        mailComposerController.setMessageBody("Guess what?!\n\n", isHTML: false)
        
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposerController, animated: true, completion: nil)
        } else {
            UIAlertController.explain(withPresenter: self, title: "darn", message: "can't send mail on this device")
        }
    }
    
    // MARK: Logout
    
    private func logoutCurrentUser()
    {
        User.currentUser()?.logout { success, error in
            
            DispatchQueue.main.async {
                guard error == nil else {
                    let alertController = UIAlertController(title: "Oh No 😳", message: "That didn't work. Try again or restart the app if the problem continues", preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "OK", style: .cancel) { (_) in
                        alertController.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                    
                    alertController.addAction(okButton)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
            }
        }
    }
    
    // MARK: Utilities
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
