//
//  FusumaViewController.swift
//  Fusuma
//
//  Created by Thong Nguyen on 2015/11/14.
//  Copyright © 2015年 Thong Nguyen. All rights reserved.
//

import UIKit

@objc public protocol FusumaDelegate: class {
    
    func fusumaImageSelected(image: UIImage)
    func fusumaCameraRollUnauthorized()
    
    optional func fusumaClosed()
    optional func fusumaDismissedWithImage(image: UIImage)
}

public var fusumaBaseTintColor       = UIColor.hex("#000000", alpha: 1.0)
public var fusumaBaseWhiteTintColor       = UIColor.hex("#FFFFFF", alpha: 1.0)
public var fusumaTintColor       = UIColor.hex("#FFFFFF", alpha: 1.0)
public var fusumaBackgroundColor = UIColor.hex("#000000", alpha: 1.0)
public var fusumaBackgroundBlackColor = UIColor.hex("#000000", alpha: 1.0)

public func changeMode() {}

public enum FusumaMode {
    case Camera
    case Library
}

public enum FusumaModeOrder {
    case CameraFirst
    case LibraryFirst
}

@objc public class FusumaViewController: UIViewController, FSCameraViewDelegate, FSAlbumViewDelegate {

    private var mode: FusumaMode?
    public var defaultMode: FusumaMode?
    public var modeOrder: FusumaModeOrder = .LibraryFirst
    public var willFilter = true

    @IBOutlet weak var photoLibraryViewerContainer: UIView!
    @IBOutlet weak var cameraShotContainer: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!

    @IBOutlet var libraryFirstConstraints: [NSLayoutConstraint]!
    @IBOutlet var cameraFirstConstraints: [NSLayoutConstraint]!
    @IBOutlet var menuHeighConstraint: NSLayoutConstraint!
    
    var albumView  = FSAlbumView.instance()
    var cameraView = FSCameraView.instance()
    
    public weak var delegate: FusumaDelegate? = nil
    
