//
//  URLConstant.swift
//  pummel
//
//  Created by Bear Daddy on 10/28/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import Foundation

// ---------------------------DEV-----------------------------------------//
//let kPMAPI = "http://dev.pummel.fit"
//let kPMAPIUSER = "http://dev.pummel.fit/api/users/"
//let kPMAPISEARCHUSER = "http://dev.pummel.fit/api/users/searchUser?offset="
//let kPMAPICHECKUSERCONNECT = "http://dev.pummel.fit/api/users/check"
//let kPMAPIUSER_OFFSET = "http://dev.pummel.fit/api/users?offset="
//let kPMAPICOACH = "http://dev.pummel.fit/api/coaches/"
//let kPMAPICOACH_SEARCHV1 = "http://dev.pummel.fit/api/coaches/search"
//let kPMAPICOACH_SEARCH = "http://dev.pummel.fit/api/coaches/searchdistanceV2"
//let kPMAPI_LOGOUT = "http://dev.pummel.fit/api/logout"
//let kPMAPI_LIKE = "http://dev.pummel.fit/api/likes/"
//let kPMAPI_POST = "http://dev.pummel.fit/api/posts/"
//let kPMAPI_POST_OFFSET = "http://dev.pummel.fit/api/posts/?offset="
//let kPMAPI_LOGIN = "http://dev.pummel.fit/api/login"
//let kPMAPI_REPORT = "http://dev.pummel.fit/api/posts/report"
//let kPMAPI_FORGOT = "http://dev.pummel.fit/api/forget"
//let kPMAPI_REGISTER = "http://dev.pummel.fit/api/register"
//let kPMAPI_TAG_OFFSET = "http://dev.pummel.fit/api/tags?offset="
//let kPMAPI_TAG4_OFFSET = "http://dev.pummel.fit/api/tags4?offset="
//let kPMAPI_TAGALL_OFFSET = "http://dev.pummel.fit/api/tagsAll?offset="
//let kPMAPI_BUSINESS = "http://dev.pummel.fit//api/businesses/"
//let kPM_TERM = "http://pummel.fit/terms/"
//let kPM_PRIVACY = "http://pummel.fit/privacy/"
//let kPM = "http://pummel.fit"
//let kPMAPIDELETEACTIVITY = "http://dev.pummel.fit/api/activities/deleteActivity"
//let kPMAPIACTIVITY = "http://dev.pummel.fit/api/activities/"
//let kPMSUPPORT_EMAIL = "support@pummel.fit"
//let kPMHELLO_EMAIL = "hello@pummel.fit"
//let kPM_PATH_PHOTO_PROFILE = "/photos"
//let kPM_PATH_PHOTO = "/photos?offset="
//let kPM_PATH_PHOTOV2 = "/photosV2?offset="
//let kPM_PATH_CONVERSATION = "/conversations"
//let kPM_PATH_CONVERSATION_OFFSET = "/conversations?offset="
//let kPM_PATH_DEVICES =  "/devices"
//let kPM_PARTH_MESSAGE = "/messages"
//let kPM_PATH_LIKE = "/likes"
//let kPM_PATH_COMMENT_OFFSET = "/comments?offset="
//let kPM_PATH_COMMENT_LIMIT = "/comments?limit="
//let kPM_PATH_LIMIT_ONE = "&limit=1"
//let kPM_PATH_LOG_ACTIVITIES_USER = "/activitiesuserV2"
//let kPM_PATH_LOG_ACTIVITIES_COACH = "/activitiescoachV2"
//let kPM_PATH_ACTIVITIES_USER = "/activitiesuser?offset="
//let kPMAPI_ADD_TAG = "http://dev.pummel.fit/api/tags"
//let kPMAPICOACH_LEADS = "/leads?offset="
//let kPMAPICOACH_CURRENT = "/current?offset="
//let kPMAPICOACH_OLD = "/old?offset="
//let kPMAPICOACH_JUSTCONNECTED = "/justconnected?offset="
//let kPMAPICOACH_COACHCURRENT = "/currentCoach?offset="
//let kPMAPICOACH_COACHOLD = "/pastCoach?offset="
//let kPMAPICOACHES = "http://dev.pummel.fit/api/coaches/"
//let kPMAPICOACH_BOOK = "/bookV2"
//let kPMAPI_LEAD = "/lead"
//let kPMAPI_CHANGEPASS = "/password"
//let kPMAPI_POSTOFPHOTO = "/api/postOfPhoto"


