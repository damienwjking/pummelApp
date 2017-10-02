//
//  FeedWebViewController.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 3/13/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

class FeedWebViewController: UIViewController, UIWebViewDelegate {
    var URL : NSURL? = nil
    var closeButton:UIButton? = nil
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadWeb()
        
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:"BACK", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.backButtonClicked))
//        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], for: .normal)
        
        
        
        
        // Title
        self.title = kNavFeed
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        
        // Left button
        let image = UIImage(named: "back")!.withRenderingMode(.alwaysTemplate)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.plain, target: self, action:#selector(self.backButtonClicked))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.pmmBrightOrangeColor()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated: animated)
        
//        let closeImage = UIImage(named: "closewhite")
        
//        self.closeButton = UIButton(type: UIButtonType.Custom)
//        self.closeButton!.frame = CGRectMake(0, 20, 40, 40)
//        self.closeButton?.setImage(closeImage, for: .normal)
//        self.closeButton?.tintColor = UIColor.pmmBrightOrangeColor()
//        self.closeButton!.addTarget(self, action: #selector(self.backButtonClicked), for: .touchUpInside)
//        
//        
//        self.webView.scrollView.addSubview(self.closeButton!)
    }
    
    func loadWeb() {
        if (self.URL != nil) {
            let request = NSURLRequest(URL: self.URL!)
            self.webView.loadRequest(request)
        }
    }
    
    func backButtonClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
}
