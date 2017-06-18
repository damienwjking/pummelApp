//
//  DiskRecorder.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 6/15/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class DiskRecorder: NSObject {
    var assetWriter: AVAssetWriter!
    var settings = [String: [String: AnyObject]]()
    
    func convertFileMOVToMP4(fileName: String) {
        let aFileName = fileName + ".mp4"
        var url = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        url = url.URLByAppendingPathComponent(aFileName)!
        let path = url.path
        
        guard NSFileManager.defaultManager().fileExistsAtPath(path!) == false else {
            return
        }
        
        do {
            self.assetWriter = try AVAssetWriter(URL: url, fileType: AVFileTypeMPEG4)
            let setting = self.settings[AVMediaTypeVideo]
            let mediaWriter = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: setting)
            mediaWriter.expectsMediaDataInRealTime = true
            
            guard self.assetWriter.canAddInput(mediaWriter) == true else {
                return
            }

            self.assetWriter.addInput(mediaWriter)
            
            guard self.assetWriter.inputs.count == 1 else {
                return
            }
            
            guard self.assetWriter.startWriting() == true else {
                return
            }
            
            guard self.assetWriter.status == .Writing else {
                return
            }
            
            // We are going to synchronize all write operations to the host clock, so start timing from now
            self.assetWriter.startSessionAtSourceTime(CMClockGetTime(CMClockGetHostTimeClock()))
        } catch let error {
            print("error: ", error)
        }
    }
    
}
