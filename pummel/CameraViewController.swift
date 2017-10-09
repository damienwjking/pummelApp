//
//  CameraViewController.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 6/19/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import PhotosUI
import Alamofire

enum RecordStatus: Int {
    case pending, recording, finish, uploading
}

class CameraViewController: UIViewController {
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cameraBorderView: UIView!
    @IBOutlet weak var playVideoButton: UIButton!
    @IBOutlet weak var cameraIndicatorView: UIActivityIndicatorView!

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var changeCameraButton: UIButton!
    
    @IBOutlet weak var playBorderBigView: UIView!
    @IBOutlet weak var playBorderSmallView: UIView!
    @IBOutlet weak var playButtonIndicatorView: UIActivityIndicatorView!
    
    var videoPlayer: AVPlayer? = nil
    var videoPlayerLayer: AVPlayerLayer? = nil
    var isRecordByCamera = false
    
    var pickerController: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.movie"]
        
        return imagePicker
    }()
    
    var needRemoveKVO = false
    
    var videoURL:NSURL? = nil
    
    var isVideoPlaying = false
    
    var recordStatus: RecordStatus = .pending {
        didSet {
            // Hidden indicator
            self.playButtonIndicatorView.isHidden = true
            self.cameraIndicatorView.isHidden = true
            self.playVideoButton.isHidden = true
            self.changeCameraButton.isHidden = true
            
            self.cameraBorderView.backgroundColor = UIColor.clear
            
            UIView.animate(withDuration: 0.3) { 
                // Setup play button image
                if (self.recordStatus == .pending) {
                    self.playButton.setImage(nil, for: .normal)
                    self.changeCameraButton.isHidden = false
                } else if (self.recordStatus == .recording) {
                    let pauseImage = UIImage(named: "icon_pause")?.withRenderingMode(.alwaysTemplate)
                    self.playButton.setImage(pauseImage, for: .normal)
                } else if (self.recordStatus == .finish) {
                    let uploadImage = UIImage(named: "icon_upload")?.withRenderingMode(.alwaysTemplate)
                    self.playButton.setImage(uploadImage, for: .normal)
                    
                    self.cameraIndicatorView.isHidden = false
                    self.playVideoButton.isHidden = false
                    
                    self.cameraBorderView.backgroundColor = UIColor.black
                } else if (self.recordStatus == .uploading) {
                    self.playButton.setImage(nil, for: .normal)
                    
                    // Show indicator for uploading
                    self.playButtonIndicatorView.isHidden = false
                }
                
                // Retake button
                if (self.retakeButton != nil) {
                    self.retakeButton.isHidden = true
                    
                    if (self.recordStatus == .finish) {
                        self.retakeButton.isHidden = false
                    }
                }
            }
        }
    }
    
    var cameraSession: AVCaptureSession = {
        let s = AVCaptureSession()
        s.sessionPreset = AVCaptureSessionPresetHigh
        return s
    }()
    
    var cameraOutput: AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview =  AVCaptureVideoPreviewLayer(session: self.cameraSession)
        preview?.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        preview?.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        preview?.videoGravity = AVLayerVideoGravityResize
        return preview!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBasicLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (self.videoURL == nil) {
            self.isRecordByCamera = true
            
            self.recordStatus = .pending
            
            let permission = self.checkPermissionDeviceInput()
            
            if (permission == true) {
                self.setupCameraSession(cameraPosition: .back)
            } else {
                self.showSettingAlert()
            }
            
            
            self.cameraView.layer.addSublayer(previewLayer)
            cameraSession.startRunning()
        } else {
            self.isRecordByCamera = false
            // Stop camera and show video from video URL
            cameraSession.stopRunning()
            
            self.showVideoLayout()
            
            // Change record status
            self.recordStatus = .finish
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (self.needRemoveKVO) {
            self.videoPlayer?.currentItem?.removeObserver(self, forKeyPath: "status")
            self.needRemoveKVO = false
        }
    }
    
    func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutableRawPointer) {
        let currentItem = object as! AVPlayerItem
        if currentItem.status == .readyToPlay {
            let videoRect = self.videoPlayerLayer?.videoRect
            if (Int((videoRect?.width)!) > Int((videoRect?.height)!)) {
                self.videoPlayerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            } else {
                self.videoPlayerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            }
            
            self.playButton.isUserInteractionEnabled = true
            
            if (self.needRemoveKVO) {
                self.videoPlayer?.currentItem?.removeObserver(self, forKeyPath: "status")
                self.needRemoveKVO = false
            }
        }
    }

    
    //MARK: - Private function
    func showVideoLayout() {
        // Show Video URL in border view
        self.videoPlayer = AVPlayer(url: self.videoURL! as URL)
        self.videoPlayer!.actionAtItemEnd = .none
        self.videoPlayerLayer = AVPlayerLayer(player: self.videoPlayer)
        self.videoPlayerLayer!.frame = self.cameraBorderView.bounds
        
        self.cameraBorderView.layer.addSublayer(self.videoPlayerLayer!)
        
        // Catch size of video and crop
        self.videoPlayer!.currentItem!.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
        self.needRemoveKVO = true
        
        // Catch end video
        // Remove loop play video for
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        // Add notification for loop play video
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(self.endVideoNotification),
                                                         name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                         object: self.videoPlayer!.currentItem)
    }
    
    func endVideoNotification(notification: NSNotification) {
        let playerItem = notification.object as! AVPlayerItem
        
        // Show first frame video
        playerItem.seek(to: kCMTimeZero)
        
        self.videoPlayerSetPlay(isPlay: false)
    }
    
    func setupBasicLayout() {
        // Border camera view
//        self.cameraBorderView.layer.borderColor = UIColor.white.cgColor
//        self.cameraBorderView.layer.borderWidth = 1.0
        
        // Close button
        let closeImage = UIImage(named: "close")?.withRenderingMode(.alwaysTemplate)
        self.closeButton.setImage(closeImage, for: .normal)
        self.closeButton.tintColor = UIColor.white
        
        // Retake button
        
        
        // Play button
        self.playButton.tintColor = UIColor.white
        self.recordStatus = .pending
        
        self.playBorderBigView.layer.cornerRadius = 54/2
        self.playBorderSmallView.layer.cornerRadius = 36/2
        
        // Change Camera button
    }
    
    func getTempVideoPath(fileName: String) -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        //        let filePath = "\(documentsPath)/tempFile.mp4"
        let templatePath = documentsPath.appendingFormat(fileName)
        
        // Remove file at template path
        let fileManager = FileManager.default
        if (fileManager.fileExists(atPath: templatePath)) {
            do {
                try fileManager.removeItem(atPath: templatePath)
            } catch {
                print("Could not clear temp folder: \(error)")
            }
        }
        
        return templatePath
    }
    
    func cropVideoCenterToSquare(videoURL: NSURL, completionHandler: (_ exportURL:NSURL) -> Void) {
        //        self.getTempVideoPath()
        // Crop video to square
        let asset: AVAsset = AVAsset(URL: videoURL as URL)
        let assetTrack: AVAssetTrack = asset.tracks(withMediaType: "vide").first!
        
        let videoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTimeMake(1, 60) // Frame 1/60
        
        let instruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30)) // Total video time by 30 minute
        
        let transformer: AVMutableVideoCompositionLayerInstruction =
            AVMutableVideoCompositionLayerInstruction(assetTrack: assetTrack)
        
        // Square param
        let minWidthHeightVideo = min(assetTrack.naturalSize.width, assetTrack.naturalSize.height)
        let cropOffX = (assetTrack.naturalSize.width - minWidthHeightVideo) / 2
        let cropOffY = (assetTrack.naturalSize.height - minWidthHeightVideo) / 2
        let cropWidth = minWidthHeightVideo
        let cropHeight = minWidthHeightVideo
        
        videoComposition.renderSize = CGSize(width: cropWidth, cropHeight)
        
        
        let videoOrientation = self.orientationForTrack(videoTrack: assetTrack)
        var t1 = CGAffineTransformIdentity
        var t2 = CGAffineTransformIdentity
        
        switch (videoOrientation) {
        case .portrait:
            t1 = CGAffineTransform(translationX: assetTrack.naturalSize.height - cropOffX, y: 0 - cropOffX)
            t2 = t1.rotated(by: CGFloat(Double.pi/2))
            
//            transformer.setCropRectangle(CGRect(x: cropOffX, y: cropOffX, width: cropWidth, height: cropHeight), atTime: kCMTimeZero)
            break
        case .portraitUpsideDown:
            t1 = CGAffineTransform(translationX: 0 - cropOffX, y: assetTrack.naturalSize.width - cropOffY ) // not fixed width is the real height in upside down
            t2 = t1.rotated(by: CGFloat(-Double.pi/2))
            break
        case .landscapeRight:
            t1 = CGAffineTransform(translationX: 0 - cropOffX, y: 0 - cropOffY )
            t2 = t1.rotated(by: 0)
            
            transformer.setCropRectangle(CGRect(x: cropOffX, y: cropOffY, width: cropWidth, height: cropHeight), at: kCMTimeZero)
            break
        case .landscapeLeft:
            t1 = CGAffineTransform(translationX: assetTrack.naturalSize.width - cropOffX, y: assetTrack.naturalSize.height - cropOffY )
            t2 = t1.rotated(by: CGFloat(Double.pi))
            break
        default:
            print("no supported orientation has been found in this video")
            break
        }
        
        let finalTransform = t2;
        transformer.setTransform(finalTransform, at: kCMTimeZero)
        
        instruction.layerInstructions = NSArray(object: transformer) as! [AVVideoCompositionLayerInstruction]
        videoComposition.instructions = NSArray(object: instruction) as! [AVVideoCompositionInstructionProtocol]
        
        let exportPath = self.getTempVideoPath(fileName: "/library.mp4")
        
        let exportUrl: NSURL = NSURL.fileURL(withPath: exportPath) as NSURL
        
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
       // exporter!.videoComposition = videoComposition
        exporter!.outputFileType = AVFileTypeMPEG4
        exporter!.outputURL = exportUrl as URL
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.timeRange =  CMTimeRangeMake(CMTimeMakeWithSeconds(0.0, 0), asset.duration)
        
        exporter?.exportAsynchronously(completionHandler: {
            let outputURL:NSURL = exporter!.outputURL! as NSURL
            
            completionHandler(outputURL)
        })
    }
    
    func getComplimentSize(size: CGFloat) -> CGFloat {
        let screenRect = SCREEN_BOUND
        var ratio = screenRect.size.height / screenRect.size.width
        
        // we have to adjust the ratio for 16:9 screens
        if (ratio == 1.775) {
            ratio = 1.77777777777778
        }
        
        return size * ratio
    }
    
    func orientationForTrack(videoTrack: AVAssetTrack) -> UIInterfaceOrientation {
        var orientation: UIInterfaceOrientation = .portrait
        let t: CGAffineTransform = videoTrack.preferredTransform
        
        // Portrait
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0) {
            orientation = .portrait
        }
        // PortraitUpsideDown
        if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0) {
            orientation = .portraitUpsideDown
        }
        // LandscapeRight
        if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0) {
            orientation = .landscapeRight
        }
        // LandscapeLeft
        if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0) {
            orientation = .landscapeLeft
        }
        
        return orientation
    }
    
    func cropAndUploadToServer() {
        self.cropVideoCenterToSquare(videoURL: self.videoURL!, completionHandler: { (exportURL) in
            self.uploadCurrentVideo(exportURL)
            
            // Save Video to Library
            //            self.saveVideoToLibrary(exportURL)
            })
    }
    
    func saveVideoToLibrary(exportURL: NSURL) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let url = NSURL(string: exportURL.absoluteString!)
            let urlData = NSData(contentsOfURL: url! as URL)
            if(urlData != nil) {
                dispatch_get_main_queue().async(execute: {
                    let exportPath = self.getTempVideoPath(fileName: "/libraryTemp.mp4")
                    
                    urlData?.writeToFile(exportPath as String, atomically: true)
                    PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(NSURL(fileURLWithPath: exportPath as String))
                    }) { completed, error in
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    func uploadCurrentVideo(videoURL: NSURL) {
        let videoData = NSData(contentsOfURL: videoURL as URL)
        let videoExtend = (videoURL.absoluteString!.components(separatedBy: ".").last?.lowercased())!
        let videoType = "video/" + videoExtend
        let videoName = "video." + videoExtend
        
        // Insert activity indicator
        self.view.makeToastActivity(message: "Uploading")
        
        // send video by method mutipart to server
        var prefix = kPMAPIUSER
        prefix.append(PMHelper.getCurrentID())
        prefix.append(kPM_PATH_VIDEO)
        var parameters = [String:AnyObject]()
        
        parameters = [kUserId : PMHelper.getCurrentID(),
                      kProfileVideo : "1"]
        
        Alamofire.upload(
            .POST,
            prefix,
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(data: videoData!,
                    name: "file",
                    fileName:videoName,
                    mimeType:videoType)
                for (key, value) in parameters {
                    multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                }
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                    
                case .Success(let upload, _, _):
                    upload.progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                    }
                    upload.validate()
                    upload.responseJSON { response in
                        self.view.hideToastActivity()
                        
                        self.recordStatus = .pending
                        
                        if (response.response?.statusCode == 200) {
                            NotificationCenter.default.post(name: "PROFILE_GET_DETAIL", object: nil, userInfo: nil)
                            
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            let alertController = UIAlertController(title: pmmNotice, message: "Please try again", preferredStyle: .alert)
                            let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
                                self.recordStatus = .finish
                            }
                            alertController.addAction(OKAction)
                            self.present(alertController, animated: true) {
                                // ...
                            }
                        }
                    }
                    
                case .Failure( _): break
                    // Do nothing
                }
        })
    }
    
    func videoPlayerSetPlay(isPlay: Bool) {
        if (isPlay) {
            self.videoPlayer?.play()
            self.playVideoButton.setImage(nil, for: .normal)
        } else {
            self.videoPlayer?.pause()
            
            let playImage = UIImage(named: "icon_play_video")
            self.playVideoButton.setImage(playImage, for: .normal)
        }
        
        self.isVideoPlaying = isPlay
    }
    
    func showSettingAlert() {
        let alertController = UIAlertController(title: pmmNotice, message: kNoCameraPermission, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            UIApplication.shared.openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
        }
        
        alertController.addAction(settingsAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Outlet function
    
    @IBAction func closeButtonClicked(sender: AnyObject) {
        if (self.recordStatus != .uploading) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func retakeButtonClicked(sender: AnyObject) {
        if (self.isRecordByCamera) {
            self.videoURL = nil
            
            self.recordStatus = .pending
            
            self.videoPlayerLayer?.removeFromSuperlayer()
            
            self.videoPlayerSetPlay(false)
            
        } else {
            self.pickerController.delegate = self
            self.present(self.pickerController, animated: true, completion: { 
                // Do nothing
            })
        }
    }
    
    @IBAction func playButtonClicked(sender: AnyObject) {
        let permission = self.checkPermissionDeviceInput()
        
        if (permission == true) {
            if (self.recordStatus == .pending) {
                self.recordStatus = .recording
                
                // Start record video
                self.startRecordVideo()
            } else if (self.recordStatus == .recording) {
                self.recordStatus = .finish
                
                // Stop record video
                self.cameraOutput.stopRecording()
            } else if (self.recordStatus == .finish) {
                self.recordStatus = .uploading
                
                self.videoPlayerSetPlay(false)
                self.videoPlayer?.currentItem?.seekToTime(kCMTimeZero)
                
                // Notification for upload video in background
                NotificationCenter.default.post(name: "PROFILE_UPLOAD_VIDEO", object: self.videoURL)
                
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            self.showSettingAlert()
        }
    }
    
    @IBAction func changeCameraButtonClicked(sender: AnyObject) {
        for deviceInput in self.cameraSession.inputs {
            if ((deviceInput as? AVCaptureDeviceInput) != nil) {
                let input: AVCaptureDeviceInput = deviceInput as! AVCaptureDeviceInput
                
                if #available(iOS 10.0, *) {
                    if (input.device.deviceType == "AVCaptureDeviceTypeBuiltInWideAngleCamera") {
                        self.cameraSession.beginConfiguration()
                        
                        // Remove current camera input
                        self.cameraSession.removeInput(input)
                        
                        // Check current camera position
                        var captureDevice: AVCaptureDevice? = nil
                        if (input.device.position == .Back) {
                            captureDevice = self.cameraWithPosition(.Front)
                        } else {
                            captureDevice = self.cameraWithPosition(.Back)
                        }
                        
                        // Add new camera input
                        do {
                            let deviceInput = try AVCaptureDeviceInput(device: captureDevice!)
                            
                            if (self.cameraSession.canAddInput(deviceInput) == true) {
                                self.cameraSession.addInput(deviceInput)
                            }
                        }
                        catch let error as NSError {
                            NSLog("\(error), \(error.localizedDescription)")
                        }
                        
                        self.cameraSession.commitConfiguration()
                    }
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    
    @IBAction func playVideoButtonClicked(sender: AnyObject) {
        self.isVideoPlaying = !self.isVideoPlaying
        self.videoPlayerSetPlay(self.isVideoPlaying)
    }
    
    func startRecordVideo() {
        // Delete template if exist
        let videoTemplatePath = self.getTempVideoPath("/video.mp4")
        let videoTemplateURL = NSURL.fileURLWithPath(videoTemplatePath)
        
        // Record video to template file
        self.cameraOutput.startRecordingToOutputFileURL(videoTemplateURL, recordingDelegate: self)
        //            self.audioOutput.startRecordingToOutputFileURL(videoTemplateURL, recordingDelegate: self)
    }
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    @available(iOS 4.0, *)
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        // Do nothing
        // TODO: do something
    }

    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        print("Finish record video")
        
        self.playButton.isUserInteractionEnabled = false
        
        // Save video to library
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let urlData = NSData(contentsOfURL: outputFileURL as URL)
            if(urlData != nil) {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .UserDomainMask, true)[0]
                let filePath="\(documentsPath)/tempFile.mp4"
                DispatchQueue.main.async(execute: {
                    urlData?.writeToFile(filePath, atomically: true)
                    PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: NSURL(fileURLWithPath: filePath) as URL)
                    }) { completed, error in
                        self.videoURL = outputFileURL
                        
                        // Show video layout
                        dispatch_get_main_queue().async(execute: {
                            self.showVideoLayout()
                        })
                    }
                })
            }
        }
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        print("Start record video")
    }
}

