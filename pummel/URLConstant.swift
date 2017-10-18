//
//  URLConstant.swift
//  pummel
//
//  Created by Bear Daddy on 10/28/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import Foundation

//-----------------------------PRODUCTION------------------------------------//

// Product
//let kPMAPI                          = "http://api.pummel.fit"

// Developer
let kPMAPI                          = "http://dev.pummel.fit"

// PM API Link
let kPMAPI_BUSINESS                 = kPMAPI + "//api/businesses/"
let kPMAPIDELETEACTIVITY            = kPMAPI + "/api/activities/deleteActivity"
let kPMAPIACTIVITY                  = kPMAPI + "/api/activities/"
let kPMAPI_ADD_TAG                  = kPMAPI + "/api/tags"
let kPMAPICOACHES                   = kPMAPI + "/api/coaches/"
let kPMAPIAUTHENTICATEFACEBOOK      = kPMAPI + "/api/authenticateFacebook"
let kPMAPIUSER                      = kPMAPI + "/api/users/"
let kPMAPISEARCHUSER                = kPMAPI + "/api/users/searchUser"
let kPMAPICHECKUSERCONNECT          = kPMAPI + "/api/users/check"
let kPMAPIUSER_OFFSET               = kPMAPI + "/api/users?offset="
let kPMAPICOACH                     = kPMAPI + "/api/coaches/"
let kPMAPICOACH_SEARCHV1            = kPMAPI + "/api/coaches/search"
let kPMAPICOACH_SEARCHV2            = kPMAPI + "/api/coaches/searchdistanceV2"
let kPMAPICOACH_SEARCHV3            = kPMAPI + "/api/coaches/searchdistanceV3"
let kPMAPI_FORGOT                   = kPMAPI + "/api/forget"
let kPMAPI_LOGIN                    = kPMAPI + "/api/login"
let kPMAPI_LOGOUT                   = kPMAPI + "/api/logout"
let kPMAPI_LIKE                     = kPMAPI + "/api/likes/"
let kPMAPI_POST                     = kPMAPI + "/api/posts/"
let kPMAPI_POST_OFFSET              = kPMAPI + "/api/posts/?offset="
let kPMAPI_REPORT                   = kPMAPI + "/api/posts/report"
let kPMAPI_REGISTER                 = kPMAPI + "/api/register"
//let kPMAPI_TAG_OFFSET               = kPMAPI + "/api/tags?offset="        ||
//let kPMAPI_TAG4_OFFSET              = kPMAPI + "/api/tags4?offset="       ||
//let kPMAPI_TAGALL_OFFSET            = kPMAPI + "/api/tagsAll?offset="     \/
let kPMAPI_TAG_OFFSET               = kPMAPI + "/api/tagsAll?offset="

let kPMAPI_DISCOUNTS                = kPMAPI + "/api/discounts"
let kPMAPI_POSTOFPHOTO              = kPMAPI + "/api/postOfPhoto"

// PM Link
let kPM                             = "http://pummel.fit"
let kPM_TERM                        = kPM + "/terms/"
let kPM_PRIVACY                     = kPM + "/privacy/"

// Mail
let kPMSUPPORT_EMAIL                = "support@pummel.fit"
let kPMHELLO_EMAIL                  = "hello@pummel.fit"

// Sub Link
let kPM_PATH_PHOTO_PROFILE          = "/photos"
//let kPM_PATH_PHOTO                  = "/photos?offset="       // Can repleace by kPM_PATH_PHOTO_PROFILE
let kPM_PATH_VIDEO                  = "/videos"
let kPM_PATH_PHOTOV2                = "/photosV2?offset="
let kPM_PATH_CONVERSATION           = "/conversations"
let kPM_PATH_CONVERSATION_V2        = "/conversationsV2"
let kPM_PATH_CONVERSATION_OFFSET_V2 = "/conversationsVersion2?offset="
//let kPM_PATH_CONVERSATION_OFFSET    = "/conversations?offset="    // No use
let kPM_PATH_DELETEACTIVITY         = "/activities/deleteActivity"
let kPM_PATH_DEVICES                = "/devices"
let kPM_PARTH_MESSAGE               = "/messages"
let kPM_PARTH_MESSAGE_V2            = "/messagesV2"
let kPM_PATH_LIKE                   = "/likes"
let kPM_PATH_COMMENT                = "/comments"
let kPM_PATH_COMMENT_OFFSET         = "/comments?offset="
let kPM_PATH_COMMENT_LIMIT          = "/comments?limit="
let kPM_PATH_LIMIT_ONE              = "&limit=1"
let kPM_PATH_LOG_ACTIVITIES_USER    = "/activitiesuserV2"
let kPM_PATH_LOG_ACTIVITIES_COACH   = "/activitiescoachV2"
let kPM_PATH_ACTIVITIES_USER        = "/activitiesuser?limit=20&offset="
let kPM_PATH_UPCOMING_SESSION       = "/upcommingActivities?limit=20&offset="
let kPM_PATH_COMPLETED_SESSION      = "/completedActivities?limit=20&offset="
let kPM_PATH_TOTAL_ACTIVE_USER      = "/totalActive"

let kPM_PATH_M_BADGE_S_BADGE        = "/numberofNewMessageAndNewSessionAndLeadAndComment"
let kPM_PATH_RESET_S_BADGE          = "/resetsNotificationBadge"
let kPM_PATH_RESET_L_BADGE          = "/resetlNotificationBadge"
let kPM_PATH_RESET_C_BADGE          = "/resetcNotificationBadge"
let kPM_PATH_DECREASE_M_BADGE       = "/decreasemNotificationBadge"
let kPM_PATH_TESTIMONIAL            = "/testimonial"
let kPM_PATH_TESTIMONIAL_OFFSET     = "/testimonial?limit=20&offset="
let kPM_PATH_USERCOACH_OFFSET       = "/userCoach?limit=20&offset="

let kPM_PATH_LEADS               = "/leads"
let kPM_PATH_CURRENT             = "/current"
let kPM_PATH_OLD                 = "/old"
let kPM_PATH_JUSTCONNECTED       = "/justconnected"
let kPM_PATH_COACHCURRENT        = "/currentCoach"
let kPM_PATH_COACHOLD            = "/pastCoach"

let kPMAPICOACH_BOOK                = "/bookV2"
let kPMAPI_LEAD                     = "/lead"
let kPMAPI_CHANGEPASS               = "/password"

// Tracking
let kPMAPI_TRACKCALLBACK            = "/api/trackCallBackBt"
let kPMAPI_TRACKCONNECT             = "/api/trackConnectBt"
let kPMAPI_TRACKMESSAGE             = "/api/trackMessageBt"
let kPMAPI_TRACKPROFILECARD         = "/api/trackProfileCard"
let kPMAPI_TRACKPROFILEVIEW         = "/api/trackProfileView"
let kPMAPI_TRACKSOCIALFB            = "/api/trackSocialFacebook"
let kPMAPI_TRACKSOCIALINSTA         = "/api/trackSocialInstagram"
let kPMAPI_TRACKSOCIALTWI           = "/api/trackSocialTwitter"
let kPMAPI_TRACKSOCIALWEB           = "/api/trackSocialWeb"
