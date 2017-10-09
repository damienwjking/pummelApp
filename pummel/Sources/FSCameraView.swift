//
//  FSCameraView.swift
//  Fusuma
//
//  Created by Thong Nguyen on 2015/11/14.
//  Copyright © 2015年 Thong Nguyen. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
import Photos

@objc protocol FSCameraViewDelegate: class {
    func cameraShotFinished(image: UIImage)
}

final class FSCameraView: UIView, UIGestureRecognizerDelegate {

    @IBOutlet weak var previewViewContainer: UIView!
    @IBOutlet weak var shotButton: UIButton!
    var flashButton: UIButton!
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var bigShotIMV: UIImageView!
    @IBOutlet weak var smallShotIMV: UIImageView!
    var cameraRollButton: UIButton!
    @IBOutlet weak var goLibrary: UIButton!
    weak var delegate: FSCameraViewDelegate? = nil
    
    var session: AVCaptureSession?
    var device: AVCaptureDevice?
    var videoInput: AVCaptureDeviceInput?
    var imageOutput: AVCaptureStillImageOutput?
    var focusView: UIView?

    static func instance() -> FSCameraView {
        
        return UINib(nibName: "FSCameraView", bundle: nil).instantiate(withOwner: self, options: nil).first as! FSCameraView
    }
    
    func initialize() {
        
        if session != nil {
            
            return
        }
        
        self.backgroundColor = fusumaBackgroundColor
        
        self.isHidden = false
        
        // AVCapture
        session = AVCaptureSession()
        
        for device in AVCaptureDevice.devices() {
            
            if let device = device as? AVCaptureDevice, device.position == AVCaptureDevicePosition.back {
                
                self.device = device
                
                if !device.hasFlash {
                    
                    flashButton.isHidden = true
                }
            }
        }
        
        do {

            if let session = session {

                videoInput = try AVCaptureDeviceInput(device: device)

                session.addInput(videoInput)
                
                imageOutput = AVCaptureStillImageOutput()
                
                session.addOutput(imageOutput)
                
                let videoLayer = AVCaptureVideoPreviewLayer(session: session)
                videoLayer?.frame = self.previewViewContainer.bounds
                videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                
                self.previewViewContainer.layer.addSublayer(videoLayer!)
                
                session.startRunning()
                
            }
            
            // Focus View
            self.focusView         = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
            let tapRecognizer      = UITapGestureRecognizer(target: self, action:#selector(FSCameraView.focus(_:)))
            tapRecognizer.delegate = self
            self.previewViewContainer.addGestureRecognizer(tapRecognizer)
            
        } catch {
            
            print(error)
        }
        
		//flashButton.tintColor = fusumaBaseTintColor
        flipButton.tintColor  = fusumaBaseWhiteTintColor
        //shotButton.tintColor  = fusumaBaseTintColor
        
        //let bundle = NSBundle(forClass: self.classForCoder)
        
        //let flashImage = UIImage(named: "ic_flash_off", inBundle: bundle, compatibleWithTraitCollection: nil)
        //let flipImage = UIImage(named: "rotateCamera")
        //let shotImage = UIImage(named: "ic_radio_button_checked", inBundle: bundle, compatibleWithTraitCollection: nil)

        //flashButton.setImage(flashImage?.withRenderingMode(.alwaysTemplate), for: .normal)
       //flipButton.setImage(flipImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        goLibrary.layer.cornerRadius = 3
        self.pickingTheLastImageFromThePhotoLibrary()
        bigShotIMV.layer.cornerRadius = 36
        bigShotIMV.clipsToBounds = true
        smallShotIMV.layer.cornerRadius = 24
        smallShotIMV.clipsToBounds = true
       // flashConfiguration()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.willEnterForegroundNotification(notification:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func willEnterForegroundNotification(notification: NSNotification) {
        
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if status == AVAuthorizationStatus.authorized {

            session?.startRunning()
            
        } else if status == AVAuthorizationStatus.denied || status == AVAuthorizationStatus.restricted {

            session?.stopRunning()
        }
    }
    
    func pickingTheLastImageFromThePhotoLibrary() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        
        if let lastAsset: PHAsset = fetchResult.lastObject as? PHAsset {
            let manager = PHImageManager.default()
            let imageRequestOptions = PHImageRequestOptions()
            
            manager.requestImageDataForAsset(lastAsset, options: imageRequestOptions) {
                ( imageData: NSData?, dataUTI: String?,
                orientation: UIImageOrientation,
                info: [NSObject : AnyObject]?) -> Void in
                
                if let imageDataUnwrapped = imageData, let lastImageRetrieved = UIImage(data: imageDataUnwrapped) {
                    // do stuff with image
                        self.goLibrary.setBackgroundImage(lastImageRetrieved, for: .normal) 
                }
            }
        }
    }
    
