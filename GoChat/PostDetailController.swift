//
//  PostDetailController.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/13/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit
import MapKit
import DZNEmptyDataSet

class PostDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, KeyboardMover, PostDetailHeaderDelegate, GrowingTextViewDelegate
{
    @IBOutlet weak var headerView: PostDetailHeaderView!
    @IBOutlet weak var mapView: PostsMap!
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textContainer: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textContainerBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var textContainerHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var growingTextView: GrowingTextView! {
        didSet {
            self.growingTextView.growingTextViewDelegate = self
            self.growingTextView.maxHeight = 100
            self.growingTextView.font = UIFont(name: "Avenir-Book", size: 15)
            self.growingTextView.placeholderText = "Bruhhh..."
        }
    }
    
    private struct PostDetail {
        static let CELL_IDENTIFIER_COMMENT = "commentCell"
    }
    
    var post: Post?
    var comments = [Comment]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupTableView()
        self.textContainer.drawShadow(withOffset: -0.5)
        self.listenForKeyboardNotifications(shouldListen: true)
        self.headerView.delegate = self
        
        if let post = self.post {
            self.update(withPost: post)
        }
    }
    
    deinit
    {
        self.listenForKeyboardNotifications(shouldListen: false)
    }
    
    // MARK: GrowingTextViewDelegate
    
    func textView(_ textView: GrowingTextView, didChangeHeight height: CGFloat) {
        self.textContainerHeightAnchor.constant = height
    }
    
    // MARK: Actions
    
    @IBAction func handleSend(_ sender: UIButton)
    {
        if let commentText = self.growingTextView.text, !growingTextView.text.isEmpty {
            
            self.sendButton.isEnabled = false
            self.growingTextView.isUserInteractionEnabled = true
            
            self.view.endEditing(true)
            
            let comment = Comment()
            comment.postID = self.post?._id
            comment.content = commentText
            
            comment.save { newComment, error in
                
                DispatchQueue.main.async {
                    guard error == nil else {
                        
                        // keep input container enabled so user can send again:
                        self.sendButton.isEnabled = true
                        self.growingTextView.isUserInteractionEnabled = true
                        self.growingTextView.becomeFirstResponder()
                        return
                    }
                    
                    // success
                    self.growingTextView.text = nil
                    
                    // textViewDidChange only gets called when user changes something
                    // not progamatic changes so we need to call it to update placeholder
                    // call this on the delegate which is not us its the growingTextView
                    self.growingTextView.textViewDidChange(self.growingTextView)
                    
                    self.growingTextView.isUserInteractionEnabled = true
                    self.sendButton.isEnabled = true
                    self.add(comment: newComment)
                }
            }
        }
    }
    
    private var contentIsVisible = false
    
    @IBAction func showMap(_ sender: UIButton)
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.contentContainerView.alpha = self.contentIsVisible ? 1 : 0
        }) { isComplete in
            self.contentContainerView.isHidden = !self.contentContainerView.isHidden
            self.contentIsVisible = !self.contentIsVisible
        }
    }
    
// MARK: - PostDetailHeaderDelegate Actions
    
    func showPostOptions()
    {
        self.showOptions(item: self.post)
    }
    
// MARK: - TableView
    
    private func setupTableView()
    {
        self.tableView.estimatedRowHeight = 88
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.clipsToBounds = false
        self.tableView.contentInset.bottom = 20
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostDetail.CELL_IDENTIFIER_COMMENT, for: indexPath) as! CommentCell
        cell.comment = self.comments[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.showOptions(item: self.comments[indexPath.row])
    }
    
