//
//  PostDetailHeaderView.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/14/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit

protocol PostDetailHeaderDelegate: class
{
    func showPostOptions()
}

class PostDetailHeaderView: UIView
{
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: TimestampLabel!
    @IBOutlet weak var contentLabel: ContentLabel!
    @IBOutlet weak var repliesLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    weak var delegate: PostDetailHeaderDelegate?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        _ = Bundle.main.loadNibNamed(String(describing: PostDetailHeaderView.self), owner: self, options: nil)?[0] as! UIView
        self.addSubview(self.view)
        self.view.frame = self.bounds
    }
    
    var post: Post? {
        didSet {
            self.usernameLabel.textColor = post?.team.color
            self.usernameLabel.text = self.post?.username
            self.contentLabel.text = self.post?.content
            self.timestampLabel.setTimeAgo(date: self.post?.createdAt)
            
            if let commentCount = self.post?.commentCount {
                self.numReplies = commentCount
            }
        }
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.contentContainerView.drawShadow()
        self.contentContainerView.rasterizeShadow()
    }
    
    func showLoading(_ shouldShow: Bool)
    {
        shouldShow ? self.spinner.startAnimating() : self.spinner.stopAnimating()
        self.repliesLabel.isHidden = shouldShow
    }
    
    // MARK: Actions
    
    @IBAction func showPostOptions(_ sender: UIButton)
    {
        self.delegate?.showPostOptions()
    }
    
    // MARK: Utilities
    
    var numReplies = 0 {
        didSet {
            self.repliesLabel.text = "\(self.numReplies) " + (self.numReplies == 1 ? "reply" : "replies")
        }
    }
}
