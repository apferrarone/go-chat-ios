//
//  InputContainer.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 11/28/18.
//  Copyright © 2018 Andrew Ferrarone. All rights reserved.
//

import UIKit
import UITextView_Placeholder

private let LIGHT_GRAY = UIColor.white.withAlphaComponent(0.15)
private let PINK = UIColor(hex: Constants.ColorHexValues.CRYPTO_PINK)

class InputContainer: UIVisualEffectView, UITextViewDelegate
{
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    var textViewHeightAnchor: NSLayoutConstraint!
    
    var minHeight: CGFloat = 36.0 { didSet { self.updateUI() } }
    var maxHeight: CGFloat = 100.0 { didSet { self.updateUI() } }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.setup()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?)
    {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateUI()
    }
    
// MARK: - Actions
    
    @IBAction func handleAction(_ sender: Any)
    {
        print("Handle Send from Comment Input")
    }
    
// MARK: - UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView)
    {
        self.updateUI()
    }
    
    func updateUI()
    {
        // resize textView
        let size = CGSize(width: textView.frame.width, height: .greatestFiniteMagnitude)
        var estimatedSize = textView.sizeThatFits(size)
        estimatedSize.height = max(min(estimatedSize.height, self.maxHeight), self.minHeight)
        
        self.textView.isScrollEnabled = estimatedSize.height >= self.maxHeight
        self.textViewHeightAnchor.constant = estimatedSize.height
        
        // toggle send button
        self.sendButton.isEnabled = !textView.text.isEmpty
    }
    

// MARK: - Utilities
    
    private func setup()
    {
        defer {
            self.updateUI() // get initial size
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.backgroundColor = UIColor(hex: Constants.ColorHexValues.DARK_GRAY)

        // start us off at min height, hold onto the height,
        // we will be updated after this function returns
        self.textViewHeightAnchor = self.textView.heightAnchor.constraint(equalToConstant: self.minHeight)
        self.textViewHeightAnchor.isActive = true
        
        self.textView.textContainerInset.top = 12.0
        self.textView.textContainerInset.bottom = 12.0
        self.textView.textContainerInset.left = 10.0
        
        self.textView.layer.cornerRadius = 18.0
        self.textView.layer.borderWidth = 1.0
        self.textView.layer.borderColor = LIGHT_GRAY.cgColor
        
        self.textView.isScrollEnabled = false
        self.textView.delegate = self
        self.textView.placeholder = "Add a comment..."
        self.textView.placeholderColor = LIGHT_GRAY
        self.textView.showsVerticalScrollIndicator = false
        
        self.sendButton.setTitleColor(LIGHT_GRAY, for: .disabled)
        self.sendButton.setTitleColor(PINK, for: .normal)
    }
}
