//
//  PostsController.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/7/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import DZNEmptyDataSet

class PostsController: UIViewController, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, PostsMapDelegate, UINavigationControllerDelegate, NewPostControllerDelegate
{
    // Foreground
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuButton: UIButton!
    
    // Background
    @IBOutlet weak var backgroundContainer: UIView!
    
    @IBOutlet weak var mapView: PostsMap! {
        didSet {
            self.mapView.showsUserLocation = true
        }
    }
    
    @IBOutlet weak var centerPoint: UIImageView!
    @IBOutlet weak var currentLocationButton: BouncingButton!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var teamSwitch: UISwitch! // on for team posts, off for local posts
    
    fileprivate let refreshControl = UIRefreshControl()
    fileprivate let mapSpinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    var location : CLLocationCoordinate2D?
    
    var mapViewIsVisible = false
    var userIsdraggingMap = false
    
    private struct Posts
    {
        static let CELL_IDENTIFIER_POST = "PostCell"
        static let RADIUS_DEFAULT_MILES: Double = 5.0
        static let RADIUS_MINIMUM_MILES: Double = 1.0
        static let SEGUE_POST_DETAIL = "postDetail"
        static let SEGUE_MENU = "showMenu"
    }
    
    lazy var localPosts = [Post]()
    lazy var teamPosts = [Post]()
    
    var currentPosts: [Post] {
        get {
            return self.teamSwitch.isOn ? self.teamPosts : self.localPosts
        }
    }
    
    // follow this all the way and make sure you understand its role:
    var radiusMiles: Double = Posts.RADIUS_DEFAULT_MILES
    
    let locationService = LocationService()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.teamSwitch.setOn(false, animated: false)
        self.setupTableView()
        self.listenForNotifications(true)
        
        self.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.tableView.addSubview(self.refreshControl)
        
        //check for a logged in user, if not begin auth flow
//        self.checkForUser { newUser in
//            Team.notifyTeamChanged() //notify everyone who listens to update their team colors!
//            self.fetchDefaultPosts() //will also center map to users current location
//            self.mapView.zoomToHumanLevel()
//            self.mapView.postDelegate = self
//        }
        
        self.fetchDefaultPosts() //will also center map to users current location
        self.mapView.zoomToHumanLevel()
        self.mapView.postDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.updateTitle()
        self.tableView.deselect()
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        self.navigationController?.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit
    {
        self.listenForNotifications(false)
    }
    
// MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == Posts.SEGUE_POST_DETAIL && sender is Post {
            if let detailController = segue.destination.contentViewController as? PostDetailController {
                detailController.post = sender as? Post
            }
        } else if segue.identifier == Posts.SEGUE_MENU {
            if let menuController = segue.destination.contentViewController as? MenuController {
                menuController.newPostDelegate = self
            }
        }
    }
    
// MARK: - UINavigationControllerDelegate
    
    // implement this method for custom push/pop navigation controller vc transition
    // method receives both vcs involved in transition and we must return an animator object
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        if (fromVC is PostsController && toVC is MenuController) || (fromVC is MenuController && toVC is PostsController) {
            let animator = PostsMenuAnimator()
            animator.isPushAnimation = (operation == .push)
            return animator
        } else {
            return nil
        }
    }
    
// MARK: - NewPostControllerDelegate
    
    func newPostControllerDidCancel(controller: NewPostController) {}
    
    func newPostControllerLocationForPost(controller: NewPostController) -> CLLocationCoordinate2D?
    {
        return self.location
    }
    
    func newPostControllerDidSubmit(controller: NewPostController, newPost: Post, location: CLLocationCoordinate2D)
    {
        self.location = location
        self.centerMap(atCoordinate: location)
        
        controller.presentingViewController?.dismiss(animated: true) {
            
            // update list/ map
            self.fetchPosts(atLocation: location, withinMiles: nil, completion: nil)
            self.mapView.zoomToHumanLevel()
            self.radiusMiles = self.mapView.radiusInMiles()
        }
    }
    