//-----------------------------PRODUCTION------------------------------------//

// Product
//let kPMAPI                          = "http://api.pummel.fit"

// Developer
let kPMAPI                          = "http://dev.pummel.fit"


// PM API Link
let kPMAPIUSER                      = kPMAPI + "/api/users/"
let kPMAPISEARCHUSER                = kPMAPI + "/api/users/searchUser?offset="
let kPMAPICHECKUSERCONNECT          = kPMAPI + "/api/users/check"
let kPMAPIUSER_OFFSET               = kPMAPI + "/api/users?offset="
let kPMAPICOACH                     = kPMAPI + "/api/coaches/"
let kPMAPICOACH_SEARCHV1            = kPMAPI + "/api/coaches/search"
let kPMAPICOACH_SEARCH              = kPMAPI + "/api/coaches/searchdistanceV2"
let kPMAPI_LOGOUT                   = kPMAPI + "/api/logout"
let kPMAPI_LIKE                     = kPMAPI + "/api/likes/"
let kPMAPI_POST                     = kPMAPI + "/api/posts/"
let kPMAPI_POST_OFFSET              = kPMAPI + "/api/posts/?offset="
let kPMAPI_LOGIN                    = kPMAPI + "/api/login"
let kPMAPI_REPORT                   = kPMAPI + "/api/posts/report"
let kPMAPI_FORGOT                   = kPMAPI + "/api/forget"
let kPMAPI_REGISTER                 = kPMAPI + "/api/register"
let kPMAPI_TAG_OFFSET               = kPMAPI + "/api/tags?offset="
let kPMAPI_TAG4_OFFSET              = kPMAPI + "/api/tags4?offset="
let kPMAPI_TAGALL_OFFSET            = kPMAPI + "/api/tagsAll?offset="
let kPMAPI_BUSINESS                 = kPMAPI + "//api/businesses/"
let kPMAPIDELETEACTIVITY            = kPMAPI + "/api/activities/deleteActivity"
let kPMAPIACTIVITY                  = kPMAPI + "/api/activities/"
let kPMAPI_ADD_TAG                  = kPMAPI + "/api/tags"
let kPMAPICOACHES                   = kPMAPI + "/api/coaches/"

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
let kPM_PATH_DEVICES                = "/devices"
let kPM_PARTH_MESSAGE               = "/messages"
let kPM_PARTH_MESSAGE_V2            = "/messagesV2"
let kPM_PATH_LIKE                   = "/likes"
let kPM_PATH_COMMENT_OFFSET         = "/comments?offset="
let kPM_PATH_COMMENT_LIMIT          = "/comments?limit="
let kPM_PATH_LIMIT_ONE              = "&limit=1"
let kPM_PATH_LOG_ACTIVITIES_USER    = "/activitiesuserV2"
let kPM_PATH_LOG_ACTIVITIES_COACH   = "/activitiescoachV2"
let kPM_PATH_ACTIVITIES_USER        = "/activitiesuser?offset="
let kPMAPICOACH_LEADS               = "/leads?offset="
let kPMAPICOACH_CURRENT             = "/current?offset="
let kPMAPICOACH_OLD                 = "/old?offset="
let kPMAPICOACH_JUSTCONNECTED       = "/justconnected?offset="
let kPMAPICOACH_COACHCURRENT        = "/currentCoach?offset="
let kPMAPICOACH_COACHOLD            = "/pastCoach?offset="
let kPMAPICOACH_BOOK                = "/bookV2"
let kPMAPI_LEAD                     = "/lead"
let kPMAPI_CHANGEPASS               = "/password"
let kPMAPI_POSTOFPHOTO              = "/api/postOfPhoto"

// Discount
let kPMAPI_DISCOUNTS                = "/api/discounts/?offset="

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
