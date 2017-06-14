//
//  TrackingPMAPI.swift
//  pummel
//
//  Created by Nguyen Vu Hao on 6/14/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit
import Alamofire

class TrackingPMAPI: NSObject {
    static let sharedInstance = TrackingPMAPI()
    
    func trackingCallBackButtonClick(coachId:String) {
        let param = [kCoachId:coachId]
        let prefix = "\(kPMAPI)\(kPMAPI_TRACKCALLBACK)"
        Alamofire.request(.POST, prefix, parameters: param)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                } else {
                }
        }
    }
    
    func trackingConnectButtonCLick(coachId:String) {
        let param = [kCoachId:coachId]
        let prefix = "\(kPMAPI)\(kPMAPI_TRACKCONNECT)"
        Alamofire.request(.POST, prefix, parameters: param)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                } else {
                }
        }
    }
    
    func trackingMessageButtonCLick(coachId:String) {
        let param = [kCoachId:coachId]
        let prefix = "\(kPMAPI)\(kPMAPI_TRACKMESSAGE)"
        Alamofire.request(.POST, prefix, parameters: param)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                } else {
                }
        }
    }
    
    func trackingProfileCard(coachId:String) {
        let param = [kCoachId:coachId]
        let prefix = "\(kPMAPI)\(kPMAPI_TRACKPROFILECARD)"
        Alamofire.request(.POST, prefix, parameters: param)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                } else {
                }
        }
    }
    
    func trackingProfileViewed(coachId:String) {
        let param = [kCoachId:coachId]
        let prefix = "\(kPMAPI)\(kPMAPI_TRACKPROFILEVIEW)"
        Alamofire.request(.POST, prefix, parameters: param)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                } else {
                }
        }
    }
    
    func trackSocialFacebook(coachId:String) {
        let param = [kCoachId:coachId]
        let prefix = "\(kPMAPI)\(kPMAPI_TRACKSOCIALFB)"
        Alamofire.request(.POST, prefix, parameters: param)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                } else {
                }
        }
    }
    
    func trackSocialInstagram(coachId:String) {
        let param = [kCoachId:coachId]
        let prefix = "\(kPMAPI)\(kPMAPI_TRACKSOCIALINSTA)"
        Alamofire.request(.POST, prefix, parameters: param)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                } else {
                }
        }
    }
    
    func trackSocialTwitter(coachId:String) {
        let param = [kCoachId:coachId]
        let prefix = "\(kPMAPI)\(kPMAPI_TRACKSOCIALTWI)"
        Alamofire.request(.POST, prefix, parameters: param)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                } else {
                }
        }
    }
    
    func trackSocialWeb(coachId:String) {
        let param = [kCoachId:coachId]
        let prefix = "\(kPMAPI)\(kPMAPI_TRACKSOCIALWEB)"
        Alamofire.request(.POST, prefix, parameters: param)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                } else {
                }
        }
    }
}
