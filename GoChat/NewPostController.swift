//
//  NewPostController.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 1/14/17.
//  Copyright © 2017 Andrew Ferrarone. All rights reserved.
//

import UIKit
import MapKit

protocol NewPostControllerDelegate: class
{
    func newPostControllerLocationForPost(controller: NewPostController) -> CLLocationCoordinate2D?
    func newPostControllerDidCancel(controller: NewPostController)
    func newPostControllerDidSubmit(controller: NewPostController, newPost: Post, location: CLLocationCoordinate2D)
}

class NewPostController: UIViewController, PostsMapDelegate, KeyboardMover, UITextViewDelegate
{
    @IBOutlet weak var mapView: PostsMap!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var mapButton: BouncingButton!
    @IBOutlet weak var coordinateLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    weak var delegate: NewPostControllerDelegate?
    private var spinner: UIActivityIndicatorView?
    
    // not an IBOutlet - just to hold onto them when hiding and showing
    private var leftNavigationButton: UIBarButtonItem?
    private var rightNavigationButton: UIBarButtonItem?
    
    var location: CLLocationCoordinate2D? = LocationService.lastLocation {
        didSet {
            if location != nil {
                self.coordinateLabel.text = String(format: "%5f, %5f", location!.latitude, location!.longitude)
            }
        }
    }
    
    private var navigationTitle: String {
        get {
            return User.currentUser()?.teamMode == .team ? Constants.NewPost.TITLE_TEAM : Constants.NewPost.TITLE_DEFAULT
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = self.navigationTitle
        self.setupMap()
        self.listenForKeyboardNotifications(shouldListen: true)
        self.textView.tintColor = User.currentUser()?.team?.color
        self.textView.text = nil
        self.textView.contentInset.bottom = 8.0
        self.textView.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if let location = self.location {
            self.mapView.setCenter(location, animated: false)
        }
        self.mapView.postDelegate = self
    }
    
    deinit
    {
        self.listenForKeyboardNotifications(shouldListen: false)
    }
    
    // MARK: UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        return textView.text.characters.count + (text.characters.count - range.length) <= Constants.NewPost.CHARACTERS_MAX
    }
    
    // MARK: PostsMapDelegate
    
    func postsMapView(_ mapView: PostsMap, didMoveToCenterCoordinate centerCoordinate: CLLocationCoordinate2D)
    {
        self.location = centerCoordinate
    }
    
    // MARK: Actions
    
    @IBAction func handleCheckTapped(_ sender: UIButton)
    {
        //if we are looking at the map toggle back since user selected location
        if self.contentView.isHidden {
            self.toggleMap(self.mapButton)
        } else {
            
            //we are ready to post user's new post:
            if let text = self.textView.text, !text.isEmpty, let currentLocation = self.location {
                sender.isEnabled = false
                
                let newPost = Post()
                newPost.content = text
                newPost.latitude = currentLocation.latitude
                newPost.longitude = currentLocation.longitude
                newPost.isPrivate = User.currentUser()?.teamMode == .team
                
                //save new post
                self.showSpinner(true)
                
                newPost.save { post, error in
                    
                    DispatchQueue.main.async {
                        self.showSpinner(false)
                        
                        if error != nil {
                            sender.isEnabled = true //enable send button (also should notify user)
                        } else {
                            
                            //success
                            self.view.endEditing(true)
                            self.delegate?.newPostControllerDidSubmit(controller: self, newPost: post, location: currentLocation)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func handleCancel(_ sender: UIButton)
    {
        self.textView.endEditing(true)
        self.presentingViewController?.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func toggleMap(_ sender: BouncingButton)
    {
        var shouldShowContent = false
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3)
        {
            if self.contentView.isHidden {
                
                //show Content
                shouldShowContent = true
                self.contentView.isHidden = false
                self.textView.becomeFirstResponder()
                self.title = self.navigationTitle
                self.navigationItem.leftBarButtonItem = self.leftNavigationButton
                
            } else {
                
                //show map
                self.textView.resignFirstResponder()
                self.title = Constants.NewPost.TITLE_MAP
                self.leftNavigationButton = self.navigationItem.leftBarButtonItem
                self.navigationItem.leftBarButtonItem = nil
            }
            
            self.contentView.alpha = shouldShowContent ? 1.0 : 0.0
            self.contentView.isHidden = !shouldShowContent
        }
    }
    
    @IBAction func handleCurrentLocation(_ sender: BouncingButton)
    {
        //our center pin is offet 14 pixels so the bottom points to the center
        self.mapView.centerOnCurrentUser()
    }
    
    // MARK: KeyboardMover
    
    func keyboardMoved(notification: Notification)
    {
        self.view.layoutIfNeeded() //update pending layout changes then animate
        
        UIView.animateWithKeyboardNotification(notification: notification) { (keyboardHeight, keyboardWindowY) in
            
            self.bottomConstraint.constant = keyboardHeight
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: Utilities
    
    private func showSpinner(_ shouldShow: Bool)
    {
        self.rightNavigationButton = self.navigationItem.rightBarButtonItem
        
        if shouldShow {
            self.spinner = self.navigationItem.showSpinner(shouldShow: true, onSide: .right)
        } else {
            self.spinner?.stopAnimating()
            self.navigationItem.rightBarButtonItem = self.rightNavigationButton
        }
    }
    
    private func setupMap()
    {
        //set delegate in viewDidAppear to prevent map from changing coordinate
        self.view.layoutIfNeeded()
        self.mapView.layoutIfNeeded()
        
        //if a location is provided to jump to, use it:
        if let chosenLocation = self.delegate?.newPostControllerLocationForPost(controller: self) {
            self.location = chosenLocation
            self.mapView.setCenter(chosenLocation, animated: false)
        }
        
        // otherwise use the last known location as default
        else if let coordinate = self.location {
            self.mapView.setCenter(coordinate, animated: false)
        }
        
        self.mapView.zoomToHumanLevel()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
