//
//  UserLocationController.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/6/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit

class UserLocationController: UIViewController
{
    var user: User?
    lazy var locationService = LocationService()
    var completionHandler: AuthenticationResultClosure?

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        let color = self.user?.team?.color ?? UIColor(hex: Constants.ColorHexValues.DARK_GRAY)
        self.navigationController?.navigationBar.barTintColor = color
        self.view.backgroundColor = color
    }
    
    @IBAction func mapButtonTapped(_ sender: UIButton)
    {
        //calls us back on the main queue
        self.locationService.getLocation() { (coordinate, error) in
            
            guard error == nil else {
                LocationService.alertUserForFailedLocation(fromHostController: self) {
                    
                    //all we can do is proceed and hope that user adjusts permissions in settings
                    self.completionHandler?(true)
                }
                return
            }
            
            //got the location!!
            self.completionHandler?(true)
        }
    }
}