// MARK: - DZNEmptyDataSetSource
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage!
    {
        return UIImage(named: Constants.PostDetail.IMAGE_NAME_FOR_EMPTY_COMMENTS)
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString!
    {
        let attributedText = NSAttributedString(string: Constants.PostDetail.TITLE_FOR_EMPTY_COMMENTS, attributes: [NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 18)!])
        return attributedText
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat
    {
        return 40
    }
    
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool
    {
        return true
    }
    
// MARK: - Keyboard Management
    
    func keyboardMoved(notification: Notification)
    {
        // apple reccomends calling this before to address any pending layout changes
        // always callt on the parent view to update all constraints
        self.view.layoutIfNeeded()
        
        UIView.animateWithKeyboardNotification(notification: notification)
        { keyboardHeight, keyboardWindowY in
            
            self.textContainerBottomAnchor.constant = keyboardHeight
            self.view.layoutIfNeeded()
            
            if keyboardHeight > 0 {
                
                // could also try to scroll the last cell to visible
                // false keeps it less jerky since we are already inside of animation block
                self.tableView.scrollToBottom(animated: false)
                
                // get rid of replies label if snorlax is showing - he will cover it anyway
                if self.comments.count == 0 {
                    self.headerView.repliesLabel.alpha = 0
                }
                
            } else {
                
                // bring back replies label
                self.headerView.repliesLabel.alpha = 1
            }
        }
    }
    
// MARK: - Utilities
    
    private func add(comment: Comment)
    {
        self.comments.append(comment)
        
        // update comments tableView
        let indexPath = IndexPath(row: self.comments.count - 1, section: 0)
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [indexPath], with: .bottom)
        self.tableView.endUpdates()
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
        // update header replies label
        self.update(withNumberOfReplies: self.comments.count)
    }
    
    // works for posts and comments only
    private func showOptions(item: AnyObject?)
    {
        let contentIsUsers: Bool
        let pronoun: String
        let isPost: Bool
        
        // use whichever one is passed in
        var selectedPost: Post! = nil
        var selectedComment: Comment! = nil
        
        if let postItem = item as? Post {
            
            selectedPost = postItem
            isPost = true
            contentIsUsers = postItem.userID == User.currentUser()?._id
            let username = postItem.username != nil ? postItem.username! : "another person"
            pronoun = contentIsUsers ? "your post" : "\(username)'s post"
        }
        else if let commentItem = item as? Comment {
            
            selectedComment = commentItem
            isPost = false
            contentIsUsers = commentItem.userID == User.currentUser()?._id
            let username = commentItem.username != nil ? commentItem.username! : "another person"
            pronoun = contentIsUsers ? "your comment" : "\(username)'s comment"
        }
        else {
            return
        }
        
        // build alert action sheet style controller
        let controller = UIAlertController(title: pronoun, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        
        if contentIsUsers {
            
            // add delete action that is the only option the user will have for their own post or comment:
            let deleteAction = UIAlertAction(title: "delete", style: .destructive) { action in
                UIAlertController.confirm(withPresenter: self, message: "Are you sure you want to delete this?") {
                    isPost ? self.delete(post: selectedPost) : self.delete(comment: selectedComment)
                }
            }
            
            controller.addAction(deleteAction)
            
        }
        else {
            // add report and block user action for another person's post or comment:
            let reportAction = UIAlertAction(title: "report", style: .destructive) { action in
                UIAlertController.confirm(withPresenter: self, message: "Are you sure you want to report this?") {
                    isPost ? self.report(post: selectedPost) : self.report(comment: selectedComment)
                }
            }
            
            controller.addAction(reportAction)
            
            let blockUserAction = UIAlertAction(title: "block user", style: .destructive) { action in
                                UIAlertController.confirm(withPresenter: self, message: "Are you sure you want to block this user forever?") {
                    isPost ? self.blockUser(withUserID: selectedPost.userID) : self.blockUser(withUserID: selectedComment.userID)
                }
            }
            
            controller.addAction(blockUserAction)
        }
        
        // present alert Action sheet
        self.present(controller, animated: true, completion: nil)
    }
    
    private func delete(post: Post)
    {
        self.showLoading(true)
        post.delete { success, error in
            
            DispatchQueue.main.async {
                self.showLoading(false)
                
                if success && error == nil {
                    
                    // broadcast that post was deleted so listeners can update data sources then return back to Posts
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.Notifications.NOTIFICATION_POST_DELETED), object: post)
                    _ = self.navigationController?.popViewController(animated: true)
                    
                } else {
                    UIAlertController.explain(withPresenter: self, title: "Oops", message: "couldn't delete the post.")
                }
            }
        }
    }
    
    private func delete(comment: Comment)
    {
        self.showLoading(true)
        comment.delete { success, error in
            
            DispatchQueue.main.async {
                self.showLoading(false)
                
                if success && error == nil {
                    self.remove(comment: comment)
                } else {
                    UIAlertController.explain(withPresenter: self, title: "Oops", message: "couldn't delete the comment.")
                }
            }
        }
    }
    
    private func report(post: Post)
    {
        self.showLoading(true)
        post.report { success, error in
            
            DispatchQueue.main.async {
                self.showLoading(false)
                
                if success && error == nil {
                    UIAlertController.explain(withPresenter: self, title: "thanks!", message: "you didn't have to care, but you did. shout out you 😊")
                } else {
                    UIAlertController.explain(withPresenter: self, title: "Oops", message: "couldn't report the post.")
                }
            }
        }
    }
    
    private func report(comment: Comment)
    {
        self.showLoading(true)
        comment.report { success, error in
            
            DispatchQueue.main.async {
                self.showLoading(false)
                
                if success && error == nil {
                    UIAlertController.explain(withPresenter: self, title: "thanks!", message: "you didn't have to care, but you did. shout out you 😊")
                } else {
                    UIAlertController.explain(withPresenter: self, title: "Oops", message: "couldn't report the comment.")
                }
            }
        }
    }
    
    private func blockUser(withUserID userID: String?)
    {
        if let id = userID {
            self.showLoading(true)
            
            User.currentUser()?.blockUser(withUserID: id) { success, error in
                
                DispatchQueue.main.async {
                    self.showLoading(false)
                    
                    if success && error == nil {
                        UIAlertController.explain(withPresenter: self, title: "be gone, foul user!", message: "this user's content will be removed when you refresh")
                    } else {
                        UIAlertController.explain(withPresenter: self, title: "Oops", message: "couldn't block the user.")
                    }
                }
            }
        }
    }
    
    private func remove(comment: Comment)
    {
        if let commentIndex = self.comments.index(of: comment) {
            self.comments.remove(at: commentIndex)
           
            // update comments table view
            let indexPath = IndexPath(row: commentIndex, section: 0)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
            
            // update replies label and post
            self.update(withNumberOfReplies: self.comments.count)
        }
    }
    
    private func update(withNumberOfReplies numberOfReplies: Int?)
    {
        let replyCount = numberOfReplies != nil ? numberOfReplies! : 0
        self.headerView.numReplies = replyCount
        self.post?.commentCount = replyCount
    }
    
    private func showLoading(_ shouldLoad: Bool)
    {
        self.headerView.showLoading(shouldLoad)
        self.tableView.allowsSelection = !shouldLoad
    }
    
    private func update(withPost post: Post)
    {
        self.headerView.post = post
        self.configureHeaderSize()
        self.tableView.layoutIfNeeded()
        
        self.setupMap()
        self.getComments(forPost: post)
    }
    
    private func setupMap()
    {
        // add pin for selected post and show it in the middle of the map
        if let post = post {
            self.mapView.addPin(forPost: post, canShowCallout: false)
            self.mapView.centerCoordinate = CLLocationCoordinate2D(latitude: post.latitude, longitude: post.longitude)
            self.mapView.zoomToHumanLevel()
        }
    }
    
    private func getComments(forPost post: Post)
    {
        self.showLoading(true)
        APIService().getComments(forPost: post) { comments, error in
            
            guard let newComments = comments, error == nil else {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                self.comments = newComments
                
                // update header replies label to be consistent to our dataSource
                self.headerView.numReplies = self.comments.count
                
                // for no comments
                self.tableView.emptyDataSetSource = self
                self.tableView.emptyDataSetDelegate = self
                
                self.showLoading(false)
                self.tableView.reloadData()
            }
        }
    }

    private func configureHeaderSize()
    {
        self.headerView.layoutIfNeeded()
        let height = self.headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        var frame = self.headerView.frame
        frame.size.height = height
        self.headerView.frame = frame
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
