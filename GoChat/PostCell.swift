//
//  PostCell.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/8/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell
{
    @IBOutlet weak var blurContainerView: UIVisualEffectView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var repliesContainerView: UIView!
    @IBOutlet weak var repliesLabel: UILabel!
    @IBOutlet weak var replyIndicatorLabel: UILabel!
    
    // track the original width for hide/show of replies
    fileprivate var repliesContainerDefaultWidth = CGFloat(63.0)
    @IBOutlet weak var repliesContainerWidth: NSLayoutConstraint! {
        didSet {
            self.repliesContainerDefaultWidth = repliesContainerWidth.constant
        }
    }
    
    @IBOutlet weak var timestampLabel: TimestampLabel!
    
    var post: Post? {
        didSet {
            self.contentLabel.text = post?.content
            self.usernameLabel.text = post?.username
            self.timestampLabel.setTimeAgo(date: post?.createdAt)
            
            if let post = self.post {
                
                if post.commentCount > 0 {
                    self.hideRepliesContainer(false)
                    self.repliesLabel.text = String(post.commentCount)
                    self.replyIndicatorLabel.text = post.commentCount == 1 ? "reply" : "replies"
                } else {
                    self.hideRepliesContainer(true)
                }
                
            } else {
                self.hideRepliesContainer(true)
            }
        }
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.blurContainerView.roundCorners()
        self.containerView.roundCorners()
    }
        
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        selected ? self.touchDown() : self.touchUp()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool)
    {
        super.setHighlighted(highlighted, animated: animated)
        highlighted ? self.touchDown() : self.touchUp()
    }

// MARK: - Utilities
    
    func hideRepliesContainer(_ shouldHide: Bool)
    {
        self.repliesContainerWidth.constant = shouldHide ? 0.0 : self.repliesContainerDefaultWidth
        self.layoutIfNeeded()
    }
    
}