// MARK: - Actions
    
    @IBAction func handleTeamChange(_ sender: UISwitch)
    {
        User.currentUser()?.teamMode = sender.isOn ? .team : .local
        self.updateTitle()
        
        UIView.animate(withDuration: 0.22, animations: {
            self.tableView.alpha = 0
        }) { isFinished in
            self.updateMapPins()
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            self.tableView.contentOffset = CGPoint(x: 0.0, y: -(self.tableView.contentInset.top))
            
            UIView.animate(withDuration: 0.12) {
                self.tableView.alpha = 1.0
            }
        }
    }
    
    @IBAction func menuTapped(_ sender: UIButton)
    {
        self.performSegue(withIdentifier: Posts.SEGUE_MENU, sender: self)
    }
    
    @IBAction func showCurrentLocation(_ sender: UIButton)
    {
        self.mapView.zoomToHumanLevel()
        self.mapView.centerOnCurrentUser()
        self.location = self.mapView.userLocation.coordinate
        self.radiusMiles = self.mapView.radiusInMiles()
        self.tableView.reloadData()
    }
    
    @IBAction func showMap(_ sender: UIButton)
    {
        // show the map, or unhide the list
        let mapShouldBeVisible = !self.mapViewIsVisible
        
        if !mapShouldBeVisible {
            self.tableView.isHidden = false
            self.blurView.isHidden = false
            self.menuButton.isHidden = false
        }
        
        UIView.animate(withDuration: 0.23, animations: {
            self.tableView.alpha = CGFloat(!mapShouldBeVisible ? 1 : 0)
            self.blurView.alpha = CGFloat(!mapShouldBeVisible ? 1 : 0)
            self.menuButton.alpha = CGFloat(!mapShouldBeVisible ? 1 : 0)
        }) { _ in
            self.tableView.isHidden = mapShouldBeVisible
            self.blurView.isHidden = mapShouldBeVisible
            self.menuButton.isHidden = mapShouldBeVisible
        }
        
        self.mapViewIsVisible = mapShouldBeVisible
    }
    
    // MARK: PostsMapDelegate
    
    func postsMap(_ mapView: PostsMap, willMoveFromCenterCoordinate centerCoordinate: CLLocationCoordinate2D)
    {
        self.showMapLoading(false)
    }
    
    func postsMapView(_ mapView: PostsMap, didMoveToCenterCoordinate centerCoordinate: CLLocationCoordinate2D)
    {
        self.location = centerCoordinate
        self.radiusMiles = self.mapView.radiusInMiles()
        
        if self.mapViewIsVisible && !self.mapView.isDragging {
            
            self.showMapLoading(true)
            
            // refresh after 1 second
            wait(seconds: 1.0) {
                
                if self.location?.latitude == centerCoordinate.latitude
                    && self.location?.longitude == centerCoordinate.longitude
                    && !self.mapView.isDragging {
                    
                    print("\nrefresh from map scroll location: \(centerCoordinate.latitude) \(centerCoordinate.longitude)")
                    self.fetchPosts(atLocation: centerCoordinate, withinMiles: self.mapView.radiusInMiles(), completion: nil)
                    self.showMapLoading(false)
                }
            }
        }
    }
    
    func postsMapView(_ mapView: PostsMap, didSelectPost post: Post)
    {
        self.performSegue(withIdentifier: Posts.SEGUE_POST_DETAIL, sender: post)
    }
    
    
    // MARK: TableView
    
    fileprivate func setupTableView()
    {
        // Using auto layout when creating table view cells and the code below (row height)
        // allows for the system to take care of cell sizing
        // ex. label line count needs to be 0 so it will grow dynamically
        self.tableView.estimatedRowHeight = 420
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.contentInset.top = 10
        self.tableView.contentInset.bottom = 96
        self.tableView.register(UINib(nibName: String(describing: PostCell.self), bundle: nil), forCellReuseIdentifier: Posts.CELL_IDENTIFIER_POST)
    }
    
    // MARK: TableView DataSource
    
