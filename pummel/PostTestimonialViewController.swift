//
//  PostTestimonialViewController.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 9/18/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

class PostTestimonialViewController: UIViewController {
    @IBOutlet weak var backgroundImageView: UIImageView!

    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    
    @IBOutlet weak var currentUserAvatarImageView: UIImageView!
    @IBOutlet weak var currentUserNameLabel: UILabel!
    
    @IBOutlet weak var currentUserPlaceLabel: UILabel!
    
    @IBOutlet weak var ratingStarView: UIView!
    
    @IBOutlet weak var totalCharacterView: UIView!
    @IBOutlet weak var totalCharacterLabel: UILabel!
    @IBOutlet weak var overCharacterLabel: UILabel!
    @IBOutlet weak var testimonialPlaceHolder: UILabel!
    @IBOutlet weak var testimonialTextView: UITextView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    var userID = ""
    var backgroundImage : UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        
        let longPressGusture = UILongPressGestureRecognizer(target: self, action: #selector(self.ratingStarViewLongPress(_:)))
        longPressGusture.minimumPressDuration = 0.01
        self.ratingStarView.addGestureRecognizer(longPressGusture)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.backgroundImageView.image = self.backgroundImage
    }

    func setupUI() {
        self.backgroundImageView.addBlurEffect()
        
        let cancelImage = UIImage(named: "close")?.imageWithRenderingMode(.AlwaysTemplate)
        self.cancelButton.tintColor = UIColor.whiteColor()
        self.cancelButton.setImage(cancelImage, forState: .Normal)
        
        self.userAvatarImageView.layer.cornerRadius = self.userAvatarImageView.frame.size.width/2
        self.userAvatarImageView.layer.masksToBounds = true
        self.userAvatarImageView.layer.borderWidth = 1
        self.userAvatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.contentView.layer.cornerRadius = 5
        self.contentView.layer.masksToBounds = true
        
        self.currentUserAvatarImageView.layer.cornerRadius = self.currentUserAvatarImageView.frame.size.width/2
        self.currentUserAvatarImageView.layer.masksToBounds = true
        
        self.totalCharacterView.layer.cornerRadius = 2
        self.totalCharacterView.layer.masksToBounds = true
        self.totalCharacterView.backgroundColor = UIColor.pmmWarmGreyColor()
        self.overCharacterLabel.hidden = true
        self.overCharacterLabel.textColor = UIColor.pmmRougeColor()
        
        self.submitButton.layer.cornerRadius = 2
        self.submitButton.layer.masksToBounds = true
    }
    
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func ratingStarViewLongPress(gesture: UILongPressGestureRecognizer) {
        print(gesture.state)
    }
}

// MARK: - UITextViewDelegate
extension PostTestimonialViewController : UITextViewDelegate {
    func textViewDidChange(textView: UITextView) {
        let textViewText = NSString(string: textView.text)
        
        self.totalCharacterLabel.text = String(format: "%ld", textViewText.length)
        
        if (textViewText.length == 0) {
            self.testimonialPlaceHolder.hidden = false
        } else {
            self.testimonialPlaceHolder.hidden = true
        }
        
        if (textViewText.length >= 300) {
            textView.scrollEnabled = true
            
            self.overCharacterLabel.hidden = false
            
            self.totalCharacterView.backgroundColor = UIColor.pmmRougeColor()
            
            self.submitButton.userInteractionEnabled = false
        } else {
            textView.scrollEnabled = false
            
            self.overCharacterLabel.hidden = true
            
            self.totalCharacterView.backgroundColor = UIColor.pmmWarmGreyColor()
            
            self.submitButton.userInteractionEnabled = true
        }
    }
    
}
