//
//  Alerts.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/17/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit

extension UIAlertController
{
    static func explain(withPresenter presenter: UIViewController, title: String?, message: String?)
    {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "got it", style: .cancel, handler: nil)
        controller.addAction(okAction)
        presenter.present(controller, animated: true, completion: nil)
    }
    
    static func confirm(withPresenter presenter: UIViewController, message: String?, completion: @escaping () -> Void)
    {
        let title = "Just making sure"
        let affirmative = "do it"
        let negative = "nevermind"
        
        self.ask(withPresenter: presenter, title: title, message: message, affirmative: affirmative, negative: negative, completion: completion)
    }
    
    static func ask(withPresenter presenter: UIViewController?, title: String?, message: String?, affirmative: String, negative: String, completion: @escaping () -> Void)
    {
        guard presenter != nil else { return }
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: affirmative, style: .default) { action in
            completion()
        }
        controller.addAction(confirmAction)
        
        let denyAction = UIAlertAction(title: negative, style: .default) { action in
            completion()
        }
        controller.addAction(denyAction)
        
        presenter!.present(controller, animated: true, completion: nil)
    }
}