    override public func loadView() {
        
        if let view = UINib(nibName: "FusumaViewController", bundle: NSBundle(forClass: self.classForCoder)).instantiateWithOwner(self, options: nil).first as? UIView {
            
            self.view = view
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
       
        
        cameraView.delegate = self
        albumView.delegate  = self
        titleLabel.font = UIFont(name: "Montserrat-Regular", size: 13)
        doneButton.titleLabel?.font = UIFont(name: "Montserrat-Light", size: 13)!

        menuView.backgroundColor = fusumaBackgroundColor
        menuView.layer.shadowColor = UIColor.blackColor().CGColor;
        menuView.layer.shadowOffset = CGSizeMake(0.0, 3);
        menuView.layer.shadowOpacity = 0.25;
        
		libraryButton.tintColor = fusumaTintColor
		
        cameraButton.adjustsImageWhenHighlighted  = false
        libraryButton.adjustsImageWhenHighlighted = false
        cameraButton.clipsToBounds  = true
        libraryButton.clipsToBounds = true

        changeMode(defaultMode ?? FusumaMode.Library)
        photoLibraryViewerContainer.addSubview(albumView)
        cameraShotContainer.addSubview(cameraView)
        
        doneButton.tintColor = fusumaBaseTintColor

		titleLabel.textColor = fusumaBaseTintColor
		
        if modeOrder != .LibraryFirst {
            libraryFirstConstraints.forEach { $0.priority = 250 }
            cameraFirstConstraints.forEach { $0.priority = 1000 }
        }
        
        if modeOrder == .CameraFirst {
            self.menuHeighConstraint.constant = 44
            self.menuView.backgroundColor = UIColor.blackColor()
        } else {
            self.menuHeighConstraint.constant = 70
            self.menuView.backgroundColor = UIColor.whiteColor()
        }
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
         self.view.backgroundColor = fusumaBackgroundColor
       
        
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        albumView.frame  = CGRect(origin: CGPointZero, size: photoLibraryViewerContainer.frame.size)
        albumView.layoutIfNeeded()
        cameraView.frame = CGRect(origin: CGPointZero, size: cameraShotContainer.frame.size)
        cameraView.layoutIfNeeded()
        
        albumView.initialize()
        cameraView.initialize()
        cameraView.goLibrary.addTarget(self, action:#selector(FusumaViewController.libraryButtonPressed(_:)), forControlEvents:UIControlEvents.TouchUpInside)
    }

    override public func prefersStatusBarHidden() -> Bool {
            return false

    }
    
    @IBAction func closeButtonPressed(sender: UIButton) {

        self.dismissViewControllerAnimated(true, completion: {
            
            self.delegate?.fusumaClosed?()
        })
    }
    
    @IBAction func libraryButtonPressed(sender: UIButton) {
        
        changeMode(FusumaMode.Library)
    }
    
    @IBAction func photoButtonPressed(sender: UIButton) {
    
        changeMode(FusumaMode.Camera)
    }
    
    @IBAction func doneButtonPressed(sender: UIButton) {
        
        let image = albumView.imageSelected as UIImage
        delegate?.fusumaImageSelected(image)
        self.dismissViewControllerAnimated(true, completion: {
            
            self.delegate?.fusumaDismissedWithImage?(image)
        })
    }
    
    // MARK: FSCameraViewDelegate
    func cameraShotFinished(image: UIImage) {
        
        delegate?.fusumaImageSelected(image)
        self.dismissViewControllerAnimated(true, completion: {
        
            self.delegate?.fusumaDismissedWithImage?(image)
        })
    }
    
    // MARK: FSAlbumViewDelegate
    public func albumViewCameraRollUnauthorized() {
        
        delegate?.fusumaCameraRollUnauthorized()
    }
}

private extension FusumaViewController {
    
    func changeMode(mode: FusumaMode) {

        if self.mode == mode {
            
            return
        }
        
        self.mode = mode
        
        dishighlightButtons()
        
        if mode == FusumaMode.Library {
            titleLabel.text = NSLocalizedString("CAMERA ROLL", comment: "CAMERA ROLL")
            titleLabel.font = UIFont(name: "Montserrat-Regular", size: 13)
            doneButton.hidden = false
            doneButton.titleLabel?.font = UIFont(name: "Montserrat-Light", size: 13)!
            self.menuHeighConstraint.constant = 70
            self.menuView.backgroundColor = UIColor.whiteColor()
            titleLabel.hidden = false
            closeButton.hidden = true
            highlightButton(libraryButton)
            self.view.insertSubview(photoLibraryViewerContainer, aboveSubview: cameraShotContainer)
            
        } else {
            doneButton.hidden = true
            titleLabel.hidden = true
            self.menuView.backgroundColor = UIColor.blackColor()
            highlightButton(cameraButton)
            self.view.insertSubview(cameraShotContainer, aboveSubview: photoLibraryViewerContainer)
        }
    }
    
    
    func dishighlightButtons() {
        
        cameraButton.tintColor  = fusumaBaseTintColor
        libraryButton.tintColor = fusumaBaseTintColor
        
        if cameraButton.layer.sublayers?.count > 1 {
            
            for layer in cameraButton.layer.sublayers! {
                
                if let borderColor = layer.borderColor where UIColor(CGColor: borderColor) == fusumaTintColor {
                    
                    layer.removeFromSuperlayer()
                }
                
            }
        }
        
        if libraryButton.layer.sublayers?.count > 1 {
            
            for layer in libraryButton.layer.sublayers! {
                
                if let borderColor = layer.borderColor where UIColor(CGColor: borderColor) == fusumaTintColor {
                    
                    layer.removeFromSuperlayer()
                }
                
            }
        }
        
    }
    
    func highlightButton(button: UIButton) {
        
        button.tintColor = fusumaTintColor
        
        button.addBottomBorder(fusumaTintColor, width: 3)
    }
}