extension CameraViewController: AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        
        for device in devices! {
            if ((device as? AVCaptureDevice) != nil) {
                let device: AVCaptureDevice = device as! AVCaptureDevice
                
                if (device.position == position) {
                    return device
                }
            }
        }
        
        return nil
    }
    
    func checkPermissionDeviceInput() -> Bool {
        var permission = true
        
        // Micro permission
        let microAuthStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio)
        
        // Camera permission
        let cameraAuthStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if (microAuthStatus == .restricted ||
            microAuthStatus == .denied ||
            cameraAuthStatus == .restricted ||
            cameraAuthStatus == .denied) {
            permission = false
        }
        
        return permission
    }
    
    func setupCameraSession(cameraPosition: AVCaptureDevicePosition) {
        let captureDevice = self.cameraWithPosition(position: cameraPosition)
        let audioCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        
        if (captureDevice != nil) {
            do {
                let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
                let audioInput = try AVCaptureDeviceInput(device: audioCaptureDevice)
                
                self.cameraSession.beginConfiguration()
                
                // Add Camera input
                if (self.cameraSession.canAddInput(deviceInput) == true) {
                    self.cameraSession.addInput(deviceInput)
                }
                
                // Add Audio input
                if (self.cameraSession.canAddInput(audioInput) == true) {
                    self.cameraSession.addInput(audioInput)
                }
                
                let dataOutput = AVCaptureVideoDataOutput()
                dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange as UInt32)]
                dataOutput.alwaysDiscardsLateVideoFrames = true
                
                if (self.cameraSession.canAddOutput(dataOutput) == true) {
                    self.cameraSession.addOutput(dataOutput)
                }
            
                // Add video output
                if (self.cameraSession.canAddOutput(self.cameraOutput)) {
                    self.cameraSession.addOutput(self.cameraOutput)
                }
                
                self.cameraSession.commitConfiguration()
                
                let queue = dispatch_queue_create("com.invasivecode.videoQueue", DISPATCH_QUEUE_SERIAL)
                dataOutput.setSampleBufferDelegate(self, queue: queue)
                
            }
            catch let error as NSError {
                NSLog("\(error), \(error.localizedDescription)")
            }
        }
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        // Here you collect each frame and process it
        print(sampleBuffer)
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        // Here you can count how many frames are dopped
//        print(sampleBuffer)
    }
}

