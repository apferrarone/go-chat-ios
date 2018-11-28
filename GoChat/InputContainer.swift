//
//  InputContainer.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 11/28/18.
//  Copyright © 2018 Andrew Ferrarone. All rights reserved.
//

import UIKit
import UITextView_Placeholder

private let LIGHT_GRAY = UIColor.white.withAlphaComponent(0.2)
private let DARK_GRAY = UIColor(hex: Constants.ColorHexValues.DARK_GRAY)
private let PINK = UIColor(hex: Constants.ColorHexValues.CRYPTO_PINK)
private let INSETS_TEXTVIEW = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)

protocol InputContainerDelegate: class
{
    func inputContainer(_ inputContainer: InputContainer, didChangeText text: String?)
    func inputContainer(_ inputContainer: InputContainer, didCommitAction text: String?)
}

class InputContainer: UIVisualEffectView, UITextViewDelegate
{
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    var textViewHeightAnchor: NSLayoutConstraint!
    
    var minHeight: CGFloat = 36.0 { didSet { self.updateUI() } }
    var maxHeight: CGFloat = 100.0 { didSet { self.updateUI() } }
    
    weak var delegate: InputContainerDelegate?
    
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
    
    func resetText()
    {
        self.textView.text = nil
        self.updateUI()
    }
    
// MARK: - Actions
    
    @IBAction func handleAction(_ sender: Any)
    {
        print("Handle Send from Comment Input")
        self.delegate?.inputContainer(self, didCommitAction: self.textView.text)
    }
    
// MARK: - UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView)
    {
        self.updateUI()
        self.delegate?.inputContainer(self, didChangeText: textView.text)
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
        // get initial size
        defer { self.updateUI() }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.textView.keyboardAppearance = .dark
        
        self.contentView.backgroundColor = DARK_GRAY

        // start us off at min height, hold onto the height,
        // we will be updated after this function returns
        self.textViewHeightAnchor = self.textView.heightAnchor.constraint(equalToConstant: self.minHeight)
        self.textViewHeightAnchor.isActive = true
        
        self.textView.textContainerInset = INSETS_TEXTVIEW
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
