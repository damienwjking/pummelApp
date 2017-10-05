//
//  Spinner.swift
//  Search
//
//  Created by Vinay Jain on 7/19/15.
//  Copyright (c) 2015 Vinay Jain. All rights reserved.
//

import UIKit


@IBDesignable

class Spinner: UIView {
    
    enum SpinnerStyle : Int{
        case None = 0
        case Light = 1
        case Dark = 2
    }
    
    var Style : SpinnerStyle = .None
    
    @IBInspectable var hidesWhenStopped : Bool = false
    
    @IBInspectable var outerFillColor : UIColor = UIColor.clear
    @IBInspectable var outerStrokeColor : UIColor = UIColor.grayColor()
    @IBInspectable var outerLineWidth : CGFloat = 5.0
    @IBInspectable var outerEndStroke : CGFloat = 0.5
    @IBInspectable var outerAnimationDuration : CGFloat = 2.0
    
    @IBInspectable var enableInnerLayer : Bool = true
    
    @IBInspectable var innerFillColor : UIColor  = UIColor.clear
    @IBInspectable var innerStrokeColor : UIColor = UIColor.grayColor()
    @IBInspectable var innerLineWidth : CGFloat = 5.0
    @IBInspectable var innerEndStroke : CGFloat = 0.5
    @IBInspectable var innerAnimationDuration : CGFloat = 1.6
    
    @IBInspectable var labelText : String  = ""
    @IBInspectable var labelFont : String  = "Helvetica"
    @IBInspectable var labelTextColor : UIColor  = UIColor.black
    
    @IBInspectable var labelFontSize : CGFloat = 11.0
    
    var currentInnerRotation : CGFloat = 0
    var currentOuterRotation : CGFloat = 0
    
    var innerView : UIView = UIView()
    var outerView : UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        self.commonInit()
    }
    
    func commonInit(){
        self.backgroundColor = UIColor.clear
    }
    
    override func drawRect(rect: CGRect) {
        
        switch Style{
        case .Dark:
            outerStrokeColor = UIColor.grayColor()
            innerStrokeColor = UIColor.grayColor()
            labelTextColor = UIColor.grayColor()
        case .Light:
            outerStrokeColor = UIColor ( red: 0.9333, green: 0.9333, blue: 0.9333, alpha: 1.0 )
            innerStrokeColor = UIColor ( red: 0.9333, green: 0.9333, blue: 0.9333, alpha: 1.0 )
            labelTextColor = UIColor ( red: 0.9333, green: 0.9333, blue: 0.9333, alpha: 1.0 )
        case .None:
            break
        }
        
        self.addSubview(outerView)
        outerView.frame = CGRect(x: 0 , 0, rect.size.width, rect.size.height)
        outerView.center = self.convertPoint(self.center, fromCoordinateSpace: self.superview!)
        
        let outerLayer = CAShapeLayer()
        outerLayer.path = UIBezierPath(ovalInRect: outerView.bounds).CGPath
        outerLayer.lineWidth = outerLineWidth
        outerLayer.strokeStart = 0.0
        outerLayer.strokeEnd = outerEndStroke
        outerLayer.lineCap = kCALineCapRound
        outerLayer.fillColor = outerFillColor.cgColor
        outerLayer.strokeColor = outerStrokeColor.cgColor
        outerView.layer.addSublayer(outerLayer)
        
        if enableInnerLayer{
            
            self.addSubview(innerView)
            innerView.frame = CGRect(x: 0 , 0, rect.size.width - 20, rect.size.height - 20)
            innerView.center =  self.convertPoint(self.center, fromCoordinateSpace: self.superview!)
            let innerLayer = CAShapeLayer()
            innerLayer.path = UIBezierPath(ovalInRect: innerView.bounds).CGPath
            innerLayer.lineWidth = innerLineWidth
            innerLayer.strokeStart = 0
            innerLayer.strokeEnd = innerEndStroke
            innerLayer.lineCap = kCALineCapRound
            innerLayer.fillColor = innerFillColor.cgColor
            innerLayer.strokeColor = innerStrokeColor.cgColor
            
            innerView.layer.addSublayer(innerLayer)
        }
        
        let label = UILabel()
        
        label.text = labelText
        label.textColor = labelTextColor
        label.font = UIFont(name: labelFont, size: labelFontSize)
        
        self.addSubview(label)
        if enableInnerLayer{
            label.frame.size.width = innerView.frame.size.width/1.20
            label.frame.size.height = innerView.frame.size.height
        }
        else{
            label.frame.size.width = outerView.frame.size.width/1.2
            label.frame.size.height = outerView.frame.size.height
        }
        label.numberOfLines = 0
        label.lineBreakMode = .ByWordWrapping
        label.textAlignment = .Center
        label.center = self.convertPoint(self.center, fromCoordinateSpace: self.superview!)
        
        self.startAnimating()
    }
    
    func animateInnerRing(){
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0 * CGFloat(Double.pi/180)
        rotationAnimation.toValue = 360 * CGFloat(Double.pi/180)
        rotationAnimation.duration = Double(innerAnimationDuration)
        rotationAnimation.repeatCount = HUGE
        self.innerView.layer.addAnimation(rotationAnimation, forKey: "rotateInner")
    }
    func animateOuterRing(){
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 360 * CGFloat(Double.pi/180)
        rotationAnimation.toValue = 0 * CGFloat(Double.pi/180)
        rotationAnimation.duration = Double(outerAnimationDuration)
        rotationAnimation.repeatCount = HUGE
        self.outerView.layer.addAnimation(rotationAnimation, forKey: "rotateOuter")
    }
    
    func startAnimating(){
        
        self.isHidden = false
        
        self.animateOuterRing()
        self.animateInnerRing()
    }
    
    func stopAnimating(){
        if hidesWhenStopped{
            self.isHidden = true
        }
        self.outerView.layer.removeAllAnimations()
        self.innerView.layer.removeAllAnimations()
        
    }
}
