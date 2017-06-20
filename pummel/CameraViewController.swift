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


class CameraViewController: UIViewController {
    var videoURL:NSURL? = nil
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cameraBorderView: UIView!

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var changeCameraButton: UIButton!
    
    @IBOutlet weak var playBorderBigView: UIView!
    @IBOutlet weak var playBorderSmallView: UIView!
    
    var isRecording = false
    
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
        self.setupLayout()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (self.videoURL == nil) {
            self.setupCameraSession()
            self.cameraView.layer.addSublayer(previewLayer)
            cameraSession.startRunning()
        }
    }
    
    //MARK: - Private function
    func setupLayout() {
        // Close button
        let closeImage = UIImage(named: "close")?.imageWithRenderingMode(.AlwaysTemplate)
        self.closeButton.setImage(closeImage, forState: .Normal)
        self.closeButton.tintColor = UIColor.whiteColor()
        
        // Retake button
        
        
        // Play button
        let playImage = UIImage(named: "icon_play")?.imageWithRenderingMode(.AlwaysTemplate)
        self.playButton.setImage(playImage, forState: .Normal)
        self.playButton.tintColor = UIColor.whiteColor()
        
        self.playBorderBigView.layer.cornerRadius = 54/2
        self.playBorderSmallView.layer.cornerRadius = 36/2
        
        // Change Camera button
    }
    
    func exportVideo() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0];
//        let filePath = "\(documentsPath)/tempFile.mp4";
        let exportPath: NSString = documentsPath.stringByAppendingFormat("/xvideo.mov")
        
        // Remove file at template path
        let fileManager = NSFileManager.defaultManager()
        if (fileManager.fileExistsAtPath(exportPath as String)) {
            do {
                try fileManager.removeItemAtPath(exportPath as String)
            } catch {
                print("Could not clear temp folder: \(error)")
            }
        }
        
        let videoSize: CGFloat = 600
        let asset: AVAsset = AVAsset(URL: self.videoURL!)
        let assetTrack: AVAssetTrack = asset.tracksWithMediaType("vide")[0]
        
        let videoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTimeMake(1, 60)
        videoComposition.renderSize = CGSizeMake(videoSize, videoSize)
        
        let instruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))
        
        let transformer: AVMutableVideoCompositionLayerInstruction =
            AVMutableVideoCompositionLayerInstruction(assetTrack: assetTrack)
        
        let finalTransform: CGAffineTransform = CGAffineTransformMakeTranslation(-100, -300)
        
        transformer.setTransform(finalTransform, atTime: kCMTimeZero)
        transformer.setCropRectangle(CGRect(x: 100, y: 300, width: videoSize, height: videoSize), atTime: kCMTimeZero)
        
        instruction.layerInstructions = NSArray(object: transformer) as! [AVVideoCompositionLayerInstruction]
        videoComposition.instructions = NSArray(object: instruction) as! [AVVideoCompositionInstructionProtocol]
        
        let exportUrl: NSURL = NSURL.fileURLWithPath(exportPath as String)
        
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        exporter!.videoComposition = videoComposition
        exporter!.outputFileType = AVFileTypeQuickTimeMovie
        exporter!.outputURL = exportUrl
        
        exporter?.exportAsynchronouslyWithCompletionHandler({ 
            //display video after export is complete, for example...
            let outputURL:NSURL = exporter!.outputURL!;
            let asset:AVURLAsset = AVURLAsset(URL: outputURL, options: nil)
            let newPlayerItem:AVPlayerItem = AVPlayerItem(asset: asset)
            
            
            
            let videoImageUrl = "https://pummel-prod.s3.amazonaws.com/videos/1497421626868-0.mov"
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let url = NSURL(string: outputURL.absoluteString!);
                let urlData = NSData(contentsOfURL: url!);
                if(urlData != nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        urlData?.writeToFile(exportPath as String, atomically: true);
                        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(NSURL(fileURLWithPath: exportPath as String))
                        }) { completed, error in
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                            self.closeButton.backgroundColor = UIColor.redColor()
                            })
                        }
                    })
                }
            })
        })
    }
    
    // MARK: - Outlet function
    
    @IBAction func closeButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func retakeButtonClicked(sender: AnyObject) {
        
    }
    
    @IBAction func playButtonClicked(sender: AnyObject) {
//        self.exportVideo()
        
        if (self.isRecording == false) {
            self.isRecording = true
            
            // Delete template if exist
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0];
            //        let filePath = "\(documentsPath)/tempFile.mp4";
            let templatePath = documentsPath.stringByAppendingFormat("/video.mov")
            let videoTemplateURL = NSURL.fileURLWithPath(templatePath)
            
            let fileManager = NSFileManager.defaultManager()
            if (fileManager.fileExistsAtPath(videoTemplateURL.absoluteString!)) {
                do {
                    try fileManager.removeItemAtURL(videoTemplateURL)
                } catch {
                    print("Could not clear temp folder: \(error)")
                }
            }
            
            // Record video to template file
            self.cameraOutput.startRecordingToOutputFileURL(videoTemplateURL, recordingDelegate: self)
//            self.audioOutput.startRecordingToOutputFileURL(videoTemplateURL, recordingDelegate: self)
        } else {
            self.isRecording = false
            self.cameraOutput.stopRecording()
        }
    }
    
    @IBAction func changeCameraButtonClicked(sender: AnyObject) {
//        self.cameraSession
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

