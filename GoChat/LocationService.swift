//
//  LocationService.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/6/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate
{
    fileprivate let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        return manager
    }()
    
    // keep track of most recent location
    // useful when presenting a new vc w/ a map to use this location as default
    static var lastLocation : CLLocationCoordinate2D?
    
    fileprivate var locationCompletionHandler: ((CLLocationCoordinate2D?, Error?) -> Void)?
    
    func getLocation(completion: @escaping (CLLocationCoordinate2D?, Error?) -> Void)
    {
        print("getting location")
        
        // system async prompts user for permission w/ usage string if and only if status is not determined
        // otherwise it does nothing and does NOT call didChangeAuthorization
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self
        self.locationCompletionHandler = completion
        self.locationManager.startUpdatingLocation()
    }
    
    static func alertUserForFailedLocation(fromHostController hostController: UIViewController, completion: (() -> Void)?)
    {
        let controller = UIAlertController(title: "Drat", message: "Can't find your location. Check Settings to make sure you've given us permission to use your location.", preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "OK", style: .cancel) { _ in
            controller.presentingViewController?.dismiss(animated: true, completion: completion)
        }
        
        let settingsButton = UIAlertAction(title: "Settings", style: .default) { _ in
            completion?()
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
        }
        
        controller.addAction(okButton)
        controller.addAction(settingsButton)
        
        hostController.present(controller, animated: true, completion: nil)
    }
    
    // MARK: Location Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        print("didUpdateLocations")
        if let mostRecentLocationCoordinate = locations.last?.coordinate {
            LocationService.lastLocation = mostRecentLocationCoordinate
            self.complete(location: mostRecentLocationCoordinate, error: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error: Could not get location")
        self.complete(location: nil, error: error)
    }
    
    
    //If the user has previously given permission to use location services, 
    //this delegate method will also be called after the location manager is initialized 
    //and has its delegate set with the appropriate authorization status.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        print("Authorization Status changed \(status.rawValue)")
        if status != .authorizedWhenInUse && status != .authorizedAlways && status != .notDetermined {
            let error = NSError(domain: "LocationService", code: Int(status.rawValue), userInfo: nil)
            self.complete(location: nil, error: error)
        }
        //not necessary since we handle start/stop updates in getLocation and the completion handler
//        if status == .authorizedAlways || status == .authorizedWhenInUse {
//            locationManager.startUpdatingLocation()
//        }
    }
    
    // MARK: Helpers
    
    fileprivate func complete(location: CLLocationCoordinate2D?, error: Error?)
    {
        //stop getting locations and save the users battery
        self.locationManager.stopUpdatingLocation()
        
        DispatchQueue.main.async {
            self.locationCompletionHandler?(location, error)
            self.locationCompletionHandler = nil
        }
    }
}
