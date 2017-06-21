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

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var changeCameraButton: UIButton!
    
    @IBOutlet weak var playBorderBigView: UIView!
    @IBOutlet weak var playBorderSmallView: UIView!
    @IBOutlet weak var playButtonIndicatorView: UIActivityIndicatorView!
    
    var videoPlayer: AVPlayer? = nil
    var videoPlayerLayer: AVPlayerLayer? = nil
    
    var needRemoveKVO = false
    
    var videoURL:NSURL? = nil {
        didSet {
            if (playVideoButton != nil) {
                if (self.videoURL == nil) {
                    self.playVideoButton.hidden = true
                } else {
                    self.playVideoButton.hidden = false
                }
            }
        }
    }
    
    var isVideoPlaying = false
    
    var recordStatus: RecordStatus = .pending {
        didSet {
            // Hidden indicator
            self.playButtonIndicatorView.hidden = true
            
            if (self.recordStatus == .pending) {
                let playImage = UIImage(named: "icon_play")?.imageWithRenderingMode(.AlwaysTemplate)
                self.playButton.setImage(playImage, forState: .Normal)
            } else if (self.recordStatus == .recording) {
                let pauseImage = UIImage(named: "icon_pause")?.imageWithRenderingMode(.AlwaysTemplate)
                self.playButton.setImage(pauseImage, forState: .Normal)
            } else if (self.recordStatus == .finish) {
                let uploadImage = UIImage(named: "icon_upload")?.imageWithRenderingMode(.AlwaysTemplate)
                self.playButton.setImage(uploadImage, forState: .Normal)
            } else if (self.recordStatus == .uploading) {
                self.playButton.setImage(nil, forState: .Normal)
                
                // Show indicator for uploading
                self.playButtonIndicatorView.hidden = false
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (self.videoURL == nil) {
            self.setupCameraSession()
            self.cameraView.layer.addSublayer(previewLayer)
            cameraSession.startRunning()
            
            self.playVideoButton.hidden = true
        } else {
            // Stop camera and show video from video URL
            cameraSession.stopRunning()
            
            self.showVideoLayout()
            
            // Change record status
            self.recordStatus = .finish
            self.playVideoButton.hidden = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (self.needRemoveKVO) {
            self.videoPlayer?.currentItem?.removeObserver(self, forKeyPath: "status")
            self.needRemoveKVO = false
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        let currentItem = object as! AVPlayerItem
        if currentItem.status == .ReadyToPlay {
            let videoRect = self.videoPlayerLayer?.videoRect
            if (videoRect?.width > videoRect?.height) {
                self.videoPlayerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            } else {
                self.videoPlayerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            }
            
            if (self.needRemoveKVO) {
                self.videoPlayer?.currentItem?.removeObserver(self, forKeyPath: "status")
                self.needRemoveKVO = false
            }
        }
    }

    
    //MARK: - Private function
    func showVideoLayout() {
        // Show Video URL in border view
        self.videoPlayer = AVPlayer(URL: self.videoURL!)
        self.videoPlayer!.actionAtItemEnd = .None
        self.videoPlayerLayer = AVPlayerLayer(player: self.videoPlayer)
        self.videoPlayerLayer!.frame = self.cameraBorderView.bounds
        
        self.cameraBorderView.layer.addSublayer(self.videoPlayerLayer!)
        
        // Catch size of video and crop
        self.videoPlayer!.currentItem!.addObserver(self, forKeyPath: "status", options: [.Old, .New], context: nil)
        self.needRemoveKVO = true
        
        // Catch end video
        // Remove loop play video for
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        
        // Add notification for loop play video
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.endVideoNotification),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: self.videoPlayer!.currentItem)
    }
    
    func endVideoNotification(notification: NSNotification) {
        let playerItem = notification.object as! AVPlayerItem
        
        // Show first frame video
        playerItem.seekToTime(kCMTimeZero)
        self.videoPlayer?.pause()
        
        self.isVideoPlaying = false
        let playImage = UIImage(named: "icon_play_video")
        self.playVideoButton.setImage(playImage, forState: .Normal)
    }
    
    func setupBasicLayout() {
        // Border camera view
        self.cameraBorderView.layer.borderColor = UIColor.whiteColor().CGColor
        self.cameraBorderView.layer.borderWidth = 1.0
        
        // Close button
        let closeImage = UIImage(named: "close")?.imageWithRenderingMode(.AlwaysTemplate)
        self.closeButton.setImage(closeImage, forState: .Normal)
        self.closeButton.tintColor = UIColor.whiteColor()
        
        // Retake button
        
        
        // Play button
        self.playButton.tintColor = UIColor.whiteColor()
        self.recordStatus = .pending
        
        self.playBorderBigView.layer.cornerRadius = 54/2
        self.playBorderSmallView.layer.cornerRadius = 36/2
        
        // Change Camera button
    }
    
    func getTempVideoPath(fileName: String) -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0];
        //        let filePath = "\(documentsPath)/tempFile.mp4";
        let templatePath = documentsPath.stringByAppendingFormat(fileName)
        
        // Remove file at template path
        let fileManager = NSFileManager.defaultManager()
        if (fileManager.fileExistsAtPath(templatePath)) {
            do {
                try fileManager.removeItemAtPath(templatePath)
            } catch {
                print("Could not clear temp folder: \(error)")
            }
        }
        
        return templatePath
    }
    
    func cropVideoCenterToSquare(completionHandler: (exportURL:NSURL) -> Void) {
        //        self.getTempVideoPath()
        // Crop video to square
        let asset: AVAsset = AVAsset(URL: self.videoURL!)
        let assetTrack: AVAssetTrack = asset.tracksWithMediaType("vide").first!
        
        let videoSize: CGFloat = min(assetTrack.naturalSize.width, assetTrack.naturalSize.height)
        
        let videoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTimeMake(1, 60) // Frame 1/60
        videoComposition.renderSize = CGSizeMake(videoSize, videoSize)
        
        let instruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30)) // Total video time by 30 minute
        
        let transformer: AVMutableVideoCompositionLayerInstruction =
            AVMutableVideoCompositionLayerInstruction(assetTrack: assetTrack)
        
        let spaceLeft = (assetTrack.naturalSize.width - videoSize) / 2
        let spaceTop = (assetTrack.naturalSize.height - videoSize) / 2
        
        let finalTransform: CGAffineTransform = CGAffineTransformMakeTranslation(-spaceLeft, -spaceTop)
        
        transformer.setTransform(finalTransform, atTime: kCMTimeZero)
        transformer.setCropRectangle(CGRect(x: spaceLeft, y: spaceTop, width: videoSize, height: videoSize), atTime: kCMTimeZero)
        
        instruction.layerInstructions = NSArray(object: transformer) as! [AVVideoCompositionLayerInstruction]
        videoComposition.instructions = NSArray(object: instruction) as! [AVVideoCompositionInstructionProtocol]
        
        let exportPath = self.getTempVideoPath("/library.mov")
        
        let exportUrl: NSURL = NSURL.fileURLWithPath(exportPath)
        
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        exporter!.videoComposition = videoComposition
        exporter!.outputFileType = AVFileTypeQuickTimeMovie
        exporter!.outputURL = exportUrl
        
        exporter?.exportAsynchronouslyWithCompletionHandler({
            let outputURL:NSURL = exporter!.outputURL!;
            
            completionHandler(exportURL: outputURL)
        })
    }
    
    func cropAndSaveVideo() {
        self.cropVideoCenterToSquare { (exportURL) in
            self.uploadCurrentVideo(exportURL)
            
            // Save Video to Library
//            self.saveVideoToLibrary(exportURL)
        }
    }
    
    func saveVideoToLibrary(exportURL: NSURL) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let url = NSURL(string: exportURL.absoluteString!);
            let urlData = NSData(contentsOfURL: url!);
            if(urlData != nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    let exportPath = self.getTempVideoPath("/libraryTemp.mov")
                    
                    urlData?.writeToFile(exportPath as String, atomically: true);
                    PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(NSURL(fileURLWithPath: exportPath as String))
                    }) { completed, error in
                        // Upload video to server
                        self.recordStatus = .pending
                    }
                })
            }
        })
    }
    
    func uploadCurrentVideo(videoURL: NSURL) {
        let videoData = NSData(contentsOfURL: videoURL)
        let videoExtend = (videoURL.absoluteString!.componentsSeparatedByString(".").last?.lowercaseString)!
        let videoType = "video/" + videoExtend
        let videoName = "video." + videoExtend
        
        // Insert activity indicator
        self.view.makeToastActivity(message: "Uploading")
        
        // send video by method mutipart to server
        var prefix = kPMAPIUSER
        let defaults = NSUserDefaults.standardUserDefaults()
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        prefix.appendContentsOf(kPM_PATH_VIDEO)
        var parameters = [String:AnyObject]()
        
        parameters = [kUserId:defaults.objectForKey(k_PM_CURRENT_ID) as! String, kProfileVideo : "1"]
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
                        
                        if (response.response?.statusCode == 200) {
                            self.dismissViewControllerAnimated(true, completion: nil)
                        } else {
                            let alertController = UIAlertController(title: pmmNotice, message: "Please try again", preferredStyle: .Alert)
                            let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                                // TODO: LOGOUT
                            }
                            alertController.addAction(OKAction)
                            self.presentViewController(alertController, animated: true) {
                                // ...
                            }
                        }
                    }
                    
                case .Failure( _): break
                    // Do nothing
                }
        })
    }
    
    // MARK: - Outlet function
    
    @IBAction func closeButtonClicked(sender: AnyObject) {
        if (self.recordStatus != .uploading) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func retakeButtonClicked(sender: AnyObject) {
        
    }
    
    @IBAction func playButtonClicked(sender: AnyObject) {
//        self.exportVideo()
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
            
            self.videoPlayer?.pause()
            self.videoPlayer?.currentItem?.seekToTime(kCMTimeZero)
            
            
            // Check render video
            self.cropAndSaveVideo()
        }
    }
    
    @IBAction func changeCameraButtonClicked(sender: AnyObject) {
//        self.cameraSession
    }
    
    @IBAction func playVideoButtonClicked(sender: AnyObject) {
        self.isVideoPlaying = !self.isVideoPlaying
        
        if (self.isVideoPlaying) {
            self.videoPlayer?.play()
            self.playVideoButton.setImage(nil, forState: .Normal)
        } else {
            self.videoPlayer?.pause()
            
            let playImage = UIImage(named: "icon_play_video")
            self.playVideoButton.setImage(playImage, forState: .Normal)
        }
        
    }
    
    func startRecordVideo() {
        // Delete template if exist
        let videoTemplatePath = self.getTempVideoPath("/video.mov")
        let videoTemplateURL = NSURL.fileURLWithPath(videoTemplatePath)
        
        // Record video to template file
        self.cameraOutput.startRecordingToOutputFileURL(videoTemplateURL, recordingDelegate: self)
        //            self.audioOutput.startRecordingToOutputFileURL(videoTemplateURL, recordingDelegate: self)
    }
}