    @IBAction func shotButtonPressed(sender: UIButton) {
        
        guard let imageOutput = imageOutput else {
            
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let videoConnection = imageOutput.connection(withMediaType: AVMediaTypeVideo)
            
            imageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (buffer, error) -> Void in
                
                self.session?.stopRunning()
                
                let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                
                if let image = UIImage(data: data!), let delegate = self.delegate {
                    
                    // Image size
                    let iw = image.size.width
                    let ih = image.size.height
                    
                    // Frame size
                    let sw = self.previewViewContainer.frame.width
                    
                    // The center coordinate along Y axis
                    let rcy = ih*0.5
                    
                    let imageRef = image.cgImage!.cropping(to: CGRect(x: rcy-iw*0.5, y: 0 , width: iw, height: iw))
                    
                    let resizedImage = UIImage(cgImage: imageRef!, scale: sw/iw, orientation: image.imageOrientation)
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        delegate.cameraShotFinished(image: resizedImage)
                        
                        self.session     = nil
                        self.device      = nil
                        self.imageOutput = nil
                        
                    })
                }
                
            })
        }
    }
    
    @IBAction func flipButtonPressed(sender: UIButton) {

        if !cameraIsAvailable() {

            return
        }
        
        session?.stopRunning()
        
        do {

            session?.beginConfiguration()

            if let session = session {
                
                for input in session.inputs {
                    
                    session.removeInput(input as! AVCaptureInput)
                }

                let position = (videoInput?.device.position == AVCaptureDevicePosition.front) ? AVCaptureDevicePosition.back : AVCaptureDevicePosition.front

                for device in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) {

                    if let device = device as? AVCaptureDevice, device.position == position {
                 
                        videoInput = try AVCaptureDeviceInput(device: device)
                        session.addInput(videoInput)
                        
                    }
                }

            }
            
            session?.commitConfiguration()

            
        } catch {
            
        }
        
        session?.startRunning()
    }
    
    @IBAction func flashButtonPressed(sender: UIButton) {

        if !cameraIsAvailable() {

            return
        }

        do {

            if let device = device {
                
                guard device.hasFlash else { return }
            
                try device.lockForConfiguration()
                
                let mode = device.flashMode
                
                if mode == AVCaptureFlashMode.off {
                    
                    device.flashMode = AVCaptureFlashMode.on
                    flashButton.setImage(UIImage(named: "ic_flash_on")?.withRenderingMode(.alwaysTemplate), for: .normal)
                    
                } else if mode == AVCaptureFlashMode.on {
                    
                    device.flashMode = AVCaptureFlashMode.off
                    flashButton.setImage(UIImage(named: "ic_flash_off")?.withRenderingMode(.alwaysTemplate), for: .normal)
                }
                
                device.unlockForConfiguration()

            }

        } catch _ {

            flashButton.setImage(UIImage(named: "ic_flash_off")?.withRenderingMode(.alwaysTemplate), for: .normal)
            return
        }

    }
}


private extension FSCameraView {
    
    @objc func focus(recognizer: UITapGestureRecognizer) {
        
        let point = recognizer.location(in: self)
        let viewsize = self.bounds.size
        let newPoint = CGPoint(x: point.y/viewsize.height, y: 1.0-point.x/viewsize.width)
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            
            try device?.lockForConfiguration()
            
        } catch _ {
            
            return
        }
        
        if device?.isFocusModeSupported(AVCaptureFocusMode.autoFocus) == true {

            device?.focusMode = AVCaptureFocusMode.autoFocus
            device?.focusPointOfInterest = newPoint
        }

        if device?.isExposureModeSupported(AVCaptureExposureMode.continuousAutoExposure) == true {
            
            device?.exposureMode = AVCaptureExposureMode.continuousAutoExposure
            device?.exposurePointOfInterest = newPoint
        }
        
        device?.unlockForConfiguration()
        
        self.focusView?.alpha = 0.0
        self.focusView?.center = point
        self.focusView?.backgroundColor = UIColor.clear
        self.focusView?.layer.borderColor = fusumaBaseTintColor.cgColor
        self.focusView?.layer.borderWidth = 1.0
        self.focusView!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.addSubview(self.focusView!)
        
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.8,
            initialSpringVelocity: 3.0, options: UIViewAnimationOptions.curveEaseIn, // UIViewAnimationOptions.BeginFromCurrentState
            animations: {
                self.focusView!.alpha = 1.0
                self.focusView!.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            }, completion: {(finished) in
                self.focusView!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.focusView!.removeFromSuperview()
        })
    }
    
    func flashConfiguration() {
    
        do {
            
            if let device = device {
                
                guard device.hasFlash else { return }
                
                try device.lockForConfiguration()
                
                device.flashMode = AVCaptureFlashMode.off
                flashButton.setImage(UIImage(named: "ic_flash_off")?.withRenderingMode(.alwaysTemplate), for: .normal)
                
                device.unlockForConfiguration()
                
            }
            
        } catch _ {
            
            return
        }
    }

    func cameraIsAvailable() -> Bool {

        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)

        if status == AVAuthorizationStatus.authorized {

            return true
        }

        return false
    }
}
