//
//  MyPostsController.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 1/17/17.
//  Copyright © 2017 Andrew Ferrarone. All rights reserved.
//

import UIKit

enum MyPostsControllerMode: String
{
    case myPosts = "my posts"
    case myCommentedPosts = "posts i commented on"
}

class MyPostsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate
{
    @IBOutlet weak var postsMapView: PostsMap!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var teamSwitch: UISwitch!
    
    lazy var localPosts = [Post]()
    lazy var teamPosts = [Post]()
    
    var currentPosts: [Post] {
        get {
            return self.teamSwitch.isOn ? self.teamPosts : self.localPosts
        }
    }
    
    var mode = MyPostsControllerMode.myPosts
    
    private struct MyPosts
    {
        static let CELL_IDENTIFIER_POST = "MyPostCell"
        static let SEGUE_TO_DETAIL = "MyPostsToDetail"
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let isTeamMode = User.currentUser()?.teamMode == .team
        self.teamSwitch.setOn(isTeamMode, animated: false)
        self.setupTableView()
        
        if self.mode == .myPosts {
            self.getMyPosts()
        } else if self.mode == .myCommentedPosts {
            self.getMyCommentedPosts()
        }
        
        self.setTitle()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.tableView.deselect()
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        self.navigationController?.delegate = self
    }
    
    // MARK: Actions
    
    @IBAction func toggleTeamMode(_ sender: UISwitch)
    {
        User.currentUser()?.teamMode = sender.isOn ? .team : .local
        self.setTitle()
                
        UIView.animate(withDuration: 0.3, animations: { 
            
            self.tableView.alpha = 0.0
            
        }) { finished in
            
            self.updateMapPins()
            self.tableView.reloadData()
            self.tableView.contentOffset = CGPoint(x: 0.0, y: -self.tableView.contentInset.top)
            
            UIView.animate(withDuration: 0.2) {
                self.tableView.alpha = 1
            }
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.currentPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: MyPosts.CELL_IDENTIFIER_POST, for: indexPath) as! PostCell
        
        //work around for crash when scrolling fast and switching team
        if self.currentPosts.count > indexPath.row {
            cell.post = self.currentPosts[indexPath.row]
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = self.currentPosts[indexPath.row]
        self.performSegue(withIdentifier: MyPosts.SEGUE_TO_DETAIL, sender: post)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == MyPosts.SEGUE_TO_DETAIL {
            if let post = sender as? Post {
                let detailController = segue.destination.contentViewController as! PostDetailController
                detailController.post = post
            }
        }
    }
    
    // MARK: Utilities
    
    private func getMyPosts()
    {
        if let user = User.currentUser() {
            APIService().getPosts(forUser: user) { localPosts, teamPosts, error in
                
                DispatchQueue.main.async {
                    if let userLocalPosts = localPosts, let userTeamPosts = teamPosts {
                        self.localPosts = userLocalPosts
                        self.teamPosts = userTeamPosts
                        self.tableView.reloadData()
                        self.updateMapPins()
                    }
                }
            }
        }
    }
    
    private func getMyCommentedPosts()
    {
        if let user = User.currentUser() {
            APIService().getCommentedPosts(forUser: user) { localPosts, teamPosts, error in
                
                DispatchQueue.main.async {
                    if let userLocalPosts = localPosts, let userTeamPosts = teamPosts {
                        self.localPosts = userLocalPosts
                        self.teamPosts = userTeamPosts
                        self.tableView.reloadData()
                        self.updateMapPins()
                    }
                }
            }
        }
    }
    
    private func setTitle()
    {
        var modeTitle = "my stuff"
        let currentTeamMode = User.currentUser()?.teamMode
        
        if self.mode == .myPosts && currentTeamMode == .local {
            modeTitle = Constants.MyPosts.TITLE_NEARBY_POSTS
        }
        if self.mode == .myPosts && currentTeamMode == .team {
            modeTitle = Constants.MyPosts.TITLE_TEAM_POSTS
        }
        if self.mode == .myCommentedPosts && currentTeamMode == .local {
            modeTitle = Constants.MyPosts.TITLE_NEARBY_COMMENTS
        }
        if self.mode == .myCommentedPosts && currentTeamMode == .team {
            modeTitle = Constants.MyPosts.TITLE_TEAM_COMMENTS
        }
        
        self.title = modeTitle
    }
    
    private func setupTableView()
    {
        self.tableView.estimatedRowHeight = 420
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.contentInset.top = 10
        self.tableView.contentInset.bottom = 10
        self.tableView.register(UINib(nibName: String(describing: PostCell.self), bundle: nil), forCellReuseIdentifier: MyPosts.CELL_IDENTIFIER_POST)
    }
    
    private func updateMapPins()
    {
        self.postsMapView.setPins(forPosts: self.currentPosts)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