extension CameraViewController:AVCaptureFileOutputRecordingDelegate {
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        print("Finish record video")
        
        // Save video to library
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let urlData = NSData(contentsOfURL: outputFileURL);
            if(urlData != nil)
            {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0];
                let filePath="\(documentsPath)/tempFile.mov";
                dispatch_async(dispatch_get_main_queue(), {
                    urlData?.writeToFile(filePath, atomically: true);
                    PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(NSURL(fileURLWithPath: filePath))
                    }) { completed, error in
                        self.videoURL = outputFileURL
                    }
                })
            }
        })
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
    func setupCameraSession() {
        let captureDevice = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).first as! AVCaptureDevice
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            self.cameraSession.beginConfiguration()
            
            if (self.cameraSession.canAddInput(deviceInput) == true) {
                self.cameraSession.addInput(deviceInput)
            }
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(unsignedInt: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange as UInt32)]
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if (self.cameraSession.canAddOutput(dataOutput) == true) {
                self.cameraSession.addOutput(dataOutput)
            }
            
            let audioOutput: AVCaptureAudioDataOutput = AVCaptureAudioDataOutput()
            
            if (self.cameraSession.canAddOutput(audioOutput) == true) {
                self.cameraSession.addOutput(audioOutput)
            }
            
            // Add video output and audio output
            if (self.cameraSession.canAddOutput(self.cameraOutput)) {
                self.cameraSession.addOutput(self.cameraOutput)
            }
            
            self.cameraSession.commitConfiguration()
            
            let queue = dispatch_queue_create("com.invasivecode.videoQueue", DISPATCH_QUEUE_SERIAL)
            dataOutput.setSampleBufferDelegate(self, queue: queue)
            
            let audioqueue = dispatch_queue_create("com.invasivecode.audioQueue", DISPATCH_QUEUE_SERIAL)
            audioOutput.setSampleBufferDelegate(self, queue: audioqueue)
            
        }
        catch let error as NSError {
            NSLog("\(error), \(error.localizedDescription)")
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

