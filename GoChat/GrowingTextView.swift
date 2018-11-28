//
//  GrowingTextView.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/19/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit

@objc protocol GrowingTextViewDelegate: class
{
    @objc optional func textView(_ textView: GrowingTextView, didChangeHeight height: CGFloat)
}

class GrowingTextView: UITextView, UITextViewDelegate
{
//    var placeholderText: String?
//    var minHeight: CGFloat?
//    var maxHeight: CGFloat?
//    
//    weak var growingTextViewDelegate: GrowingTextViewDelegate?
//    
//    private var textViewHeightAnchor: NSLayoutConstraint!
//    
//    private lazy var placeholderLabel: UILabel = { [unowned self] in
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = self.font
//        label.textColor = .lightGray
//        return label
//    }()
//    
//    func textViewDidChange(_ textView: UITextView)
//    {
//        // toggle placeholder:
//        if self.text.isEmpty {
//            self.placeholderLabel.isHidden = false
//        } else {
//            self.placeholderLabel.isHidden = true
//        }
//        
//        // resize textView
//        let size = CGSize(width: textView.frame.width, height: .greatestFiniteMagnitude)
//        var estimatedSize = textView.sizeThatFits(size)
//        
//        if let max = self.maxHeight {
//            estimatedSize.height = min(estimatedSize.height, max)
//            self.isScrollEnabled = estimatedSize.height >= max
//        }
//        
//        self.textViewHeightAnchor.constant = estimatedSize.height
//    }
//    
//    override func layoutSubviews()
//    {
////        super.layoutSubviews()
////
////        var newSize = self.contentSize
////        newSize.width += (self.textContainerInset.left + self.textContainerInset.right) / 2.0
////        newSize.height += (self.textContainerInset.top + self.textContainerInset.bottom) / 2.0
////
////        if let min = self.minHeight {
////            newSize.height = max(newSize.height, min)
////        }
////        if let max = self.maxHeight {
////            newSize.height = min(newSize.height, max)
////        }
////
////        self.textViewHeightAnchor.constant = newSize.height
////        self.growingTextViewDelegate?.textView?(self, didChangeHeight: newSize.height)
////
////        self.scrollToBottom(animated: true)
//    }
//
//// MARK: Initialization
//    
//    private func setup()
//    {
//        var height = CGFloat(36.0) // self.frame.size.height
//        
//        if let maxHeight = self.maxHeight, maxHeight > CGFloat(0.0) {
//            height = min(height, maxHeight)
//        }
//    
//        self.textViewHeightAnchor = self.heightAnchor.constraint(equalToConstant: height)
//        self.textViewHeightAnchor.isActive = true
//        self.isScrollEnabled = false
//        
//        self.delegate = self
//        self.showsVerticalScrollIndicator = false
//        
//        self.textContainerInset.bottom = 8.0
//        self.textContainerInset.top = 8.0
//        
//        if let placeholder = self.placeholderText {
//            self.addSubview(self.placeholderLabel)
//            self.placeholderLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
//            self.placeholderLabel.heightAnchor.constraint(equalToConstant: 26).isActive = true
//            self.placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
//            self.placeholderLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 10).isActive = true
//            self.placeholderLabel.text = placeholder
//            self.placeholderLabel.isHidden = false
//        }
//    }
//    
//    override init(frame: CGRect, textContainer: NSTextContainer?) {
//        super.init(frame: frame, textContainer: textContainer)
//        self.setup()
//    }
//    
//    required init?(coder aDecoder: NSCoder)
//    {
//        super.init(coder: aDecoder)
//    }
//    
//    override func awakeFromNib()
//    {
//        super.awakeFromNib()
//        self.setup()
//    }
}
