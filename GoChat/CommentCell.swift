//
//  CommentCell.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/13/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var usernameLabel: UsernameLabel!
    @IBOutlet weak var contentLabel: ContentLabel!
    @IBOutlet weak var timestampLabel: TimestampLabel!
    
    var comment: Comment? {
        didSet {
            self.usernameLabel.text = comment?.username
            self.contentLabel.text = comment?.content
            self.timestampLabel.setTimeAgo(date: comment?.createdAt)
        }
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.containerView.roundCorners()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool)
    {
        super.setHighlighted(highlighted, animated: animated)
        highlighted ? self.touchDown() : self.touchUp()
    }
}
