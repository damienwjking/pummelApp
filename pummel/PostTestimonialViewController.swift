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
    @IBOutlet weak var currentLocationTextField: UITextField!
    
    @IBOutlet weak var ratingStarView: UIView!
    @IBOutlet weak var ratingStarViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var totalCharacterView: UIView!
    @IBOutlet weak var totalCharacterLabel: UILabel!
    @IBOutlet weak var overCharacterLabel: UILabel!
    @IBOutlet weak var testimonialPlaceHolder: UILabel!
    @IBOutlet weak var testimonialTextView: UITextView!
    @IBOutlet weak var templateKeyboardViewHeightContraint: NSLayoutConstraint!
    
    @IBOutlet weak var submitButton: UIButton!
    
    var userID = ""
    var backgroundImage : UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.ratingTapped(_:)))
        self.ratingStarView.addGestureRecognizer(tapGesture)
        
        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.backgroundTapGesture(_:)))
        self.backgroundImageView.addGestureRecognizer(backgroundTapGesture)
        
        let contentViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.contentViewTapGesture(_:)))
        self.contentView.addGestureRecognizer(contentViewTapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.backgroundImageView.image = self.backgroundImage
        
        self.setupUserInfo()
        self.setupCurrentInfo()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) {
            self.templateKeyboardViewHeightContraint.constant = keyboardSize.height
            
            self.scrollView.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.templateKeyboardViewHeightContraint.constant = 0
        
        self.scrollView.layoutIfNeeded()
    }
    
    func setupUserInfo() {
        UserRouter.getUserInfo(userID: self.userID) { (result, error) in
            if (error == nil) {
                let userInfo = result as! NSDictionary

                let firstName = userInfo[kFirstname] as! String
                self.userNameLabel.text = firstName
                
                let imageURL = userInfo[kImageUrl] as? String
                if (imageURL != nil) {
                    ImageRouter.getImage(imageURLString: imageURL!, sizeString: widthHeight160, completed: { (result, error) in
                        if (error == nil) {
                            let image = result as! UIImage
                            
                            self.userAvatarImageView.image = image
                        } else {
                            print("Request failed with error: \(String(describing: error))")
                        }
                    }).fetchdata()
                }
                
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
            }.fetchdata()
    }
    
    func setupCurrentInfo() {
        UserRouter.getCurrentUserInfo { (result, error) in
            if (error == nil) {
                let userInfo = result as! NSDictionary
                
                let firstName = userInfo[kFirstname] as! String
                self.currentUserNameLabel.text = firstName
                
                let imageURL = userInfo[kImageUrl] as? String
                if (imageURL != nil) {
                    ImageRouter.getImage(imageURLString: imageURL!, sizeString: widthHeight160, completed: { (result, error) in
                        if (error == nil) {
                            let image = result as! UIImage
                            
                            self.currentUserAvatarImageView.image = image
                        } else {
                            print("Request failed with error: \(String(describing: error))")
                        }
                    }).fetchdata()
                }
                
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
            }.fetchdata()
    }

    func setupUI() {
        self.backgroundImageView.addBlurEffect(0.5)
        
        let cancelImage = UIImage(named: "close")?.withRenderingMode(.alwaysTemplate)
        self.cancelButton.tintColor = UIColor.white
        self.cancelButton.setImage(cancelImage, for: .normal)
        
        self.userAvatarImageView.layer.cornerRadius = self.userAvatarImageView.frame.size.width/2
        self.userAvatarImageView.layer.masksToBounds = true
        self.userAvatarImageView.layer.borderWidth = 1
        self.userAvatarImageView.layer.borderColor = UIColor.white.cgColor
        
        self.contentView.layer.cornerRadius = 5
        self.contentView.layer.masksToBounds = true
        
        self.currentUserAvatarImageView.layer.cornerRadius = self.currentUserAvatarImageView.frame.size.width/2
        self.currentUserAvatarImageView.layer.masksToBounds = true
        
        self.totalCharacterView.layer.cornerRadius = 2
        self.totalCharacterView.layer.masksToBounds = true
        self.totalCharacterView.backgroundColor = UIColor.pmmWarmGreyColor()
        self.overCharacterLabel.isHidden = true
        self.overCharacterLabel.textColor = UIColor.pmmRougeColor()
        
        self.submitButton.layer.cornerRadius = 2
        self.submitButton.layer.masksToBounds = true
    }
    
    @IBAction func submitButtonClicked(sender: AnyObject) {
        let location = self.currentLocationTextField.text
        let description = self.testimonialTextView.text
        let rating = (self.ratingStarViewWidthConstraint.constant / 100.0) * 5.0
        
        UserRouter.postTestimonial(userID: self.userID, description: description, location: location!, rating: rating) { (result, error) in
            if (error == nil) {
                self.dismissViewControllerAnimated(animated: true, completion: nil)
            } else {
                PMHelper.showDoAgainAlert()
            }
        }.fetchdata()
    }
    
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(animated: true, completion: nil)
    }
    
    func ratingTapped(gesture: UITapGestureRecognizer) {
        var touchLocation = gesture.locationInView(self.ratingStarView).x - 15
        touchLocation = (touchLocation > 100) ? 100 : touchLocation
        touchLocation = (touchLocation < 0) ? 0 : touchLocation
        
        self.ratingStarViewWidthConstraint.constant = touchLocation
        
        UIView.animate(withDuration: 0.3) {
            self.contentView.layoutIfNeeded()
        }
    }
    
    func backgroundTapGesture(gesture: UITapGestureRecognizer) {
        self.currentLocationTextField.resignFirstResponder()
        self.testimonialTextView.resignFirstResponder()
    }
    
    func contentViewTapGesture(gesture: UITapGestureRecognizer) {
        self.currentLocationTextField.resignFirstResponder()
        self.testimonialTextView.resignFirstResponder()
    }
}

// MARK: - UITextViewDelegate, UITextFieldDelegate
extension PostTestimonialViewController : UITextViewDelegate, UITextFieldDelegate {
    func textViewDidChange(textView: UITextView) {
        let textViewText = NSString(string: textView.text)
        
        self.totalCharacterLabel.text = String(format: "%ld", textViewText.length)
        
        if (textViewText.length == 0) {
            self.testimonialPlaceHolder.isHidden = false
        } else {
            self.testimonialPlaceHolder.isHidden = true
        }
        
        if (textViewText.length >= 300) {
            textView.isScrollEnabled = true
            
            self.overCharacterLabel.isHidden = false
            
            self.totalCharacterView.backgroundColor = UIColor.pmmRougeColor()
        } else {
            textView.isScrollEnabled = false
            
            self.overCharacterLabel.isHidden = true
            
            self.totalCharacterView.backgroundColor = UIColor.pmmWarmGreyColor()
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        let newYOffset = self.scrollView.contentSize.height - self.scrollView.frame.size.height
        
        let offsetPoint = CGPoint(x: 0, y: newYOffset)
        
        self.scrollView.setContentOffset(offsetPoint, animated: true)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        let offsetPoint = CGPoint(x: 0, y: 0)
        
        self.scrollView.setContentOffset(offsetPoint, animated: true)
    }
}
