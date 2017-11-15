//
//  TestimonialModel.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 8/29/17.
//  Copyright © 2017 pummel. All rights reserved.
//

protocol TestimonialDelegate {
    func testimonialSynsDataCompleted(testimonial: TestimonialModel)
}

class TestimonialModel: NSObject {
    var delegate: TestimonialDelegate? = nil
    var id = 0
    var rating = 0.0
    var userId = 0
    var userCommentId = ""
    
    var descript = ""
    var updatedAt = ""
    var createdAt = ""
//    var userCommentUrl = ""
    var userCommentLocation = ""
    
    var needUpdate = true
    var userImageCache: UIImage? = nil
    var nameCache = ""
    
    func parseData(data: NSDictionary) {
        self.id = data["id"] as! Int
        self.rating = data["rating"] as! Double
        self.userId = data["userId"] as! Int
        
        let userCommentId = data["userCommentId"] as? Int
        if (userCommentId != nil) {
            self.userCommentId = "\(userCommentId!)"
        }
        
        let descript = data["description"] as? String
        if (descript != nil && descript?.isEmpty == false) {
            let descriptString: NSString = NSString(string: descript!)
//            if (descriptString.length > 300) {
//                descriptString = descriptString.substringToIndex(300)
//            }
            
            self.descript = descriptString as String
        }
        
        let updatedAt = data["updatedAt"] as? String
        if (updatedAt != nil && updatedAt?.isEmpty == false) {
            self.updatedAt = updatedAt!
        }
        
        let createdAt = data["createdAt"] as? String
        if (createdAt != nil && createdAt?.isEmpty == false) {
            self.createdAt = createdAt!
        }
        
//        let userCommentUrl = data["userCommentUrl"] as? String
//        if (userCommentUrl != nil && userCommentUrl?.isEmpty == false) {
//            self.userCommentUrl = userCommentUrl!
//        }
//        
//        let userCommentName = data["userCommentName"] as? String
//        if (userCommentName != nil && userCommentName?.isEmpty == false) {
//            self.userCommentName = userCommentName!
//        }
        
        let userCommentLocation = data["userCommentLocation"] as? String
        if (userCommentLocation != nil && userCommentLocation?.isEmpty == false) {
            self.userCommentLocation = userCommentLocation!
        }
    }
    
    func synsDataImage() {
        UserRouter.getUserInfo(userID: self.userCommentId) { (result, error) in
            if (error == nil) {
                let userInfo = result as! NSDictionary
                
                let firstName = userInfo[kFirstname] as! String
                let lastName = userInfo[kLastName] as? String
                
                var userName = firstName
                if (lastName != nil && lastName?.isEmpty == false) {
                    userName = firstName + " " + lastName!
                }
                
                self.nameCache = userName
                
                let imageURL = userInfo[kImageUrl] as? String
                if (imageURL != nil && imageURL?.isEmpty == false) {
                    ImageVideoRouter.getImage(imageURLString: imageURL!, sizeString: widthHeight120) { (result, error) in
                        if (error == nil) {
                            let imageRes = result as! UIImage
                            self.userImageCache = imageRes
                        } else {
                            let imageRes = UIImage(named: "display-empty.jpg")
                            self.userImageCache = imageRes
                            
                            print("Request failed with error: \(String(describing: error))")
                        }
                        
                        self.callDelegate()
                        }.fetchdata()
                }
                
                
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
            }.fetchdata()
    }
    
    func callDelegate() {
        if (self.delegate != nil) {
            self.delegate?.testimonialSynsDataCompleted(testimonial: self)
        }
    }
    
    func same(testimonial: TestimonialModel) -> Bool {
        if (self.id == testimonial.id) {
            return true
        }
        
        return false
    }
    
    func existInList(testimonialList: [TestimonialModel]) -> Bool {
        for testimonial in testimonialList {
            if (self.same(testimonial: testimonial) == true) {
                return true
            }
        }
        
        return false
    }
    
}
