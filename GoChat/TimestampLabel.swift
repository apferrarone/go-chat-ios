//
//  TimestampLabel.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/8/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit

class TimestampLabel: UIView
{
    @IBOutlet var view: TimestampLabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var clockIconImageView: UIImageView!
    private var innerView: UIView!
    
    var date: NSDate?
    private var countingTimer: Timer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let icon = UIImage(named: "ClockIcon")?.withRenderingMode(.alwaysTemplate)
        self.clockIconImageView.image = icon
        self.clockIconImageView.tintColor = .lightGray
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        _ = Bundle.main.loadNibNamed(String(describing: TimestampLabel.self), owner: self, options: nil)?[0] as! UIView
        self.addSubview(self.view)
        self.view.frame = self.bounds
    }
    
    deinit
    {
        self.countingTimer?.invalidate()
    }
    
    func setTimeAgo(date: NSDate?)
    {
        self.label.text = date?.timeAgo()
        self.date = date
        self.updateTime()
    }
    
    fileprivate func updateTime()
    {
        self.countingTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(handleTimeUpdated), userInfo: nil, repeats: true)
    }
    
    internal func handleTimeUpdated()
    {
        self.label.text = self.date?.timeAgo()
    }
}