//    //unecessary now since we fixed the shadowPath drawing but a good thing to do if issues w/ ads
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
//    {
//        cell.contentView.layoutIfNeeded() //shadowPath
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.currentPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: Posts.CELL_IDENTIFIER_POST, for: indexPath) as! PostCell
        
        //work around for crash when scrolling fast / changing switch
        //id you change data source, while tableView is still loading cells it can be a problem
        if self.currentPosts.count > indexPath.row {
            let post = self.currentPosts[indexPath.row]
            cell.post = post
        }
        
        return cell
    }
    
    // MARK: TableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let selectedPost = self.currentPosts[indexPath.row]
        self.performSegue(withIdentifier: Posts.SEGUE_POST_DETAIL, sender: selectedPost)
    }
    
    // DNZEmptyDataSet
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage!
    {
        return UIImage(named: Constants.Posts.IMAGE_NAME_FOR_EMPTY_LOCAL_POSTS)
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString!
    {
        let attributedTitle = NSMutableAttributedString(string: Constants.Posts.TITLE_FOR_EMPTY_LOCAL_POSTS, attributes: [NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 18)!])
        return attributedTitle
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool
    {
        return true
    }
    
    // MARK: Networking & Refresh
    
    func refresh()
    {
        self.fetchPosts(atLocation: self.location, withinMiles: self.radiusMiles, completion: nil)
    }
    
    fileprivate func fetchDefaultPosts()
    {
        //use users location and default radius
        //this will also cause map to recenter based on users location
        self.fetchPosts(atLocation: nil, withinMiles: nil, completion: nil)
    }
    
    //middleman function that accepts optionals and checks minimum radius:
    //if location is nil, then use currentUsers location
    fileprivate func fetchPosts(atLocation location: CLLocationCoordinate2D?, withinMiles radius: Double?, completion: (() -> Void)?)
    {
        // get radius -> must be at least one mile
        var miles: Double = Posts.RADIUS_DEFAULT_MILES
        if let radius = radius, radius > Posts.RADIUS_MINIMUM_MILES {
            miles = radius
        }
        
        // get given location or get users current location
        if let location = location {
            self.fetchPosts(atLocation: location, withinMiles: miles, completion: completion)
        } else {
            
            //called back on Main Queue
            self.locationService.getLocation { newLocation, error in
                
                //set location and center map to this location
                //when default first fetch happens, this is where the map is set
                self.location = newLocation
                self.centerMap(atCoordinate: newLocation)
                
                if let currentLocation = newLocation {
                    self.fetchPosts(atLocation: currentLocation, withinMiles: miles, completion: completion)
                } else {
                    LocationService.alertUserForFailedLocation(fromHostController: self, completion: nil)
                    self.refreshControl.endRefreshing() //in case we refreshed
                }
            }
        }
    }
    
    fileprivate func fetchPosts(atLocation location: CLLocationCoordinate2D, withinMiles radius: Double, completion: (() -> Void)?)
    {
        print("fetching w/ in \(radius) miles")
        APIService().getPosts(forLocation: location, withinMiles: radius) { localPosts, localTeamPosts, error in
            DispatchQueue.main.async {
                
                self.refreshControl.endRefreshing()
                
                // enable emptyDataSet here so that it doesn't show empty before the network call is complete
                self.tableView.emptyDataSetSource = self
                self.tableView.emptyDataSetDelegate = self
                
                if let newLocalPosts = localPosts, let newTeamPosts = localTeamPosts {
                    self.localPosts = newLocalPosts
                    self.teamPosts = newTeamPosts
                    self.tableView.reloadData()
                    self.updateMapPins()
                    completion?()
                }
            }
        }
    }
    
    // MARK: Utilities
    
    fileprivate func listenForNotifications(_ shouldListen: Bool)
    {
        if shouldListen {
            NotificationCenter.default.addObserver(self, selector: #selector(postDeleted(notification:)), name: Notification.Name(rawValue: Constants.Notifications.NOTIFICATION_POST_DELETED), object: nil)
        } else {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    func postDeleted(notification: Notification)
    {
        print("post deleted")
        
        if let post = notification.object as? Post {
            
            if let postIndex = self.localPosts.index(of: post) {
                self.localPosts.remove(at: postIndex)
            } else if let postIndex = self.teamPosts.index(of: post) {
                self.teamPosts.remove(at: postIndex)
            }
            
            self.tableView.reloadData()
            self.updateMapPins()
        }
    }
    
    fileprivate func updateMapPins()
    {
        self.mapView.setPins(forPosts: self.currentPosts)
    }
    
    fileprivate func showMapLoading(_ shouldShow: Bool)
    {
        if shouldShow {
            self.backgroundContainer.addSubview(self.mapSpinner)
            self.mapSpinner.translatesAutoresizingMaskIntoConstraints = false
            self.mapSpinner.topAnchor.constraint(equalTo: self.backgroundContainer.topAnchor, constant: 20.0).isActive = true
            self.mapSpinner.centerXAnchor.constraint(equalTo: self.backgroundContainer.centerXAnchor).isActive = true
            self.mapSpinner.startAnimating()
            print("start map spinner spinner size: \(self.mapSpinner.frame.size)")
        } else {
            self.mapSpinner.hidesWhenStopped = true
            self.mapSpinner.stopAnimating()
            print("stop map spinner")
        }
    }
    
    fileprivate func centerMap(atCoordinate coordinate: CLLocationCoordinate2D?)
    {
        if let location = coordinate {
            self.mapView.setCenter(location, animated: true)
        }
    }
    
    fileprivate func checkForUser(completion: @escaping AuthenticationResultClosure)
    {
        //check if there is a current user signed in, if not, begin auth flow
        if User.currentUser() == nil || User.currentUserToken() == nil {
            
            let authFlowRootController = UIStoryboard(name: Constants.Authentication.MAIN_STORYBOARD_ID, bundle: nil).instantiateViewController(withIdentifier: Constants.Authentication.ROOT_NAVIGATION_CONTROLLER_ID) as! UINavigationController
            
            let signUpController = authFlowRootController.viewControllers.first as! SelectTeamController
            
            signUpController.completionHandler = { userIsNew in
                
                signUpController.presentingViewController?.dismiss(animated: true) {
                    
                    completion(userIsNew)
                }
            }
            
            self.present(authFlowRootController, animated: true, completion: nil)
        }
        
        //we have a current user and ready to go
        else {
            completion(false)
        }
    }
    
    func updateTitle()
    {
        self.title = User.currentUser()?.teamMode == .team ? Constants.Posts.TITLE_TEAM_ONLY : Constants.Posts.TITLE_NEARBY
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
}
